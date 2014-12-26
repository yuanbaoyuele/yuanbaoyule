#pragma once
#include <string>
#include <boost/asio.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/shared_ptr.hpp>

#include "Lock.h"

class HttpRequestHandler : public boost::enable_shared_from_this<HttpRequestHandler> {
private:
	boost::shared_ptr<boost::asio::ip::tcp::socket> m_clientSocketPtr;
	boost::asio::ip::tcp::socket& m_clientSocket;
	char m_readBuffer[2048];
	std::string m_requestString;
	std::string m_responseString;
	boost::asio::windows::stream_handle m_fileStream;
	
private:
	HttpRequestHandler(boost::asio::io_service& io_service, boost::shared_ptr<boost::asio::ip::tcp::socket>& clientSocket);
	void AsyncReadDataFromClientSocket();
	void HandleReadDataFromClientSocket(const boost::system::error_code& error, std::size_t bytes_transferred);
	void HandleWriteDataToClientSocket(const boost::system::error_code& error, std::size_t bytes_transferred);
	void HandleReadDataFromFile(const boost::system::error_code& error, std::size_t bytes_transfferred);
public:
	static boost::shared_ptr<HttpRequestHandler> CreateHandler(boost::asio::io_service& io_service, boost::shared_ptr<boost::asio::ip::tcp::socket>& clientSocket);
	void AsyncStart();
private:
	static XMLib::CriticalSection cs;
	static std::wstring WebRootPath;
	static const std::size_t MAXIMUM_REQUEST_HEADER_LENGTH = 1048576;
private:
	std::string::const_iterator SplitRequestLine(std::string::const_iterator begin, std::string::const_iterator end, std::string& leftString, std::string& middleString, std::string& rightString) const;
	bool IsSeperators(char ch) const;
	bool ParseHttpRequestHeader(std::string::const_iterator begin, std::string::const_iterator end, std::multimap<std::string, std::string>& requestHeaders) const;
public:
	static void SetWebRoot(const std::wstring& root);
	static std::wstring GetWebRoot();
};
