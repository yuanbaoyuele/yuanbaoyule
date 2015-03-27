// CBrowserHelper.h : Declaration of the CCBrowserHelper

#pragma once
#include "resource.h"       // main symbols

#include "iekernel_i.h"
#include <ExDispid.h>
#include "YBKernelHelper\CYBMsgWnd.h"
#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif



// CCBrowserHelper

class ATL_NO_VTABLE CCBrowserHelper :
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CCBrowserHelper, &CLSID_CBrowserHelper>,
	public IDispatchImpl<ICBrowserHelper, &IID_ICBrowserHelper, &LIBID_iekernelLib, /*wMajor =*/ 1, /*wMinor =*/ 0>,
	public IDispEventImpl<1, CCBrowserHelper, &DIID_DWebBrowserEvents2, &LIBID_SHDocVw, 1, 1>
{
	typedef IDispEventImpl<1, CCBrowserHelper, &DIID_DWebBrowserEvents2, &LIBID_SHDocVw, 1, 1> BrowerEvents;
public:
	CCBrowserHelper()
	{
	}

//DECLARE_REGISTRY_RESOURCEID(IDR_CBROWSERHELPER1)
DECLARE_NO_REGISTRY()
DECLARE_NOT_AGGREGATABLE(CCBrowserHelper)

BEGIN_COM_MAP(CCBrowserHelper)
	COM_INTERFACE_ENTRY(ICBrowserHelper)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

BEGIN_SINK_MAP(CCBrowserHelper)
	SINK_ENTRY_EX(1, DIID_DWebBrowserEvents2, DISPID_STATUSTEXTCHANGE , OnStatusTextChange)
END_SINK_MAP()

	DECLARE_PROTECT_FINAL_CONSTRUCT()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}

public:
	CComQIPtr<IWebBrowser2, &IID_IWebBrowser2> m_spWebBrowser;
private:
	void STDMETHODCALLTYPE OnStatusTextChange(BSTR  *pvarText);

public:
	STDMETHOD(AttachBrowser)(IDispatch* pUnkSite);
	STDMETHOD(DetachBrowser)(void);
};

OBJECT_ENTRY_AUTO(__uuidof(CBrowserHelper), CCBrowserHelper)
