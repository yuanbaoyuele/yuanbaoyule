#include "stdafx.h"
#include "WinsockHooker.h"

#include <iostream>
#include <sstream>
#include <memory>
#include <cassert>
#include "detours.h"
#include <process.h>

WinsockHooker::socket_FuncType WinsockHooker::Real_socket = ::socket;
WinsockHooker::connect_FuncType WinsockHooker::Real_connect = ::connect;
WinsockHooker::closesocket_FuncType WinsockHooker::Real_closesocket = ::closesocket;
WinsockHooker::WSASocket_FuncType WinsockHooker::Real_WSASocket = ::WSASocket;
WinsockHooker::WSAIoctl_FuncType WinsockHooker::Real_WSAIoctl = ::WSAIoctl;

XMLib::CriticalSection WinsockHooker::cs;
std::set<SOCKET> WinsockHooker::TcpSocketSet;
std::map<SOCKET, LPFN_CONNECTEX> WinsockHooker::Connect_Ex_Funcs;
std::map<SOCKET, USHORT> WinsockHooker::SocketToLocalPortMap;
std::map<USHORT, std::pair<u_long, USHORT> > WinsockHooker::LocalPortToRemoteAddressMap;
bool WinsockHooker::IsHooked = false;
bool WinsockHooker::IsFilterEnable = false;
USHORT WinsockHooker::ProxyPort = 0;

#define UUU_MSG_LOG(MSG)

SOCKET WSAAPI WinsockHooker::Hooked_socket(int af, int type, int protocol)
{
	SOCKET s = Real_socket(af, type, protocol);
	int lastError = ::WSAGetLastError();
	if(s != INVALID_SOCKET) {
		// IPv4 Stream TCP Firefox使用IPPROTO_HOPOPTS
		if(af == AF_INET &&
			type == SOCK_STREAM &&
			(protocol == IPPROTO_TCP || protocol == IPPROTO_HOPOPTS)) {
				// 满足这些条件的加入表中
				XMLib::CriticalSectionLockGuard lck(cs);
				TcpSocketSet.insert(s);
		}
	}
	::WSASetLastError(lastError);
	return s;
}

SOCKET WSAAPI WinsockHooker::Hooked_WSASocket(int af, int type, int protocol, LPWSAPROTOCOL_INFO lpProtocolInfo, GROUP g, DWORD dwFlags)
{
	SOCKET s = Real_WSASocket(af, type, protocol, lpProtocolInfo, g, dwFlags);
	int lastError = ::WSAGetLastError();
	if(s != INVALID_SOCKET) {
		// IPv4 Stream TCP Firefox使用IPPROTO_HOPOPTS
		if(af == AF_INET &&
			type == SOCK_STREAM &&
			(protocol == IPPROTO_TCP || protocol == IPPROTO_HOPOPTS)) {
				// 满足这些条件的加入表中
				XMLib::CriticalSectionLockGuard lck(cs);
				TcpSocketSet.insert(s);
		}
	}
	::WSASetLastError(lastError);
	return s;
}

int WSAAPI WinsockHooker::Hooked_connect(SOCKET s, const struct sockaddr *name, int namelen)
{
	USHORT remote_port = 0;
	ULONG remote_ip = 0;
	bool is_ipv4_tcp = false;
	{
		XMLib::CriticalSectionLockGuard lck(cs);
		is_ipv4_tcp = TcpSocketSet.find(s) != TcpSocketSet.end();
	}

	USHORT test_remote_port = ntohs(reinterpret_cast<const sockaddr_in*>(name)->sin_port);
	ULONG test_remote_ip = reinterpret_cast<const sockaddr_in*>(name)->sin_addr.s_addr;

	if(is_ipv4_tcp && namelen == sizeof(sockaddr_in) && reinterpret_cast<const sockaddr_in*>(name)->sin_family == AF_INET) {
		remote_port = ntohs(reinterpret_cast<const sockaddr_in*>(name)->sin_port);
		remote_ip = reinterpret_cast<const sockaddr_in*>(name)->sin_addr.s_addr;
		is_ipv4_tcp = reinterpret_cast<const sockaddr_in*>(name)->sin_family == AF_INET;
	}
	unsigned short proxy_port = 0;
	if(is_ipv4_tcp && (remote_port >= 1024 || remote_port == 80) && IsEnable(&proxy_port)) {
		unsigned short local_port = 0;
		sockaddr_in local_addr;
		std::memset(&local_addr, 0, sizeof(local_addr));
		int local_addr_len = sizeof(local_addr);
		if(getsockname(s, reinterpret_cast<sockaddr*>(&local_addr), &local_addr_len) == 0 && local_addr_len == sizeof(local_addr)) {
			local_port = ntohs(reinterpret_cast<const sockaddr_in*>(&local_addr)->sin_port);
		}
		if(local_port == 0) {
			local_addr.sin_family = AF_INET;
			local_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
			local_addr.sin_port = 0;
			if(bind(s, reinterpret_cast<const sockaddr*>(&local_addr), sizeof(local_addr)) == 0) {
				std::memset(&local_addr, 0, sizeof(local_addr));
				local_addr_len = sizeof(local_addr);
				if(getsockname(s, reinterpret_cast<sockaddr*>(&local_addr), &local_addr_len) == 0 && local_addr_len == sizeof(local_addr)) {
					local_port = ntohs(reinterpret_cast<const sockaddr_in*>(&local_addr)->sin_port);
				}
			}
		}
		if(local_port != 0) {
			sockaddr_in proxy_addr;
			proxy_addr.sin_family = AF_INET;
			proxy_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
			proxy_addr.sin_port = htons(proxy_port);
			{
				XMLib::CriticalSectionLockGuard lck(cs);
				SocketToLocalPortMap[s] = local_port;
				LocalPortToRemoteAddressMap[local_port] = std::make_pair(ntohl(remote_ip), remote_port);
			}
			int connect_result = Real_connect(s, reinterpret_cast<const sockaddr*>(&proxy_addr), sizeof(proxy_addr));
			DWORD dwLastError = ::WSAGetLastError();
			if(connect_result != 0 &&  dwLastError == 0) {
				dwLastError = WSAEWOULDBLOCK;
			}
			::WSASetLastError(dwLastError);
			return connect_result;
		}
	}
	return Real_connect(s, name, namelen);
}

int WSAAPI WinsockHooker::Hooked_closesocket(SOCKET s)
{
	{
		XMLib::CriticalSectionLockGuard lck(cs);
		std::map<SOCKET, LPFN_CONNECTEX>::iterator connect_ex_iter = Connect_Ex_Funcs.find(s);
		if(connect_ex_iter != Connect_Ex_Funcs.end()) {
			Connect_Ex_Funcs.erase(connect_ex_iter);
		}
		std::set<SOCKET>::const_iterator socket_iter = TcpSocketSet.find(s);
		if(socket_iter != TcpSocketSet.end()) {
			TcpSocketSet.erase(socket_iter);
		}

		std::map<SOCKET, USHORT>::const_iterator s2p_iter = SocketToLocalPortMap.find(s);
		if(s2p_iter != SocketToLocalPortMap.end()) {
			USHORT local_port = s2p_iter->second;
			SocketToLocalPortMap.erase(s2p_iter);
			std::map<USHORT, std::pair<u_long, USHORT> >::const_iterator s2a_iter = LocalPortToRemoteAddressMap.find(local_port);
			if(s2a_iter != LocalPortToRemoteAddressMap.end()) {
				LocalPortToRemoteAddressMap.erase(s2a_iter);
			}
		}
	}
	return Real_closesocket(s);
}

int WSAAPI WinsockHooker::Hooked_WSAIoctl(SOCKET s, DWORD dwIoControlCode, LPVOID lpvInBuffer, DWORD cbInBuffer, LPVOID lpvOutBuffer, DWORD cbOutBuffer, LPDWORD lpcbBytesReturned, LPWSAOVERLAPPED lpOverlapped, LPWSAOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine)
{
	int ret = SOCKET_ERROR;

	ret = WinsockHooker::Real_WSAIoctl(s, dwIoControlCode, lpvInBuffer, cbInBuffer, lpvOutBuffer,
		cbOutBuffer, lpcbBytesReturned, lpOverlapped,
		lpCompletionRoutine);

	bool is_ipv4_tcp = false;
	{
		XMLib::CriticalSectionLockGuard lck(cs);
		is_ipv4_tcp = TcpSocketSet.find(s) != TcpSocketSet.end();
	}
	
	if (is_ipv4_tcp && dwIoControlCode == SIO_GET_EXTENSION_FUNCTION_POINTER
		&& lpvInBuffer && cbInBuffer >= sizeof(GUID)
		&& lpvOutBuffer && cbOutBuffer >= sizeof(LPFN_CONNECTEX)) {
			GUID connect_ex_guid = WSAID_CONNECTEX;
			if(!memcmp(lpvInBuffer, &connect_ex_guid, sizeof(GUID))) {
				LPFN_CONNECTEX connect_ex;
				std::memcpy(&connect_ex, lpvOutBuffer, sizeof(LPFN_CONNECTEX));
				{
					XMLib::CriticalSectionLockGuard lck(cs);
					Connect_Ex_Funcs[s] = connect_ex;
				}
				LPFN_CONNECTEX connect_ex_hook = WinsockHooker::Hooked_ExtendConnectEx;
				std::memcpy(lpvOutBuffer, &connect_ex_hook, sizeof(LPFN_CONNECTEX));
			}
	}
	return ret;
}

BOOL WSAAPI WinsockHooker::Hooked_ExtendConnectEx(SOCKET s, const struct sockaddr *name, int namelen, PVOID lpSendBuffer, DWORD dwSendDataLength, LPDWORD lpdwBytesSent, LPOVERLAPPED lpOverlapped)
{
	USHORT remote_port = 0;
	ULONG remote_ip = 0;
	bool is_ipv4_tcp = false;
	{
		XMLib::CriticalSectionLockGuard lck(cs);
		is_ipv4_tcp = TcpSocketSet.find(s) != TcpSocketSet.end();
	}

	if(is_ipv4_tcp && namelen == sizeof(sockaddr_in) && reinterpret_cast<const sockaddr_in*>(name)->sin_family == AF_INET) {
		remote_port = ntohs(reinterpret_cast<const sockaddr_in*>(name)->sin_port);
		remote_ip = reinterpret_cast<const sockaddr_in*>(name)->sin_addr.s_addr;
		is_ipv4_tcp = reinterpret_cast<const sockaddr_in*>(name)->sin_family == AF_INET;
	}
	LPFN_CONNECTEX real_connect_ex = NULL;
	{
		XMLib::CriticalSectionLockGuard lck(cs);
		std::map<SOCKET, LPFN_CONNECTEX>::iterator iter = Connect_Ex_Funcs.find(s);
		if(iter != Connect_Ex_Funcs.end()) {
			real_connect_ex = iter->second;
		}
	}
	BOOL ret = FALSE;
	if(real_connect_ex != NULL) {
		unsigned short proxy_port = 0;
		if(is_ipv4_tcp && (remote_port >= 1024 || remote_port == 80) && IsEnable(&proxy_port)) {
			unsigned short local_port = 0;
			sockaddr_in local_addr;
			std::memset(&local_addr, 0, sizeof(local_addr));
			int local_addr_len = sizeof(local_addr);
			if(getsockname(s, reinterpret_cast<sockaddr*>(&local_addr), &local_addr_len) == 0 && local_addr_len == sizeof(local_addr)) {
				local_port = ntohs(reinterpret_cast<const sockaddr_in*>(&local_addr)->sin_port);
			}
			if(local_port == 0) {
				local_addr.sin_family = AF_INET;
				local_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
				local_addr.sin_port = 0;
				if(bind(s, reinterpret_cast<const sockaddr*>(&local_addr), sizeof(local_addr)) == 0) {
					std::memset(&local_addr, 0, sizeof(local_addr));
					local_addr_len = sizeof(local_addr);
					if(getsockname(s, reinterpret_cast<sockaddr*>(&local_addr), &local_addr_len) == 0 && local_addr_len == sizeof(local_addr)) {
						local_port = ntohs(reinterpret_cast<const sockaddr_in*>(&local_addr)->sin_port);
					}
				}
			}
			if(local_port != 0) {
				sockaddr_in proxy_addr;
				proxy_addr.sin_family = AF_INET;
				proxy_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
				proxy_addr.sin_port = htons(proxy_port);
				{
					XMLib::CriticalSectionLockGuard lck(cs);
					SocketToLocalPortMap[s] = local_port;
					LocalPortToRemoteAddressMap[local_port] = std::make_pair(ntohl(remote_ip), remote_port);
				}
				BOOL connect_result = real_connect_ex(s, reinterpret_cast<const sockaddr*>(&proxy_addr), sizeof(proxy_addr), lpSendBuffer, dwSendDataLength, lpdwBytesSent, lpOverlapped);
				/*
				DWORD dwLastError = ::WSAGetLastError();
				if(connect_result != 0 &&  dwLastError == 0) {
					dwLastError = WSAEWOULDBLOCK;
				}
				::WSASetLastError(dwLastError);
				*/
				return connect_result;
			}
		}
		ret = real_connect_ex(s, name, namelen, lpSendBuffer, dwSendDataLength, lpdwBytesSent, lpOverlapped);
	}
	return ret;
}

std::pair<u_long, USHORT> WinsockHooker::GetRemoteAddressPair(USHORT local_port)
{
	std::pair<u_long, USHORT> result(0ul, 0);
	XMLib::CriticalSectionLockGuard lck(cs);
	std::map<USHORT, std::pair<u_long, USHORT> >::const_iterator iter = LocalPortToRemoteAddressMap.find(local_port);
	if(iter != LocalPortToRemoteAddressMap.end()) {
		result = iter->second;
	}
	return result;
}

void WinsockHooker::EnableProxy(bool enable, USHORT proxy_port)
{
	XMLib::CriticalSectionLockGuard lck(cs);
	IsFilterEnable = enable;
	ProxyPort = proxy_port;
}

bool WinsockHooker::TryRemoveSocketFromTcpSocketSet(SOCKET s)
{
	bool result = false;
	XMLib::CriticalSectionLockGuard lck(cs);
	std::set<SOCKET>::const_iterator socket_iter = TcpSocketSet.find(s);
	if(socket_iter != TcpSocketSet.end()) {
		result = true;
		TcpSocketSet.erase(socket_iter);
	}
	return result;
}

bool WinsockHooker::AttachHook()
{
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_socket), Hooked_socket);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_WSASocket), Hooked_WSASocket);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_connect), Hooked_connect);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_closesocket), Hooked_closesocket);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_WSAIoctl), Hooked_WSAIoctl);
	DetourTransactionCommit();
	IsHooked = true;
	return true;
}

void WinsockHooker::DetachHook()
{
	if(IsHooked) {
		DetourTransactionBegin();
		DetourUpdateThread(GetCurrentThread());
		DetourDetach(reinterpret_cast<LPVOID*>(&Real_socket), Hooked_socket);
		DetourDetach(reinterpret_cast<LPVOID*>(&Real_WSASocket), Hooked_WSASocket);
		DetourDetach(reinterpret_cast<LPVOID*>(&Real_connect), Hooked_connect);
		DetourDetach(reinterpret_cast<LPVOID*>(&Real_closesocket), Hooked_closesocket);
		DetourDetach(reinterpret_cast<LPVOID*>(&Real_WSAIoctl), Hooked_WSAIoctl);
		DetourTransactionCommit();
		IsHooked = false;
	}
}

bool WinsockHooker::IsEnable(unsigned short* proxy_port)
{
	XMLib::CriticalSectionLockGuard lck(cs);
	if(!IsFilterEnable) {
		return false;
	}
	*proxy_port = ProxyPort;
	return true;
}
