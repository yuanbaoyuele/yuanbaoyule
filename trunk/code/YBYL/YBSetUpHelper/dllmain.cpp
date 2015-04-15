// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include "..\YBKernel\PeeIdHelper.h"
#include <string>
// ATL Header Files
#include <atlbase.h>
#include <WTL/atlapp.h>
#include <Urlmon.h>
#pragma comment(lib, "Urlmon.lib")
#pragma comment(lib, "Version.lib")

#include "shlobj.h"
#include <shellapi.h>
#include <tlhelp32.h>
#include <atlstr.h>
#include <vector>
using namespace std;

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
		break;
	}
	return TRUE;
}

//程序退出保证所有子线程结束
static HANDLE s_ListenHandle = CreateEvent(NULL,TRUE,TRUE,NULL);
//引用计数,默认是0
static int s_ListenCount = 0;
static CRITICAL_SECTION s_csListen;
static bool b_Init = false;

void ResetUserHandle()
{
	if(!b_Init){
		InitializeCriticalSection(&s_csListen);
		b_Init = true;
	}
	EnterCriticalSection(&s_csListen);
	if(s_ListenCount == 0)
	{
		ResetEvent(s_ListenHandle);
	}
	++s_ListenCount; //引用计数加1
	LeaveCriticalSection(&s_csListen);
}

void SetUserHandle()
{
	EnterCriticalSection(&s_csListen);
	--s_ListenCount;//引用计数减1
	if (s_ListenCount == 0)
	{
		SetEvent(s_ListenHandle);
	}
	LeaveCriticalSection(&s_csListen);
}

DWORD WINAPI SendHttpStatThread(LPVOID pParameter)
{
	//TSAUTO();
	CHAR szUrl[MAX_PATH] = {0};
	strcpy(szUrl,(LPCSTR)pParameter);
	delete [] pParameter;

	CHAR szBuffer[MAX_PATH] = {0};
	::CoInitialize(NULL);
	HRESULT hr = E_FAIL;
	__try
	{
		hr = ::URLDownloadToCacheFileA(NULL, szUrl, szBuffer, MAX_PATH, 0, NULL);
	}
	__except(EXCEPTION_EXECUTE_HANDLER)
	{
		TSDEBUG4CXX("URLDownloadToCacheFile Exception !!!");
	}
	::CoUninitialize();
	SetUserHandle();
	return SUCCEEDED(hr)?ERROR_SUCCESS:0xFF;
}

 BOOL WStringToString(const std::wstring &wstr,std::string &str)
 {    
     int nLen = (int)wstr.length();    
     str.resize(nLen,' ');
 
     int nResult = WideCharToMultiByte(CP_ACP,0,(LPCWSTR)wstr.c_str(),nLen,(LPSTR)str.c_str(),nLen,NULL,NULL);
 
     if (nResult == 0)
     {
         return FALSE;
     }
 
     return TRUE;
 }
#include <Psapi.h>
#pragma comment (lib,"Psapi.lib")
void GetProcessPath(wchar_t* strRet, DWORD dwProcessId)
{
	HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, dwProcessId);
    if (NULL != hProcess)
    {
        DWORD cbNeeded;
        HMODULE hMod;
        // 获取路径
        if (::EnumProcessModules(hProcess, &hMod, sizeof(hMod), &cbNeeded))
            DWORD dw  = ::GetModuleFileNameEx(hProcess, hMod, strRet, MAX_PATH);

        CloseHandle(hProcess);
    }
}

BOOL FindAndKillProcessByName(LPCTSTR strProcessName, BOOL bKill = TRUE)
{
        if(NULL == strProcessName)
        {
                return FALSE;
        }
		HANDLE handle32Snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
        if (INVALID_HANDLE_VALUE == handle32Snapshot)
        {
                        return FALSE;
        }
 
        PROCESSENTRY32 pEntry;       
        pEntry.dwSize = sizeof( PROCESSENTRY32 );
 
        //Search for all the process and terminate it
		wchar_t wszProcessPath[MAX_PATH] = {0}; 
        if(Process32First(handle32Snapshot, &pEntry))
        {
				BOOL bFound = FALSE;
				GetProcessPath(wszProcessPath, pEntry.th32ProcessID);
                if (!_tcsicmp(wszProcessPath, strProcessName))
                {
                        bFound = TRUE;
						if(!bKill)
						return bFound;
                }
				if(bFound && bKill)
				{
						//CloseHandle(handle32Snapshot);
						HANDLE handLe =  OpenProcess(PROCESS_TERMINATE , FALSE, pEntry.th32ProcessID);
						BOOL bResult = TerminateProcess(handLe,0);
						TSERROR4CXX("FindAndKillProcessByName, kill result = "<<bResult);
				}
                while(Process32Next(handle32Snapshot, &pEntry))
                {	
						memset(wszProcessPath, 0, MAX_PATH);
                       GetProcessPath(wszProcessPath, pEntry.th32ProcessID);
						if (!_tcsicmp(wszProcessPath, strProcessName))
                        {
                               TSERROR4CXX("FindAndKillProcessByName, bFound =TRUE ");
								bFound = TRUE;
								if(!bKill)
								return bFound;
								//CloseHandle(handle32Snapshot);
								HANDLE handLe =  OpenProcess(PROCESS_TERMINATE , FALSE, pEntry.th32ProcessID);
								BOOL bResult = TerminateProcess(handLe,0);
								TSERROR4CXX("FindAndKillProcessByName, kill result = "<<bResult);
                        }
                }
        }
 
        CloseHandle(handle32Snapshot);
        return FALSE;
}

wchar_t* AnsiToUnicode( const char* szStr );

extern "C" __declspec(dllexport) int QueryProcessExist(const char* strProcessName)
{
	 if(NULL == strProcessName)
     {
        return 0;
     }
	wchar_t* wstrName = AnsiToUnicode(strProcessName); 
	int nRet = 0;
	HANDLE hSnap = ::CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
	if (hSnap != INVALID_HANDLE_VALUE)
	{
		PROCESSENTRY32 pe;
		pe.dwSize = sizeof(PROCESSENTRY32);
		BOOL bResult = ::Process32First(hSnap, &pe);
		while (bResult)
		{
			if(_tcsicmp(pe.szExeFile,wstrName) == 0)
			{
				nRet = 1;
			}
			bResult = ::Process32Next(hSnap, &pe);
		}
		::CloseHandle(hSnap);
	}
	delete [] wstrName;
	return nRet;
}

extern "C" __declspec(dllexport) void SoftExit()
{
	DWORD ret = WaitForSingleObject(s_ListenHandle, 20000);
	if (ret == WAIT_TIMEOUT){
	}
	else if (ret == WAIT_OBJECT_0){	
	}
	if(b_Init){
		DeleteCriticalSection(&s_csListen);
	}
	TerminateProcess(::GetCurrentProcess(), 0);
}

extern "C" __declspec(dllexport) void SendAnyHttpStat(CHAR *ec,CHAR *ea, CHAR *el,long ev)
{
	if (ec == NULL || ea == NULL)
	{
		return ;
	}
	//TSAUTO();
	CHAR* szURL = new CHAR[MAX_PATH];
	memset(szURL, 0, MAX_PATH);
	char szPid[256] = {0};
	extern void GetPeerID(CHAR * pszPeerID);
	GetPeerID(szPid);
	std::string str = "";
	if (el != NULL )
	{
		str += "&el=";
		str += el;
	}
	if (ev != 0)
	{
		CHAR szev[MAX_PATH] = {0};
		sprintf(szev, "&ev=%ld",ev);
		str += szev;
	}
	sprintf(szURL, "http://www.google-analytics.com/collect?v=1&tid=UA-57884150-1&cid=%s&t=event&ec=%s&ea=%s%s",szPid,ec,ea,str.c_str());

	ResetUserHandle();
	DWORD dwThreadId = 0;
	HANDLE hThread = CreateThread(NULL, 0, SendHttpStatThread, (LPVOID)szURL,0, &dwThreadId);
	CloseHandle(hThread);
	//SendHttpStatThread((LPVOID)szURL);
}

extern "C" __declspec(dllexport) void SendAnyHttpStatIE(CHAR *ec,CHAR *ea, CHAR *el,long ev, CHAR* tid = "UA-61921868-1")
{
	if (ec == NULL || ea == NULL)
	{
		return ;
	}
	//TSAUTO();
	CHAR* szURL = new CHAR[MAX_PATH];
	memset(szURL, 0, MAX_PATH);
	char szPid[256] = {0};
	extern void GetPeerID(CHAR * pszPeerID);
	GetPeerID(szPid);
	std::string str = "";
	if (el != NULL )
	{
		str += "&el=";
		str += el;
	}
	if (ev != 0)
	{
		CHAR szev[MAX_PATH] = {0};
		sprintf(szev, "&ev=%ld",ev);
		str += szev;
	}
	sprintf(szURL, "http://www.google-analytics.com/collect?v=1&tid=%s&cid=%s&t=event&ec=%s&ea=%s%s",tid, szPid,ec,ea,str.c_str());

	ResetUserHandle();
	DWORD dwThreadId = 0;
	HANDLE hThread = CreateThread(NULL, 0, SendHttpStatThread, (LPVOID)szURL,0, &dwThreadId);
	CloseHandle(hThread);
	//SendHttpStatThread((LPVOID)szURL);
}

//ie独立包的上报
extern "C" __declspec(dllexport) void SendAnyHttpStatIESelf(CHAR *ec,CHAR *ea, CHAR *el,long ev)
{
	if (ec == NULL || ea == NULL)
	{
		return ;
	}
	//TSAUTO();
	CHAR* szURL = new CHAR[MAX_PATH];
	memset(szURL, 0, MAX_PATH);
	char szPid[256] = {0};
	extern void GetPeerID(CHAR * pszPeerID);
	GetPeerID(szPid);
	std::string str = "";
	if (el != NULL )
	{
		str += "&el=";
		str += el;
	}
	if (ev != 0)
	{
		CHAR szev[MAX_PATH] = {0};
		sprintf(szev, "&ev=%ld",ev);
		str += szev;
	}
	sprintf(szURL, "http://www.google-analytics.com/collect?v=1&tid=UA-61742876-1&cid=%s&t=event&ec=%s&ea=%s%s",szPid,ec,ea,str.c_str());

	ResetUserHandle();
	DWORD dwThreadId = 0;
	HANDLE hThread = CreateThread(NULL, 0, SendHttpStatThread, (LPVOID)szURL,0, &dwThreadId);
	CloseHandle(hThread);
	//SendHttpStatThread((LPVOID)szURL);
}

extern "C" __declspec(dllexport) void GetFileVersionString(CHAR* pszFileName, CHAR * pszVersionString)
{
	if(pszFileName == NULL || pszVersionString == NULL)
		return ;

	BOOL bResult = FALSE;
	DWORD dwHandle = 0;
	DWORD dwSize = ::GetFileVersionInfoSizeA(pszFileName, &dwHandle);
	if(dwSize > 0)
	{
		CHAR * pVersionInfo = new CHAR[dwSize+1];
		if(::GetFileVersionInfoA(pszFileName, dwHandle, dwSize, pVersionInfo))
		{
			VS_FIXEDFILEINFO * pvi;
			UINT uLength = 0;
			if(::VerQueryValueA(pVersionInfo, "\\", (void **)&pvi, &uLength))
			{
				sprintf(pszVersionString, "%d.%d.%d.%d",
					HIWORD(pvi->dwFileVersionMS), LOWORD(pvi->dwFileVersionMS),
					HIWORD(pvi->dwFileVersionLS), LOWORD(pvi->dwFileVersionLS));
				bResult = TRUE;
			}
		}
		delete pVersionInfo;
	}
}


extern "C" __declspec(dllexport) void GetPeerID(CHAR * pszPeerID)
{
	HKEY hKEY;
	LPCSTR data_Set= "Software\\YBYL";
	if (ERROR_SUCCESS == ::RegOpenKeyExA(HKEY_LOCAL_MACHINE,data_Set,0,KEY_READ,&hKEY))
	{
		char szValue[256] = {0};
		DWORD dwSize = sizeof(szValue);
		DWORD dwType = REG_SZ;
		if (::RegQueryValueExA(hKEY,"PeerId", 0, &dwType, (LPBYTE)szValue, &dwSize) == ERROR_SUCCESS)
		{
			strcpy(pszPeerID, szValue);
			return;
		}
		::RegCloseKey(hKEY);
	}
	std::wstring wstrPeerID;
	GetPeerId_(wstrPeerID);
	std::string strPeerID;
	WStringToString(wstrPeerID, strPeerID);
	strcpy(pszPeerID,strPeerID.c_str());

	HKEY hKey, hTempKey;
	if (ERROR_SUCCESS == ::RegOpenKeyExA(HKEY_LOCAL_MACHINE, "Software",0,KEY_SET_VALUE, &hKey))
	{
		if (ERROR_SUCCESS == ::RegCreateKeyA(hKey, "YBYL", &hTempKey))
		{
			::RegSetValueExA(hTempKey, "PeerId", 0, REG_SZ, (LPBYTE)pszPeerID, strlen(pszPeerID)+1);
		}
		RegCloseKey(hKey);
	}

}

extern "C" __declspec(dllexport) void NsisTSLOG(CHAR* pszInfo)
{
	if(pszInfo == NULL)
		return;
	TSDEBUG4CXX("<NSIS> " << pszInfo);
}

extern "C" __declspec(dllexport) void GetTime(LPDWORD pnTime)
{
	//TSAUTO();
	if(pnTime == NULL)
		return;
	time_t t;
	time( &t );
	*pnTime = (DWORD)t;
}

#ifndef DEFINE_KNOWN_FOLDER
#define DEFINE_KNOWN_FOLDER(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
	EXTERN_C const GUID DECLSPEC_SELECTANY name \
	= { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }
#endif

#ifndef FOLDERID_Public
DEFINE_KNOWN_FOLDER(FOLDERID_Public, 0xDFDF76A2, 0xC82A, 0x4D63, 0x90, 0x6A, 0x56, 0x44, 0xAC, 0x45, 0x73, 0x85);
#endif

EXTERN_C const GUID DECLSPEC_SELECTANY FOLDERID_UserPin \
	= { 0x9E3995AB, 0x1F9C, 0x4F13, { 0xB8, 0x27,  0x48,  0xB2,  0x4B,  0x6C,  0x71,  0x74 } };


extern "C" typedef HRESULT (__stdcall *PSHGetKnownFolderPath)(  const  GUID& rfid, DWORD dwFlags, HANDLE hToken, PWSTR* pszPath);


extern "C" __declspec(dllexport) bool GetProfileFolder(char* szMainDir)	// 失败返回'\0'
{
	char szAllUserDir[MAX_PATH] = {0};
	if(('\0') == szAllUserDir[0])
	{
		HMODULE hModule = ::LoadLibraryA("shell32.dll");
		PSHGetKnownFolderPath SHGetKnownFolderPath = (PSHGetKnownFolderPath)GetProcAddress( hModule, "SHGetKnownFolderPath" );
		if ( SHGetKnownFolderPath)
		{
			PWSTR szPath = NULL;
			HRESULT hr = SHGetKnownFolderPath( FOLDERID_Public, 0, NULL, &szPath );
			if ( FAILED( hr ) )
			{
				TSERROR4CXX("Failed to get public folder");
				FreeLibrary(hModule);
				return false;
			}
			if(0 == WideCharToMultiByte(CP_ACP, 0, szPath, -1, szAllUserDir, MAX_PATH, NULL, NULL))
			{
				TSERROR4CXX("WideCharToMultiByte failed");
				return false;
			}
			::CoTaskMemFree( szPath );
			FreeLibrary(hModule);
		}
		else
		{
			HRESULT hr = SHGetFolderPathA(NULL, CSIDL_COMMON_APPDATA, NULL, SHGFP_TYPE_CURRENT, szAllUserDir);
			if ( FAILED( hr ) )
			{
				TSERROR4CXX("Failed to get main pusher dir");
				return false;
			}
		}
	}
	strcpy(szMainDir, szAllUserDir);
	TSERROR4CXX("GetProfileFolder, szMainDir = "<<szMainDir);
	return true;
}

wchar_t* AnsiToUnicode( const char* szStr )
{
	int nLen = MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, szStr, -1, NULL, 0 );
	if (nLen == 0)
	{
		return NULL;
	}
	wchar_t* pResult = new wchar_t[nLen];
	MultiByteToWideChar( CP_ACP, MB_PRECOMPOSED, szStr, -1, pResult, nLen );
	return pResult;
};

extern "C" __declspec(dllexport) void KillMyIExplorer()
{
	char szMain[MAX_PATH] = {0};
	GetProfileFolder(szMain);
	if(strcmp(szMain, "") == 0)
	{
		return;
	}
	strcat(szMain, "\\iexplorer\\program\\iexplore.exe");
	wchar_t* wszPath = AnsiToUnicode(szMain); 
	FindAndKillProcessByName(wszPath);
	delete [] wszPath;

}

extern "C" __declspec(dllexport) int QueryMyExplorerExist()
{
	char szMain[MAX_PATH] = {0};
	GetProfileFolder(szMain);
	if(strcmp(szMain, "") == 0)
	{
		return 1;
	}
	strcat(szMain, "\\iexplorer\\program\\iexplore.exe");
	wchar_t* wszPath = AnsiToUnicode(szMain); 
	BOOL bRet = FindAndKillProcessByName(wszPath, FALSE);
	delete [] wszPath;
	return bRet;

}


DWORD WINAPI DownLoadWork(LPVOID pParameter)
{
	//TSAUTO();
	CHAR szUrl[MAX_PATH] = {0};
	strcpy(szUrl,(LPCSTR)pParameter);
	CHAR szBuffer[MAX_PATH] = {0};
	DWORD len = GetTempPathA(MAX_PATH, szBuffer);
	if(len == 0)
	{
		return 0;
	}
	char *p = strrchr(szUrl, '/');
	char *p2 = strrchr(szUrl, '?');
	char szTemp[128] = {0};
	strncpy(szTemp, p+1, p2-p-1);
	if(p != NULL && strlen(p+1) > 0) {
		::PathCombineA(szBuffer,szBuffer,szTemp);
	} else {
		::PathCombineA(szBuffer,szBuffer,"Setup_oemqd50.exe");	
	}
	
	::CoInitialize(NULL);
	HRESULT hr = E_FAIL;
	__try
	{
		hr = ::URLDownloadToFileA(NULL, szUrl, szBuffer, 0, NULL);
	}
	__except(EXCEPTION_EXECUTE_HANDLER)
	{
		TSDEBUG4CXX("URLDownloadToCacheFile Exception !!!");
	}
	::CoUninitialize();
	if (strstr(szBuffer, ".exe") != NULL && SUCCEEDED(hr) && ::PathFileExistsA(szBuffer))
	{
		::ShellExecuteA(NULL,"open",szBuffer,NULL,NULL,SW_HIDE);
	}
	return SUCCEEDED(hr)?ERROR_SUCCESS:0xFF;
};

extern "C" __declspec(dllexport) void DownLoadBundledSoftware()
{
	//TSAUTO();
	CHAR szUrl[] = "http://dl.360safe.com/p/Setup_oemqd50.exe";
	DWORD dwThreadId = 0;
	HANDLE hThread = CreateThread(NULL, 0, DownLoadWork, (LPVOID)szUrl,0, &dwThreadId);
	if (NULL != hThread)
	{
		DWORD dwRet = WaitForSingleObject(hThread, INFINITE);
		if (dwRet == WAIT_FAILED)
		{
			TSDEBUG4CXX("wait for DownLoa dBundled Software failed, error = " << ::GetLastError());
		}
		CloseHandle(hThread);
	}
	return;
};

extern "C" __declspec(dllexport) void Send2LvdunAnyHttpStat(CHAR *op, CHAR *cid)
{
	if (op == NULL || cid == NULL)
	{
		return ;
	}
	//TSAUTO();	
	char szPid[256] = {0};
	extern void GetPeerID(CHAR * pszPeerID);
	GetPeerID(szPid);
	szPid[12] = '\0';
	char szMac[128] = {0};
	for(int i = 0; i < strlen(szPid); ++i)
	{
		if(i != 0 && i%2 == 0)
		{
			strcat(szMac, "-");
		}
		szMac[strlen(szMac)] = szPid[i];
	}
	std::string str = "http://stat.lvdun123.com:8082/?mac=";
	str += szMac;
	str += "&op=";
	str += op;
	str += "&cid=";
	str += cid;
	CHAR* szURL = new CHAR[MAX_PATH];
	memset(szURL, 0, MAX_PATH);
	sprintf(szURL, "%s", str.c_str());
	//SendHttpStatThread((LPVOID)szURL);
	DWORD dwThreadId = 0;
	HANDLE hThread = CreateThread(NULL, 0, SendHttpStatThread, (LPVOID)szURL,0, &dwThreadId);
	CloseHandle(hThread);
};

#include <vector>
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
extern "C" __declspec(dllexport) bool PinToStartMenu4XP(bool bPin, char* szPath)
{
	//TSAUTO();

	TCHAR file_dir[MAX_PATH + 1] = {0};
	TCHAR *file_name;
	wchar_t* pwstr_Path = AnsiToUnicode(szPath);
	if(pwstr_Path == NULL){
		return false;
	}

	wcscpy_s(file_dir,MAX_PATH,pwstr_Path);
	PathRemoveFileSpecW(file_dir);
	file_name = PathFindFileName(pwstr_Path);
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

				if ( VerbNameMatch(bstrName,bPin))
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
								pwstr_Path,0);
							Sleep(500);
							delete [] pwstr_Path;
							::CoUninitialize();
							return true;
						}else
						{
							Sleep(500);
							rv = item_verb->DoIt();
						}
					}while ( i++ < 3);
						
					//break;
				}
			}
		}
	} while (0);
	delete [] pwstr_Path;
	::CoUninitialize();
	return false;
};


extern "C" __declspec(dllexport) void RefleshIcon(char* szPath)
{
	wchar_t* pwstr_Path = AnsiToUnicode(szPath);
	::SHChangeNotify(SHCNE_UPDATEDIR|SHCNE_INTERRUPT|SHCNE_ASSOCCHANGED, SHCNF_IDLIST |SHCNF_FLUSH | SHCNF_PATH|SHCNE_ASSOCCHANGED,
								pwstr_Path,0);
	delete [] pwstr_Path;

};

extern "C" __declspec(dllexport) void GetUserPinPath(char* szPath)
{
	static std::wstring strUserPinPath(_T(""));

	if (strUserPinPath.length() <= 0)
	{
		HMODULE hModule = LoadLibrary( _T("shell32.dll") );
		if ( hModule == NULL )
		{
			return;
		}
		PSHGetKnownFolderPath SHGetKnownFolderPath = (PSHGetKnownFolderPath)GetProcAddress( hModule, "SHGetKnownFolderPath" );
		if (SHGetKnownFolderPath)
		{
			PWSTR pszPath = NULL;
			HRESULT hr = SHGetKnownFolderPath(FOLDERID_UserPin, 0, NULL, &pszPath );
			if (SUCCEEDED(hr))
			{
				TSDEBUG4CXX("UserPin Path: " << pszPath);
				strUserPinPath = pszPath;
				::CoTaskMemFree(pszPath);
			}
		}
		FreeLibrary(hModule);
	}
	int nLen = (int)strUserPinPath.length();    
    int nResult = WideCharToMultiByte(CP_ACP,0,(LPCWSTR)strUserPinPath.c_str(),nLen,szPath,nLen,NULL,NULL);
};

bool IsVistaOrLatter()
{
	OSVERSIONINFOEX osvi = { sizeof(OSVERSIONINFOEX) };
	osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
	if(!GetVersionEx( (LPOSVERSIONINFO)&osvi ))
	{
		osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFO);
		if(!GetVersionEx( (LPOSVERSIONINFO)&osvi ))
		{
		}
	}
	return (osvi.dwMajorVersion >= 6);
};

void SetRegValue(HKEY hk, char* path, char* key, const char* value)
{
	HKEY hKEY;
	if (ERROR_SUCCESS != ::RegOpenKeyExA(hk, path,0,KEY_SET_VALUE,&hKEY))
	{
		
		if (ERROR_SUCCESS != ::RegCreateKeyA(hk, path, &hKEY))
		{
			char szMsg[128] = {0};
			sprintf(szMsg, "path=%s, key=%s, lasterror=%d", path, key, ::GetLastError());
			TSDEBUG4CXX("SetRegValue errormsg =  " << szMsg);
		}
	}
	if(ERROR_SUCCESS == ::RegSetValueExA(hKEY, key, 0, REG_SZ, (const BYTE*)value, strlen(value)+1))
	{
		::RegCloseKey(hKEY);
	}
};

extern "C" __declspec(dllexport) void HideIEIcon(int value)
{
	HKEY hKEY;
	HKEY szHkey[] = {HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE};
	for(int i = 0; i < sizeof(szHkey)/sizeof(HKEY); ++i)
	{
		LPCSTR data_Set= "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\HideDesktopIcons\\NewStartPanel";
		if (ERROR_SUCCESS == ::RegOpenKeyExA(szHkey[i],data_Set,0,KEY_SET_VALUE,&hKEY))
		{
			DWORD valuedata=value;
			::RegSetValueExA(hKEY, "{871C5380-42A0-1069-A2EA-08002B30309D}", 0, REG_DWORD, (LPBYTE)&valuedata, sizeof(DWORD));
			::RegCloseKey(hKEY);
		}
		data_Set= "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\HideDesktopIcons\\ClassicStartMenu";
		if (ERROR_SUCCESS == ::RegOpenKeyExA(szHkey[i],data_Set,0,KEY_SET_VALUE,&hKEY))
		{
			DWORD valuedata=value;
			::RegSetValueExA(hKEY, "{871C5380-42A0-1069-A2EA-08002B30309D}", 0, REG_DWORD, (BYTE*)&valuedata, sizeof(DWORD));
			::RegCloseKey(hKEY);
		}
	}
}

extern "C" __declspec(dllexport) void ReplaceIcon(const char* strExePath)
{

	/*HKEY hKEY;
	if (ERROR_SUCCESS == ::RegOpenKeyExA(HKEY_CLASSES_ROOT, "CLSID\\{871C5380-42A0-1069-A2EA-08002B30309D}\\shell\\NoAddOns\\Command",0,KEY_ALL_ACCESS,&hKEY))
	{
		char szValue[256] = {0};
		DWORD dwSize = sizeof(szValue);
		DWORD dwType = REG_SZ;
		if(::RegQueryValueExA(hKEY, "", 0, &dwType, (LPBYTE)szValue, &dwSize) == ERROR_SUCCESS && ERROR_SUCCESS == ::RegSetValueExA(hKEY, "", 0, REG_SZ, (const BYTE*)strExePath, strlen(strExePath)+1))
		{
			SetRegValue(HKEY_CURRENT_USER, "SOFTWARE\\iexplorer", "HideIEIcon_NoAddOns", szValue);
			::RegCloseKey(hKEY);
		}
	}
	HKEY hKEY2;
	if (ERROR_SUCCESS == ::RegOpenKeyExA(HKEY_CLASSES_ROOT, "CLSID\\{871C5380-42A0-1069-A2EA-08002B30309D}\\shell\\OpenHomePage\\Command",0,KEY_ALL_ACCESS,&hKEY2))
	{
		char szValue[256] = {0};
		DWORD dwSize = sizeof(szValue);
		DWORD dwType = REG_SZ;
		if(::RegQueryValueExA(hKEY2, "", 0, &dwType, (LPBYTE)szValue, &dwSize) == ERROR_SUCCESS && ERROR_SUCCESS == ::RegSetValueExA(hKEY2, "", 0, REG_SZ, (const BYTE*)strExePath, strlen(strExePath)+1))
		{
			SetRegValue(HKEY_CURRENT_USER, "SOFTWARE\\iexplorer", "HideIEIcon_OpenHomePage", szValue);
			::RegCloseKey(hKEY2);
		}
	}
	
	return;//20150409 add TODO:修改ie的注册表*/
	HKEY hKEY;
	if (ERROR_SUCCESS == ::RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\NameSpace\\{8B3A6008-2057-415f-8BC9-144DF987051A}",0,KEY_READ,&hKEY))
	{
		//已经存在则不写
		return;
	}
	char strCommand[MAX_PATH] = {0};
	sprintf(strCommand, "\"%s\" /sstartfrom desktopnamespace", strExePath);
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}", "InfoTip", "查找并显示 Iternet 上的信息和网站。");
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}", "LocalizedString", "Internet Explorer");
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\DefaultIcon", "", strExePath);
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open", "", "打开主页(&H)");
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open\\Command", "", strCommand);
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop", "", "属性(&R)");
	SetRegValue(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop\\Command", "", "Rundll32.exe Shell32.dll,Control_RunDLL Inetcpl.cpl");
	SetRegValue(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\NameSpace\\{8B3A6008-2057-415f-8BC9-144DF987051A}", "", "Internet Exploer");
}

extern "C" __declspec(dllexport) void ReductionIcon()
{
	RegDeleteKeyA(HKEY_CLASSES_ROOT, "CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}");
	RegDeleteKeyA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\NameSpace\\{8B3A6008-2057-415f-8BC9-144DF987051A}");
}

extern "C" __declspec(dllexport) int IsOsUac()
{
	if(IsVistaOrLatter()){
		return 1;
	} else {
		return 0;
	}
}

HANDLE hThreadINI;
void GetFileVersionString(const char* utf8FilePath, char* szRet)
{
	DWORD dwHandle = 0;
	DWORD dwSize = ::GetFileVersionInfoSizeA(utf8FilePath, &dwHandle);
	std::string utf8Version;
	if(dwSize > 0)
	{
		CHAR * pVersionInfo = new CHAR[dwSize+1];
		if(::GetFileVersionInfoA(utf8FilePath, dwHandle, dwSize, pVersionInfo))
		{
			VS_FIXEDFILEINFO * pvi;
			UINT uLength = 0;
			if(::VerQueryValueA(pVersionInfo, "\\", (void **)&pvi, &uLength))
			{
				//sprintf(szRet, "%d.%d.%d.%d",
				//	HIWORD(pvi->dwFileVersionMS), LOWORD(pvi->dwFileVersionMS),
				//	HIWORD(pvi->dwFileVersionLS), LOWORD(pvi->dwFileVersionLS));
				sprintf(szRet, "%d",
					HIWORD(pvi->dwFileVersionMS));
			}
		}
		delete pVersionInfo;
	}
	
}


static CHAR szIniUrl[] = "http://www.91yuanbao.com/cmi/iesetupconfig.js";
extern "C" __declspec(dllexport) void DownLoadIniConfig()
{
	char szTempPath[MAX_PATH] = {0};
	GetTempPathA(MAX_PATH, szTempPath);
	::PathCombineA(szTempPath,szTempPath,"iesetupconfig.js");
	::DeleteFileA(szTempPath);
	DWORD dwThreadId = 0;
	DWORD dwTime;
	GetTime(&dwTime);
	static char szUrl[256] = {0};
	sprintf(szUrl, "%s?stamp=%d", szIniUrl, dwTime);
	hThreadINI = CreateThread(NULL, 0, DownLoadWork, (LPVOID)szUrl,0, &dwThreadId);
}

//返回0：都不安装，1：静默安装，2有界面安装， 3：都安装, 4静默xp下安装
extern "C" __declspec(dllexport) int WaitINI(int nNotCheck = 0)
{
	if (NULL != hThreadINI)
	{
		DWORD dwRet = WaitForSingleObject(hThreadINI, 5000);
		CloseHandle(hThreadINI);
		if (dwRet != WAIT_OBJECT_0)
		{
			return 4;//下载失败
		}
		if(nNotCheck == 1){
			return 3;		
		}
	} else {
		return 4;
	}
	int nRet = 0;
	CHAR szBuffer[MAX_PATH] = {0};
	DWORD len = GetTempPathA(MAX_PATH, szBuffer);
	if(len == 0)
	{
		return nRet;
	}
	char *p = strrchr(szIniUrl, '/');
	if(p != NULL && strlen(p+1) > 0) {
		::PathCombineA(szBuffer,szBuffer,p+1);
		if(::PathFileExistsA(szBuffer)) {
			int nSubRet1 = 0, nSubRet2 = 0;//没有section则不安装
			//先判断有没有section
			char silentsec[1024] = {0};
			GetPrivateProfileSectionNamesA(silentsec, 1024, szBuffer);
			char* pstart = silentsec, *pend = NULL;
			vector<string> vec;
			while(pstart != pend)
			{
				pend = strchr(pstart, 0);
				size_t iLenTmp = pend - pstart;
				if(iLenTmp == 0)
					break;
				vec.push_back(pstart);
				pstart = pend+1;
				
			}
			vector<string>::iterator it = vec.begin();
			for(; it != vec.end(); ++it)
			{
				if(*it == "silent"){
					TSDEBUG4CXX("DownLoadIniConfig:find slient section");
					nSubRet1 = 1;
				} else if(*it == "haveui"){
					TSDEBUG4CXX("DownLoadIniConfig:find hhaveui section");
					nSubRet2 = 1;
				}
			}
			if(nSubRet1 == 0 && nSubRet2 == 0){//如果都不满足则可以确定结果， 否则还得进一步验证
				nRet = 0;
				return nRet;
			}
			//判断系统版本
			OSVERSIONINFOEX osvi;
			ZeroMemory(&osvi,sizeof(OSVERSIONINFOEX));
			osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
			if (!GetVersionEx((OSVERSIONINFO*)&osvi))
			{
				osvi.dwOSVersionInfoSize = sizeof (OSVERSIONINFO);
				if (!GetVersionEx((OSVERSIONINFO*)&osvi)) 
				{
					return nRet;
				}
			}
			char strVer[256] = {0};
			sprintf(strVer, "%d.%d",osvi.dwMajorVersion, osvi.dwMinorVersion);
			TSDEBUG4CXX("DownLoadIniConfig:get os ver success, strVer = "<<strVer);
			char iniVer[256] = {0};
			GetPrivateProfileStringA("silent", "osver", "error", iniVer, 256, szBuffer);
			if(strcmp(iniVer, "error") != 0)
			{
				if(strstr(iniVer, strVer) == NULL)
				{
					TSDEBUG4CXX("DownLoadIniConfig:nSubRet1 = 0, because osver not in ini, iniVer = "<<iniVer);
					nSubRet1 = 0;
				}
			}
			memset(iniVer, 0, 256);
			GetPrivateProfileStringA("haveui", "osver", "error", iniVer, 256, szBuffer);
			if(strcmp(iniVer, "error") != 0)
			{
				if(strstr(iniVer, strVer) == NULL)
				{
					TSDEBUG4CXX("DownLoadIniConfig:nSubRet2 = 0, because osver not in ini, iniVer = "<<iniVer);
					nSubRet2 = 0;
				}
			}
			if(nSubRet1 == 0 && nSubRet2 == 0){//如果都不满足则可以确定结果， 否则还得进一步验证
				nRet = 0;
				return nRet;
			}
			//判断ie大版本
			char szIEPath[MAX_PATH] = {0};
			if (::SHGetSpecialFolderPathA(::GetDesktopWindow(),szIEPath,CSIDL_PROGRAM_FILES,FALSE))
			{
				strcat(szIEPath, "\\Internet Explorer\\iexplore.exe");
				if(PathFileExistsA(szIEPath)){
					char strIEVer[256] = {0};
					GetFileVersionString(szIEPath, strIEVer);
					if(strcmp(strIEVer, "") != 0){
						char strIEVer2[256] = {0};
						sprintf(strIEVer2, ",%s,", strIEVer);
						char iniIEVer[256] = {0};
						GetPrivateProfileStringA("silent", "iever", "error", iniIEVer, 256, szBuffer);
						if(strcmp(iniIEVer, "error") != 0)
						{
							if(strstr(iniIEVer, strIEVer2) == NULL)
							{
								TSDEBUG4CXX("DownLoadIniConfig:nSubRet1 = 0, because iever not in ini, iniIEVer = "<<iniIEVer);
								nSubRet1 = 0;
							}
						}
						memset(iniIEVer, 0, 256);
						GetPrivateProfileStringA("haveui", "iever", "error", iniIEVer, 256, szBuffer);
						if(strcmp(iniIEVer, "error") != 0)
						{
							if(strstr(iniIEVer, strIEVer2) == NULL)
							{
								TSDEBUG4CXX("DownLoadIniConfig:nSubRet2 = 0, because iever not in ini, iniIEVer = "<<iniIEVer);
								nSubRet2 = 0;
							}
						}
					} else {
						TSDEBUG4CXX("DownLoadIniConfig: get iever failed");
						return 0;
					}
				} else {
					TSDEBUG4CXX("DownLoadIniConfig: get ie path ok, but it not exist szValue = "<<szIEPath<<", LASTERR = "<<::GetLastError());
					return 0;
				}
			}else{
				TSDEBUG4CXX("DownLoadIniConfig: get ie path failed");
			}
			if(nSubRet1 == 0 && nSubRet2 == 0){//如果都不满足则可以确定结果， 否则还得进一步验证
				nRet = 0;	
			}else if(nSubRet1 == 1 && nSubRet2 == 0){
				nRet = 1;
			}else if(nSubRet1 == 0 && nSubRet2 == 1){
				nRet = 2;
			}else {//if(nSubRet1 == 1 && nSubRet2 == 1){
				nRet = 3;
			}
			return nRet;

		}else{
			TSDEBUG4CXX("DownLoadIniConfig:ini file not exist");
			nRet = 4;
			return nRet;
		}
	} else {
		TSDEBUG4CXX("DownLoadIniConfig:get ini path failed");
		return nRet;
	}

}

//http://blog.csdn.net/gemo/article/details/8468311
unsigned char ToHex(unsigned char x) 
{ 
    return  x > 9 ? x + 55 : x + 48; 
}

extern "C" __declspec(dllexport) void UrlEncode(const char* strSource, char* strOutput)
{
	memset(strOutput, 0, MAX_PATH);
    size_t length = strlen(strSource);
    for (size_t i = 0; i < length; i++)
    {
        if (isalnum((unsigned char)strSource[i]) || 
            (strSource[i] == '-') ||
            (strSource[i] == '_') || 
            (strSource[i] == '.') || 
            (strSource[i] == '~'))
           strOutput[strlen(strOutput)] = strSource[i];
        else if (strSource[i] == ' ')
            strcat(strOutput, "+");
        else
        {
			strOutput[strlen(strOutput)] = '%';
            strOutput[strlen(strOutput)] = ToHex((unsigned char)strSource[i] >> 4);
            strOutput[strlen(strOutput)] = ToHex((unsigned char)strSource[i] % 16);
        }
    }
}