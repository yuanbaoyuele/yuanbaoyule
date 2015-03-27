// CBrowserHelper.cpp : Implementation of CCBrowserHelper

#include "stdafx.h"
#include "CBrowserHelper.h"


// CCBrowserHelper


STDMETHODIMP CCBrowserHelper::AttachBrowser(IDispatch* pUnkSite)
{
	// TODO: Add your implementation code here
	
	if (pUnkSite)
	{
		m_spWebBrowser = pUnkSite;
		HRESULT hr = BrowerEvents::DispEventAdvise(m_spWebBrowser);
		TSDEBUG4CXX(L"[CCBrowserHelper] AttachBrowser: hr = " << hr);
		return hr;
	}
	return S_FALSE;
}

STDMETHODIMP CCBrowserHelper::DetachBrowser(void)
{
	// TODO: Add your implementation code here
	if (m_spWebBrowser)
	{
		HRESULT hr = BrowerEvents::DispEventUnadvise(m_spWebBrowser);
		//TSDEBUG4CXX(L"[CCBrowserHelper] DetachBrowser: hr = " << hr);
		return hr;
	}
	return S_FALSE;
}


void STDMETHODCALLTYPE CCBrowserHelper::OnStatusTextChange(BSTR *pvarText)   
{
	//TSAUTO();
	if (pvarText)
	{
		CComVariant vParam[1];
		vParam[0] = (LPWSTR)pvarText;
		DISPPARAMS params = { vParam, NULL, 2, 0 };
		CYBMsgWindow::Instance()->Fire_LuaEvent("OnStatusTextChange", &params);
	}
}