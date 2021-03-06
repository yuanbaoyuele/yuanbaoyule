#include "StdAfx.h"

#include <TlHelp32.h>
#include <Shlobj.h>
#include <atlsync.h>
#include <atltime.h>
#include <WTL/atldlgs.h>
#include "DatFileUtility.h"
#include "LuaAPIUtil.h"
#include "LuaAPIHelper.h"
#include "YBApp.h"
#include "PeeIdHelper.h"
#include "AES.h"
#include "commonshare\md5.h"
//#include <openssl/rsa.h>
//#include <openssl/aes.h>
//#include <openssl/evp.h>
//#pragma comment(lib,"libeay32.lib")
//#pragma comment(lib,"ssleay32.lib")
#include <MsHtmcid.h>
#include <Psapi.h>
#include <mshtml.h> 
#include <Exdisp.h>
#include "UACElevate.h"
extern CYBApp theApp;

#include "YBKernelHelper\CYBMsgWnd.h"
#include "base64.h"

#include "YbSpeed\YbSpeedHook.h"
#include "..\YBNetFilter\YBNetFilter.h"

extern HANDLE g_hInst;

LuaAPIUtil::LuaAPIUtil(void)
{
}

LuaAPIUtil::~LuaAPIUtil(void)
{
}

XLLRTGlobalAPI LuaAPIUtil::sm_LuaMemberFunctions[] = 
{
	//{"RegisterFilterWnd", RegisterFilterWnd},	
	//主要函数
	{"MsgBox",MsgBox},

	{"LoadVideoRules",LoadVideoRules},
	{"FYBFilter",FYBFilter},
	{"FYbSetWebRoot",FYbSetWebRoot},
	{"Exit", Exit},	
	{"GetPeerId", GetPeerId},
	{"Log", Log},
	{"SaveLuaTableToLuaFile", SaveLuaTableToLuaFile},
	{"GetCommandLine", GetCommandLine},
	{"CommandLineToList", CommandLineToList},
	{"GetModuleExeName", GetModuleExeName},

	{"GetWorkArea", GetWorkArea},
	{"GetScreenArea", GetScreenArea},
	{"GetScreenSize", GetScreenSize},
	{"GetCursorPos", GetCursorPos},
	{"PostWndMessage", PostWndMessage},
	{"GetSysWorkArea", GetSysWorkArea},
	{"GetCurrentScreenRect", GetCurrentScreenRect},
	{"GetDesktopWndHandle", FGetDesktopWndHandle}, 
	{"SetWndPos", FSetWndPos}, 
	{"ShowWnd", FShowWnd}, 
	{"GetWndRect", FGetWndRect}, 
	{"GetWndClientRect", FGetWndClientRect}, 
	{"FindWindow", FFindWindow}, 
	{"FindWindowEx", FFindWindowEx},
	{"IsWindowVisible", FIsWindowVisible},
	{"IsWindowIconic", IsWindowIconic},
	{"GetWindowTitle", GetWindowTitle},
	{"GetWndClassName", GetWndClassName},
	{"GetWndProcessThreadId", GetWndProcessThreadId},
	{"PostWndMessageByHandle", PostWndMessageByHandle},
	{"SendMessageByHwnd", SendMessageByHwnd},
	{"IsNowFullScreen", IsNowFullScreen},

	{"GetCursorWndHandle", GetCursorWndHandle},
	{"GetFocusWnd", GetFocusWnd},
	{"GetKeyState", FGetKeyState},
	
	{"CreateParentWnd", FCreateParentWnd},
	{"GetForegroundProcessInfo", GetForegroundProcessInfo},

	//文件
	{"GetMD5Value", GetMD5Value},
	{"GetStringMD5", GetStringMD5},
	{"GetFileVersionString", GetFileVersionString},
	{"GetSystemTempPath", GetSystemTempPath},
	{"GetFileSize", GetFileSize},
	{"GetFileCreateTime", GetFileCreateTime},
	{"GetTmpFileName", GetTmpFileName},
	{"GetSpecialFolderPathEx", GetSpecialFolderPathEx}, 
	{"FindFileList", FindFileList},
	{"FindDirList", FindDirList},
	{"PathCombine", PathCombine},
	{"ExpandEnvironmentStrings", ExpandEnvironmentString},	
	{"QueryFileExists", QueryFileExists},
	{"Rename", Rename},
	{"CreateDir", CreateDir},
	{"CopyPathFile", CopyPathFile},
	{"DeletePathFile", DeletePathFile},
	{"GetUserPinPath", GetUserPinPath},
	//读写UTF8文件
	{"ReadFileToString", ReadFileToString},
	{"WriteStringToFile", WriteStringToFile},

	//注册表操作
	{"QueryRegValue", QueryRegValue},
	{"QueryRegValue64", QueryRegValue64},
	{"DeleteRegValue", DeleteRegValue},
	{"DeleteRegValue64", DeleteRegValue64},
	{"CreateRegKey", CreateRegKey},
	{"CreateRegKey64", CreateRegKey64},
	{"DeleteRegKey", DeleteRegKey},
	{"DeleteRegKey64", DeleteRegKey64},
	{"SetRegValue", SetRegValue},
	{"SetRegValue64", SetRegValue64},
	{"QueryRegKeyExists", QueryRegKeyExists}, 
	{"EnumRegLeftSubKey", EnumRegLeftSubKey}, 
	{"EnumRegRightSubKey", EnumRegRightSubKey}, 

	//时间函数
	{"GetCurTimeSpan", GetCurTimeSpan},
	{"FormatCrtTime", FormatCrtTime},
	{"GetLocalDateTime", GetLocalDateTime},
	{"GetCurrentUTCTime", GetCurrentUTCTime},
	{"DateTime2Seconds", DateTime2Seconds},
	{"Seconds2DateTime", Seconds2DateTime},
	{"FileTime2LocalTime", FileTime2LocalTime},
	{"InternetTimeToUTCTime", InternetTimeToUTCTime},

	//互斥量函数
	{"CreateMutex", CreateNamedMutex},
	{"CloseMutex", CloseNamedMutex},
	
	//系统
	{"GetCurrentProcessId", FGetCurrentProcessId},
	{"GetAllSystemInfo", FGetAllSystemInfo},
	{"GetProcessIdFromHandle", FGetProcessIdFromHandle},
	{"GetTickCount", GetTotalTickCount},
	{"GetOSVersion", GetOSVersionInfo},
	{"QueryProcessExists", QueryProcessExists},
	{"IsWindows8Point1",IsWindows8Point1},
	{"GetProcessElevation",GetProcessElevation},

	//功能
	{"CreateShortCutLinkEx", CreateShortCutLinkEx},
	{"OpenURL", OpenURL},
	{"OpenURLIE", OpenURLIE},
	{"ShellExecute", ShellExecuteEX},


	{"EncryptAESToFile", EncryptAESToFile},
	{"DecryptFileAES", DecryptFileAES},


	{"GetIEHistoryInfo", GetIEHistoryInfo},

	{"DownloadFileByIE", DownloadFileByIE},
	//INI配置文件操作
	{"ReadINI", ReadINI},
	{"WriteINI", WriteINI},
	{"ReadStringUtf8", ReadStringUtf8},
	{"ReadSections", ReadSections},
	{"ReadKeyValueInSection", ReadKeyValueInSection},
	{"ReadINIInteger", ReadINIInteger},
	
	//文件对话框操作
	{"FileDialog", FileDialog},
	{"BrowserForFile", BrowserForFile},
	{"IEMenu_SaveAs", IEMenu_SaveAs},
	{"IEMenu_Zoom", IEMenu_Zoom},
	{"IEFavorite_Organize", IEFavorite_Organize},

	// 变速相关
	{"YbSpeedInitialize", YbSpeedInitialize},
	{"YbSpeedHook", YbSpeedHook},
	{"YbSpeedUnhook", YbSpeedUnhook},
	{"YbSpeedChangeRate", YbSpeedChangeRate},

	//快捷键相关
	{"FSetKeyboardHook", FSetKeyboardHook},
	{"FDelKeyboardHook", FDelKeyboardHook},
	
	{"PinToStartMenu4XP", PinToStartMenu4XP},
	{"RefleshIcon", RefleshIcon},
	{"UpdateShortCutLinkInfo", UpdateShortCutLinkInfo},


	//提权操作
	{"ElevateOperate", ElevateOperate},
	{NULL, NULL}
};

int LuaAPIUtil::MsgBox(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	if (!lua_isstring(pLuaState,2) && !lua_isstring(pLuaState,3))
	{
		return 0;
	}
	const char* utf8Text = luaL_checkstring(pLuaState, 2);
	const char* utf8Title = luaL_checkstring(pLuaState, 3);

	CComBSTR bstrTitle,bstrText;
	LuaStringToCComBSTR(utf8Title,bstrTitle);
	LuaStringToCComBSTR(utf8Text,bstrText);
	
	UINT uType = MB_OK;
	if ( !lua_isnoneornil( pLuaState, 4 ))
	{
		uType = (int)lua_tointeger( pLuaState, 4);
	}
	MessageBox(NULL,bstrText.m_str,bstrTitle.m_str,uType);
	return 1;
}

int LuaAPIUtil::LoadVideoRules(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	if (!lua_isstring(pLuaState,2))
	{
		return 0;
	}

	BOOL bRet = FALSE;
	const char* utf8CfgPath = luaL_checkstring(pLuaState, 2);
	CComBSTR bstrPath;
	LuaStringToCComBSTR(utf8CfgPath,bstrPath);
	if (::PathFileExists(bstrPath.m_str))
	{
		if (YbGetVideoRules(bstrPath.m_str))
		{
			bRet = TRUE;
		}
	}
	lua_pushboolean(pLuaState, bRet);
	return 1;
}

int LuaAPIUtil::FYBFilter(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	BOOL bRet = FALSE;
	int nFilter = lua_toboolean(pLuaState, 2);
	BOOL bFilter = (nFilter == 0) ? FALSE : TRUE;
	if (bFilter)
	{
		static BOOL bOnce  = FALSE;
		static USHORT listen_port = 0;

		if (!bOnce)
		{	
			if (YbSetHook())
			{
				HANDLE hThread = YbStartProxy(&listen_port);

				if (NULL != hThread)
				{
					bRet = YbEnable(TRUE, listen_port);
					bOnce = TRUE;
				}
			}
		}
		else
		{
			bRet = YbEnable(TRUE, listen_port);
		}
	}
	else
	{
		bRet = YbEnable(FALSE, 0);
	}
	lua_pushboolean(pLuaState, bRet);
	return 1;
}

int LuaAPIUtil::FYbSetWebRoot(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8WebRoot = luaL_checkstring(pLuaState, 2);
	if (utf8WebRoot == NULL) 
	{
		return 0;
	}
	CComBSTR bstrWebRoot;
	LuaStringToCComBSTR(utf8WebRoot,bstrWebRoot);
	BOOL bRet = YbSetWebRoot(bstrWebRoot.m_str);
	lua_pushboolean(pLuaState, bRet);
	return 1;
}

int LuaAPIUtil::Exit(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	theApp.ExitInstance();
	return 0;
}

int LuaAPIUtil::GetPeerId(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}

	std::wstring strPeerId=L"";
	GetPeerId_(strPeerId);
	wchar_t szPeerId[MAX_PATH] = {0};
	wcsncpy(szPeerId,strPeerId.c_str(),strPeerId.size());

	std::string strUtf8Pid;
	BSTRToLuaString(szPeerId,strUtf8Pid);
	lua_pushstring(pLuaState, strUtf8Pid.c_str());
	return 1;
}

int LuaAPIUtil::GetWorkArea(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int x = 1;
		int y = 1;
		if ( !lua_isnoneornil( pLuaState, 2 ) && !lua_isnoneornil( pLuaState, 3 ) )
		{
			x = (int)lua_tointeger( pLuaState, 2 );
			y = (int)lua_tointeger( pLuaState, 3 );
		}
		POINT pt;
		pt.x = x;
		pt.y = y;
		HMONITOR hMonitor = MonitorFromPoint( pt, MONITOR_DEFAULTTONEAREST );
		MONITORINFO info;
		ZeroMemory( &info, sizeof( info ) );
		info.cbSize = sizeof( info );
		if (GetMonitorInfo( hMonitor, &info ))
		{
			lua_pushinteger( pLuaState, info.rcWork.left );
			lua_pushinteger( pLuaState, info.rcWork.top );
			lua_pushinteger( pLuaState, info.rcWork.right );
			lua_pushinteger( pLuaState, info.rcWork.bottom );
			return 4;
		}
	}
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	return 4;
}

int LuaAPIUtil::GetScreenArea(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int x = 1;
		int y = 1;
		if ( !lua_isnoneornil( pLuaState, 2 ) && !lua_isnoneornil( pLuaState, 3 ) )
		{
			x = (int)lua_tointeger( pLuaState, 2 );
			y = (int)lua_tointeger( pLuaState, 3 );
		}
		POINT pt;
		pt.x = x;
		pt.y = y;
		HMONITOR hMonitor = MonitorFromPoint( pt, MONITOR_DEFAULTTONEAREST );
		MONITORINFO info;
		ZeroMemory( &info, sizeof( info ) );
		info.cbSize = sizeof( info );
		if (GetMonitorInfo( hMonitor, &info ))
		{
			lua_pushinteger( pLuaState, info.rcMonitor.left );
			lua_pushinteger( pLuaState, info.rcMonitor.top );
			lua_pushinteger( pLuaState, info.rcMonitor.right );
			lua_pushinteger( pLuaState, info.rcMonitor.bottom );
			return 4;
		}
	}
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	lua_pushinteger(pLuaState, 0);
	return 4;
}

int LuaAPIUtil::GetScreenSize(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	int iScreenWidth = ::GetSystemMetrics(SM_CXSCREEN);
	int iScreenHeight = ::GetSystemMetrics(SM_CYSCREEN);
	lua_pushnumber(pLuaState, iScreenWidth);
	lua_pushnumber(pLuaState, iScreenHeight);
	return 2;
}

int LuaAPIUtil::GetCursorPos(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	POINT pt;
	::GetCursorPos(&pt);
	lua_pushnumber(pLuaState, pt.x);
	lua_pushnumber(pLuaState, pt.y);
	return 2;
}

// 获取命令行参数(不包含可执行程序路径)
int LuaAPIUtil::GetCommandLine(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	std::string strUtf8 = "";

	std::wstring wstrCommandLine = theApp.GetCommandLine();
	 
	if (!wstrCommandLine.empty())
	{	
		wchar_t szCmd[1024*4] = {0};
		wcsncpy(szCmd,wstrCommandLine.c_str(),wstrCommandLine.size());
		szCmd[1024*4-1] = '\0';
		BSTRToLuaString(szCmd, strUtf8);
	}

	lua_pushstring(pLuaState, strUtf8.c_str());
	return 1;
}

int LuaAPIUtil::GetFileVersionString(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8FilePath = luaL_checkstring(pLuaState, 2);
		if (utf8FilePath == NULL) 
		{
			return 0;
		}
		long nfileExist = QueryFileExistsHelper(utf8FilePath);
		if(nfileExist == 0)
		{
			return 0;
		}
		
		CComBSTR bstr;

		if(utf8FilePath)
		{
			LuaStringToCComBSTR(utf8FilePath,bstr);
		}

		DWORD dwHandle = 0;
		DWORD dwSize = ::GetFileVersionInfoSizeW(bstr.m_str, &dwHandle);
		std::string utf8Version;
		if(dwSize > 0)
		{
			TCHAR * pVersionInfo = new TCHAR[dwSize+1];
			if(::GetFileVersionInfo(bstr.m_str, dwHandle, dwSize, pVersionInfo))
			{
				VS_FIXEDFILEINFO * pvi;
				UINT uLength = 0;
				if(::VerQueryValueA(pVersionInfo, "\\", (void **)&pvi, &uLength))
				{
					TCHAR szVer[MAX_PATH] = {0};
					swprintf(szVer, L"%d.%d.%d.%d",
						HIWORD(pvi->dwFileVersionMS), LOWORD(pvi->dwFileVersionMS),
						HIWORD(pvi->dwFileVersionLS), LOWORD(pvi->dwFileVersionLS));
					BSTRToLuaString(szVer, utf8Version);
				}
			}
			delete pVersionInfo;
		}
		lua_pushstring(pLuaState, utf8Version.c_str());
		return 1;
	}

	lua_pushnil(pLuaState);
	return 1;
}


int LuaAPIUtil::GetMD5Value(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8FilePath = lua_tostring(pLuaState,2);
		if (utf8FilePath != NULL)
		{
			CComBSTR bstrFilePath;
			LuaStringToCComBSTR(utf8FilePath,bstrFilePath);

			wchar_t pszMD5[MAX_PATH] = {0};
			std::wstring wstrPath = bstrFilePath.m_str;
			if (GetMd5(wstrPath,pszMD5))
			{

				std::string utf8MD5;
				BSTRToLuaString(pszMD5, utf8MD5);
				lua_pushstring(pLuaState, utf8MD5.c_str());
			}
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetStringMD5(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8str = lua_tostring(pLuaState,2);
		if (utf8str != NULL)
		{
			wchar_t pszMD5[MAX_PATH] = {0};
			if (GetStringMd5(utf8str,pszMD5))
			{
				std::string utf8MD5;
				BSTRToLuaString(pszMD5, utf8MD5);
				lua_pushstring(pLuaState, utf8MD5.c_str());
			}
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}


int LuaAPIUtil::GetSystemTempPath(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	wchar_t szPath[MAX_PATH] = {0};
	DWORD len = GetTempPath(MAX_PATH, szPath);
	if(len > 0)
	{
		std::string utf8TempPath;
		BSTRToLuaString(szPath, utf8TempPath);
		lua_pushstring(pLuaState, utf8TempPath.c_str());
		lua_pushboolean(pLuaState, 1);
		return 2;
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

__int64 LuaAPIUtil::GetFileSizeHelper(const char* utf8FileFullPath)
{
	long nfileExist = QueryFileExistsHelper(utf8FileFullPath);
	if(nfileExist == 0)
	{
		return -1;
	}

	CComBSTR bstr;

	if(utf8FileFullPath)
	{
		LuaStringToCComBSTR(utf8FileFullPath,bstr);
	}

	HANDLE hFile = CreateFile(bstr.m_str, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, NULL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
	{
		return -1;
	}

	LARGE_INTEGER li;
	BOOL bRet = GetFileSizeEx(hFile,&li);
	CloseHandle( hFile );
	if(!bRet)
	{
		return -1;
	}

	return li.QuadPart;
}

int LuaAPIUtil::GetFileSize(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* filePath = luaL_checkstring(pLuaState, 2);
		__int64 nFileSize = GetFileSizeHelper(filePath);
		lua_pushnumber(pLuaState,(lua_Number)nFileSize);
		return 1;
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetFileCreateTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8FilePath = luaL_checkstring(pLuaState, 2);
		CComBSTR bstrFilePath;
		LuaStringToCComBSTR(utf8FilePath,bstrFilePath);
		
		HANDLE hFile = INVALID_HANDLE_VALUE;
		hFile = CreateFile(bstrFilePath.m_str, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, 0, NULL);
		if (hFile != INVALID_HANDLE_VALUE)
		{
			FILETIME ftCreate, ftAccess, ftWrite;
			if (0 != GetFileTime(hFile, &ftCreate, &ftAccess, &ftWrite))
			{
				CloseHandle(hFile);
				SYSTEMTIME stUTC, stLocal;
				FileTimeToSystemTime(&ftCreate, &stUTC);
				SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stLocal);

				lua_pushnumber(pLuaState, stLocal.wYear);
				lua_pushnumber(pLuaState, stLocal.wMonth);
				lua_pushnumber(pLuaState, stLocal.wDay);
				lua_pushnumber(pLuaState, stLocal.wHour);
				lua_pushnumber(pLuaState, stLocal.wMinute);
				lua_pushnumber(pLuaState, stLocal.wSecond);
				lua_pushnumber(pLuaState, stLocal.wDayOfWeek);
				return 7;
			}
			CloseHandle(hFile);
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetCurTimeSpan(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int nYear = 0, nMonth = 0, nDate = 0, nHour = 0, nMinute = 0, nSeconds = 0;
		nYear = (int)lua_tointeger(pLuaState, 2);
		nMonth = (int)lua_tointeger(pLuaState, 3);
		nDate = (int)lua_tointeger(pLuaState, 4);
		nHour = (int)lua_tointeger(pLuaState, 5);
		nMinute = (int)lua_tointeger(pLuaState, 6);
		nSeconds = (int)lua_tointeger(pLuaState, 7);
		CTime tm1(nYear, nMonth, nDate, nHour, nMinute, nSeconds);

		SYSTEMTIME systemTime;
		::GetLocalTime(&systemTime);
		CTime tm2(systemTime);

		CTimeSpan ts = tm2 - tm1;
		LONGLONG llHourSpan = ts.GetTotalHours();
		LONGLONG llMinuteSpan = ts.GetTotalMinutes();
		LONGLONG llSecSpan = ts.GetTotalSeconds();
		lua_pushnumber(pLuaState, (lua_Number)llHourSpan);
		lua_pushnumber(pLuaState, (lua_Number)llMinuteSpan);
		lua_pushnumber(pLuaState, (lua_Number)llSecSpan);
		return 3;
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetTmpFileName(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		wchar_t* pwTemplate = L"TWXXXXXXXX";
		wchar_t szTmp[11] = {0};
		wcscpy(szTmp, pwTemplate);
		wchar_t* szFileName = _wmktemp(szTmp);
		if (szFileName != NULL)
		{
			std::string utf8FileName;
			BSTRToLuaString(szFileName,utf8FileName);
			lua_pushstring(pLuaState, utf8FileName.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}


int LuaAPIUtil::GetSpecialFolderPathEx(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int iCLSID = (int)lua_tointeger(pLuaState, 2);
		TCHAR szPath[MAX_PATH] = {0};
		if (SHGetSpecialFolderPath(NULL, szPath, iCLSID, 0))
		{
			std::string strFilePath;
			BSTRToLuaString(szPath,strFilePath);
			lua_pushstring(pLuaState, strFilePath.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::Log(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		if (ISTSDEBUGVALID())
		{
			const char* szInput = lua_tostring(pLuaState, 2);
			CComBSTR bstrInput;
			LuaStringToCComBSTR(szInput,bstrInput);
			TSDEBUG4CXX(L"[YBKernel] " << bstrInput.m_str);
		}
	}
	return 0;
}

void LuaAPIUtil::ConvertAllEscape(std::string& strSrc)
{
	char szEscape[] = {'\\', '\'', '\"', '\?', '\0'};
	for (std::string::size_type i = 0; i < strSrc.length(); i++)
	{
		for (size_t j = 0; j < strlen(szEscape); j++)
		{
			if (strSrc[i] == szEscape[j])
			{
				strSrc.insert(i, "\\");
				i++;
				break;
			}
		}
	}
}

std::string LuaAPIUtil::GetTableStr(lua_State* luaState, int nIndex, std::ofstream& ofs, const std::string strTableName, int nFloor)
{
	bool bTable = lua_istable(luaState, nIndex);
	ATLASSERT(bTable);
	if (!bTable)
		return false;
	lua_pushnil(luaState);
	std::string strTableAll(strTableName + " = {\r\n");

	std::map<int, std::string> mapArrary;
	while (lua_next(luaState, nIndex)) 
	{
		std::string strKey;
		int t = lua_type(luaState, -2);

		std::string strTable("");
		int iIndex = -1;
		//key
		if(lua_isnumber(luaState, -2) && t == LUA_TNUMBER)
		{
			int n = (int)lua_tointeger(luaState, -2);
			char szIndex[30] = {0};
			itoa(n, szIndex, 10);
			strKey += "[";
			strKey += szIndex;
			strKey += "]";
			iIndex = n;
		}
		else if(lua_isstring(luaState, -2))
		{
			const char* szKey = (const char*)lua_tostring(luaState, -2);

			strKey += "[\"";
			strKey += szKey;
			strKey += "\"]";
		}
		else
		{
			ATLASSERT(FALSE && "table key only support number or string!");
		}
		// 带#号的临时属性不保存
		if(strKey[2] == '#')
		{
			lua_pop(luaState, 1);
			continue;
		}

		//value
		if(lua_istable(luaState, -1))
		{
			//strTable += "\r\n";
			for(int i = 0; i < nFloor; i++)
				strTable += "\t";
			//ofs.write(strTable.c_str(), (std::streamsize)strTable.length());
			strTable += GetTableStr(luaState, lua_gettop(luaState), ofs, strKey, nFloor + 1);
			strTable += ", \r\n";
		}
		else
		{
			for(int i = 0; i < nFloor; i++)
				strTable += "\t";
			strTable += strKey;
			strTable += " = ";
			t = lua_type(luaState, -1);
			if(lua_isboolean(luaState, -1))
			{
				int b = lua_toboolean(luaState, -1);
				strTable += (b ? "true" : "false");
				strTable += ", \r\n";
			}
			else if(lua_isnumber(luaState, -1) && t == LUA_TNUMBER)
			{
				double dbValue = (double)lua_tonumber(luaState, -1);
				char szValue[30] = {0};
				//itoa(nValue, szValue, 10);
				sprintf(szValue, "%f", dbValue);
				char* p = szValue + strlen(szValue) - 1;
				while(*p == '0')
					p--;
				if (*p == '.')
					p--;
				*(p+1) = '\0';
				strTable += szValue;
				strTable += ", \r\n";
			}
			else if(lua_isstring(luaState, -1))
			{
				std::string strValue = (const char*)lua_tostring(luaState, -1);
				ConvertAllEscape(strValue);
				strTable += "\"";
				strTable += strValue;
				strTable += "\", \r\n";
			}
			// table的已经内部弹出堆栈了，非table才用弹出堆栈
			lua_pop(luaState, 1);
		}
		if(0 > iIndex)
		{
			strTableAll += strTable;
		}
		else
		{
			mapArrary.insert(std::pair<int, std::string>(iIndex, strTable));
		}
	}
	lua_pop( luaState, 1 );
	for(std::map<int, std::string>::iterator it = mapArrary.begin(); it != mapArrary.end(); it++ )
	{
		strTableAll += it->second;
	}
	for(int i = 0; i < nFloor - 1; i++)
		strTableAll += "\t";
	strTableAll += "}";
	//ofs.write(strTable.c_str(), (std::streamsize)strTable.length());
	return strTableAll;
}

// 2, table, 3, save path, 4, function param
int LuaAPIUtil::SaveLuaTableToLuaFile(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int nParamCount = lua_gettop(pLuaState) - 1;
		// 至少两个参数
		ATLASSERT(nParamCount >= 2);
		if(nParamCount < 2)
		{
			return 0;
		}
		size_t nLen = 0;
		const char* szSavePath = (const char*)lua_tolstring(pLuaState, 3, &nLen);
		CComBSTR bstrSavePath;
		LuaStringToCComBSTR(szSavePath,bstrSavePath);


		std::string strSavePath;
		UnicodeToMultiByte(bstrSavePath.m_str, strSavePath);
		

		std::string strParam;
		if(nParamCount >= 3)
		{
			const char* szParam = (const char*)lua_tolstring(pLuaState, 4, &nLen);
			if(szParam != NULL)
			{
				CComBSTR bstrParam;
				LuaStringToCComBSTR(szParam,bstrParam);
				UnicodeToMultiByte(bstrSavePath.m_str, strParam);
			}
		}
		// 第四个参数允许写入 额外的代码
		std::string strExtra;
		if(nParamCount >= 4)
		{
			const char* pszExtra = (const char*)lua_tolstring(pLuaState, 5, &nLen);
			if(pszExtra)
			{
				strExtra = pszExtra;
				// 这里不转，lua传参数的时候要带多一个 '\'
				// ConvertAllEscape(strExtra);
			}
		}
		std::ofstream ofs(strSavePath.c_str(), std::ofstream::binary);

		std::string strFirstLine = "function GetSubTable(";
		strFirstLine += strParam;
		strFirstLine += ")\r\n\tlocal ";
		ofs.write(strFirstLine.c_str(), (std::streamsize)strFirstLine.length());
		std::string strRes = GetTableStr(pLuaState, 2, ofs, "t", 2);
		strRes += "\r\n\treturn t";
		strRes += "\r\nend\r\n";
		strRes += strExtra;
		ofs.write(strRes.c_str(), (std::streamsize)strRes.length());
		ofs.close();
		return 0;
	}
	return 0;
}

int LuaAPIUtil::FindFileList(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8Path = luaL_checkstring(pLuaState, 2);
		const char* utf8Flag = luaL_checkstring(pLuaState, 3);
		if ((utf8Path != NULL) && (utf8Flag != NULL))
		{
			CComBSTR bstrPath, bstrFlag;			
			LuaStringToCComBSTR(utf8Path,bstrPath);
			LuaStringToCComBSTR(utf8Flag,bstrFlag);

			std::vector<std::string> vecFileList;
			vecFileList.clear();
			WIN32_FIND_DATA fd;
			HANDLE hFind = INVALID_HANDLE_VALUE;
			TCHAR szSearchPath[MAX_PATH] = {0};
			::PathCombine(szSearchPath, bstrPath.m_str, bstrFlag.m_str);
			hFind = FindFirstFile(szSearchPath, &fd);
			while (INVALID_HANDLE_VALUE != hFind)
			{
				if (_tcsicmp(fd.cFileName, _T("..")) && _tcsicmp(fd.cFileName, _T(".")) && FILE_ATTRIBUTE_DIRECTORY != fd.dwFileAttributes)
				{
					TCHAR szLnkFileTmp[MAX_PATH] = {0};
					::PathCombine(szLnkFileTmp, bstrPath.m_str, fd.cFileName);
					std::string strTmp;
					BSTRToLuaString(szLnkFileTmp,strTmp);
					vecFileList.push_back(strTmp);
				}

				if (FindNextFile(hFind, &fd) == 0)
				{
					break;
				}
			}
			FindClose(hFind);

			int iCount = vecFileList.size();
			lua_checkstack(pLuaState, iCount);
			lua_newtable(pLuaState);
			for (int i = 0; i < iCount; i++)
			{
				std::string strTmp = vecFileList.at(i);
				lua_pushstring(pLuaState, strTmp.c_str());
				lua_rawseti(pLuaState, -2, i + 1);
			}
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::FindDirList(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8Path = luaL_checkstring(pLuaState, 2);
		if (utf8Path != NULL)
		{			
			CComBSTR bstrPath;			
			LuaStringToCComBSTR(utf8Path,bstrPath);

			std::vector<std::string> vecDirList;
			vecDirList.clear();
			WIN32_FIND_DATA fd;
			HANDLE hFind = INVALID_HANDLE_VALUE;
			TCHAR szSearchPath[MAX_PATH] = {0};
			::PathCombine(szSearchPath, bstrPath.m_str, L"*");
			hFind = FindFirstFile(szSearchPath, &fd);
			while (INVALID_HANDLE_VALUE != hFind)
			{
				if (_tcsicmp(fd.cFileName, _T("..")) && _tcsicmp(fd.cFileName, _T(".")) && FILE_ATTRIBUTE_DIRECTORY == fd.dwFileAttributes)
				{
					TCHAR szLnkFileTmp[MAX_PATH] = {0};
					::PathCombine(szLnkFileTmp, bstrPath.m_str, fd.cFileName);
					std::string strTmp;
					BSTRToLuaString(szLnkFileTmp,strTmp);
					vecDirList.push_back(strTmp);
				}

				if (FindNextFile(hFind, &fd) == 0)
				{
					break;
				}
			}
			FindClose(hFind);

			int iCount = vecDirList.size();
			lua_checkstack(pLuaState, iCount);
			lua_newtable(pLuaState);
			for (int i = 0; i < iCount; i++)
			{
				std::string strTmp = vecDirList.at(i);
				lua_pushstring(pLuaState, strTmp.c_str());
				lua_rawseti(pLuaState, -2, i + 1);
			}
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::ExpandEnvironmentString(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8Path = luaL_checkstring(pLuaState, 2);
		if (utf8Path != NULL)
		{
			CComBSTR bstrPath;			
			LuaStringToCComBSTR(utf8Path,bstrPath);
			TCHAR szPathTmp[MAX_PATH] = {0};
			ExpandEnvironmentStrings(bstrPath.m_str, szPathTmp, MAX_PATH);

			std::string strRetPath;
			BSTRToLuaString(szPathTmp,strRetPath);
			lua_pushstring(pLuaState, strRetPath.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetTotalTickCount(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	lua_pushnumber(pLuaState, ::GetTickCount());
	return 1;
}

int LuaAPIUtil::CommandLineToList(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8CmdLine = luaL_checkstring(pLuaState, 2);
	if (utf8CmdLine != NULL)
	{
		CComBSTR bstrCmdLine;			
		LuaStringToCComBSTR(utf8CmdLine,bstrCmdLine);
		int nNumArgs = 0;
		LPWSTR *szArgList = CommandLineToArgvW(bstrCmdLine.m_str, &nNumArgs);
		if (NULL != szArgList)
		{
			lua_newtable(pLuaState);
			for (int i=0; i<nNumArgs; ++i)
			{
				std::string strUtf8;
				BSTRToLuaString(szArgList[i],strUtf8);
				lua_pushstring(pLuaState, strUtf8.c_str()); 
				lua_rawseti(pLuaState, -2, i+1);
			}
			GlobalFree(szArgList);
			return 1;
		}
	}
	return 0;
}

int LuaAPIUtil::GetModuleExeName(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		TCHAR szExePath[MAX_PATH] = {0};
		if (0 != GetModuleFileName(NULL, szExePath, MAX_PATH))
		{
			std::string strExePath;
			BSTRToLuaString(szExePath,strExePath);
			lua_pushstring(pLuaState, strExePath.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetOSVersionInfo(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		OSVERSIONINFOEX osvi;
		ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
		osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
		if (!GetVersionEx((OSVERSIONINFO*)&osvi))
		{
			osvi.dwOSVersionInfoSize = sizeof (OSVERSIONINFO);
			if (!GetVersionEx((OSVERSIONINFO*)&osvi)) 
			{
				return 0;
			}
		}
		lua_pushnumber(pLuaState, osvi.dwMajorVersion);
		lua_pushnumber(pLuaState, osvi.dwMinorVersion);
		return 2;
	}
	return 0;
}

int LuaAPIUtil::IsWindows8Point1(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		OSVERSIONINFOEX osVersionInfo;
		::ZeroMemory(&osVersionInfo, sizeof(OSVERSIONINFOEX));
		osVersionInfo.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
		osVersionInfo.dwMajorVersion = 6;
		ULONGLONG maskCondition = ::VerSetConditionMask(0, VER_MAJORVERSION, VER_EQUAL);
		BOOL bMajorVer = ::VerifyVersionInfo(&osVersionInfo, VER_MAJORVERSION, maskCondition);
		osVersionInfo.dwMinorVersion = 3;
		BOOL bMinorVer = ::VerifyVersionInfo(&osVersionInfo, VER_MINORVERSION, maskCondition);
		lua_pushboolean(pLuaState, (int )(bMajorVer && bMinorVer));
		return 1;	

	}
	return 0;
}

int LuaAPIUtil::GetProcessElevation(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		BOOL bResult = FALSE;
		TOKEN_ELEVATION_TYPE ElevationType;
		BOOL bIsAdmin = FALSE;
		HANDLE hToken = NULL;
		DWORD dwSize;
		if (OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY,&hToken))
		{
			if (GetTokenInformation(hToken,TokenElevationType,&ElevationType,sizeof(TOKEN_ELEVATION_TYPE),&dwSize))
			{
				if (ElevationType == TokenElevationTypeLimited)
				{
					BYTE adminSID[SECURITY_MAX_SID_SIZE];
					dwSize = sizeof(adminSID);
					::CreateWellKnownSid(WinBuiltinAdministratorsSid,NULL,adminSID,&dwSize);

					HANDLE hUnfilterToken = NULL;

					GetTokenInformation(hToken,TokenLinkedToken,(LPVOID)&hUnfilterToken,sizeof(HANDLE),&dwSize);
					if (CheckTokenMembership(hUnfilterToken,&adminSID,&bIsAdmin))
						bResult = TRUE;
					CloseHandle(hUnfilterToken);
				}
				else
				{
					bIsAdmin = IsUserAnAdmin();
					bResult = TRUE;
				}
			}
			else
			{
				TSDEBUG4CXX(L"get token elevation type error = " <<::GetLastError());
			}
			CloseHandle(hToken);
		}
		else
		{
			TSDEBUG4CXX(L"open process token error = " <<::GetLastError());
		}
		if (bResult)
		{
			lua_pushboolean(pLuaState, bResult);
			lua_pushinteger(pLuaState, (int)ElevationType);
			lua_pushboolean(pLuaState, bIsAdmin);
			return 3;
		}
		else
		{
			lua_pushboolean(pLuaState, bResult);
			return 1;
		}

	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::PathCombine(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utfPath = luaL_checkstring(pLuaState,2);
	const char* utfFile = luaL_checkstring(pLuaState,3);

	std::string strFilePath;
	if (utfFile != NULL && utfPath != NULL)
	{
		CComBSTR bstrDir,bstrFile;

		LuaStringToCComBSTR(utfPath,bstrDir);
		LuaStringToCComBSTR(utfFile,bstrFile);

		TCHAR szBuffer[MAX_PATH] = {0};
		ZeroMemory(szBuffer, sizeof(szBuffer));
		::PathCombine(szBuffer, bstrDir.m_str, bstrFile.m_str);
		
		std::string strFilePath;
		BSTRToLuaString(szBuffer,strFilePath);
		lua_pushstring(pLuaState, strFilePath.c_str());
		return 1;

	}
	return 0;
}

int LuaAPIUtil::QueryRegValue(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8RootPath = luaL_checkstring(pLuaState,2);
	const char* utf8RegPath = luaL_checkstring(pLuaState,3);
	const char* utf8Key = luaL_checkstring(pLuaState,4);

	if(utf8RegPath == NULL || utf8RootPath == NULL || utf8Key == NULL)
	{
		lua_pushnil(pLuaState);
		return 1;
	}

	std::string result;
	DWORD dwType;
	DWORD dwValue;
	if (0 == QueryRegValueHelper(utf8RootPath,utf8RegPath,utf8Key,dwType, result, dwValue))
	{
		if (dwType == REG_DWORD)
		{
			lua_pushinteger(pLuaState, dwValue);
			return 1;
		}
		else if (dwType == REG_SZ || dwType == REG_EXPAND_SZ)
		{
			lua_pushstring(pLuaState,result.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::QueryRegValue64(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8RootPath = luaL_checkstring(pLuaState,2);
	const char* utf8RegPath = luaL_checkstring(pLuaState,3);
	const char* utf8Key = luaL_checkstring(pLuaState,4);

	if(utf8RegPath == NULL || utf8RootPath == NULL || utf8Key == NULL)
	{
		lua_pushnil(pLuaState);
		return 1;
	}

	std::string result;
	DWORD dwType;
	DWORD dwValue;
	if (0 == QueryRegValueHelper(utf8RootPath,utf8RegPath,utf8Key,dwType, result, dwValue,TRUE))
	{
		if (dwType == REG_DWORD)
		{
			lua_pushinteger(pLuaState, dwValue);
			return 1;
		}
		else if (dwType == REG_SZ || dwType == REG_EXPAND_SZ)
		{
			lua_pushstring(pLuaState,result.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

BOOL LuaAPIUtil::GetHKEY(const char* utf8Root, HKEY &hKey)
{
	BOOL bRet = TRUE;
	if(stricmp(utf8Root,"HKEY_CURRENT_USER") == 0)
	{
		hKey = HKEY_CURRENT_USER;
	}
	else if(stricmp(utf8Root,"HKEY_CLASSES_ROOT") == 0)
	{
		hKey = HKEY_CLASSES_ROOT;
	}
	else if(stricmp(utf8Root,"HKEY_LOCAL_MACHINE") == 0)
	{
		hKey = HKEY_LOCAL_MACHINE;
	}
	else if(stricmp(utf8Root,"HKEY_USERS") == 0)
	{
		hKey = HKEY_USERS;
	}
	else if(stricmp(utf8Root, "HKEY_CURRENT_CONFIG") == 0)
	{
		hKey = HKEY_CURRENT_CONFIG;
	}
	else
	{
		bRet = FALSE;
		hKey = (HKEY)(ULONG_PTR)((LONG)-1);
	}
	return bRet;
}

long LuaAPIUtil::QueryRegValueHelper(const char* utf8Root,const char* utf8RegPath,const char* utf8Key, DWORD &dwType, std::string& utf8Result, DWORD &dwValue,BOOL bWow64)
{
	//TODO
	HKEY root;
	if(utf8Root == NULL || utf8RegPath == NULL || utf8Key == NULL)
	{
		return 1;
	}
	if (!GetHKEY(utf8Root, root))
	{
		return 1;
	}

	CComBSTR bstrRegPath,bstrKey;

	LuaStringToCComBSTR(utf8RegPath,bstrRegPath);
	LuaStringToCComBSTR(utf8Key,bstrKey);

	CRegKey regKey;
	REGSAM samDesired = bWow64?(KEY_WOW64_64KEY|KEY_READ):KEY_READ;
	if (regKey.Open(root, bstrRegPath.m_str, samDesired) == ERROR_SUCCESS)
	{
		ULONG ulBytes = 0;
		if (ERROR_SUCCESS == regKey.QueryValue(bstrKey.m_str, &dwType, NULL, &ulBytes))
		{
			if (dwType == REG_DWORD)
			{
				regKey.QueryDWORDValue(bstrKey.m_str, dwValue);
				return 0;
			}
			else if (dwType == REG_SZ || dwType == REG_EXPAND_SZ)
			{
				wchar_t* pBuffer = (wchar_t *)new BYTE[ulBytes+2];
				memset(pBuffer, 0, ulBytes+2);
				regKey.QueryStringValue(bstrKey.m_str, pBuffer, &ulBytes);

				BSTRToLuaString(pBuffer,utf8Result);
				TSDEBUG4CXX(L"REG_EXPAND_SZ = " << utf8Result.c_str());
				delete [] pBuffer;
				pBuffer = NULL;
				return 0;
			}
		}
	}
	return 1;
}


int LuaAPIUtil::DeleteRegValue(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8Key = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8Key == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(DeleteRegValueHelper(utf8Root, utf8Key) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

int LuaAPIUtil::DeleteRegValue64(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8Key = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8Key == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(DeleteRegValueHelper(utf8Root, utf8Key,TRUE) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

long LuaAPIUtil::DeleteRegValueHelper(const char* utf8Root, const char* utf8Key,BOOL bWow64)
{
	HKEY root;
	if(utf8Root == NULL || utf8Key == NULL)
	{
		return 0;
	}
	if (!GetHKEY(utf8Root, root))
	{
		return 0;
	}

	CComBSTR bstrKey;
	LuaStringToCComBSTR(utf8Key,bstrKey);
	
	std::wstring wstrKey = bstrKey.m_str;
	std::wstring::size_type index = wstrKey.find_last_of(L"\\");
	if (index == std::wstring::npos)
	{
		return 0;
	}
	std::wstring  strsubkey,strvalue;
	strsubkey = wstrKey.substr(0,index);
	strvalue =  wstrKey.substr(index+1);
	
	REGSAM samDesired = bWow64?(KEY_WOW64_64KEY|KEY_WRITE):KEY_WRITE;
	HKEY hKey;
	if(RegOpenKeyEx(root,strsubkey.c_str(),0,samDesired,&hKey) == ERROR_SUCCESS)
	{
		RegDeleteValue(hKey, strvalue.c_str());
		RegCloseKey( hKey );
	}
	else
	{
		return 0;
	}
	return 1;
}

int LuaAPIUtil::DeleteRegKey(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8Key = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8Key == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(DeleteRegKeyHelper(utf8Root, utf8Key) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

int LuaAPIUtil::DeleteRegKey64(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8Key = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8Key == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(DeleteRegKeyHelper(utf8Root, utf8Key,TRUE) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

typedef LONG (WINAPI*_RegDeleteTree)(HKEY hKey, LPCWSTR lpSubKey);
typedef LONG (WINAPI*_RegDeleteKeyEx)(HKEY hKey, LPCWSTR lpSubKey,REGSAM samDesired, DWORD);

long LuaAPIUtil::DeleteRegKeyHelper(const char* utf8Root, const char* utf8SubKey,BOOL bWow64)
{
	HKEY root;
	if(utf8Root == NULL || utf8SubKey == NULL)
	{
		return 0;
	}
	if (!GetHKEY(utf8Root, root))
	{
		return 0;
	}
	CComBSTR bstrKey;
	LuaStringToCComBSTR(utf8SubKey,bstrKey);
	if (!bWow64)
	{
		if (ERROR_SUCCESS == SHDeleteKey(root, bstrKey.m_str))
		{
			return 1;
		}
	}
	else
	{
		HMODULE hModule = ::LoadLibrary(_T("Advapi32.dll"));
		if (NULL == hModule)
		{
			return 0;
		}
		_RegDeleteTree fnRegDeleteTree = (_RegDeleteTree)GetProcAddress(hModule, "RegDeleteTreeW");
		if (NULL == fnRegDeleteTree)
		{
			FreeLibrary(hModule);
			return 0;
		}
		HKEY hKey;
		if(RegOpenKeyEx(root,bstrKey.m_str,0, DELETE|KEY_ENUMERATE_SUB_KEYS| KEY_QUERY_VALUE|KEY_SET_VALUE|KEY_WOW64_64KEY,&hKey) == ERROR_SUCCESS)
		{
			LONG lRet = fnRegDeleteTree(hKey,NULL);
			RegCloseKey( hKey );
			if (ERROR_SUCCESS == lRet)
			{
				_RegDeleteKeyEx fnRegDeleteKeyEx = (_RegDeleteKeyEx)GetProcAddress(hModule, "RegDeleteKeyExW");
				if (NULL != fnRegDeleteKeyEx)
				{
					if (ERROR_SUCCESS == fnRegDeleteKeyEx(root,bstrKey.m_str,KEY_WOW64_64KEY,NULL))
					{
						FreeLibrary(hModule);
						return 1;
					}
				}
			}
		}
		FreeLibrary(hModule);
	}
	return 0;
}

int LuaAPIUtil::CreateRegKey(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8SubKey = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8SubKey == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(CreateRegKeyHelper(utf8Root, utf8SubKey) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}

int LuaAPIUtil::CreateRegKey64(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8SubKey = luaL_checkstring(pLuaState, 3);

		if(utf8Root == NULL || utf8SubKey == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		if(CreateRegKeyHelper(utf8Root, utf8SubKey,TRUE) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}

long LuaAPIUtil::CreateRegKeyHelper(const char* utf8Root, const char* utf8SubKey,BOOL bWow64)
{
	HKEY root;
	if(utf8Root == NULL || utf8SubKey == NULL)
	{
		return 0;
	}
	if (!GetHKEY(utf8Root, root))
	{
		return 0;
	}
	
	CComBSTR bstrKey;
	LuaStringToCComBSTR(utf8SubKey,bstrKey);
	HKEY hCreateKey;
	LONG lRet;
	if (!bWow64)
	{
		lRet = RegCreateKey(root, bstrKey.m_str, &hCreateKey);
	}
	else
	{
		lRet = RegCreateKeyEx(root, bstrKey.m_str, NULL,NULL,REG_OPTION_NON_VOLATILE,KEY_WOW64_64KEY|KEY_READ|KEY_WRITE,NULL,&hCreateKey,NULL);
	}
	if(lRet == ERROR_SUCCESS)
	{
		RegCloseKey(hCreateKey);
		return 1;
	}

	return 0;
}

int LuaAPIUtil::SetRegValue(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8SubKey = luaL_checkstring(pLuaState, 3);
		const char* utf8ValueName = luaL_checkstring(pLuaState, 4);

		if(utf8Root == NULL || utf8SubKey == NULL || utf8ValueName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		int type = lua_type(pLuaState, 5);
		if (type == LUA_TNUMBER)
		{
			DWORD dwValue = (DWORD)luaL_checkinteger(pLuaState, 5);
			if (SetRegValueHelper(utf8Root, utf8SubKey, utf8ValueName, REG_DWORD, NULL, dwValue) == 0)
			{
				lua_pushboolean(pLuaState, 1);
				return 1;
			}
		}
		else if (type == LUA_TSTRING)
		{
			const char* utf8Data = luaL_checkstring(pLuaState, 5);
			if (SetRegValueHelper(utf8Root, utf8SubKey, utf8ValueName, REG_SZ, utf8Data) == 0)
			{
				lua_pushboolean(pLuaState, 1);
				return 1;
			}
		}
		else
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}

int LuaAPIUtil::SetRegValue64(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Root = luaL_checkstring(pLuaState, 2);
		const char* utf8SubKey = luaL_checkstring(pLuaState, 3);
		const char* utf8ValueName = luaL_checkstring(pLuaState, 4);

		if(utf8Root == NULL || utf8SubKey == NULL || utf8ValueName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		int type = lua_type(pLuaState, 5);
		if (type == LUA_TNUMBER)
		{
			DWORD dwValue = (DWORD)luaL_checkinteger(pLuaState, 5);
			if (SetRegValueHelper(utf8Root, utf8SubKey, utf8ValueName, REG_DWORD, NULL, dwValue,TRUE) == 0)
			{
				lua_pushboolean(pLuaState, 1);
				return 1;
			}
		}
		else if (type == LUA_TSTRING)
		{
			const char* utf8Data = luaL_checkstring(pLuaState, 5);
			if (SetRegValueHelper(utf8Root, utf8SubKey, utf8ValueName, REG_SZ, utf8Data,0,TRUE) == 0)
			{
				lua_pushboolean(pLuaState, 1);
				return 1;
			}
		}
		else
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}

long LuaAPIUtil::SetRegValueHelper(const char* utf8Root, const char* utf8SubKey, const char* utf8ValueName,DWORD dwType, const char* utf8Data, DWORD dwValue,BOOL bWow64)
{
	HKEY root;
	if(utf8Root == NULL || utf8SubKey == NULL || utf8ValueName == NULL)
	{
		return 1;
	}
	if (!GetHKEY(utf8Root, root))
	{
		return 1;
	}

	CComBSTR bstrSubKey,bstrValueName;

	LuaStringToCComBSTR(utf8SubKey,bstrSubKey);
	LuaStringToCComBSTR(utf8ValueName,bstrValueName);

	CRegKey regKey;

	REGSAM samDesired = bWow64?(KEY_WOW64_64KEY|KEY_SET_VALUE):KEY_SET_VALUE;
	if (regKey.Open(root, bstrSubKey.m_str, samDesired) == ERROR_SUCCESS)
	{
		// 判断类型
		if (dwType == REG_DWORD)
		{
			if (ERROR_SUCCESS == regKey.SetDWORDValue(bstrValueName.m_str, dwValue))
			{
				return 0;
			}
		}
		else if (dwType == REG_SZ)
		{
			CComBSTR bstrData;
			LuaStringToCComBSTR(utf8Data,bstrData);
			if (ERROR_SUCCESS == regKey.SetStringValue(bstrValueName.m_str, bstrData.m_str))
			{
				return 0;
			}
		}
	}

	return 1;
}

int LuaAPIUtil::QueryRegKeyExists(lua_State* pLuaState)
{
	TSTRACEAUTO();
	BOOL bRet = FALSE;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8RootPath = luaL_checkstring(pLuaState,2);
		const char* utf8RegPath = luaL_checkstring(pLuaState,3);
		if (utf8RegPath != NULL || utf8RootPath != NULL)
		{
			HKEY root;
			if (GetHKEY(utf8RootPath, root))
			{
				CComBSTR bstrRegPath;
				LuaStringToCComBSTR(utf8RegPath,bstrRegPath);
				CRegKey regKey;
				if (regKey.Open(root, bstrRegPath.m_str, KEY_READ) == ERROR_SUCCESS)
				{
					bRet = TRUE;
				}
			}
		}
	}
	lua_pushboolean(pLuaState, bRet);
	return 1;
}

int LuaAPIUtil::EnumRegLeftSubKey(lua_State* pLuaState)
{
	TSTRACEAUTO();
	BOOL bRet = FALSE;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8RootPath = luaL_checkstring(pLuaState,2);
		const char* utf8RegPath = luaL_checkstring(pLuaState,3);
		if (utf8RegPath != NULL || utf8RootPath != NULL)
		{
			HKEY root;
			if (GetHKEY(utf8RootPath, root))
			{
				CComBSTR bstrRegPath;
				LuaStringToCComBSTR(utf8RegPath,bstrRegPath);
				CRegKey regKey;
				if (regKey.Open(root, bstrRegPath.m_str, KEY_READ) == ERROR_SUCCESS)
				{
					std::vector<std::string> vecStrKeys;
					LONG retCode = ERROR_SUCCESS;
					for (int i = 0; retCode == ERROR_SUCCESS; i++) 
					{
						DWORD dwLen = MAX_PATH;
						TCHAR achKey[MAX_PATH] = {0};
						retCode = regKey.EnumKey(i, achKey, &dwLen);
						if (retCode == ERROR_SUCCESS) 
						{
							std::string strKeyTmp;
							BSTRToLuaString(achKey,strKeyTmp);
							vecStrKeys.push_back(strKeyTmp);
						}
					}
					int nCount = vecStrKeys.size();
					lua_checkstack(pLuaState, nCount);
					lua_newtable(pLuaState);
					for(int i = 0; i < nCount;i++)
					{
						std::string strTemp = vecStrKeys.at(i);
						lua_pushstring(pLuaState,strTemp.c_str()); 
						lua_rawseti(pLuaState,-2,i+1); 
					}
					return 1;
				}
			}
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::EnumRegRightSubKey(lua_State* pLuaState)
{
	TSTRACEAUTO();
	BOOL bRet = FALSE;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8RootPath = luaL_checkstring(pLuaState,2);
		const char* utf8RegPath = luaL_checkstring(pLuaState,3);
		if (utf8RegPath != NULL || utf8RootPath != NULL)
		{
			HKEY root;
			if (GetHKEY(utf8RootPath, root))
			{
				CComBSTR bstrRegPath;
				LuaStringToCComBSTR(utf8RegPath,bstrRegPath);
				
				HKEY hKey;
				if(RegOpenKeyEx(root,bstrRegPath.m_str,0,KEY_READ,&hKey) == ERROR_SUCCESS)
				{
					std::vector<std::string> vecStrKeys;
					LONG retCode = ERROR_SUCCESS;
					for (int j = 0; retCode == ERROR_SUCCESS; j++) 
					{
						TCHAR achValue[MAX_PATH] = {0};
						DWORD dwLen = MAX_PATH;
						retCode = RegEnumValue(hKey, j, achValue, &dwLen, NULL, NULL, NULL, NULL);
						if (retCode == ERROR_SUCCESS)
						{
							std::string strKeyTmp;
							BSTRToLuaString(achValue,strKeyTmp);
							vecStrKeys.push_back(strKeyTmp);
						}
					}
					int nCount = vecStrKeys.size();
					lua_checkstack(pLuaState, nCount);
					lua_newtable(pLuaState);
					for(int i = 0; i < nCount;i++)
					{
						std::string strTemp = vecStrKeys.at(i);
						lua_pushstring(pLuaState,strTemp.c_str()); 
						lua_rawseti(pLuaState,-2,i+1); 
					}
					RegCloseKey(hKey);
					return 1;
				}
			}
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}


long LuaAPIUtil::OpenURLHelper(const char* utf8URL)
{
	//TODO
	CComBSTR bstrURL;
	if(utf8URL)
	{
		LuaStringToCComBSTR(utf8URL,bstrURL);
	}

	TCHAR explorer[1024] = {0};
	HKEY hKey;
	//vista和win7下的默认浏览器应该在这个目录下查找
	if ( RegOpenKeyEx(HKEY_CURRENT_USER, _T("Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice"), 0, KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS )
	{
		TCHAR szPath[1024] = {0};
		DWORD dCount=1024;
		if(RegQueryValueEx( hKey, _T("Progid"),NULL,NULL,(BYTE*)szPath, &dCount) == ERROR_SUCCESS )
		{
			RegCloseKey( hKey);
			::PathCombine(szPath, szPath, _T("shell\\open\\command"));

			HKEY hVlaueKey;
			//需要再次到HKEY_CLASSES_ROOT对应的目录查找程序的路径
			if (RegOpenKeyEx(HKEY_CLASSES_ROOT, szPath, 0, KEY_QUERY_VALUE, &hVlaueKey) == ERROR_SUCCESS)
			{
				DWORD dCount=1024;
				if(RegQueryValueEx(hVlaueKey, _T(""),NULL,NULL,(BYTE*)explorer, &dCount) == ERROR_SUCCESS )
				{
					RegCloseKey(hVlaueKey);
				}
			}
		}
	}
	//XP系统下则只在HKEY_CLASSES_ROOT\\http\\shell\\open\\command中标示当前默认浏览器
	else if ( RegOpenKeyEx(HKEY_CLASSES_ROOT, _T("http\\shell\\open\\command"), 0, KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS )
	{
		DWORD dCount=1024;
		if(RegQueryValueEx(hKey, _T(""),NULL,NULL,(BYTE*)explorer, &dCount) == ERROR_SUCCESS )
		{
			RegCloseKey(hKey);
		}
	}

	std::wstring  exp( explorer);
	std::wstring strParam;
	std::wstring::size_type pos = exp.find('"');
	if ( std::wstring::npos != pos )
	{
		exp = exp.substr( pos+1 );
	}
	pos = exp.find('"');      
	if( std::wstring::npos != pos)
	{  
		strParam = exp.substr(pos + 1);
		exp = exp.substr( 0, pos );
	}

	pos = strParam.find( L"%1" );
	if ( std::wstring::npos != pos )
	{
		strParam.replace( pos, 2, bstrURL.m_str);
	}
	else
	{
		strParam = bstrURL.m_str;
	}

	//对得到的程序路径值进行检查，判断该文件是否存在
	//有可能有些用户注册表对应的值为空的情形，文件路径不存在则使用IE打开链接
	if (PathFileExists(exp.c_str()))
	{
		if (ShellExecute(NULL,_T("open"), exp.c_str(), strParam.c_str(),NULL,SW_SHOWNORMAL) > (HINSTANCE) 32)//浏览成功?
		{
			return 0;
		}
	}

	std::wstring strTemp = L"\"";
	strTemp += bstrURL.m_str;
	strTemp += L"\"";

	//用IE 来尝试
	memset(explorer,0,sizeof(explorer));
	if (::SHGetSpecialFolderPath(::GetDesktopWindow(),explorer,CSIDL_PROGRAM_FILES,FALSE))
	{
		wcsncat(explorer,_T("\\Internet Explorer\\iexplore.exe"),64);
		if (ShellExecute(NULL,_T("open"), explorer, strTemp.c_str(),NULL,SW_SHOWNORMAL) > (HINSTANCE) 32)//浏览成功?	
		{
			return 1;
		}
	}
	return 0;
}

int LuaAPIUtil::OpenURL(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8URL = luaL_checkstring(pLuaState, 2);
	if (utf8URL == NULL)
		return 0;

	OpenURLHelper(utf8URL);
	return 0;
}

int LuaAPIUtil::OpenURLIE(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8URL = luaL_checkstring(pLuaState, 2);
	if (utf8URL == NULL)
		return 0;

	CComBSTR bstrURL;
	LuaStringToCComBSTR(utf8URL,bstrURL);

	TCHAR explorer[1024]= {0};
	std::wstring strTemp = L"\"";
	strTemp += bstrURL.m_str;
	strTemp += L"\"";
	if (::SHGetSpecialFolderPath(::GetDesktopWindow(),explorer,CSIDL_PROGRAM_FILES,FALSE))
	{
		wcsncat(explorer,_T("\\Internet Explorer\\iexplore.exe"),64);
		if (ShellExecute(NULL,_T("open"), explorer, strTemp.c_str(),NULL,SW_SHOWNORMAL) > (HINSTANCE) 32)//浏览成功?	
		{
			return 0;
		}
	}
	return 0;
}

BOOL LuaAPIUtil::IsFullScreenHelper()
{
	struct LocalUtil
	{
		// 取得窗口句柄所属进程ID
		static inline DWORD ProcessIdFromWindow(HWND hWnd)
		{
			DWORD dwPID = 0;
			if (hWnd)
			{
				::GetWindowThreadProcessId(hWnd, &dwPID);
			}

			return dwPID;
		}

		// 取得屏幕坐标所在用户界面进程ID
		static inline DWORD ProcessIdFromPoint(const POINT& pt)
		{
			return ProcessIdFromWindow(::WindowFromPoint(pt));
		}
	};

	// 取得系统Explorer进程ID
	// 和遍历进程快照相比，如果系统不幸存在多个Explorer进程，该方法总是取得Shell进程
	DWORD dwExplorerPID = LocalUtil::ProcessIdFromWindow(::GetShellWindow());

	// 判断当前用户前台进程是否为Explorer，如果是则直接返回
	if ((dwExplorerPID > 0) && (dwExplorerPID == LocalUtil::ProcessIdFromWindow(::GetForegroundWindow())))
	{
		return FALSE;
	}

	// 取得屏幕四个角所在窗口的进程ID
	RECT rcFullScreen = {0, 0, ::GetSystemMetrics(SM_CXSCREEN), ::GetSystemMetrics(SM_CYSCREEN)};
	if (!::IsRectEmpty(&rcFullScreen) && ::InflateRect(&rcFullScreen, -1, -1))
	{
		POINT ptLeftTop = {rcFullScreen.left, rcFullScreen.top};
		POINT ptLeftBottom = {rcFullScreen.left, rcFullScreen.bottom};
		POINT ptRightTop = {rcFullScreen.right, rcFullScreen.top};
		POINT ptRightBottom = {rcFullScreen.right, rcFullScreen.bottom};
		DWORD dwLeftTopPID = LocalUtil::ProcessIdFromPoint(ptLeftTop);
		DWORD dwLeftBottomPID = LocalUtil::ProcessIdFromPoint(ptLeftBottom);
		DWORD dwRightTopPID = LocalUtil::ProcessIdFromPoint(ptRightTop);
		DWORD dwRightBottomPID = LocalUtil::ProcessIdFromPoint(ptRightBottom);
		if ((dwLeftTopPID > 0) && (dwLeftTopPID != dwExplorerPID) && /*过滤掉Shell进程*/
			(dwLeftTopPID == dwLeftBottomPID) && (dwLeftBottomPID == dwRightTopPID) && (dwRightTopPID == dwRightBottomPID))
		{
			return TRUE;
		}
	}

	return FALSE;
	// add end
}

int LuaAPIUtil::IsNowFullScreen(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	int iValue = 0;
	if (IsFullScreenHelper())
	{
		iValue = 1;
	}

	lua_pushboolean(pLuaState, iValue);
	return 1;
}

int LuaAPIUtil::GetCursorWndHandle(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	POINT p = {0};
	::GetCursorPos(&p);
	HWND hWnd = ::WindowFromPoint(p);
	lua_pushinteger(pLuaState, (lua_Integer)hWnd);
	return 1;
}

int LuaAPIUtil::GetFocusWnd(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	HWND hWndFocus = ::GetFocus();
	lua_pushinteger(pLuaState, (int)hWndFocus);
	return 1;
}

int LuaAPIUtil::FGetKeyState(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	LONG nVirtKey = (LONG)lua_tointeger(pLuaState,3);
	LONG state =  (LONG)::GetKeyState(nVirtKey);
	lua_pushinteger(pLuaState,state);
	return 1;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT ps;
	HDC hdc;

	switch (message)
	{
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		EndPaint(hWnd, &ps);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

int LuaAPIUtil::FCreateParentWnd(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		WNDCLASSEX wcex;
		wcex.cbSize = sizeof(WNDCLASSEX);

		wcex.style			= CS_HREDRAW | CS_VREDRAW;
		wcex.lpfnWndProc	= WndProc;
		wcex.cbClsExtra		= 0;
		wcex.cbWndExtra		= 0;
		wcex.hInstance		= NULL;
		wcex.hIcon			= NULL;//LoadIcon(hInstance, MAKEINTRESOURCE(IDI_IEXPLORE));
		wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
		wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW+1);
		wcex.lpszMenuName	= NULL;//MAKEINTRESOURCE(IDC_IEXPLORE);
		wcex.lpszClassName	= _T(" - Windows Internet Explorer");
		wcex.hIconSm		= NULL;//LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));
		RegisterClassEx(&wcex);
		DWORD dwError1 = ::GetLastError();
		HWND hWnd = CreateWindow( _T(" - Windows Internet Explorer"), _T(" - Windows Internet Explorer"), WS_OVERLAPPEDWINDOW|WS_SYSMENU,CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, NULL, NULL);
		DWORD dwError = ::GetLastError();
		if (hWnd)
		{
			ShowWindow(hWnd, SW_SHOW);
			UpdateWindow(hWnd);
			lua_pushlightuserdata(pLuaState, hWnd);
			return 1;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetForegroundProcessInfo(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hwndForeground = ::GetForegroundWindow();
		DWORD dwPID;
		GetWindowThreadProcessId(hwndForeground, &dwPID);
		HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, dwPID);
		TCHAR buf[MAX_PATH] = {0};
		GetModuleFileNameEx(hProcess, NULL, buf, MAX_PATH);
		std::string strUtf8;
		BSTRToLuaString(buf,strUtf8);
		lua_pushlightuserdata(pLuaState, hwndForeground);
		lua_pushstring(pLuaState, strUtf8.c_str());
		return 2;
	}

	lua_pushnil(pLuaState);
	return 1;
}

long LuaAPIUtil::ShellExecHelper(HWND hWnd, const char* lpOperation, const char* lpFile, const char* lpParameters, const char* lpDirectory, const char* lpShowCmd, int iShowCmd)
{
	CComBSTR bstrOperation;
	CComBSTR bstrFile;
	CComBSTR bstrParameters;
	CComBSTR bstrDir;
	CComBSTR bstrCmd;

	if ( lpOperation )
	{
		LuaStringToCComBSTR(lpOperation,bstrOperation);
	}
	if ( lpFile )
	{
		LuaStringToCComBSTR(lpFile,bstrFile);
	}
	if ( lpParameters )
	{
		LuaStringToCComBSTR(lpParameters,bstrParameters);
	}
	if ( lpDirectory )
	{
		LuaStringToCComBSTR(lpDirectory,bstrDir);
	}
	if ( lpShowCmd )
	{
		LuaStringToCComBSTR(lpShowCmd,bstrCmd);
	}
	std::wstring strCmd = bstrCmd.m_str;
	INT nShowCmd = 0;
	if (iShowCmd != -1)
	{
		nShowCmd = iShowCmd;
	}
	else if ( strCmd == L"SW_HIDE" )
	{
		nShowCmd = SW_HIDE;
	}
	else if ( strCmd == L"SW_MAXIMIZE" )
	{
		nShowCmd = SW_MAXIMIZE;
	}
	else if ( strCmd == L"SW_MINIMIZE" )
	{
		nShowCmd = SW_MINIMIZE;
	}
	else if ( strCmd == L"SW_RESTORE" )
	{
		nShowCmd = SW_RESTORE;
	}
	else if ( strCmd == L"SW_SHOW" )
	{
		nShowCmd = SW_SHOW;
	}
	else if ( strCmd == L"SW_SHOWDEFAULT" )
	{
		nShowCmd = SW_SHOWDEFAULT;
	}
	else if ( strCmd == L"SW_SHOWMAXIMIZED" )
	{
		nShowCmd = SW_SHOWMAXIMIZED;
	}
	else if ( strCmd == L"SW_SHOWMINIMIZED" )
	{
		nShowCmd = SW_SHOWMINIMIZED;
	}
	else if ( strCmd == L"SW_SHOWMINNOACTIVE" )
	{
		nShowCmd = SW_SHOWMINNOACTIVE;
	}
	else if ( strCmd == L"SW_SHOWNA" )
	{
		nShowCmd = SW_SHOWNA;
	}
	else if ( strCmd == L"SW_SHOWNOACTIVATE" )
	{
		nShowCmd = SW_SHOWNOACTIVATE;
	}
	else if ( strCmd == L"SW_SHOWNORMAL" )
	{
		nShowCmd = SW_SHOWNORMAL;
	}

	if ( (HINSTANCE) 32 < ::ShellExecute( hWnd, bstrOperation.m_str, bstrFile.m_str, bstrParameters.m_str, bstrDir.m_str, nShowCmd ) )
	{
		return 0;
	}
	return 1;
}

int LuaAPIUtil::ShellExecuteEX(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	//HWND hWnd = (HWND)lua_tointeger(pLuaState,2);
	HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
	const char* lpOperation = luaL_checkstring(pLuaState, 3);
	const char* lpFile = luaL_checkstring(pLuaState, 4);
	const char* lpParameters = luaL_checkstring(pLuaState, 5);
	const char* lpDir = luaL_checkstring(pLuaState, 6);
	int luaType = lua_type(pLuaState, 7);
	if (luaType == LUA_TSTRING)
	{
		const char* lpCmd = luaL_checkstring(pLuaState, 7);
		lua_pushinteger(pLuaState, ShellExecHelper(hWnd, lpOperation, lpFile, lpParameters, lpDir, lpCmd, -1));
	}
	else if (luaType == LUA_TNUMBER)
	{
		int iCmd = (int)luaL_checkinteger(pLuaState, 7);
		lua_pushinteger(pLuaState, ShellExecHelper(hWnd, lpOperation, lpFile, lpParameters, lpDir, NULL, iCmd));
	}
	
	return 1;
}

int LuaAPIUtil::QueryProcessExists(lua_State* pLuaState)
{
	int iValue = 0;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8ProcessName = luaL_checkstring(pLuaState, 2);		
		if(utf8ProcessName != NULL)
		{
			CComBSTR bstrProcessName;
			LuaStringToCComBSTR(utf8ProcessName,bstrProcessName);
			HANDLE hSnap = ::CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
			if (hSnap != INVALID_HANDLE_VALUE)
			{
				PROCESSENTRY32 pe;
				pe.dwSize = sizeof(PROCESSENTRY32);
				BOOL bResult = ::Process32First(hSnap, &pe);
				while (bResult)
				{
					if(_tcsicmp(pe.szExeFile, bstrProcessName.m_str) == 0)
					{
						iValue = 1;
						break;
					}
					bResult = ::Process32Next(hSnap, &pe);
				}
				::CloseHandle(hSnap);
			}
		}
	}
	lua_pushboolean(pLuaState, iValue);
	return 1;
}

long LuaAPIUtil::QueryFileExistsHelper(const char*utf8FilePath)
{
	CComBSTR bstrFilePath;
	if(utf8FilePath)
	{
		LuaStringToCComBSTR(utf8FilePath,bstrFilePath);
	}

	if(PathFileExists(bstrFilePath.m_str))
	{
		return 1;
	}

	return 0;
}

int LuaAPIUtil::QueryFileExists(lua_State* pLuaState)
{
	int iValue = 0;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8FilePath = luaL_checkstring(pLuaState, 2);		
		if(utf8FilePath != NULL)
		{
			if (QueryFileExistsHelper(utf8FilePath) == 1)
			{
				iValue = 1;
			}
		}
	}
	lua_pushboolean(pLuaState, iValue);
	return 1;
}

int LuaAPIUtil::Rename(lua_State* pLuaState)
{
	int iValue = 0;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8OldName = luaL_checkstring(pLuaState, 2);
		if(utf8OldName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		const char* utf8NewName = luaL_checkstring(pLuaState, 3);
		if(utf8NewName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		CComBSTR bstrOldName, bstrNewName;
		LuaStringToCComBSTR(utf8OldName,bstrOldName);
		LuaStringToCComBSTR(utf8NewName,bstrNewName);

		if (0 == _wrename(bstrOldName.m_str, bstrNewName.m_str))
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, iValue);
	return 1;
}

int LuaAPIUtil::CreateDir(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil == NULL)
	{
		return 0;
	}
	const char* utf8DirPath = luaL_checkstring(pLuaState, 2);
	int iValue = 0;
	if(utf8DirPath != NULL)
	{
		CComBSTR bstrDirPath;
		LuaStringToCComBSTR(utf8DirPath,bstrDirPath);

		if (ERROR_SUCCESS == SHCreateDirectoryEx(NULL, bstrDirPath.m_str, NULL))
		{
			iValue = 1;
		}
	}	
	lua_pushboolean(pLuaState, iValue);
	return 1;
}

long LuaAPIUtil::CopyPathFileHelper(const char* utf8ExistingFileName, const char* utf8NewFileName, BOOL bFailedIfExists)
{
	CComBSTR bstrExistingFileName,bstrNewFileName;
	
	LuaStringToCComBSTR(utf8ExistingFileName,bstrExistingFileName);
	LuaStringToCComBSTR(utf8NewFileName,bstrNewFileName);

	if(CopyFile(bstrExistingFileName.m_str, bstrNewFileName.m_str, bFailedIfExists))
	{
		return 1;
	}

	return 0;
}

int LuaAPIUtil::CopyPathFile(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8ExistingFileName = luaL_checkstring(pLuaState, 2);
		if(utf8ExistingFileName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		const char* utf8NewFileName = luaL_checkstring(pLuaState, 3);
		if(utf8NewFileName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}

		int nFailedIfExists = lua_toboolean(pLuaState, 4);
		BOOL bFailedIfExists = (nFailedIfExists == 0) ? FALSE : TRUE;

		if(CopyPathFileHelper(utf8ExistingFileName, utf8NewFileName, bFailedIfExists) == 1)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}

int LuaAPIUtil::DeletePathFile(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8FileName = luaL_checkstring(pLuaState, 2);
		if (utf8FileName == NULL)
		{
			lua_pushboolean(pLuaState, 0);
			return 1;
		}
		CComBSTR bstrFileName;
		LuaStringToCComBSTR(utf8FileName,bstrFileName);

		if (DeleteFile(bstrFileName.m_str))
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}
	}
	lua_pushboolean(pLuaState, 0);
	return 1;
}

#ifndef DEFINE_KNOWN_FOLDER
#define DEFINE_KNOWN_FOLDER(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
	EXTERN_C const GUID DECLSPEC_SELECTANY name \
	= { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }
#endif


EXTERN_C const GUID DECLSPEC_SELECTANY FOLDERID_UserPin \
= { 0x9E3995AB, 0x1F9C, 0x4F13, { 0xB8, 0x27,  0x48,  0xB2,  0x4B,  0x6C,  0x71,  0x74 } };

typedef HRESULT (__stdcall *PSHGetKnownFolderPath)(  const  GUID& rfid, DWORD dwFlags, HANDLE hToken, PWSTR* pszPath);

int LuaAPIUtil::GetUserPinPath(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HMODULE hModule = LoadLibrary( _T("shell32.dll") );
		if ( hModule == NULL )
		{
			return 0;
		}
		PSHGetKnownFolderPath SHGetKnownFolderPath = (PSHGetKnownFolderPath)GetProcAddress( hModule, "SHGetKnownFolderPath" );
		if (NULL != SHGetKnownFolderPath)
		{
			PWSTR pszPath = NULL;
			HRESULT hr = SHGetKnownFolderPath(FOLDERID_UserPin, 0, NULL, &pszPath );
			if (SUCCEEDED(hr))
			{
				TSDEBUG4CXX("UserPin Path: " << pszPath);
				std::string strUserPinPath;
				
				BSTRToLuaString(pszPath,strUserPinPath);
				::CoTaskMemFree(pszPath);
				lua_pushstring(pLuaState, strUserPinPath.c_str());
				FreeLibrary(hModule);
				return 1;
			}
		}
		FreeLibrary(hModule);
	}
	return 0;
}


int LuaAPIUtil::ReadFileToString(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		// param1: file path
		std::string strSrcFile = luaL_checkstring(pLuaState, 2);

		CComBSTR bstrSrcFile;
		LuaStringToCComBSTR(strSrcFile.c_str(),bstrSrcFile);
		
		// param2: support max size
		DWORD file_max_size = (DWORD)lua_tointeger(pLuaState, 3);
		file_max_size = (file_max_size==0?1024*1024:file_max_size);

		if ( bstrSrcFile.m_str)
		{
			std::string file_data;
			DWORD dwByteRead = 0;
			tipWndDatFileUtility.ReadFileToString(bstrSrcFile.m_str, file_data, dwByteRead, file_max_size);
			if ( !file_data.empty() )
			{
				lua_pushlstring(pLuaState, file_data.c_str(), file_data.size());
				return 1;
			}
		}
	}
	return 0;
}

int LuaAPIUtil::WriteStringToFile(lua_State* pLuaState)
{
	bool ret = false;

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		// param1: file path
		std::string strSrcFile = luaL_checkstring(pLuaState, 2);        
		CComBSTR bstrSrcFile;
		LuaStringToCComBSTR(strSrcFile.c_str(),bstrSrcFile);

		// param2: file_data
		size_t len = 0;
		const char* file_data_ptr = lua_tolstring(pLuaState,3,&len);

		if ( file_data_ptr )
		{
			ret = tipWndDatFileUtility.WriteStringToFile(bstrSrcFile.m_str, file_data_ptr, len);
		}
	}
	lua_pushboolean(pLuaState,ret);
	return 1;
}

int LuaAPIUtil::FormatCrtTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		__time64_t tTime = (__time64_t)lua_tonumber(pLuaState, 2);
		LONG nYear = 0,   nMonth = 0,   nDay = 0,   nHour = 0,   nMinute = 0,   nSecond = 0;
		tm* pTm = _localtime64(&tTime);
		if (pTm == NULL)
		{
			return 0;
		}
		nYear = pTm->tm_year + 1900;
		nMonth = pTm->tm_mon + 1;
		nDay = pTm->tm_mday;
		nHour = pTm->tm_hour;
		nMinute = pTm->tm_min;
		nSecond = pTm->tm_sec;
		lua_pushnumber(pLuaState, nYear);
		lua_pushnumber(pLuaState, nMonth);
		lua_pushnumber(pLuaState, nDay);
		lua_pushnumber(pLuaState, nHour);
		lua_pushnumber(pLuaState, nMinute);
		lua_pushnumber(pLuaState, nSecond);
		return 6;
	}
	return 0;
}

int LuaAPIUtil::GetLocalDateTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int year, month, day, hour, minute, second;
		SYSTEMTIME systemTime;
		::GetLocalTime(&systemTime);
		year = systemTime.wYear;
		month = systemTime.wMonth;
		day = systemTime.wDay;
		hour = systemTime.wHour;
		minute = systemTime.wMinute;
		second = systemTime.wSecond;
		lua_pushinteger(pLuaState, year);
		lua_pushinteger(pLuaState, month);
		lua_pushinteger(pLuaState, day);
		lua_pushinteger(pLuaState, hour);
		lua_pushinteger(pLuaState, minute);
		lua_pushinteger(pLuaState, second);
		return 6;
	}
	return 0;
}

int LuaAPIUtil::GetCurrentUTCTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		__time64_t nCurrentTime = 0;
		_time64(&nCurrentTime);
		lua_pushnumber(pLuaState, (lua_Number)nCurrentTime);
	}
	else
	{
		lua_pushnumber(pLuaState, 0);
	}
	return 1;
}

int LuaAPIUtil::DateTime2Seconds(lua_State* pLuaState)
{	
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		int nYear = 0, nMonth = 0, nDate = 0, nHour = 0, nMinute = 0, nSeconds = 0;
		nYear = (int)lua_tointeger(pLuaState, 2);
		nMonth = (int)lua_tointeger(pLuaState, 3);
		nDate = (int)lua_tointeger(pLuaState, 4);
		nHour = (int)lua_tointeger(pLuaState, 5);
		nMinute = (int)lua_tointeger(pLuaState, 6);
		nSeconds = (int)lua_tointeger(pLuaState, 7);
		__time64_t fileTime = 0;
		tm time;
		time.tm_year = nYear - 1900;
		time.tm_mon = nMonth - 1;
		time.tm_mday = nDate;
		time.tm_hour = nHour;
		time.tm_min = nMinute;
		time.tm_sec = nSeconds;
		fileTime = _mktime64(&time);
		lua_pushnumber(pLuaState, (lua_Number)fileTime);
	}
	else
	{
		lua_pushnumber(pLuaState, 0);
	}
	return 1;
}

int LuaAPIUtil::Seconds2DateTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		__time64_t tTime = (__time64_t)lua_tonumber(pLuaState, 2);
		long nYear = 0,   nMonth = 0,   nDay = 0,   nHour = 0,   nMinute = 0,   nSecond = 0, nWeekDate = 0;
		const tm* pTime = _gmtime64(&tTime);
		nYear = pTime->tm_year + 1900;
		nMonth = pTime->tm_mon + 1;
		nDay = pTime->tm_mday;
		nHour = pTime->tm_hour;
		nMinute = pTime->tm_min;
		nSecond = pTime->tm_sec;
		nWeekDate = pTime->tm_wday + 1;

		lua_pushnumber(pLuaState, nYear);
		lua_pushnumber(pLuaState, nMonth);
		lua_pushnumber(pLuaState, nDay);
		lua_pushnumber(pLuaState, nHour);
		lua_pushnumber(pLuaState, nMinute);
		lua_pushnumber(pLuaState, nSecond);
		lua_pushnumber(pLuaState, nWeekDate);
		return 7;
	}
	return 0;
}

int LuaAPIUtil::FileTime2LocalTime(lua_State *pLuaState)
{
	TSTRACEAUTO();
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		DWORD dwLowTime = (DWORD)lua_tonumber(pLuaState, 2);
		DWORD dwHighTime = (DWORD)lua_tonumber(pLuaState, 3);
		FILETIME ft;
		ft.dwLowDateTime = dwLowTime;
		ft.dwHighDateTime = dwHighTime;
		SYSTEMTIME stUTC, stLocal;
		FileTimeToSystemTime(&ft, &stUTC);
		SystemTimeToTzSpecificLocalTime(NULL, &stUTC, &stLocal);

		lua_pushnumber(pLuaState, stLocal.wYear);
		lua_pushnumber(pLuaState, stLocal.wMonth);
		lua_pushnumber(pLuaState, stLocal.wDay);
		lua_pushnumber(pLuaState, stLocal.wHour);
		lua_pushnumber(pLuaState, stLocal.wMinute);
		lua_pushnumber(pLuaState, stLocal.wSecond);
		lua_pushnumber(pLuaState, stLocal.wDayOfWeek);
		return 7;
	}
	return 0;
}

#include <WinInet.h>
#pragma comment(lib, "WinInet.lib")
int LuaAPIUtil::InternetTimeToUTCTime(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		if (lua_isstring(pLuaState, 2))
		{
			const char *szInetTime = luaL_checkstring(pLuaState, 2);
			if (szInetTime)
			{
				CComBSTR bstrInetTimeW;
				LuaStringToCComBSTR(szInetTime,bstrInetTimeW);


				::SYSTEMTIME stSince1601;
				ULONGLONG ftSince1601 = 0;

				::SYSTEMTIME st1970 = {0};
				st1970.wYear = 1970;
				st1970.wMonth = 1;
				st1970.wDay = 1;
				st1970.wHour = 0;
				st1970.wMinute = 0;
				st1970.wSecond = 0;
				st1970.wMilliseconds = 0;
				ULONGLONG ft1970 = 0;

				if (   ::InternetTimeToSystemTimeW(bstrInetTimeW.m_str, &stSince1601, 0)
					&& ::SystemTimeToFileTime(&stSince1601, (FILETIME *)&ftSince1601)
					&& ::SystemTimeToFileTime(&st1970, (FILETIME *)&ft1970))
				{
					LONGLONG ftSince1970 = ftSince1601 - ft1970;
					lua_pushnumber(pLuaState, (lua_Number)(ftSince1970 / 10000000));
					return 1;
				}
			}
		}
	}

	return 0;
}


//互斥量函数
int LuaAPIUtil::CreateNamedMutex(lua_State* pLuaState)
{
	HANDLE hMutex = NULL;
	BOOL bRet = FALSE;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8MutexName = luaL_checkstring(pLuaState, 2);
		CComBSTR bstrMutexName;
		LuaStringToCComBSTR(utf8MutexName,bstrMutexName);

		hMutex = CreateMutex(NULL, FALSE, bstrMutexName.m_str);
		DWORD dwMutexExist = GetLastError();
		if (dwMutexExist == ERROR_ALREADY_EXISTS)
		{
			ReleaseMutex(hMutex);
			CloseHandle(hMutex);
			hMutex = NULL;
		}
		if (hMutex != NULL)
		{
			bRet = TRUE;
		}
	}
	lua_pushboolean(pLuaState, bRet);
	lua_pushlightuserdata(pLuaState, hMutex);
	return 2;
}

int LuaAPIUtil::CloseNamedMutex(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HANDLE hMutex = (HANDLE)lua_touserdata(pLuaState, 2);
		if (hMutex != NULL)
		{
			ReleaseMutex(hMutex);
			CloseHandle(hMutex);
			hMutex = NULL;
		}
	}
	return 0;
}


int LuaAPIUtil::PostWndMessage(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8ClassName = lua_tostring(pLuaState, 2);
		const char* utf8WindowName = lua_tostring(pLuaState, 3);
		DWORD dwMsg = (DWORD)lua_tointeger(pLuaState, 4);
		DWORD dwWParam = (DWORD)lua_tointeger(pLuaState, 5);
		DWORD dwLParam = (DWORD)lua_tointeger(pLuaState, 6);
		HWND hWnd = FindWindowA(utf8ClassName, utf8WindowName);
		while (hWnd != NULL)
		{
			PostMessage(hWnd, dwMsg, (WPARAM)dwWParam, (LPARAM)dwLParam);
			hWnd = FindWindowExA(NULL, hWnd, utf8ClassName, utf8WindowName);
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::CreateShortCutLinkEx(lua_State* pLuaState)
{
	bool success = false;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8Name = lua_tostring(pLuaState, 2);
		const char* utf8Exepath= lua_tostring(pLuaState, 3);
		const char* utf8despath= lua_tostring(pLuaState, 4);
		const char* utf8Iconpath = lua_tostring(pLuaState, 5);
		const char* utf8Argument = lua_tostring(pLuaState, 6);
		const char* utf8Description = lua_tostring(pLuaState, 7);
			
		CComBSTR bstrname;
		CComBSTR bstrexepath;
		CComBSTR bstrdespath;
		CComBSTR bstriconpath;
		CComBSTR bstrargument;
		CComBSTR bstrdescription;

		if (utf8Name != NULL)
		{
			LuaStringToCComBSTR(utf8Name,bstrname);
		}
		if (utf8Exepath != NULL)
		{
			LuaStringToCComBSTR(utf8Exepath,bstrexepath);
		}
		if (utf8despath != NULL)
		{
			LuaStringToCComBSTR(utf8despath,bstrdespath);
		}
		if (utf8Iconpath != NULL)
		{
			LuaStringToCComBSTR(utf8Iconpath,bstriconpath);
		}
		if (utf8Argument != NULL)
		{
			LuaStringToCComBSTR(utf8Argument,bstrargument);
		}
		if (utf8Description != NULL)
		{
			LuaStringToCComBSTR(utf8Description,bstrdescription);
		}
		success = CreateShortCutLinkHelper(bstrname.m_str, bstrexepath.m_str, LuaAPIUtil::CUSTOMPATH
			, bstriconpath.m_str 
			, bstrargument.m_str
			, bstrdescription.m_str
			, bstrdespath.m_str);
	}
	lua_pushboolean(pLuaState, success);
	return 1;
}

bool LuaAPIUtil::CreateShortCutLinkHelper(
	const TCHAR* name, 
	const TCHAR* exepath, 
	ShortCutPosition position, 
	const TCHAR* iconpath, 
	const TCHAR* argument, 
	const TCHAR* description,
	const TCHAR* despath)
{
	ATLASSERT(name != NULL && exepath != NULL);
	HRESULT hres;
	IShellLink *psl = NULL;
	IPersistFile *pPf = NULL;
	TCHAR buf[256] = {0};
	LPITEMIDLIST pidl;

	hres = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLink, (LPVOID*)&psl);
	if(FAILED(hres))
	{
		goto cleanup;
	}
	hres = psl->QueryInterface(IID_IPersistFile, (LPVOID*)&pPf);
	if(FAILED(hres))
	{
		goto cleanup;
	}
	hres = psl->SetPath(exepath);
	if(FAILED(hres))
	{
		goto cleanup;
	}
	if (argument != NULL)
	{
		hres = psl->SetArguments(argument);
		if(FAILED(hres))
		{
			goto cleanup;
		}
	}
	if (description != NULL)
	{
		hres = psl->SetDescription(description);
		if(FAILED(hres))
		{
			goto cleanup;
		}
	}
	if (iconpath != NULL)
	{
		hres = psl->SetIconLocation(iconpath, 0);
		if(FAILED(hres))
		{
			goto cleanup;
		}
	}

	switch (position)
	{
	case DESKTOP:
		SHGetSpecialFolderLocation(NULL, CSIDL_DESKTOP, &pidl);
		SHGetPathFromIDList(pidl, buf);
		lstrcat(buf, _T("\\"));
		break;
	case QUICKLAUNCH:
		SHGetSpecialFolderLocation(NULL, CSIDL_APPDATA, &pidl);
		SHGetPathFromIDList(pidl, buf);
		lstrcat(buf, _T("\\Microsoft\\Internet Explorer\\Quick Launch\\"));
		break;
	case COMMONDESKTOP:
		SHGetSpecialFolderLocation(NULL, CSIDL_COMMON_DESKTOPDIRECTORY, &pidl);
		SHGetPathFromIDList(pidl, buf);
		lstrcat(buf, _T("\\"));
		break;
	case CUSTOMPATH:
		lstrcpy(buf, despath);
		break;
	}
	PathAppend(buf, name);
	lstrcat(buf, _T(".lnk"));
	hres = pPf->Save(buf, TRUE);

cleanup:
	if(pPf != NULL)
	{
		pPf->Release();
	}
	if(psl != NULL)
	{
		psl->Release();
	}
	return SUCCEEDED(hres);
}

int LuaAPIUtil::GetSysWorkArea(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		if (hWnd && IsWindow(hWnd))
		{
			HMONITOR hMonitor = MonitorFromWindow(hWnd, MONITOR_DEFAULTTONEAREST);
			if (hMonitor)
			{
				MONITORINFO mi = {sizeof(MONITORINFO)};
				if (GetMonitorInfo(hMonitor, &mi))
				{
					lua_pushinteger(pLuaState, mi.rcWork.left);
					lua_pushinteger(pLuaState, mi.rcWork.top);
					lua_pushinteger(pLuaState, mi.rcWork.right);
					lua_pushinteger(pLuaState, mi.rcWork.bottom);
					return 4;
				}
				else
				{
					TSERROR(_T("GetMonitorInfo failed. hMonitor = 0x%p"), hMonitor);
				}
			}
			else
			{
				TSERROR(_T("MonitorFromWindow failed. hWnd = 0x%p"), hWnd);
			}
		}
		else
		{
			RECT rect;
			if (SystemParametersInfo(SPI_GETWORKAREA, 0, &rect, 0))
			{
				lua_pushinteger(pLuaState, rect.left);
				lua_pushinteger(pLuaState, rect.top);
				lua_pushinteger(pLuaState, rect.right);
				lua_pushinteger(pLuaState, rect.bottom);
				return 4;
			}
			else
			{
				TSERROR(_T("SystemParametersInfo failed."));
			}
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetCurrentScreenRect(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		if (hWnd && IsWindow(hWnd))
		{
			RECT rc;
			GetWindowRect(hWnd, &rc);
			HMONITOR hMonitor = MonitorFromRect(&rc, MONITOR_DEFAULTTONEAREST);
			if (hMonitor)
			{
				MONITORINFO mi = {sizeof(MONITORINFO)};
				if (GetMonitorInfo(hMonitor, &mi))
				{
					lua_pushinteger(pLuaState, mi.rcWork.left);
					lua_pushinteger(pLuaState, mi.rcWork.top);
					lua_pushinteger(pLuaState, mi.rcWork.right);
					lua_pushinteger(pLuaState, mi.rcWork.bottom);
					return 4;
				}
				else
				{
					TSERROR(_T("GetMonitorInfo failed. hMonitor = 0x%p"), hMonitor);
				}
			}
		}
		else
		{
			lua_pushinteger(pLuaState, 0);
			lua_pushinteger(pLuaState, 0);
			lua_pushinteger(pLuaState, GetSystemMetrics(SM_CXSCREEN));
			lua_pushinteger(pLuaState, GetSystemMetrics(SM_CYSCREEN));
			return 4;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::FGetProcessIdFromHandle(lua_State* pLuaState)
{
	DWORD dwPID = 0;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HANDLE hProcess = (HANDLE)lua_touserdata(pLuaState, 2);
		dwPID = GetProcessId(hProcess);
	}
	lua_pushnumber(pLuaState, dwPID);
	return 1;
}

int LuaAPIUtil::FGetCurrentProcessId(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		DWORD dwPID = GetCurrentProcessId();
		lua_pushnumber(pLuaState, dwPID);
		return 1;
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::FGetDesktopWndHandle(lua_State *pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hwndDesktop = ::GetDesktopWindow();
		TSDEBUG(_T("GetDesktopWindow() ret 0x%p"), hwndDesktop);
		if (hwndDesktop)
		{
			lua_pushlightuserdata(pLuaState, hwndDesktop);
			return 1;
		}
	}

	return 0;
}

int LuaAPIUtil::FSetWndPos(lua_State *pLuaState)
{
	BOOL bSuc = FALSE;

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hwnd = (HWND) lua_touserdata(pLuaState, 2);

		HWND hwndInsertAfter = NULL;
		if (lua_isnumber(pLuaState, 3))
		{
			hwndInsertAfter = (HWND) lua_tointeger(pLuaState, 3);
		}
		else if (lua_isuserdata(pLuaState, 3))
		{
			hwndInsertAfter = (HWND) lua_touserdata(pLuaState, 3);
		}

		int x = (int) lua_tointeger(pLuaState, 4);
		int y = (int) lua_tointeger(pLuaState, 5);
		int cx = (int) lua_tointeger(pLuaState, 6);
		int cy = (int) lua_tointeger(pLuaState, 7);
		UINT uFlags = (UINT) lua_tointeger(pLuaState, 8);

		bSuc = ::SetWindowPos(hwnd, hwndInsertAfter, x, y, cx, cy, uFlags);
		TSDEBUG(_T("SetWindowPos(0x%p, 0x%p, %d, %d, %d, %d, %u) ret %ld"), 
			hwnd, hwndInsertAfter, x, y, cx, cy, uFlags, bSuc);
	}

	lua_pushboolean(pLuaState, bSuc);
	return 1;
}

int LuaAPIUtil::FShowWnd(lua_State *pLuaState)
{
	BOOL bSuc = FALSE;

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hwnd = (HWND) lua_touserdata(pLuaState, 2);
		int nShowCmd = (int) lua_tointeger(pLuaState, 3);

		bSuc = ::ShowWindow(hwnd, nShowCmd);
		TSDEBUG(_T("ShowWindow(0x%p, %d) ret %ld"), hwnd, nShowCmd, bSuc);
	}

	lua_pushboolean(pLuaState, bSuc);
	return 1;
}

int LuaAPIUtil::FGetWndRect(lua_State *pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hwnd = (HWND) lua_touserdata(pLuaState, 2);
		RECT rc = {0};
		BOOL bOk = ::GetWindowRect(hwnd, &rc);
		TSDEBUG(_T("GetWindowRect(0x%p) ret %ld. rc = <%ld, %ld>-<%ld, %ld>"), 
			hwnd, bOk, rc.left, rc.top, rc.right, rc.bottom);
		if (bOk)
		{
			int cRetValue = 0;
			lua_pushboolean(pLuaState, TRUE);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.left);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.top);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.right);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.bottom);
			++cRetValue;

			return cRetValue;
		}
	}

	lua_pushboolean(pLuaState, FALSE);
	return 1;
}

int LuaAPIUtil::FGetWndClientRect(lua_State *pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		HWND hwnd = (HWND) lua_touserdata(pLuaState, 2);
		RECT rc = {0};
		BOOL bOk = ::GetClientRect(hwnd, &rc);
		TSDEBUG(_T("GetClientRect(0x%p) ret %ld. rc = <%ld, %ld>-<%ld, %ld>"), 
			hwnd, bOk, rc.left, rc.top, rc.right, rc.bottom);
		if (bOk)
		{
			int cRetValue = 0;
			lua_pushboolean(pLuaState, TRUE);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.left);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.top);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.right);
			++cRetValue;
			lua_pushinteger(pLuaState, rc.bottom);
			++cRetValue;

			return cRetValue;
		}
	}

	lua_pushboolean(pLuaState, FALSE);
	return 1;
}

int LuaAPIUtil::FFindWindow(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		LPCSTR lpszClassName = lua_tostring(pLuaState, 2); // utf8 string
		LPCSTR lpszWindowName = lua_tostring(pLuaState, 3); // utf8 string

		CComBSTR bstrClassName;
		if (lpszClassName && *lpszClassName)
		{
			LuaStringToCComBSTR(lpszClassName,bstrClassName);
		}
		
		CComBSTR bstrWindowName;
		if (lpszWindowName && *lpszWindowName)
		{
			LuaStringToCComBSTR(lpszWindowName,bstrWindowName);
		}

		LPCWSTR lpwszClassName = bstrClassName.m_str;
		LPCWSTR lpwszWindowName = bstrWindowName.m_str;
		HWND hWnd = ::FindWindowW(lpwszClassName, lpwszWindowName);
		TSDEBUG(_T("FindWindowW(%s, %s) ret 0x%p"), lpwszClassName, lpwszWindowName, hWnd);
		if (hWnd)
		{
			lua_pushlightuserdata(pLuaState, hWnd);
			return 1;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::FFindWindowEx(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hParentWnd = (HWND)lua_touserdata(pLuaState, 2);
		HWND hChildAfterWnd = (HWND)lua_touserdata(pLuaState, 3);
		LPCSTR lpszClassName = lua_tostring(pLuaState, 4);
		LPCSTR lpszWindowName = lua_tostring(pLuaState, 5);

		CComBSTR bstrClassName;
		if (lpszClassName && *lpszClassName)
		{
			LuaStringToCComBSTR(lpszClassName,bstrClassName);
		}

		CComBSTR bstrWindowName;
		if (lpszWindowName && *lpszWindowName)
		{
			LuaStringToCComBSTR(lpszWindowName,bstrWindowName);
		}

		LPCWSTR lpwszClassName = bstrClassName.m_str;
		LPCWSTR lpwszWindowName = bstrWindowName.m_str;
		HWND hWnd = ::FindWindowExW(hParentWnd, hChildAfterWnd, lpwszClassName, lpwszWindowName);
		TSDEBUG(_T("FindWindowExW(0x%p, 0x%p, %s, %s) ret 0x%p"), 
			hParentWnd, hChildAfterWnd, 
			lpwszClassName, lpwszWindowName, hWnd);
		if (hWnd)
		{
			lua_pushlightuserdata(pLuaState, hWnd);
			return 1;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::FIsWindowVisible(lua_State* pLuaState)
{
	bool bVisible = false;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		BOOL bIsWnd = ::IsWindow(hWnd);
		TSDEBUG(_T("IsWindow(0x%p) ret %ld"), hWnd, bIsWnd);
		BOOL bIsVisible = ::IsWindowVisible(hWnd);
		TSDEBUG(_T("IsWindowVisible(0x%p) ret %ld"), hWnd, bIsVisible);
		if (hWnd && bIsWnd && bIsVisible)
		{
			bVisible = true;
		}
	}

	lua_pushboolean(pLuaState, bVisible);
	return 1;
}

int LuaAPIUtil::IsWindowIconic(lua_State* pLuaState)
{
	bool bIconic = false;
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		BOOL bIsWnd = ::IsWindow(hWnd);
		TSDEBUG(_T("IsWindow(0x%p) ret %ld"), hWnd, bIsWnd);
		BOOL bIsIconic = ::IsIconic(hWnd);
		TSDEBUG(_T("IsIconic(0x%p) ret %ld"), hWnd, bIsIconic);
		if (hWnd && bIsWnd && bIsIconic)
		{
			bIconic = true;
		}
	}

	lua_pushboolean(pLuaState, bIconic);
	return 1;
}

int LuaAPIUtil::GetWindowTitle(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		BOOL bIsWnd = ::IsWindow(hWnd);
		TSDEBUG(_T("IsWindow(0x%p) ret %ld"), hWnd, bIsWnd);
		if (hWnd && bIsWnd)
		{
			WCHAR wszTitle[MAX_PATH + 1] = {0};
			int nLen = ::GetWindowTextW(hWnd, wszTitle, MAX_PATH);
			TSDEBUG(_T("GetWindowTextW(0x%p) ret %d. wszTitle = %s"), hWnd, nLen, wszTitle);
			if (nLen)
			{
				std::string strWndTitle;
				BSTRToLuaString(wszTitle,strWndTitle);
				lua_pushstring(pLuaState, strWndTitle.c_str());
				return 1;
			}
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetWndClassName(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		BOOL bIsWnd = ::IsWindow(hWnd);
		TSDEBUG(_T("IsWindow(0x%p) ret %ld"), hWnd, bIsWnd);
		if (hWnd && bIsWnd)
		{
			WCHAR wszClassName[MAX_PATH + 1] = {0};
			int nLen = ::GetClassNameW(hWnd, wszClassName, MAX_PATH);
			TSDEBUG(_T("GetClassNameW(0x%p) ret %d. wszClassName = %s"), hWnd, nLen, wszClassName);
			if (nLen)
			{
				std::string strClassName;
				BSTRToLuaString(wszClassName,strClassName);
				lua_pushstring(pLuaState, strClassName.c_str());
				return 1;
			}
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::GetWndProcessThreadId(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		BOOL bIsWnd = ::IsWindow(hWnd);
		TSDEBUG(_T("IsWindow(0x%p) ret %ld"), hWnd, bIsWnd);
		if (hWnd && bIsWnd)
		{
			DWORD dwProcessId, dwThreadId;
			dwThreadId = ::GetWindowThreadProcessId(hWnd, &dwProcessId);
			TSDEBUG(_T("GetWindowThreadProcessId(0x%p) ret PID = %lu, TID = %lu"), hWnd, dwProcessId, dwThreadId);
			lua_pushinteger(pLuaState, dwProcessId);
			lua_pushinteger(pLuaState, dwThreadId);
			return 2;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

typedef BOOL (WINAPI *LPFN_ISWOW64PROCESS) (HANDLE, PBOOL);

LPFN_ISWOW64PROCESS fnIsWow64Process;

BOOL IsWow64()
{
	BOOL bIsWow64 = FALSE;

	fnIsWow64Process = (LPFN_ISWOW64PROCESS)GetProcAddress(
		GetModuleHandle(TEXT("kernel32")),"IsWow64Process");

	if (NULL != fnIsWow64Process)
	{
		if (!fnIsWow64Process(GetCurrentProcess(),&bIsWow64))
		{
			// handle error
		}
	}
	return bIsWow64;
}


int LuaAPIUtil::FGetAllSystemInfo(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		lua_newtable(pLuaState);

		// system version information 
		OSVERSIONINFOEXW os = {sizeof(os)};
		if (::GetVersionEx((LPOSVERSIONINFOW)&os))
		{
			lua_pushstring(pLuaState, "Version");
			lua_newtable(pLuaState);

			// major version numbers
			{
				lua_pushstring(pLuaState, "Major");
				lua_pushinteger(pLuaState, os.dwMajorVersion);
				lua_settable(pLuaState, -3);
			}
			// minor version numbers
			{
				lua_pushstring(pLuaState, "Minor");
				lua_pushinteger(pLuaState, os.dwMinorVersion);
				lua_settable(pLuaState, -3);
			}
			// system platform id
			{
				lua_pushstring(pLuaState, "PlatformID");
				lua_pushinteger(pLuaState, os.dwPlatformId);
				lua_settable(pLuaState, -3);
			}
			// system product type
			{
				lua_pushstring(pLuaState, "ProductType");
				lua_pushinteger(pLuaState, os.wProductType);
				lua_settable(pLuaState, -3);
			}

			lua_settable(pLuaState, -3);
		}
		// system bits
		{
			lua_pushstring(pLuaState, "BitNumbers");
			lua_pushinteger(pLuaState, IsWow64() ? 64 : (unsigned(~0) > 0xFFFF ? 32 : 16));
			lua_settable(pLuaState, -3);
		}
		// cpu information
		{
			lua_pushstring(pLuaState, "CPU");
			lua_newtable(pLuaState);

			SYSTEM_INFO si;
			::GetSystemInfo(&si);
			// wProcessorArchitecture
			{
				lua_pushstring(pLuaState, "Architecture");
				lua_pushinteger(pLuaState, si.wProcessorArchitecture);
				lua_settable(pLuaState, -3);
			}
			// dwNumberOfProcessors
			{
				lua_pushstring(pLuaState, "ProcessorNumbers");
				lua_pushinteger(pLuaState, si.dwNumberOfProcessors);
				lua_settable(pLuaState, -3);
			}
			// wProcessorLevel
			{
				lua_pushstring(pLuaState, "ProcessorLevel");
				lua_pushinteger(pLuaState, si.wProcessorLevel);
				lua_settable(pLuaState, -3);
			}
			// wProcessorRevision
			{
				lua_pushstring(pLuaState, "ProcessorRevision");
				lua_pushinteger(pLuaState, si.wProcessorRevision);
				lua_settable(pLuaState, -3);
			}
			// cpu rate
			{

			}

			lua_settable(pLuaState, -3);
		}
		// memory status
		MEMORYSTATUSEX status = {sizeof(status)};
		if (::GlobalMemoryStatusEx(&status))
		{
			lua_pushstring(pLuaState, "Memory");
			lua_newtable(pLuaState);

			// total physic memory size
			{
				lua_pushstring(pLuaState, "TotalPhys");
				lua_pushinteger(pLuaState, (lua_Integer) (status.ullTotalPhys / (1024 * 1024)));
				lua_settable(pLuaState, -3);
			}
			// available physic memory size
			{
				lua_pushstring(pLuaState, "AvailPhys");
				lua_pushinteger(pLuaState, (lua_Integer) (status.ullAvailPhys / (1024 * 1024)));
				lua_settable(pLuaState, -3);
			}
			// total virtual memory size
			{
				lua_pushstring(pLuaState, "TotalVirtual");
				lua_pushinteger(pLuaState, (lua_Integer) (status.ullTotalVirtual / (1024 * 1024)));
				lua_settable(pLuaState, -3);
			}
			// available virtual memory size
			{
				lua_pushstring(pLuaState, "AvailVirtual");
				lua_pushinteger(pLuaState, (lua_Integer) (status.ullAvailVirtual / (1024 * 1024)));
				lua_settable(pLuaState, -3);
			}

			lua_settable(pLuaState, -3);
		}

		return 1;
	}

	lua_pushnil(pLuaState);
	return 1;
}


int LuaAPIUtil::PostWndMessageByHandle( lua_State *pLuaState )
{
	BOOL bSuccess = FALSE;

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		DWORD dwMsg = (DWORD)lua_tointeger(pLuaState, 3);
		DWORD dwWParam = (DWORD)lua_tointeger(pLuaState, 4);
		DWORD dwLParam = (DWORD)lua_tointeger(pLuaState, 5);
		if (::IsWindow(hWnd))
		{
			bSuccess = ::PostMessage(hWnd, dwMsg, (WPARAM)dwWParam, (LPARAM)dwLParam);
		}
		else
		{
			TSERROR(_T("Invalidate windows handle, hWnd=0x%p"), hWnd);
		}
	}

	lua_pushboolean(pLuaState, bSuccess);
	return 1;
}

int LuaAPIUtil::SendMessageByHwnd( lua_State *pLuaState )
{

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);
		DWORD dwMsg = (DWORD)lua_tointeger(pLuaState, 3);
		DWORD dwWParam = (DWORD)lua_tointeger(pLuaState, 4);
		DWORD dwLParam = (DWORD)lua_tointeger(pLuaState, 5);
		if (NULL != hWnd)
		{
			LRESULT iRet = ::SendMessage(hWnd, dwMsg, (WPARAM)dwWParam, (LPARAM)dwLParam);
			lua_pushnumber(pLuaState, (lua_Number)iRet);
			DWORD dwError = ::GetLastError();
			lua_pushinteger(pLuaState,dwError);
			return 2;
		}
	}

	lua_pushnil(pLuaState);
	return 1;
}

LuaAPIUtil* __stdcall LuaAPIUtil::Instance(void *)
{
	static LuaAPIUtil s_instance;
	return &s_instance;
}

void LuaAPIUtil::RegisterObj(XL_LRT_ENV_HANDLE hEnv)
{
	if (hEnv == NULL)
	{
		return;
	}

	XLLRTObject object;
	object.ClassName = API_UTIL_CLASS;
	object.ObjName = API_UTIL_OBJ;
	object.MemberFunctions = sm_LuaMemberFunctions;
	object.userData = NULL;
	object.pfnGetObject = (fnGetObject)LuaAPIUtil::Instance;

	XLLRT_RegisterGlobalObj(hEnv, object);
}

void LuaAPIUtil::EncryptAESHelper(unsigned char* pszKey, const char* pszMsg, int& nBuff,char* out_str)
{	
	strcpy(out_str,pszMsg);
	try
	{
		AES aes(pszKey);
		aes.Cipher((char*)out_str, strlen(pszMsg));
	}
	catch (...)
	{
		memset(out_str, 0, nBuff + 1);
		strcpy(out_str, pszMsg);
	}
}

int LuaAPIUtil::EncryptAESToFile(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* pszFile = lua_tostring(pLuaState, 2);
		const char* pszData = lua_tostring(pLuaState, 3);
		const char* pszKey = lua_tostring(pLuaState, 4);
		if (pszFile == NULL || pszKey == NULL || pszData == NULL)
		{
			return 0;
		}
		
		CComBSTR bstrFilePath;
		LuaStringToCComBSTR(pszFile,bstrFilePath);

		int msglen = strlen(pszData);
		int flen = ((msglen >> 4) + 1) << 4;
		char* out_str = (char*)malloc(flen + 1);
		memset(out_str, 0, flen + 1);

		EncryptAESHelper((unsigned char*)pszKey, pszData,flen, out_str);

		TCHAR tszSaveDir[MAX_PATH] = {0};
		_tcsncpy(tszSaveDir, bstrFilePath.m_str, MAX_PATH);
		::PathRemoveFileSpec(tszSaveDir);
		if (!::PathFileExists(tszSaveDir))
			::SHCreateDirectory(NULL, tszSaveDir);

		std::ofstream of(bstrFilePath.m_str, std::ios_base::out|std::ios_base::binary);
		of.write((const char*)out_str, flen);

		free(out_str);
		return 0;
	}
	lua_pushnil(pLuaState);
	return 1;
}


void LuaAPIUtil::DecryptAESHelper(unsigned char* pszKey, const char* pszMsg, int&nMsg,int& nBuff,char* out_str)
{
	memcpy(out_str,pszMsg,nMsg);
	try
	{
		AES aes(pszKey);
		aes.InvCipher(out_str, nMsg);
	}
	catch(...)
	{
		memset(out_str, 0, nBuff + 1);
		memcpy(out_str,pszMsg,nMsg);
	}
}

int LuaAPIUtil::DecryptFileAES(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* pszFile = lua_tostring(pLuaState, 2);
		const char* pszKey = lua_tostring(pLuaState, 3);
		int nMaxSize = 10 * 1024;
		if (lua_gettop(pLuaState) >= 4)
		{
			nMaxSize = (int)lua_tonumber(pLuaState, 4);
			if (nMaxSize <= 0)
			{
				nMaxSize = 10 * 1024;
			}
		}
		if (pszFile == NULL || pszKey == NULL)
		{
			return 0;
		}

		CComBSTR bstrFilePath;
		LuaStringToCComBSTR(pszFile,bstrFilePath);


		int iFileSize = (int)GetFileSizeHelper(pszFile);
		if (iFileSize <= 0)
		{
			lua_pushboolean(pLuaState, 1);
			return 1;
		}

		char* data = new char[iFileSize + 1];
		if (NULL == data)
		{
			return 0;
		}
		ZeroMemory(data, iFileSize + 1);
		std::ifstream pf(bstrFilePath.m_str, std::ios_base::in|std::ios_base::binary);
		pf.read(data, iFileSize);
		int curPosEnd = pf.tellg();
		if (-1 != curPosEnd && curPosEnd != iFileSize)
		{
			delete[] data;
			return 0;
		}
		char* pdata = data;
		
		int flen = ((iFileSize >> 4) + 1) << 4;
		//int flen = iFileSize;
		char* out_str = (char*)malloc(flen + 1);
		memset(out_str, 0, flen + 1);

		DecryptAESHelper((unsigned char*)pszKey, pdata,iFileSize,flen,out_str);

		lua_pushstring(pLuaState, (const char*)out_str);
		free(out_str);
		free(data);
		return 1;
	}
	lua_pushnil(pLuaState);
	return 1;
}



int LuaAPIUtil::ReadINI(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	const char* utf8Path = luaL_checkstring(pLuaState,2);
	const char* utf8App = luaL_checkstring(pLuaState,3);
	const char* utf8Key = luaL_checkstring(pLuaState,4);

	if(ppUtil == NULL || utf8Path == NULL || utf8App == NULL || utf8Key == NULL)
	{
		lua_pushnil(pLuaState);
		lua_pushboolean(pLuaState,0);
		return 2;
	}

	std::string utf8Result;

	if(ReadIniHelper(utf8Path,utf8App,utf8Key,utf8Result) == 1)
	{
		lua_pushstring(pLuaState,utf8Result.c_str());
		lua_pushboolean(pLuaState,1);
		return 2;
	}
	else
	{
		lua_pushstring(pLuaState,"");
		lua_pushboolean(pLuaState,0);
		return 2;
	}
}

long LuaAPIUtil::ReadIniHelper(const char* utf8FilePath,const char* utf8AppName,const char* utf8KeyName,std::string& utf8Result)
{
	CComBSTR bstrFilePath;
	CComBSTR bstrAppName;
	CComBSTR bstrKeyName;

	if(utf8FilePath)
	{
		LuaStringToCComBSTR(utf8FilePath, bstrFilePath);
	}
	if(utf8AppName)
	{
		LuaStringToCComBSTR(utf8AppName, bstrAppName);
	}
	if(utf8KeyName)
	{
		LuaStringToCComBSTR(utf8KeyName, bstrKeyName);
	}
	wchar_t resultBuffer[4*1024] = {0};
	DWORD result = ::GetPrivateProfileString (bstrAppName.m_str,bstrKeyName.m_str,TEXT(""),resultBuffer,4*1024,bstrFilePath.m_str);
	if(result > 0)
	{
		BSTRToLuaString(resultBuffer, utf8Result);
		return 1;
	}
	return 0;
}

int LuaAPIUtil::WriteINI(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	const char* utf8AppName = luaL_checkstring(pLuaState, 2);
	const char* utf8KeyName = luaL_checkstring(pLuaState, 3);
	const char* utf8Value = lua_tostring(pLuaState, 4);
	const char* utf8FileName = luaL_checkstring(pLuaState, 5);

	if(ppUtil == NULL || utf8AppName == NULL || utf8KeyName == NULL || utf8FileName == NULL)
	{
		lua_pushboolean(pLuaState, 0);
		return 1;
	}

	if(WriteIniHelper(utf8AppName, utf8KeyName, utf8Value, utf8FileName) == 1)
	{
		lua_pushboolean(pLuaState, 1);
		return 1;
	}

	lua_pushboolean(pLuaState, 0);
	return 1;
}


long LuaAPIUtil::WriteIniHelper(const char* utf8AppName, const char* utf8KeyName, const char* utf8String, const char* utf8FileName)
{
	CComBSTR bstrAppName;
	CComBSTR bstrKeyName;
	CComBSTR bstrString;
	CComBSTR bstrFileName;

	if(utf8AppName)
	{
		LuaStringToCComBSTR(utf8AppName, bstrAppName);
	}
	if(utf8FileName)
	{
		LuaStringToCComBSTR(utf8FileName, bstrFileName);
	}
	if(utf8KeyName)
	{
		LuaStringToCComBSTR(utf8KeyName, bstrKeyName);
	}
	if(utf8String)
	{
		LuaStringToCComBSTR(utf8String, bstrString);
	}

	BOOL bRet = FALSE;
	if (utf8String == NULL)
	{
		bRet = WritePrivateProfileString(bstrAppName.m_str, bstrKeyName.m_str, NULL, bstrFileName.m_str);
	}
	else
	{
		bRet = WritePrivateProfileString(bstrAppName.m_str, bstrKeyName.m_str, bstrString.m_str, bstrFileName.m_str);
	}

	if(bRet)
	{
		return 1;
	}

	return 0;
}

int LuaAPIUtil::ReadStringUtf8(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8IniPath = luaL_checkstring(pLuaState,2);
		const char* utf8AppName = luaL_checkstring(pLuaState,3);
		const char* utf8KeyName = luaL_checkstring(pLuaState,4);
		const char* utf8Default = luaL_checkstring(pLuaState, 5);

		CHAR szValue[MAX_PATH] = {0};

		GetPrivateProfileStringA(utf8AppName, utf8KeyName, utf8Default, szValue, MAX_PATH - 1, utf8IniPath);

		lua_pushstring(pLuaState, szValue);
		return 1;
	}
	return 0;
}

int LuaAPIUtil::ReadSections(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Path = luaL_checkstring(pLuaState,2);

		std::vector<std::string> vecStrSections;
		std::string strTemp;
		ReadSectionsHelper(utf8Path, vecStrSections);
		int nCount = vecStrSections.size();
		lua_checkstack(pLuaState, nCount);
		lua_newtable(pLuaState);
		for(int i = 0; i < nCount;i++)
		{
			strTemp=vecStrSections.at(i);
			lua_pushstring(pLuaState,strTemp.c_str()); 
			lua_rawseti(pLuaState,-2,i+1); 
		} 
		return 1;
	}
	return 0;
}

long LuaAPIUtil::ReadSectionsHelper(const char*  utf8Path, std::vector<std::string> & strSections)
{
	CComBSTR bstrPath;
	LuaStringToCComBSTR(utf8Path, bstrPath);

	strSections.clear();
	DWORD nSize = 0, nLen = nSize-2;
	TCHAR *lpszReturnBuffer = 0;
	while(nLen==nSize-2)
	{
		nSize+=2048;
		if(lpszReturnBuffer)
			delete lpszReturnBuffer;

		lpszReturnBuffer = new TCHAR[nSize];
		nLen = GetPrivateProfileSectionNames(lpszReturnBuffer, nSize,//如果返回nSize-2则表示
			bstrPath.m_str);	//缓冲区长度不足，递增MAX_BUFFER_SIZE
	}
	TCHAR *pName = new TCHAR[MAX_PATH];
	TCHAR *pStart, *pEnd;
	pStart = lpszReturnBuffer;
	pEnd = 0;
	while(pStart != pEnd)
	{
		pEnd = wcschr(pStart, 0);
		size_t iLenTmp = pEnd - pStart;
		if(iLenTmp == 0)
			break;

		wcsncpy(pName, pStart, iLenTmp);
		pName[iLenTmp] = 0;
		std::string strTemp;
		BSTRToLuaString(pName, strTemp);
		strSections.push_back(strTemp.c_str());
		pStart = pEnd + 1;
	}
	delete lpszReturnBuffer;
	delete pName;

	return 0;
}

int LuaAPIUtil::ReadKeyValueInSection(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8Path = luaL_checkstring(pLuaState,2);
		const char* utf8Section = luaL_checkstring(pLuaState,3);

		std::vector<std::string> vecStrSections;
		std::string strTemp;
		ReadKeyValueInSectionHelper(utf8Path, utf8Section, vecStrSections);
		int nCount = vecStrSections.size();
		lua_checkstack(pLuaState, nCount);
		lua_newtable(pLuaState);
		for(int i = 0; i < nCount;i++)
		{
			strTemp=vecStrSections.at(i);
			lua_pushstring(pLuaState,strTemp.c_str()); 
			lua_rawseti(pLuaState,-2,i+1); 
		} 
		return 1;
	}
	return 0;
}

long LuaAPIUtil::ReadKeyValueInSectionHelper(const char*  utf8Path, const char*  utf8Section, std::vector<std::string> & strKeyValue)
{
	CComBSTR bstrPath;
	LuaStringToCComBSTR(utf8Path, bstrPath);

	CComBSTR bstrSection;
	LuaStringToCComBSTR(utf8Section, bstrSection);

	strKeyValue.clear();
	DWORD nSize = 0, nLen = nSize-2;
	TCHAR *lpszReturnBuffer = 0;
	while(nLen==nSize-2)
	{
		nSize+=2048;
		if(lpszReturnBuffer)
			delete lpszReturnBuffer;

		lpszReturnBuffer = new TCHAR[nSize];
		nLen = GetPrivateProfileSection(bstrSection.m_str, lpszReturnBuffer, nSize,//如果返回nSize-2则表示
			bstrPath.m_str);	//缓冲区长度不足，递增MAX_BUFFER_SIZE
	}
	TCHAR *pName = new TCHAR[MAX_PATH];
	TCHAR *pStart, *pEnd;
	pStart = lpszReturnBuffer;
	pEnd = 0;
	while(pStart != pEnd)
	{
		pEnd = wcschr(pStart, 0);
		size_t iLenTmp = pEnd - pStart;
		if(iLenTmp == 0)
			break;

		wcsncpy(pName, pStart, iLenTmp);
		pName[iLenTmp] = 0;
		std::string strTemp;
		BSTRToLuaString(pName, strTemp);
		strKeyValue.push_back(strTemp.c_str());
		pStart = pEnd + 1;
	}
	delete lpszReturnBuffer;
	delete pName;

	return 0;
}

int LuaAPIUtil::ReadINIInteger(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{
		const char* utf8IniPath = luaL_checkstring(pLuaState,2);
		const char* utf8AppName = luaL_checkstring(pLuaState,3);
		const char* utf8KeyName = luaL_checkstring(pLuaState,4);
		int nDefault = (int)luaL_checkinteger(pLuaState, 5);

		CComBSTR bstrIniPath;
		LuaStringToCComBSTR(utf8IniPath, bstrIniPath);

		CComBSTR bstrAppName;
		LuaStringToCComBSTR(utf8AppName, bstrAppName);
		
		CComBSTR bstrKeyName;
		LuaStringToCComBSTR(utf8KeyName, bstrKeyName);

		int nRet = GetPrivateProfileInt(bstrAppName.m_str, bstrKeyName.m_str, nDefault, bstrIniPath.m_str);
		lua_pushinteger(pLuaState, nRet);
		return 1;
	}
	return 0;
}


int LuaAPIUtil::FileDialog(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		BOOL bOpenFileDialog = lua_toboolean(pLuaState, 2);
		const char* pszFilter = lua_tostring(pLuaState, 3);
		std::wstring strFilter;
		CComBSTR bstrFilter;
		LuaStringToCComBSTR(pszFilter, bstrFilter);
		strFilter = bstrFilter.m_str;
		std::replace(strFilter.begin(), strFilter.end(), L'|', L'\0');

		const char* pszDefExt = NULL;
		CComBSTR bstrDefExt=L"";
		if (lua_type(pLuaState, 4) == LUA_TSTRING)
		{
			pszDefExt = lua_tostring(pLuaState, 4);
			LuaStringToCComBSTR(pszDefExt, bstrDefExt);
		}
		const char* pszFileName = NULL;
		CComBSTR bstrFileName=L"";
		if (lua_type(pLuaState, 5) == LUA_TSTRING)
		{
			pszFileName = lua_tostring(pLuaState, 5);
			LuaStringToCComBSTR(pszFileName, bstrFileName);
		}

		WTL::CFileDialog dlg(bOpenFileDialog, bstrDefExt.m_str, bstrFileName.m_str, OFN_HIDEREADONLY|OFN_OVERWRITEPROMPT, strFilter.c_str());
		INT_PTR idlg = dlg.DoModal();
		if (IDOK == idlg)
		{
			std::string utf8FilePath;
			BSTRToLuaString(dlg.m_szFileName,utf8FilePath);
			lua_pushstring(pLuaState, utf8FilePath.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::BrowserForFile(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* lpszTitle = lua_tostring(pLuaState,2);
		CComBSTR bstrTitle=L"";
		if (lpszTitle != NULL)
		{
			LuaStringToCComBSTR(lpszTitle, bstrTitle);
		}
		const char* lpszFilter = lua_tostring(pLuaState,3);
		std::wstring wstrFilter;
		CComBSTR bstrFilter=L"";
		if (lpszFilter != NULL)
		{
			LuaStringToCComBSTR(lpszFilter, bstrFilter);
		}	
		wstrFilter = bstrFilter.m_str;
		//L"所有文件(*.*)|*.*|"
		std::string strFilePath;
		CComBSTR bstrFilePath=L"";
		//std::wstring wstrFilePath = L"";
		int nType = -1;
		nType = lua_type(pLuaState, 4);
		if(nType != LUA_TNONE && nType != LUA_TNIL)
		{
			strFilePath = lua_tostring(pLuaState, 4);
			LuaStringToCComBSTR(strFilePath.c_str(), bstrFilePath);
		}
		std::wstring wstrFilePath = bstrFilePath.m_str;
		OPENFILENAME ofn;       // 公共对话框结构。
		wchar_t szFile[MAX_PATH] = {0}; // 保存获取文件名称的缓冲区。        
		if (wstrFilePath.size() > 0 && wstrFilePath.size() < MAX_PATH)
		{
			wcscpy(szFile, wstrFilePath.c_str());
		}
		// 初始化选择文件对话框。
		ZeroMemory(&ofn, sizeof(ofn));
		ofn.lStructSize = sizeof(ofn);
		ofn.hwndOwner = NULL;
		ofn.lpstrFile = szFile;

		std::wstring::size_type nPos = 0;
		while (true)
		{
			nPos = wstrFilter.find(_T('|'), nPos);
			if (nPos == std::wstring::npos)
			{
				break;
			}
			wstrFilter.replace(nPos, 1, 1, _T('\0'));
		}
		ofn.nMaxFile = sizeof(szFile);
		ofn.lpstrFilter = wstrFilter.data();
		ofn.nFilterIndex = 1;
		ofn.lpstrTitle = bstrTitle.m_str;
		ofn.nMaxFileTitle = 0;
		ofn.lpstrInitialDir = NULL;
		ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;
		// 显示打开选择文件对话框
		BOOL bRet = FALSE;
		bRet = GetOpenFileName(&ofn);
		if (bRet)
		{
			//显示选择的文件。
			std::string utf8FilePath;
			BSTRToLuaString(szFile,utf8FilePath);
			lua_pushstring(pLuaState, utf8FilePath.c_str());
			return 1;
		}
	}
	lua_pushnil(pLuaState);
	return 1;
}

int LuaAPIUtil::IEMenu_SaveAs(lua_State *pLuaState)
{
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{	
		IWebBrowser2 **lpWeb2 = (IWebBrowser2**)lua_touserdata(pLuaState, 2);
		if (lpWeb2)
		{
			(*lpWeb2)->ExecWB(OLECMDID_SAVEAS, OLECMDEXECOPT_DODEFAULT, NULL, NULL);
		}
		
	}
	return 0;
}


int LuaAPIUtil::IEMenu_Zoom(lua_State *pLuaState)
{
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{	
		IWebBrowser2 **lpWeb2 = (IWebBrowser2**)lua_touserdata(pLuaState, 2);
		if (lpWeb2)
		{
			int nZoom = 100; //100表示100%，也就是原始比例
			if ( !lua_isnoneornil( pLuaState, 3))
			{
				nZoom = (int)lua_tointeger( pLuaState, 3);
			}

			CComVariant varZoom((int)nZoom);  // nZoom是要设置的缩放比例
			
			(*lpWeb2)->ExecWB(OLECMDID_OPTICAL_ZOOM, OLECMDEXECOPT_DODEFAULT, &varZoom, NULL);
		}
	}
	return 0;
}

int LuaAPIUtil::IEFavorite_Organize(lua_State *pLuaState)
{
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{	
		HWND hWnd = (HWND)lua_touserdata(pLuaState, 2);

		typedef UINT (CALLBACK* LPFNORGFAV)(HWND, LPTSTR);
		bool bFree = false;
		HMODULE hMod = ::GetModuleHandle( _T("shdocvw.dll") );
		if (hMod == NULL)//如果"shdocvw.dll"尚未载入则载入之
		{
			hMod = ::LoadLibrary( _T("shdocvw.dll") );
			bFree = true;
		}
		if (hMod == NULL)
		{
			return 0;
		}
		LPFNORGFAV lpfnDoOrganizeFavDlg = (LPFNORGFAV)::GetProcAddress( hMod, "DoOrganizeFavDlg" );
		if (lpfnDoOrganizeFavDlg == NULL)
		{
			
			return 0;
		}
		TCHAR szPath [ MAX_PATH ];
		HRESULT hr;
		hr = ::SHGetSpecialFolderPath( hWnd, szPath, CSIDL_FAVORITES, TRUE );
		if (FAILED(hr))
		{
			return 0;
		}
		BOOL bResult = (*lpfnDoOrganizeFavDlg) (hWnd, szPath) ? TRUE : FALSE;
		if (bFree)
		{
			::FreeLibrary( hMod );
		}
		lua_pushboolean(pLuaState, bResult);
		return 1;
	}
	return 0;
}


int LuaAPIUtil::YbSpeedInitialize(lua_State* pLuaState)
{
	YbSpeedHook::Initialize();
	return 0;
}

int LuaAPIUtil::YbSpeedHook(lua_State* pLuaState)
{
	lua_pushboolean(pLuaState, YbSpeedHook::AttachHook());
	return 1;
}

int LuaAPIUtil::YbSpeedUnhook(lua_State* pLuaState)
{
	lua_pushboolean(pLuaState, YbSpeedHook::DetachHook());
	return 1;
}

int LuaAPIUtil::YbSpeedChangeRate(lua_State* pLuaState)
{
	double rate = luaL_checknumber(pLuaState, 2);
	lua_pushnumber(pLuaState, YbSpeedHook::ChangeSpeedRate(rate));
	return 1;
}


int LuaAPIUtil::FSetKeyboardHook(lua_State* pLuaState)
{
	CYBMsgWindow::Instance()->SetKeyboardHook();
	return 0;
}

int LuaAPIUtil::FDelKeyboardHook(lua_State* pLuaState)
{
	CYBMsgWindow::Instance()->DelKeyboardHook();
	return 0;
}

#include <UrlHist.h>
int LuaAPIUtil::GetIEHistoryInfo(lua_State *pLuaState)
{
	TSTRACEAUTO();
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		::CoInitialize(NULL);

		IUrlHistoryStg* puhs = NULL;
		HRESULT hr = CoCreateInstance(CLSID_CUrlHistory, NULL, CLSCTX_INPROC_SERVER, IID_IUrlHistoryStg, (LPVOID *)&puhs);
		if (SUCCEEDED(hr))
		{
			IEnumSTATURL* pEnumURL;
			hr = puhs->EnumUrls(&pEnumURL);
			if (SUCCEEDED(hr))
			{
				STATURL suURL;
				ULONG pceltFetched;
				suURL.cbSize = sizeof(suURL);
				hr = pEnumURL->Reset();
				pEnumURL->SetFilter(L"http", 0);

				lua_newtable(pLuaState);
				int i = 1;
				while (SUCCEEDED(pEnumURL->Next(1, &suURL, &pceltFetched)) && (pceltFetched > 0))
				{
					TSDEBUG4CXX(suURL.pwcsUrl << L"   " << suURL.pwcsTitle);
					std::wstring strUrl = suURL.pwcsUrl;

					lua_newtable(pLuaState);
					lua_pushstring(pLuaState, "pwcsUrl");
					if (suURL.pwcsUrl != NULL)
					{
						std::string strUrl;
						BSTRToLuaString(suURL.pwcsUrl,strUrl);
						lua_pushstring(pLuaState, strUrl.c_str());
					}
					else
					{
						lua_pushnil(pLuaState);
					}
					lua_settable(pLuaState, -3);

					lua_pushstring(pLuaState, "pwcsTitle");
					if (suURL.pwcsTitle != NULL)
					{
						std::string strTitle;
						BSTRToLuaString(suURL.pwcsTitle,strTitle);
						lua_pushstring(pLuaState, strTitle.c_str());
					}
					else
					{
						lua_pushnil(pLuaState);
					}
					lua_settable(pLuaState, -3);

					TSDEBUG4CXX(L"ftLastVisited.dwLowDateTime = " << suURL.ftLastVisited.dwLowDateTime << L"  ftLastVisited.dwHighDateTime = " << suURL.ftLastVisited.dwHighDateTime);
					lua_pushstring(pLuaState, "ftLastVisited");
					lua_newtable(pLuaState);
					lua_pushstring(pLuaState, "dwLowDateTime");
					lua_pushnumber(pLuaState, suURL.ftLastVisited.dwLowDateTime);
					lua_settable(pLuaState, -3);
					lua_pushstring(pLuaState, "dwHighDateTime");
					lua_pushnumber(pLuaState, suURL.ftLastVisited.dwHighDateTime);
					lua_settable(pLuaState, -3);
					lua_settable(pLuaState, -3);

					TSDEBUG4CXX(L"ftLastUpdated.dwLowDateTime = " << suURL.ftLastUpdated.dwLowDateTime << L"  ftLastUpdated.dwHighDateTime = " << suURL.ftLastUpdated.dwHighDateTime);
					lua_pushstring(pLuaState, "ftLastUpdated");
					lua_newtable(pLuaState);
					lua_pushstring(pLuaState, "dwLowDateTime");
					lua_pushnumber(pLuaState, suURL.ftLastUpdated.dwLowDateTime);
					lua_settable(pLuaState, -3);
					lua_pushstring(pLuaState, "dwHighDateTime");
					lua_pushnumber(pLuaState, suURL.ftLastUpdated.dwHighDateTime);
					lua_settable(pLuaState, -3);
					lua_settable(pLuaState, -3);

					TSDEBUG4CXX(L"ftExpires.dwLowDateTime = " << suURL.ftExpires.dwLowDateTime << L"  ftExpires.dwHighDateTime = " << suURL.ftExpires.dwHighDateTime);
					lua_pushstring(pLuaState, "ftExpires");
					lua_newtable(pLuaState);
					lua_pushstring(pLuaState, "dwLowDateTime");
					lua_pushnumber(pLuaState, suURL.ftExpires.dwLowDateTime);
					lua_settable(pLuaState, -3);
					lua_pushstring(pLuaState, "dwHighDateTime");
					lua_pushnumber(pLuaState, suURL.ftExpires.dwHighDateTime);
					lua_settable(pLuaState, -3);
					lua_settable(pLuaState, -3);

					::CoTaskMemFree(suURL.pwcsTitle);
					::CoTaskMemFree(suURL.pwcsUrl);

					lua_rawseti(pLuaState, -2, i);
					i++;
				}

				pEnumURL->Release();
				puhs->Release();
				::CoUninitialize();

				return 1;
			}
			puhs->Release();
		}
		::CoUninitialize();
	}
	return 0;
}

int LuaAPIUtil::DownloadFileByIE(lua_State *pLuaState)
{
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil)
	{	
		BOOL bRet = FALSE;
		const char* utf8DownLoadUrl = luaL_checkstring(pLuaState, 2);
		if (utf8DownLoadUrl == NULL)
		{
			lua_pushboolean(pLuaState, bRet);
			return 1;
		}
		CComBSTR bstrDownLoadUrl;
		LuaStringToCComBSTR(utf8DownLoadUrl,bstrDownLoadUrl);

		HMODULE hModule = ::LoadLibrary(_T("ieframe.dll"));
		if (hModule == NULL)
		{
			hModule = ::LoadLibrary(_T("shdocvw.dll"));
		}

		if (hModule == NULL)
		{
			lua_pushboolean(pLuaState, bRet);
			return 1;
		}

		typedef HRESULT (WINAPI *PFNDoFileDownload)(LPCWSTR pszUrl);
		PFNDoFileDownload pfnDoFileDownload = (PFNDoFileDownload)::GetProcAddress(hModule,"DoFileDownload");
		if (pfnDoFileDownload == NULL)
		{
			TSDEBUG4CXX("GetProcAddress failed! last error : " << ::GetLastError());
			return S_FALSE;
		}
		HRESULT hr = pfnDoFileDownload(bstrDownLoadUrl);
		TSDEBUG4CXX("pfnDoFileDownload hr : " << hr);
		bRet = SUCCEEDED(hr) ? TRUE : FALSE;
		lua_pushboolean(pLuaState, bRet);
		return 1;
	}
	return 0;
}


#include <COMUTIL.H>
typedef std::vector<std::wstring> VectorVerbName;
VectorVerbName*  GetVerbNames(bool bPin)
{
	//TSAUTO();
	static bool bInit = false;
	static std::vector<std::wstring> vecPinStartMenuNames;
	static std::vector<std::wstring> vecUnPinStartMenuNames;
	if (!bInit )
	{	
		bInit = true;
		vecPinStartMenuNames.push_back(_T("锁定到开始菜单"));vecPinStartMenuNames.push_back(_T("附到「开始」菜单"));
		vecUnPinStartMenuNames.push_back(_T("从「开始」菜单脱离"));vecUnPinStartMenuNames.push_back(_T("(从「开始」菜单解锁"));
	}

	return bPin? &vecPinStartMenuNames : &vecUnPinStartMenuNames;
};

bool VerbNameMatch(TCHAR* tszName, bool bPin)
{
	//TSAUTO();
	VectorVerbName *pVec = GetVerbNames(bPin);

	VectorVerbName::iterator iter = pVec->begin();
	VectorVerbName::iterator iter_end = pVec->end();
	while(iter!=iter_end)
	{
		std::wstring strName= *iter;
		if ( 0 == _wcsnicmp(tszName,strName.c_str(),strName.length()))
			return true;
		iter ++;
	}
	return false;
};


#define IF_FAILED_OR_NULL_BREAK(rv,ptr) \
{if (FAILED(rv) || ptr == NULL) break;}

#define SAFE_RELEASE(p) { if(p) { (p)->Release(); (p)=NULL; } }
int LuaAPIUtil::PinToStartMenu4XP(lua_State *pLuaState)
{	
	TSAUTO();
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (!ppUtil)
	{	
		return 0;
	}

	const char *szShortCutPath = lua_tostring(pLuaState, 2);
	bool bPin = (bool)lua_toboolean(pLuaState, 3);
	if (!szShortCutPath)
	{
		return 0;
	}

	CComBSTR bstShortCutPath;
	LuaStringToCComBSTR(szShortCutPath,bstShortCutPath);

	TCHAR file_dir[MAX_PATH + 1] = {0};
	TCHAR *file_name;

	wcscpy_s(file_dir,MAX_PATH,bstShortCutPath.m_str);
	PathRemoveFileSpecW(file_dir);
	file_name = PathFindFileName(bstShortCutPath.m_str);
	::CoInitialize(NULL);
	CComPtr<IShellDispatch> pShellDisp;
	CComPtr<Folder> folder_ptr;
	CComPtr<FolderItem> folder_item_ptr;
	CComPtr<FolderItemVerbs> folder_item_verbs_ptr;


	HRESULT rv = CoCreateInstance( CLSID_Shell, NULL, CLSCTX_SERVER,IID_IDispatch, (LPVOID *) &pShellDisp );
	do 
	{
		IF_FAILED_OR_NULL_BREAK(rv,pShellDisp);
		rv = pShellDisp->NameSpace(_variant_t(file_dir),&folder_ptr);
		IF_FAILED_OR_NULL_BREAK(rv,folder_ptr);
		rv = folder_ptr->ParseName(CComBSTR(file_name),&folder_item_ptr);
		IF_FAILED_OR_NULL_BREAK(rv,folder_item_ptr);
		rv = folder_item_ptr->Verbs(&folder_item_verbs_ptr);
		IF_FAILED_OR_NULL_BREAK(rv,folder_item_verbs_ptr);
		long count = 0;
		folder_item_verbs_ptr->get_Count(&count);
		for (long i = 0; i < count ; ++i)
		{
			FolderItemVerb* item_verb = NULL;
			rv = folder_item_verbs_ptr->Item(_variant_t(i),&item_verb);
			if (SUCCEEDED(rv) && item_verb)
			{
				CComBSTR bstrName;
				item_verb->get_Name(&bstrName);

				if ( VerbNameMatch(bstrName,bPin) )
				{
					TSDEBUG4CXX("Find Verb to Pin:"<< bstrName);
					int i = 0;
					do
					{
						rv = item_verb->DoIt();
						TSDEBUG4CXX("Try Do Verb. NO." << i+1 << ", return="<<rv);
						if (SUCCEEDED(rv))
						{
							::SHChangeNotify(SHCNE_UPDATEDIR|SHCNE_INTERRUPT|SHCNE_ASSOCCHANGED, SHCNF_IDLIST |SHCNF_FLUSH | SHCNF_PATH|SHCNE_ASSOCCHANGED,
								bstShortCutPath.m_str,0);
							Sleep(500);
							::CoUninitialize();
							return 0;
						}else
						{
							Sleep(500);
							rv = item_verb->DoIt();
						}
					}while ( i++ < 3);

					break;
				}
			}
		}
	} while (0);
	::CoUninitialize();
	return 0;
};

int LuaAPIUtil::RefleshIcon(lua_State *pLuaState)
{
	TSAUTO();
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (!ppUtil)
	{	
		return 0;
	}

	const char *szShortCutPath = lua_tostring(pLuaState, 2);
	if (!szShortCutPath)
	{
		SHChangeNotify(SHCNE_ASSOCCHANGED, SHCNF_IDLIST|SHCNF_FLUSH, NULL, NULL);
	}
	else
	{
		CComBSTR bstShortCutPath;
		LuaStringToCComBSTR(szShortCutPath,bstShortCutPath);
		::SHChangeNotify(SHCNE_UPDATEDIR|SHCNE_INTERRUPT|SHCNE_ASSOCCHANGED, SHCNF_IDLIST |SHCNF_FLUSH | SHCNF_PATH|SHCNE_ASSOCCHANGED,
		bstShortCutPath.m_str,0);
	}

	return 0;

};

int LuaAPIUtil::UpdateShortCutLinkInfo(lua_State* pLuaState)
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil != NULL)
	{
		const char* utf8LnkFile = lua_tostring(pLuaState, 2);
		const char* utf8ExePath = lua_tostring(pLuaState, 3);
		const char* utf8Argments = lua_tostring(pLuaState, 4);
		const char* utf8IconPath = lua_tostring(pLuaState, 5);
		if (utf8LnkFile != NULL && (utf8ExePath != NULL || utf8Argments != NULL || utf8IconPath != NULL))
		{
			::CoInitialize(NULL);
			HRESULT hResult = S_FALSE;
			IShellLink* psl = NULL;
			IPersistFile* ppf = NULL;
			hResult = CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_IShellLink, (LPVOID*)&psl);
			if (SUCCEEDED(hResult))
			{
				hResult = psl->QueryInterface(IID_IPersistFile, (LPVOID *)&ppf);
				if (SUCCEEDED(hResult))
				{
					//std::wstring strLnkFile;
					//transcode::UTF8_to_Unicode(utf8LnkFile, strlen(utf8LnkFile), strLnkFile);

					CComBSTR bstLnkFile;
					LuaStringToCComBSTR(utf8LnkFile,bstLnkFile);

					hResult = ppf->Load(bstLnkFile.m_str, STGM_READWRITE | STGM_SHARE_DENY_WRITE);
					if (SUCCEEDED(hResult))
					{
						//std::wstring strExePath, strArguments, strIconPath;
						if (utf8ExePath != NULL)
						{
							//transcode::UTF8_to_Unicode(utf8ExePath, strlen(utf8ExePath), strExePath);
							CComBSTR bstExePath;
							LuaStringToCComBSTR(utf8ExePath,bstExePath);

							psl->SetPath(bstExePath.m_str);
						}
						if (utf8Argments != NULL)
						{
							//transcode::UTF8_to_Unicode(utf8Argments, strlen(utf8Argments), strArguments);
							CComBSTR bstArgments;
							LuaStringToCComBSTR(utf8Argments,bstArgments);

							psl->SetArguments(bstArgments.m_str);
						}
						if (utf8IconPath != NULL)
						{
							//transcode::UTF8_to_Unicode(utf8IconPath, strlen(utf8IconPath), strIconPath);

							CComBSTR bstIconPath;
							LuaStringToCComBSTR(utf8IconPath,bstIconPath);

							psl->SetIconLocation(bstIconPath.m_str, 0);
						}
						ppf->Save(bstLnkFile.m_str, TRUE);
					}
				}
			}

			if(ppf != NULL)
			{
				ppf->Release();
			}
			if(psl != NULL)
			{
				psl->Release();
			}
			::CoUninitialize();
		}
	}
	return 0;
}

BOOL LuaAPIUtil::ElevateOperateHelper(lua_State* luaState, int nIndex,std::vector<std::wstring> &v_AddReg,std::vector<std::wstring> &v_DelReg)
{
	BOOL bTable = lua_istable(luaState, nIndex);
	if (!bTable)
		return FALSE;
	lua_pushnil(luaState);
	while (lua_next(luaState, 2)) 
	{
		std::string strKey;
		if(lua_isstring(luaState, -2))
		{
			const char* utf8Key = (const char*)lua_tostring(luaState, -2);
			std::wstring strKey;

			CComBSTR bstrKey;
			LuaStringToCComBSTR(utf8Key,bstrKey);

			if (wcscmp(bstrKey.m_str,L"AddReg") == 0 && lua_istable(luaState, -1))
			{
				int nIndex = lua_gettop(luaState);
				lua_pushnil(luaState);
				while (lua_next(luaState, nIndex))
				{
					const char* utf8AddItem = (const char*)lua_tostring(luaState, -1);
					if (NULL != utf8AddItem)
					{
						CComBSTR bstrAddItem;
						LuaStringToCComBSTR(utf8AddItem,bstrAddItem);
						v_AddReg.push_back(bstrAddItem.m_str);
					}
					lua_pop(luaState, 1);
				}
			}
			else if (wcscmp(bstrKey.m_str,L"DelReg") == 0 && lua_istable(luaState, -1) )
			{
				int nIndex = lua_gettop(luaState);
				lua_pushnil(luaState);
				while (lua_next(luaState, nIndex))
				{
					const char* utf8DelItem = (const char*)lua_tostring(luaState, -1);
					if (NULL != utf8DelItem)
					{
						CComBSTR bstrDelItem;
						LuaStringToCComBSTR(utf8DelItem,bstrDelItem);
						v_DelReg.push_back(bstrDelItem.m_str);
					}
					lua_pop(luaState, 1);
				}
			}
			lua_pop(luaState, 1);
		}
		else
		{
			TSDEBUG4CXX(L"ElevateOperateHelper, table key not support string");
			lua_pop(luaState, 1);
		}
	}
	return TRUE;
}

int LuaAPIUtil::ElevateOperate(lua_State *pLuaState)
{
	TSAUTO();
	LuaAPIUtil **ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (!ppUtil)
	{	
		return 0;
	}
	UACElevate uac;
	const char *szInfPath = lua_tostring(pLuaState, 3);
	if (NULL == szInfPath || !lua_istable(pLuaState, 2))
	{
		return 0;
	}
	CComBSTR bstInfPath;
	LuaStringToCComBSTR(szInfPath,bstInfPath);
	int nWow64 = lua_toboolean(pLuaState, 4);
	BOOL bWow = (nWow64 == 0) ? FALSE : TRUE;
	int iErrorCode = ELEVATE_SUCCESS;
	if (iErrorCode = uac.Init(bstInfPath.m_str,bWow) != ELEVATE_SUCCESS)
	{
		lua_pushinteger(pLuaState, iErrorCode);
		return 1;
	}
	std::vector<std::wstring> v_AddReg,v_DelReg;
	ElevateOperateHelper(pLuaState,2,v_AddReg,v_DelReg);
	for (std::vector<std::wstring>::const_iterator c_iter = v_AddReg.begin(); c_iter != v_AddReg.end();c_iter++)
	{
		uac.AddReg((*c_iter).c_str());
	}
	for (std::vector<std::wstring>::const_iterator c_iter = v_DelReg.begin(); c_iter != v_DelReg.end();c_iter++)
	{
		uac.DelReg((*c_iter).c_str());
	}
	iErrorCode = uac.DoWork();
	lua_pushinteger(pLuaState, iErrorCode);
	return 1;

};


BOOL LuaAPIUtil::EnablePrivilegeHelper(HANDLE hProcess, LPCTSTR lpszName, BOOL fEnable)
{
	// Enabling the debug privilege allows the application to see
	// information about service applications
	BOOL fOk = FALSE;    // Assume function fails
	HANDLE hToken;

	// Try to open this process's access token
	if (OpenProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES, &hToken)) 
	{
		// Attempt to modify the "Debug" privilege
		TOKEN_PRIVILEGES tp;
		tp.PrivilegeCount = 1;
		LookupPrivilegeValue(NULL, lpszName, &tp.Privileges[0].Luid);

		tp.Privileges[0].Attributes = fEnable ? SE_PRIVILEGE_ENABLED : 0;
		AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);

		fOk = (GetLastError() == ERROR_SUCCESS);
		CloseHandle(hToken);
	}
	return(fOk);
}

void FreeProcessUserSID(PSID psid)
{
	::HeapFree(::GetProcessHeap(), 0, (LPVOID)psid);
}

BOOL GetProcessUserSidAndAttribute(PSID *ppsid, DWORD *pdwAttribute)
{
	if (NULL == ppsid || NULL == pdwAttribute) return FALSE;

	BOOL bRet = FALSE;

	BOOL bSuc = TRUE;
	DWORD dwLastError = ERROR_SUCCESS;

	HANDLE hProcessToken = NULL;
	bSuc = ::OpenProcessToken(::GetCurrentProcess(), TOKEN_QUERY, &hProcessToken);
	dwLastError = ::GetLastError();
	TSDEBUG4CXX(_T("OpenProcessToken(::GetCurrentProcess()) return ") << bSuc << _T(", LastError = ") << dwLastError
		<< _T(", hProcessToken = ") << hProcessToken);

	//////////////////////////////////////////////////////////////////////////
	if (bSuc && hProcessToken)
	{
		BYTE *pBuffer = NULL;
		DWORD cbBuffer = 0;
		DWORD cbBufferUsed = 0;
		bSuc = ::GetTokenInformation(hProcessToken, ::TokenUser, pBuffer, cbBuffer, &cbBufferUsed);
		dwLastError = ::GetLastError();
		if (ERROR_INSUFFICIENT_BUFFER == dwLastError)
		{
			pBuffer = new BYTE[cbBufferUsed];
			cbBuffer = cbBufferUsed;
			cbBufferUsed = 0;
			bSuc = ::GetTokenInformation(hProcessToken, ::TokenUser, pBuffer, cbBuffer, &cbBufferUsed);
			dwLastError = ::GetLastError();
			if (bSuc)
			{
				TOKEN_USER *pTokenUser = (TOKEN_USER *)pBuffer;
				DWORD dwLength = ::GetLengthSid(pTokenUser->User.Sid);
				*ppsid = (PSID)::HeapAlloc(::GetProcessHeap(), HEAP_ZERO_MEMORY, dwLength);
				if (*ppsid)
				{
					if (::CopySid(dwLength, *ppsid, pTokenUser->User.Sid))
					{
						*pdwAttribute = pTokenUser->User.Attributes;
						bRet = TRUE;
					}
					else
					{
						::HeapFree(::GetProcessHeap(), 0, (LPVOID)*ppsid);
					}
				}
			}

			delete [] pBuffer;
			pBuffer = NULL;
			cbBuffer = 0;
			cbBufferUsed = 0;
		}
	}
	//////////////////////////////////////////////////////////////////////////

	::CloseHandle(hProcessToken);
	hProcessToken = NULL;

	return bRet;
}

BOOL LuaAPIUtil::GetCurrentUserSIDHelper(PSID *ppSID)
{
	BOOL bSuc = FALSE;

	if (ppSID)
	{
		PSID psid = NULL;
		DWORD dwAttribute = 0;
		if (GetProcessUserSidAndAttribute(&psid, &dwAttribute))
		{
			*ppSID = psid;
			bSuc = TRUE;
		}
	}

	return bSuc;
}

BOOL LuaAPIUtil::SetNamedSecurityInfoHelper(LPSTR pszObjectName, SE_OBJECT_TYPE emObjectType, LPSTR pszAccessDesireds)
{
	typedef struct {
		const char* name;
		int desired;
		ACCESS_MODE mode;
	}RegAccessPermission, *RegAccessPermissionPtr;

	static RegAccessPermission filelookup[]= {
		{"ALL_ACCESS", FILE_ALL_ACCESS, SET_ACCESS},
		{"READ", FILE_READ_DATA, SET_ACCESS},
		{"WRITE", FILE_WRITE_DATA|FILE_APPEND_DATA, SET_ACCESS},
		{"~READ", FILE_READ_DATA, DENY_ACCESS},
		{"~WRITE", FILE_WRITE_DATA|FILE_APPEND_DATA, DENY_ACCESS},
		{NULL, 0},
	};

	static RegAccessPermission reglookup[]= {
		{"ALL_ACCESS", KEY_ALL_ACCESS, SET_ACCESS},
		{"READ", KEY_QUERY_VALUE|KEY_ENUMERATE_SUB_KEYS, SET_ACCESS},
		{"WRITE", KEY_SET_VALUE, SET_ACCESS},
		{"~READ", KEY_QUERY_VALUE|KEY_ENUMERATE_SUB_KEYS, DENY_ACCESS},
		{"~WRITE", KEY_SET_VALUE, DENY_ACCESS},
		{NULL, 0},
	};

	static RegAccessPermission nulllookup[]= {{NULL, 0}};

	const RegAccessPermissionPtr lookup = (emObjectType == SE_FILE_OBJECT) ? filelookup : (emObjectType == SE_REGISTRY_KEY) ? reglookup : nulllookup;
	if (pszObjectName && *pszObjectName && 
		pszAccessDesireds && *pszAccessDesireds)
	{
		BOOL bSuccess = EnablePrivilegeHelper(::GetCurrentProcess(), SE_DEBUG_NAME, TRUE);
		if (TRUE)
		{
			PSID pSID = NULL;
			PSECURITY_DESCRIPTOR pSecurityDescriptor = NULL;
			PACL pNewDAcl = NULL;
			PEXPLICIT_ACCESS pDAclEntries = NULL;

			__try
			{
				TSDEBUG(_T("About to get cur user sid"));
				bSuccess = GetCurrentUserSIDHelper(&pSID);
				if (!bSuccess) __leave;

				PACL pOldDAcl = NULL;
				DWORD dwRetCode = ERROR_SUCCESS;
				if (ERROR_SUCCESS != dwRetCode) __leave;

				pDAclEntries = (PEXPLICIT_ACCESS)::LocalAlloc(0, sizeof(EXPLICIT_ACCESS) * 10);
				if (!pDAclEntries) __leave;

				int cNumbersOfEntries = 0;
				const char* szAcessDesired = strtok(pszAccessDesireds, "|");
				BOOL bAcessDesiredExisted;
				while (szAcessDesired && *szAcessDesired)
				{
					bAcessDesiredExisted = FALSE;
					for (int i =0; lookup[i].name; ++i)
					{
						if (stricmp(szAcessDesired, lookup[i].name) == 0)
						{
							bAcessDesiredExisted = TRUE;
							BOOL bAccessModeExisted = FALSE;
							for (int cnt = 0; cnt < cNumbersOfEntries; ++cnt)
							{
								EXPLICIT_ACCESS& ea = pDAclEntries[cnt];
								if (ea.grfAccessMode == lookup[i].mode)
								{
									bAccessModeExisted = TRUE;
									ea.grfAccessPermissions |= lookup[i].desired;
									break;
								}
							}

							if (!bAccessModeExisted)
							{
								EXPLICIT_ACCESS& ea = pDAclEntries[cNumbersOfEntries];
								SecureZeroMemory(&ea, sizeof(EXPLICIT_ACCESS));
								ea.grfAccessPermissions = lookup[i].desired;
								ea.grfAccessMode = lookup[i].mode;
								ea.grfInheritance= SUB_CONTAINERS_AND_OBJECTS_INHERIT;
								ea.Trustee.TrusteeForm = TRUSTEE_IS_SID;
								ea.Trustee.ptstrName = (LPTSTR)pSID;
								++cNumbersOfEntries;
							}

							break;
						}
					}

					if (!bAcessDesiredExisted) __leave;

					szAcessDesired = strtok(NULL, "|");
				}

				if (cNumbersOfEntries > 0)
				{
					dwRetCode = ::SetEntriesInAcl(cNumbersOfEntries, pDAclEntries, NULL, &pNewDAcl);
					if (ERROR_SUCCESS != dwRetCode) __leave;

					TSDEBUG(_T("About to set sec info"));
					dwRetCode = ::SetNamedSecurityInfoA(
						pszObjectName, emObjectType, 
						DACL_SECURITY_INFORMATION,
						NULL, NULL, pNewDAcl, NULL);
					TSDEBUG(_T("End to set sec info"));

					if (ERROR_SUCCESS == dwRetCode)
					{
						return TRUE;
					}
				}
			}
			__finally
			{
				if (pSID)
				{
					FreeProcessUserSID(pSID);
				}

				if (pSecurityDescriptor)
					::LocalFree(pSecurityDescriptor);

				if (pNewDAcl)
					::LocalFree(pNewDAcl);
			}
		}
	}

	return FALSE;
}

int LuaAPIUtil::SetFileSecurity( lua_State* pLuaState )
{
	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		LPCSTR lpszFilePath = lua_tostring(pLuaState, 2); // utf8 string
		LPCSTR lpszAccessDesireds = lua_tostring(pLuaState, 3); // utf8 string
		if (lpszFilePath && *lpszFilePath)
		{
			if (QueryFileExistsHelper(lpszFilePath))
			{
				if (SetNamedSecurityInfoHelper((LPSTR)lpszFilePath, SE_FILE_OBJECT, (LPSTR)lpszAccessDesireds))
				{
					lua_pushboolean(pLuaState, true);
					return 1;
				}
			}
		}
	}

	lua_pushboolean(pLuaState, false);
	return 1;
}

int LuaAPIUtil::SetRegSecurity(lua_State* pLuaState)
{
	static struct {
		const char* name;
		const char* replace;
	}lookup[]= {
		{"HKEY_CLASSES_ROOT", "CLASSES_ROOT"},
		{"HKEY_CURRENT_USER", "CURRENT_USER"},
		{"HKEY_LOCAL_MACHINE", "MACHINE"},
		{"HKEY_USERS", "USERS"},
		{"HKEY_CURRENT_CONFIG", "CONFIG"},
		{0, 0},
	};

	LuaAPIUtil** ppUtil = (LuaAPIUtil **)luaL_checkudata(pLuaState, 1, API_UTIL_CLASS);
	if (ppUtil && *ppUtil)
	{
		LPCSTR lpszRegPath = lua_tostring(pLuaState, 2); // utf8 string
		LPCSTR lpszAccessDesireds = lua_tostring(pLuaState, 3); // utf8 string
		if (lpszRegPath && *lpszRegPath &&
			lpszAccessDesireds && *lpszAccessDesireds)
		{
			for (int i = 0; lookup[i].name; ++i)
			{
				if (::StrCmpNIA(lpszRegPath, lookup[i].name, strlen(lookup[i].name)) == 0)
				{
					char szNewRegPath[MAX_PATH + 1] = {0};
					::StrCatA(szNewRegPath, lookup[i].replace);
					::StrCatA(szNewRegPath, lpszRegPath + strlen(lookup[i].name));

					if (SetNamedSecurityInfoHelper(szNewRegPath, SE_REGISTRY_KEY, (LPSTR)lpszAccessDesireds))
					{
						lua_pushboolean(pLuaState, true);
						return 1;
					}
				}
			}
		}
	}

	lua_pushboolean(pLuaState, false);
	return 1;
}