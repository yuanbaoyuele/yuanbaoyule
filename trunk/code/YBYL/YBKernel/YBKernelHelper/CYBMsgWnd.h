#pragma once
#include "atlwin.h"
#include "map"

#define WM_FILTERRESULT WM_USER + 201

#include <XLLuaRuntime.h>
typedef void (*funResultCallBack) (DWORD userdata1,DWORD userdata2, const char* pszKey,  DISPPARAMS* pParams);

struct CallbackNode
{
	funResultCallBack pCallBack;
	DWORD userData1;
	DWORD userData2;
	const void* luaFunction;
};

class CYBMsgWindow : public  CWindowImpl<CYBMsgWindow>
{
public:
	static CYBMsgWindow* Instance()
	{
        static CYBMsgWindow s;
		return &s;
	}
	
	void InitMsgWnd()
	{
		if (m_hWnd == NULL)
			Create(HWND_MESSAGE);

	}
	int AttachListener(DWORD userData1,DWORD userData2,funResultCallBack pfn, const void* pfun);
	int DetachListener(DWORD userData1, const void* pfun);

	bool HandleSingleton();

	DECLARE_WND_CLASS(L"{C3CE0473-57F7-4a0a-9CF4-C1ECB8A3C514}_dsmainmsg")
	BEGIN_MSG_MAP(CYBMsgWindow)
		MESSAGE_HANDLER(WM_COPYDATA, OnCopyData)
		MESSAGE_HANDLER(WM_FILTERRESULT, HandleFilterResult)

	END_MSG_MAP()
private:
	CYBMsgWindow(void);
	~CYBMsgWindow(void);
	std::vector<CallbackNode> m_allCallBack;

	void Fire_LuaEvent(const char* pszKey, DISPPARAMS* pParams)
	{
		TSAUTO();
		for(size_t i = 0;i<m_allCallBack.size();i++)
		{
 			m_allCallBack[i].pCallBack(m_allCallBack[i].userData1,m_allCallBack[i].userData2, pszKey,pParams);
		}
	}
private:
	HANDLE m_hMutex;
 

private:

public:
	LRESULT OnCopyData(UINT , WPARAM , LPARAM , BOOL& );
	LRESULT HandleFilterResult(UINT uiMsg, WPARAM wParam, LPARAM lParam, BOOL & bHandled);
};
