// YBYL.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
//#include "resource.h"
#include "YBPretender.h"
#include "ParseCmd.h"
CAppModule _Module;

int Run(LPTSTR lpstrCmdLine = NULL, int nCmdShow = SW_SHOWDEFAULT)
{
	CMessageLoop theLoop;
	_Module.AddMessageLoop(&theLoop);

	int nRet = 0;
	CYBPretender ybPretender;
	if (ybPretender.Init(lpstrCmdLine))
	{
		nRet = theLoop.Run();
	}
	// ��Ϣѭ����Ӧ�ý����������������˷��������̡�����ֱ��ɱ��
	TerminateProcess(GetCurrentProcess(),(UINT)-16);
	_Module.RemoveMessageLoop();
	return nRet;
}

int WINAPI _tWinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPTSTR lpstrCmdLine, int nCmdShow)
{
	TSTRACEAUTO();

	//std::wstring strProdName, strProdId, strProdVer;

	HRESULT hRes = ::CoInitialize(NULL);
	// If you are running on NT 4.0 or higher you can use the following call instead to 
	// make the EXE free threaded. This means that calls come in on a random RPC thread.
	//	HRESULT hRes = ::CoInitializeEx(NULL, COINIT_MULTITHREADED);
	ATLASSERT(SUCCEEDED(hRes));
	
	int nArg = 0;
	BOOL bHandle = CParseCmd::PreHandleCmdline(lpstrCmdLine);
	TSDEBUG4CXX(" bHandle : "<<bHandle);
	if(bHandle)
	{		
		TerminateProcess(GetCurrentProcess(), 1);
		return 1;
	}

	// this resolves ATL window thunking problem when Microsoft Layer for Unicode (MSLU) is used
	::DefWindowProc(NULL, 0, 0, 0L);

	AtlInitCommonControls(ICC_BAR_CLASSES);	// add flags to support other controls

	hRes = _Module.Init(NULL, hInstance);
	ATLASSERT(SUCCEEDED(hRes));
	int nRet = Run(lpstrCmdLine, nCmdShow);

	_Module.Term();
	::CoUninitialize();
	return nRet;
}

