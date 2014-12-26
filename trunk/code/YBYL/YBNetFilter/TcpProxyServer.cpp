#include "stdafx.h"
#include "TcpProxyServer.h"
#include "HttpRequestHandler.h"
#include "WinsockHooker.h"
#include <boost/bind.hpp>

TcpProxyServer::TcpProxyServer()
	: acceptor(io_service),
	listen_port(0)
{
}

bool TcpProxyServer::Open(const boost::asio::ip::tcp::acceptor::protocol_type& protocol)
{
	boost::system::error_code ec;
	if(!this->acceptor.is_open()) {
		try {
			this->acceptor.open(protocol);
		}
		catch(const boost::system::system_error&) {
			return false;
		}
	}
	return true;
}

bool TcpProxyServer::Bind(boost::asio::ip::address address, unsigned short listen_port)
{
	this->listen_port = listen_port;
	if(!this->acceptor.is_open()) {
		return false;	
	}
	boost::asio::ip::tcp::acceptor::endpoint_type endpoint(address, listen_port);
	boost::system::error_code ec;
	this->acceptor.bind(endpoint, ec);
	return !ec;
}

bool TcpProxyServer::Listen(int backlog)
{
	boost::system::error_code ec;
	this->acceptor.listen(backlog, ec);
	return !ec;
}

void TcpProxyServer::Run()
{
	this->AsyncAccept();
	this->io_service.run();
}

void TcpProxyServer::AsyncAccept()
{
	boost::shared_ptr<boost::asio::ip::tcp::socket> spClientSocket(new boost::asio::ip::tcp::socket(this->io_service));
	this->acceptor.async_accept(*spClientSocket,
		boost::bind(&TcpProxyServer::HandleAccept, this, spClientSocket, _1));
}

void TcpProxyServer::HandleAccept(boost::shared_ptr<boost::asio::ip::tcp::socket> clientSocket, const boost::system::error_code& error)
{
	if(!error) {
		boost::asio::ip::address remote_ip_address;
		unsigned short remote_port = 0;
		if(this->GetRemoteAddressAndPort(*clientSocket, remote_ip_address, remote_port)) {
			if(remote_ip_address == boost::asio::ip::address::from_string("100.100.100.100") && remote_port == 80) {
				// mini local server
				boost::shared_ptr<HttpRequestHandler> requestHandlerPtr = HttpRequestHandler::CreateHandler(this->io_service, clientSocket);
				requestHandlerPtr->AsyncStart();
			}
			else {
				boost::shared_ptr<TcpProxyConnection> connection_ptr = TcpProxyConnection::CreateConnection(this->io_service, clientSocket);
				connection_ptr->AsyncStart(this->listen_port, remote_ip_address, remote_port);
			}
		}
        this->AsyncAccept();
    }
}

bool TcpProxyServer::GetRemoteAddressAndPort(boost::asio::ip::tcp::socket& clientSocket, boost::asio::ip::address& remoteAddress, unsigned short& remotePort)
{
	boost::asio::ip::tcp::socket::endpoint_type userAgentEnpoint = clientSocket.remote_endpoint();
    unsigned short userAgentPort = userAgentEnpoint.port();
	boost::asio::ip::address userAgentIP = userAgentEnpoint.address();
	if(userAgentIP != boost::asio::ip::address_v4::from_string("127.0.0.1")) {
		return false;
	}

	std::pair<u_long, USHORT> remoteAddressPair = WinsockHooker::GetRemoteAddressPair(userAgentPort);
	
	if(remoteAddressPair.first == 0ul) {
		return false;
	}

	boost::asio::ip::address_v4 remote_address(remoteAddressPair.first);
	unsigned short remote_port = remoteAddressPair.second;
	if(remote_address == boost::asio::ip::address_v4::from_string("127.0.0.1") && remote_port == listen_port)
	{
		return false;
	}
	remoteAddress = remote_address;
	remotePort = remote_port;

	TSINFO4CXX("Connect: IP:" << remoteAddress.to_string() << ", Port: " << remotePort);
	return true;
}
