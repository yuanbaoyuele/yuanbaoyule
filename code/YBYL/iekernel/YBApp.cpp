#include "StdAfx.h"
#include <string>
#include <winsock2.h>


#include "YBApp.h"


using namespace std;

CYBApp::CYBApp(void)
{
	m_strCmdLine = L"";
}

CYBApp::~CYBApp(void)
{
}

BOOL CYBApp::InitInstance(LPWSTR lpCmdLine)
{
	if (NULL != lpCmdLine)
	{
		m_strCmdLine = lpCmdLine;
	}
	// 初始化LuaRuntime的调试接口
#ifdef TSLOG
	//XLLRT_DebugInit("greenshield",XLLRT_DEBUG_TYPE_HOOK);
#else
	//XLLRT_DebugInit("greenshield",XLLRT_DEBUG_TYPE_NOHOOK);
#endif



	return IniEnv();
}


int __stdcall CYBApp::LuaErrorHandle(lua_State* luaState,const wchar_t* pExtInfo, const wchar_t* luaErrorString,PXL_LRT_ERROR_STACK pStackInfo)
{
	TSTRACEAUTO();
	static bool s_bEnter = false;
	if (!s_bEnter)
	{
		s_bEnter = true;
		if(pExtInfo != NULL)
		{
			TSDEBUG4CXX(L"LuaErrorHandle: " << luaErrorString << L" @ " << pExtInfo);
		}
		else
		{
			TSDEBUG4CXX(L"LuaErrorHandle: " << luaErrorString);
		}
		s_bEnter = false;
	}
	return 0;
}

int CYBApp::ExitInstance()
{
	TerminateProcess(GetCurrentProcess(), 0);
	return 0;
}



BOOL CYBApp::IniEnv()
{
	TCHAR szXar[MAX_PATH] = {0};
	GetModuleFileName((HMODULE)g_hInst, szXar, MAX_PATH);
	PathRemoveFileSpec(szXar);
	if (!::PathFileExists(szXar) || !::PathIsDirectory(szXar) )
	{
		//MessageBoxA(NULL,"获取界面皮肤路径失败","错误",MB_OK|MB_ICONERROR);
		//return FALSE;
	}
	m_strXarPath = szXar;
	// 1)初始化图形库
	XLGraphicParam param;
	XL_PrepareGraphicParam(&param);
	param.textType = XLTEXT_TYPE_GDI;
	XL_InitGraphicLib(&param);
	//XL_SetFreeTypeEnabled(TRUE);
	
	XLGraphicPlusParam plusParam;
	XLGP_PrepareGraphicPlusParam(&plusParam);
	XLGP_InitGraphicPlus(&plusParam);
	// 2)初始化XLUE,这函数是一个符合初始化函数
	// 完成了初始化Lua环境,标准对象,XLUELoader的工作
	//XLFS_Init();
	XLUE_InitLoader(NULL);
	XLLRT_ErrorHandle(CYBApp::LuaErrorHandle);

	if (!m_RegisterLuaAPI.Init())
	{
		return FALSE;
	}

	InternalLoadXAR();
	return TRUE;
}

BOOL CYBApp::ISUACOS()
{
	OSVERSIONINFOEX osvi;
	ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	if (GetVersionEx((OSVERSIONINFO*)&osvi))
	{
		if (osvi.dwMajorVersion <= 5)
		{
			return FALSE;
		}
	}
	return TRUE;
}

void CYBApp::InternalLoadXAR()
{
	TCHAR strPath[MAX_PATH] = {0};
	GetModuleFileName(NULL, strPath, MAX_PATH);
	std::wstring strExePath = strPath;
	PathRemoveFileSpec(strPath);
	PathAppend(strPath, _T("iexar")); 
	std::wstring strXarDest = strPath;
	
	std::wstring strXarRes = L"xar@resource://";
	strXarRes+=strExePath;
	if (ISUACOS())
		strXarRes+=L"|xar_res|1002$";
	else
		strXarRes+=L"|xar_res|1001$";
	
	TSDEBUG4CXX(L"InternalLoadXAR, strXarDest = " << strXarDest.c_str()<<L", strXarRes = " <<strXarRes.c_str());
	long iRet = XLFS_MountDir(strXarDest.c_str(), strXarRes.c_str(), 0, 0);
	TSDEBUG4CXX(L"XLFS_MountDir iRet = " << iRet);
	if (0 == iRet)
	{
		std::string strAnsi;
		WideStringToAnsiString(strXarDest,strAnsi);
		iRet = XLUE_LoadXAR(strAnsi.c_str());
	}
	if (iRet != 0)
	{
		TSDEBUG4CXX(L"XLFS_MountDir,XLUE_LoadXAR error");
		XLUE_AddXARSearchPath(m_strXarPath.c_str());
		if (XLUE_XARExist("main"))
		{
			long iRet = XLUE_LoadXAR("main");	//返回值为0说明加载成功
			TSDEBUG4CXX(L"AddXARSearch,XLUE_LoadXAR iRet = " << iRet);
			if(iRet != 0)
			{
				TerminateProcess(GetCurrentProcess(), (UINT)-20);
			}
		}
		else
		{
			MessageBoxA(NULL,"无法获取界面皮肤","错误",MB_OK|MB_ICONERROR);
			TSDEBUG(_T("XLUE_XARExist main) return FALSE"));
			TerminateProcess(GetCurrentProcess(), (UINT)-30);
		}
	}
}


std::wstring CYBApp::GetCommandLine()
{
	return m_strCmdLine;
}