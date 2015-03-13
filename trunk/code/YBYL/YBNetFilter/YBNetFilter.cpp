// YBNetFilter.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include "YbNetFilter.h"
#include "HttpRequestFilter.h"
#include "HttpRequestHandler.h"
#include "WinsockHooker.h"
#include "TcpProxyServer.h"
#include "./ParseABP/FilterManager.h"
#include <boost/asio.hpp>

#include <process.h>

BOOL YbEnable(BOOL bEnable, USHORT listen_port)
{
	return HttpRequestFilter::GetInstance().Enable(bEnable == FALSE ? false : true, listen_port) ? TRUE : FALSE;
}

namespace {
	unsigned __stdcall  ProxyWorkingThread(void* arg)
	{
		std::auto_ptr<TcpProxyServer> spServer(reinterpret_cast<TcpProxyServer*>(arg));
		spServer->Run();
		return 0;
	}
}

HANDLE YbStartProxy(USHORT* listen_port)
{
	if(listen_port == NULL) {
		return NULL;
	}
	std::auto_ptr<TcpProxyServer> spServer(new TcpProxyServer());
	if(!spServer->Open(boost::asio::ip::tcp::v4())) {
		return NULL;
	}
	boost::asio::ip::address_v4 ip = boost::asio::ip::address_v4::from_string("127.0.0.1");
	unsigned short port = 17868;
	bool bindResult = false;
	for(std::size_t i = 0; i < 1000; ++i, ++port) {
		bindResult = spServer->Bind(ip, port);
		if(bindResult) {
			break;
		}
	}
	if(!bindResult) {
		return NULL;
	}
	if(!spServer->Listen(boost::asio::ip::tcp::acceptor::max_connections)) {
		return NULL;
	}
	HANDLE hThread = reinterpret_cast<HANDLE>(_beginthreadex(NULL, 0, ProxyWorkingThread, reinterpret_cast<void*>(spServer.get()), 0, NULL));
	if(hThread != NULL) {
		spServer.release();
	}
	*listen_port = port;
	return hThread;
}

BOOL YbSetHook()
{
	WinsockHooker::AttachHook();
	return TRUE;
}

VOID GsEnableRedirect(BOOL bEnable)
{
	HttpRequestFilter::GetInstance().EnableRedirect(bEnable == FALSE ? false : true);
}

BOOL YbSetWebRoot(const wchar_t* root_path)
{
	HttpRequestHandler::SetWebRoot(root_path);
	return TRUE;
}

bool YbUpdateConfigVideoHost(const std::string& url,int istate)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
	//return m->updateConfigVideoHost(url.c_str(), istate);
	return false;
}

bool YbUpdateConfigWhiteHost(const std::string& url,bool bEnable)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
	//return m->updateConfigWhiteHost(url.c_str(), bEnable);
	return false;
}

bool YbGetWebRules(const std::wstring& filename)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
	//return m->getWebRules(filename);
	return false;
}

bool YbGetVideoRules(const std::wstring& filename)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
	return m->getVideoRules(filename);
}

bool YbGetUsersRules(const std::wstring& filename)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
	//return m->getUsersRules(filename);
	return false;
}

bool GsGetRedirectRules(const std::wstring& filename)
{
	FilterManager* m = FilterManager::getManager();
	if(m == NULL) {
		return false;
	}
//	return m->getRedirectRules(filename);
}
