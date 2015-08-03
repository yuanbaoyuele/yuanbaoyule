#include "stdafx.h"
#include "RegisterLuaAPI.h"
#include "LuaAPIUtil.h"
#include "LuaAsynAPIUtil.h"
#include "YBKernelHelper/LuaListenPre.h"
#include "YBKernelHelper/LuaPrefactory.h"
#include "LuaNotifyIcon.h"

CRegisterLuaAPI::CRegisterLuaAPI()
{

}

CRegisterLuaAPI::~CRegisterLuaAPI()
{

}

BOOL CRegisterLuaAPI::Init(LPCTSTR lpCmdLine, LPVOID lpHookObj)
{
	TSTRACEAUTO();
	XL_LRT_ENV_HANDLE hEnv = XLLRT_GetEnv(NULL);
	if (NULL == hEnv)
	{
		TSDEBUG4CXX(L"XLLRT_GetEnv error!  hEnv == NULL");
		return FALSE;
	}
	LuaAPIUtil::RegisterObj(hEnv);
	LuaAsynUtil::RegisterSelf(hEnv);
	LuaNotifyIcon::RegisterSelf(hEnv);

	LuaListenPreFactory::RegisterObj(hEnv);
	LuaListenPre::RegisterClass(hEnv);

	XLLRT_ReleaseEnv(hEnv);
	return TRUE;
}
