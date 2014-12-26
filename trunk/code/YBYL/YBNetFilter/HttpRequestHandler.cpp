#include "stdafx.h"
#include "HttpRequestHandler.h"

#include <string>
#include <sstream>

#include <boost/bind.hpp>

#include <iostream>

#include "ParseABP/CParseUrl.h"
#include <Windows.h>

XMLib::CriticalSection HttpRequestHandler::cs;
std::wstring HttpRequestHandler::WebRootPath;

boost::shared_ptr<HttpRequestHandler> HttpRequestHandler::CreateHandler(boost::asio::io_service& io_service, boost::shared_ptr<boost::asio::ip::tcp::socket>& clientSocket)
{
	return boost::shared_ptr<HttpRequestHandler>(new HttpRequestHandler(io_service, clientSocket));
}

HttpRequestHandler::HttpRequestHandler(boost::asio::io_service& io_service, boost::shared_ptr<boost::asio::ip::tcp::socket>& clientSocket) :
	m_clientSocketPtr(clientSocket),
	m_clientSocket(*m_clientSocketPtr),
	m_fileStream(io_service)
{
}

void HttpRequestHandler::AsyncReadDataFromClientSocket()
{
	boost::asio::async_read(this->m_clientSocket, boost::asio::buffer(this->m_readBuffer),
		boost::asio::transfer_at_least(1), boost::bind(&HttpRequestHandler::HandleReadDataFromClientSocket, this->shared_from_this(), _1, _2));
}

void HttpRequestHandler::HandleReadDataFromClientSocket(const boost::system::error_code& error, std::size_t bytes_transferred)
{
	if(!error) {
		this->m_requestString.append(this->m_readBuffer, this->m_readBuffer + bytes_transferred);
		std::size_t doubleCrlfPos = this->m_requestString.find("\r\n\r\n");
		if(doubleCrlfPos == std::string::npos) {
			// handle
			if(this->m_requestString.size() > MAXIMUM_REQUEST_HEADER_LENGTH) {
				return;
			}
			this->AsyncReadDataFromClientSocket();
		}
		else {
			// parse and handle request
			std::size_t crlfPos = this->m_requestString.find("\r\n\r\n");
			std::string methodString, middleString, httpVersionString;
			bool parseRequestFailed = !(this->m_requestString.begin() + crlfPos != this->SplitRequestLine(this->m_requestString.begin(), this->m_requestString.begin() + crlfPos, methodString, middleString, httpVersionString))
				|| methodString.empty() || middleString.empty() || httpVersionString.empty();

			if(methodString != "GET" && methodString != "HEAD") {
				// method not allowed
				return;
			}

			// 处理请求uri
			std::string absoluteUrl;
			std::string file_name;

			if(!parseRequestFailed) {
				bool isAbsoluteUrl = true;
				const char* absoluteUrlPrefix = "http:";
				for(std::size_t index = 0; index < 5; ++index) {
					if(std::tolower(static_cast<unsigned char>(middleString[index])) != absoluteUrlPrefix[index]) {
						isAbsoluteUrl = false;
						break;
					}
				}

				if(isAbsoluteUrl || middleString[0] == '/') {
					if(isAbsoluteUrl) {
						absoluteUrl = middleString;
					}
				}
				else {
					// 不正确的uri
					parseRequestFailed = true;
				}
			}

			std::multimap<std::string, std::string> requestHeaders;
			if(!parseRequestFailed) {
				parseRequestFailed = !this->ParseHttpRequestHeader(this->m_requestString.begin() + crlfPos + 2, this->m_requestString.begin() + doubleCrlfPos + 4, requestHeaders);
			}

			
			if(!parseRequestFailed && absoluteUrl.empty()) {
				std::multimap<std::string, std::string>::const_iterator iter = requestHeaders.find("Host");

				if(iter != requestHeaders.end()) {
					absoluteUrl = "http://" + iter->second + middleString;
				}
				else {
					// 找不到host则使用ip作为host
					absoluteUrl = "http://100.100.100.100" + middleString;
				}
			}

			std::wstring relativePath;
			if(!parseRequestFailed) {
				Url url(absoluteUrl.c_str());
				std::string path = url.GetPath();
				if(path.empty()) {
					parseRequestFailed = true;
				}
				else {
					int utf16_length = ::MultiByteToWideChar(CP_UTF8, NULL, path.data(), static_cast<int>(path.size()), NULL, 0);
					if(utf16_length == 0) {
						parseRequestFailed = true;
					}
					else {
						relativePath.resize(utf16_length);
						MultiByteToWideChar(CP_UTF8, NULL, path.data(), static_cast<int>(path.size()), &relativePath[0], utf16_length);
					}
				}
			}

			if(parseRequestFailed || relativePath.empty()) {
				// bad request
				std::string content = "<html><head><title>400 Bad Request</title></head><body bgcolor=\"white\"><center><h1>400 Bad Request</h1></center></body></html>";
				this->m_responseString = "HTTP/1.1 400 Bad Request\r\nContent-Type: text/html\r\nContent-Length: ";
				{
					std::string content_length_str;
					std::stringstream ss;
					ss << content.size();
					ss >> content_length_str;
					this->m_responseString += content_length_str;
				}
				this->m_responseString += "\r\nConnection: close\r\n\r\n";
				this->m_responseString += content;
				boost::asio::async_write(this->m_clientSocket, boost::asio::buffer(this->m_responseString),
					boost::bind(&HttpRequestHandler::HandleWriteDataToClientSocket, this->shared_from_this(), _1, _2));
				return;
			}

			if(methodString != "GET") {
				// method not allowed
				std::string content = "<html><head><title>405 Method Not Allowed</title></head><body bgcolor=\"white\"><center><h1>405 Method Not Allowed</h1></center></body></html>";
				this->m_responseString = "HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/html\r\nContent-Length: ";
				{
					std::string content_length_str;
					std::stringstream ss;
					ss << content.size();
					ss >> content_length_str;
					this->m_responseString += content_length_str;
				}
				this->m_responseString += "\r\nConnection: close\r\n\r\n";
				this->m_responseString += content;
				boost::asio::async_write(this->m_clientSocket, boost::asio::buffer(this->m_responseString),
					boost::bind(&HttpRequestHandler::HandleWriteDataToClientSocket, this->shared_from_this(), _1, _2));
				return;
			}			
			// std::clog << absoluteUrl << std::endl;
			// std::wclog << L"Path: " << relativePath << std::endl;

			bool isFileNotFound = false;
			std::wstring webRoot = GetWebRoot();
			LONGLONG contentLength = 0;
			if(!webRoot.empty()) {
				std::wstring file_path = webRoot + relativePath;
				if(methodString == "GET") {
					HANDLE hFile = ::CreateFile(file_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
					if(hFile == INVALID_HANDLE_VALUE) {
						isFileNotFound = true;
					}
					else {
						bool failed = false;
						LARGE_INTEGER liFileSize;
						if(!::GetFileSizeEx(hFile, &liFileSize)) {
							failed = true;
						}
						else {
							contentLength = liFileSize.QuadPart;
							boost::system::error_code ec;
							this->m_fileStream.assign(hFile, ec);
							if(ec) {
								failed = true;
							}
						}

						if(failed) {
							isFileNotFound  = true;
							::CloseHandle(hFile);
						}
					}
				}
				else {
					// 不支持GET以外的任何方法
					// 不会到达这个分支
					return;
				}
			}
			else {
				isFileNotFound = true;
			}

			if(isFileNotFound) {
				std::string content = "<html><head><title>404 Not Found</title></head><body bgcolor=\"white\"><center><h1>404 Not Found</h1></center></body></html>";
				this->m_responseString = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: ";
				{
					std::string content_length_str;
					std::stringstream ss;
					ss << content.size();
					ss >> content_length_str;
					this->m_responseString += content_length_str;
				}
				this->m_responseString += "\r\nConnection: close\r\n\r\n";
				this->m_responseString += content;
				boost::asio::async_write(this->m_clientSocket, boost::asio::buffer(this->m_responseString),
					boost::bind(&HttpRequestHandler::HandleWriteDataToClientSocket, this->shared_from_this(), _1, _2));
			}
			else {
				std::string content = "hello, world!";
				this->m_responseString = "HTTP/1.1 200 OK\r\nContent-Length: ";
				{
					std::string content_length_str;
					std::stringstream ss;
					ss << contentLength;
					ss >> content_length_str;
					this->m_responseString += content_length_str;
				}
				this->m_responseString += "\r\nConnection: close\r\n\r\n";
				boost::asio::async_write(this->m_clientSocket, boost::asio::buffer(this->m_responseString),
					boost::bind(&HttpRequestHandler::HandleWriteDataToClientSocket, this->shared_from_this(), _1, _2));
			}
		}
	}
	else {
		// error handle
	}
}

void HttpRequestHandler::HandleWriteDataToClientSocket(const boost::system::error_code& error, std::size_t bytes_transferred)
{
	// close
	if(!error) {
		if(this->m_fileStream.is_open()) {
			this->m_fileStream.async_read_some(boost::asio::buffer(this->m_readBuffer), boost::bind(&HttpRequestHandler::HandleReadDataFromFile, this->shared_from_this(), _1, _2));
		}
	}
}

void HttpRequestHandler::HandleReadDataFromFile(const boost::system::error_code& error, std::size_t bytes_transfferred)
{
	if(!error) {
		boost::asio::async_write(this->m_clientSocket, boost::asio::buffer(this->m_readBuffer, bytes_transfferred), boost::bind(&HttpRequestHandler::HandleWriteDataToClientSocket, this->shared_from_this(), _1, _2));
	}
}

void HttpRequestHandler::AsyncStart()
{
	this->AsyncReadDataFromClientSocket();
}

std::string::const_iterator HttpRequestHandler::SplitRequestLine(std::string::const_iterator begin, std::string::const_iterator end, std::string& leftString, std::string& middleString, std::string& rightString) const
{
	assert(leftString.empty() && middleString.empty() && rightString.empty());
	std::string::const_iterator iter = begin;
	for(;iter != end && !std::isspace(static_cast<unsigned char>(*iter)); ++iter) {
		leftString.push_back(*iter);
	}
	for(;iter != end && std::isspace(static_cast<unsigned char>(*iter)); ++iter)
		;

	for(;iter != end && !std::isspace(static_cast<unsigned char>(*iter)); ++iter) {
		middleString.push_back(*iter);
	}
	for(;iter != end && std::isspace(static_cast<unsigned char>(*iter)); ++iter)
		;

	for(;iter != end && !std::isspace(static_cast<unsigned char>(*iter)); ++iter) {
		rightString.push_back(*iter);
	}
	return iter;
}

bool HttpRequestHandler::IsSeperators(char ch) const
{
	return ch == '(' || ch == ')'
		|| ch == '<' || ch == '>'
		|| ch == '@' || ch == ','
		|| ch == ';' || ch == ':'
		|| ch == '\\' || ch == '"'
		|| ch == '/' || ch == '['
		|| ch == ']' || ch == '?'
		|| ch == '=' || ch == '{'
		|| ch == '}' || ch == ' '
		|| ch == '\t';
}

bool HttpRequestHandler::ParseHttpRequestHeader(std::string::const_iterator begin, std::string::const_iterator end, std::multimap<std::string, std::string>& requestHeaders) const
{
	int state = 0;
	std::string key;
	std::string value;
	for(std::string::const_iterator iter = begin; iter != end && state != 7; ++iter) {
		switch(state) {
			case 0:
				if(*iter == '\r') {
					state = 6;
				}
				else if((0 <= *iter && *iter <= 31) || *iter == 127) {
					return false;
				}
				else if(!std::isspace(static_cast<unsigned char>(*iter))) {
					if(this->IsSeperators(*iter)) {
						return false;
					}
					++state; // 1
					key.push_back(*iter);
				}
				break;
			case 1:
				if(std::isspace(static_cast<unsigned char>(*iter))) {
					++state; // 2
				}
				else if(*iter == ':') {
					state = 3;
				}
				else if((0 <= *iter && *iter <= 31) || *iter == 127 || this->IsSeperators(*iter)) {
					return false;
				}
				else {
					key.push_back(*iter);
				}
				break;
			case 2:
				if(*iter == ':') {
					++state; // 3
				}
				else if(!std::isspace(static_cast<unsigned char>(*iter))) {
					return false;
				}
				break;
			case 3:
				if(!std::isspace(static_cast<unsigned char>(*iter))) {
					++state; // 4
					value.push_back(*iter);
				}
				break;
			case 4:
				if(*iter == '\r') {
					++state; // 5
				}
				else {
					value.push_back(*iter);
				}
				break;
			case 5:
				if(*iter == '\n') {
					if(!value.empty()) {
						for(std::size_t index = value.size() - 1; index != 0 && std::isspace(static_cast<unsigned char>(value[index])); --index) {
							value.erase(value.begin() + index);
						}
					}
					requestHeaders.insert(std::make_pair(key, value));
					key.clear();
					value.clear();
					state = 0;
				}
				else {
					return false;
				}
				break;
			case 6:
				if(*iter == '\n') {
					state = 7;
				}
				else {
					return false;
				}
			break;
			default:
				assert(false);
				return false;
			break;
		}
	}
	return state == 7;
}

void HttpRequestHandler::SetWebRoot(const std::wstring& root)
{
	XMLib::CriticalSectionLockGuard lck(cs);
	WebRootPath = root;
}

std::wstring HttpRequestHandler::GetWebRoot()
{
	XMLib::CriticalSectionLockGuard lck(cs);
	return WebRootPath;
}
