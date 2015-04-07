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
	// ��ʼ��LuaRuntime�ĵ��Խӿ�
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
	PathAppend(szXar, _T("..\\xar\\")); 
	if (!::PathFileExists(szXar) || !::PathIsDirectory(szXar) )
	{
		MessageBoxA(NULL,"��ȡ����Ƥ��·��ʧ��","����",MB_OK|MB_ICONERROR);
		return FALSE;
	}
	m_strXarPath = szXar;
	// 1)��ʼ��ͼ�ο�
	XLGraphicParam param;
	XL_PrepareGraphicParam(&param);
	param.textType = XLTEXT_TYPE_GDI;
	XL_InitGraphicLib(&param);
	//XL_SetFreeTypeEnabled(TRUE);
	
	XLGraphicPlusParam plusParam;
	XLGP_PrepareGraphicPlusParam(&plusParam);
	XLGP_InitGraphicPlus(&plusParam);
	// 2)��ʼ��XLUE,�⺯����һ�����ϳ�ʼ������
	// ����˳�ʼ��Lua����,��׼����,XLUELoader�Ĺ���
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


void CYBApp::InternalLoadXAR()
{
	XLUE_AddXARSearchPath(m_strXarPath.c_str());
	if (XLUE_XARExist("main"))
	{
		long iRet = XLUE_LoadXAR("main");	//����ֵΪ0˵�����سɹ�
		TSDEBUG4CXX(L"XLUE_LoadXAR iret = " << iRet);
		if(iRet != 0)
		{
			TerminateProcess(GetCurrentProcess(), (UINT)-20);
		}
	}
	else
	{
		MessageBoxA(NULL,"�޷���ȡ����Ƥ��","����",MB_OK|MB_ICONERROR);
		TSDEBUG(_T("XLUE_XARExist main) return FALSE"));
		TerminateProcess(GetCurrentProcess(), (UINT)-30);
	}
}


std::wstring CYBApp::GetCommandLine()
{
	return m_strCmdLine;
}