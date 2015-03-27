// dllmain.cpp : Implementation of DllMain.

#include "stdafx.h"
#include "resource.h"
#include "iekernel_i.h"
#include "dllmain.h"
#include "dlldatax.h"

CiekernelModule _AtlModule;

#include "YBApp.h"
#include ".\YBKernelHelper\CYBMsgWnd.h"
CYBApp theApp;

HANDLE g_hInst = NULL;

// DLL Entry Point
extern "C" BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
#ifdef _MERGE_PROXYSTUB
	if (!PrxDllMain(hInstance, dwReason, lpReserved))
		return FALSE;
#endif
	hInstance;
	g_hInst = hInstance;
	return _AtlModule.DllMain(dwReason, lpReserved); 
}


STDAPI_(BOOL) InitXLUE(wchar_t* lpCmdLine)
{
	//TSAUTO();
	BOOL bRet = theApp.InitInstance(lpCmdLine);
	if (!bRet)
	{
		TSDEBUG4CXX(L"InitInstance error, exit!");
		theApp.ExitInstance();
	}
	CYBMsgWindow::Instance()->InitMsgWnd();
	return bRet;
}

STDAPI UnInitXLUE()
{
	//TSAUTO();	
	theApp.ExitInstance();
	return 0;
}