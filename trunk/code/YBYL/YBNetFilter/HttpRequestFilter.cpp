#include "stdafx.h"
#include "HttpRequestFilter.h"

#include "WinsockHooker.h"

#include "ScopeResourceHandle.h"

HttpRequestFilter::HttpRequestFilter() : m_enable(false), m_hIPCFileMapping(NULL)
{
}

bool HttpRequestFilter::Enable(bool enable, unsigned short listen_port)
{
	XMLib::CriticalSectionLockGuard lck(this->cs);
	this->m_enable = enable;
	WinsockHooker::EnableProxy(enable, listen_port);
	return true;
}

bool HttpRequestFilter::IsEnable() const
{
	XMLib::CriticalSectionLockGuard lck(this->cs);
	return this->m_enable;
}


namespace {
	XMLib::CriticalSection getInstanceCS;
}

HttpRequestFilter& HttpRequestFilter::GetInstance()
{
	XMLib::CriticalSectionLockGuard lck(getInstanceCS);
	static HttpRequestFilter instance;
	return instance;
}
