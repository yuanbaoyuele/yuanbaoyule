#pragma once

#define API_UTIL_CLASS	"API.Util.Class"
#define API_UTIL_OBJ		"API.Util"
#include "iekernel_i.h"
#include <AccCtrl.h>
#include "AddinHelper.h"
typedef std::map<IWebBrowser2*,ICBrowserHelper*> mapwebInterface;
typedef mapwebInterface::const_iterator citer_mapweb;

class LuaAPIUtil
{
public:
	LuaAPIUtil(void);
	~LuaAPIUtil(void);

private:
	static void ConvertAllEscape(std::string& strSrc);
	static std::string GetTableStr(lua_State* luaState, int nIndex, std::ofstream& ofs, const std::string strTableName, int nFloor);
	static __int64 GetFileSizeHelper(const char* utf8FileFullPath);
	static long QueryFileExistsHelper(const char*utf8FilePath);

	static BOOL GetHKEY(const char* utf8Root, HKEY &hKey);
	static long QueryRegValueHelper(const char* utf8Root,const char* utf8RegPath,const char* utf8Key, DWORD &dwType, std::string& utf8Result,  DWORD &dwValue, BOOL bWow64=FALSE);
	static long DeleteRegValueHelper(const char* utf8Root, const char* utf8Key, BOOL bWow64=FALSE);
	static long DeleteRegKeyHelper(const char* utf8Root, const char* utf8SubKey, BOOL bWow64=FALSE);
	static long CreateRegKeyHelper(const char* utf8Root, const char* utf8SubKey,BOOL bWow64=FALSE);
	static long SetRegValueHelper(const char* utf8Root, const char* utf8SubKey, const char* utf8ValueName,DWORD dwType, const char* utf8Data, DWORD dwValue = 0,BOOL bWow64=FALSE);

	//INI配置文件操作
	static long ReadIniHelper(const char* utf8FilePath,const char* utf8AppName,const char* utf8KeyName,std::string& utf8Result);
	static long WriteIniHelper(const char* utf8AppName, const char* utf8KeyName, const char* utf8String, const char* utf8FileName);
	static long ReadSectionsHelper(const char*  utf8Path, std::vector<std::string> & strSections);
	static long ReadKeyValueInSectionHelper(const char*  utf8Path, const char*  utf8Section, std::vector<std::string> & strKeyValue);


	static long OpenURLHelper(const char* utf8URL);
	static BOOL IsFullScreenHelper();
	static long ShellExecHelper(HWND hWnd, const char* lpOperation, const char* lpFile, const char* lpParameters, const char* lpDirectory, const char* lpShowCmd, int iShowCmd = -1);
	static long CopyPathFileHelper(const char* utf8ExistingFileName, const char* utf8NewFileName, BOOL bFailedIfExists);
	
	static void EncryptAESHelper(unsigned char* pszKey, const char* pszMsg, int& nBuff,char* out_str);
	static void DecryptAESHelper(unsigned char* pszKey, const char* pszMsg, int&nMsg,int& nBuff,char* out_str);
	

	//LRESULT CALLBACK  KeyboardProc(int code, WPARAM wParam, LPARAM lParam);
	enum ShortCutPosition
	{
		DESKTOP = 0,
		QUICKLAUNCH = 1, 
		COMMONDESKTOP = 2,
		CUSTOMPATH = 3
	};
	static bool CreateShortCutLinkHelper(
		const TCHAR* name, 
		const TCHAR* exepath, 
		ShortCutPosition position, 
		const TCHAR* iconpath, 
		const TCHAR* argument, 
		const TCHAR* description,
		const TCHAR* despath);
	static BOOL ElevateOperateHelper(lua_State* luaState, int nIndex,std::vector<std::wstring> &v_AddReg,std::vector<std::wstring> &v_DelReg);

	static BOOL EnablePrivilegeHelper(HANDLE hProcess, LPCTSTR lpszName, BOOL fEnable);
	static BOOL GetCurrentUserSIDHelper(PSID* pSID);
	static BOOL SetNamedSecurityInfoHelper(LPSTR pszObjectName, SE_OBJECT_TYPE emObjectType, LPSTR pszAccessDesireds);
	static long RegisterCOMHelper(const char* utf8FileName);
	static long UnRegisterCOMHelper(const char* utf8FileName);
public:
	static LuaAPIUtil * __stdcall Instance(void *);
	static void RegisterObj(XL_LRT_ENV_HANDLE hEnv);

public:
	//static int RegisterFilterWnd(lua_State* pLuaState);
	static int MsgBox(lua_State* pLuaState);
	static int LoadVideoRules(lua_State* pLuaState);
	static int FYBFilter(lua_State* pLuaState);
	//static int FYbSetWebRoot(lua_State* pLuaState);

	static int Exit(lua_State* pLuaState);
	static int GetPeerId(lua_State* pLuaState);
	static int Log(lua_State* pLuaState);
	static int SaveLuaTableToLuaFile(lua_State* pLuaState);
	static int GetCommandLine(lua_State* pLuaState);
	static int CommandLineToList(lua_State* pLuaState);
	static int GetModuleExeName(lua_State* pLuaState);


	//窗口
	static int GetWorkArea(lua_State* pLuaState);
	static int GetScreenArea(lua_State* pLuaState);
	static int GetScreenSize(lua_State* pLuaState);
	static int GetCursorPos(lua_State* pLuaState);
	static int PostWndMessage(lua_State* pLuaState);
	static int GetSysWorkArea(lua_State* pLuaState);
	static int GetCurrentScreenRect(lua_State* pLuaState);
	static int FGetDesktopWndHandle(lua_State *pLuaState);
	static int FSetWndPos(lua_State *pLuaState);
	static int FShowWnd(lua_State *pLuaState);
	static int FGetWndRect(lua_State *pLuaState);
	static int FGetWndClientRect(lua_State *pLuaState);
	static int FFindWindow(lua_State* pLuaState);
	static int FFindWindowEx(lua_State* pLuaState);
	static int FIsWindowVisible(lua_State* pLuaState);
	static int IsWindowIconic(lua_State* pLuaState);
	static int GetWindowTitle(lua_State* pLuaState);
	static int GetWndClassName(lua_State* pLuaState);
	static int GetWndProcessThreadId(lua_State* pLuaState);
	static int PostWndMessageByHandle(lua_State* pLuaState);
	static int SendMessageByHwnd(lua_State* pLuaState);
	static int IsNowFullScreen(lua_State* pLuaState);
	
	static int GetCursorWndHandle(lua_State* pLuaState);
	static int GetFocusWnd(lua_State* pLuaState);
	static int FGetKeyState(lua_State* pLuaState);

	static int FCreateParentWnd(lua_State* pLuaState);

	static int GetForegroundProcessInfo(lua_State* pLuaState);
	//文件
	static int GetMD5Value(lua_State* pLuaState);
	static int GetStringMD5(lua_State* pLuaState);
	static int GetFileVersionString(lua_State* pLuaState);
	static int GetSystemTempPath(lua_State* pLuaState);
	static int GetFileSize(lua_State* pLuaState);
	static int GetFileCreateTime(lua_State* pLuaState);
	static int GetTmpFileName(lua_State* pLuaState);
	static int GetSpecialFolderPathEx(lua_State* pLuaState);
	static int FindFileList(lua_State* pLuaState);
	static int FindDirList(lua_State* pLuaState);
	static int PathCombine(lua_State* pLuaState);
	static int ExpandEnvironmentString(lua_State* pLuaState);
	static int QueryFileExists(lua_State* pLuaState);
	static int Rename(lua_State* pLuaState);
	static int CreateDir(lua_State* pLuaState);
	static int CopyPathFile(lua_State* pLuaState);
	static int DeletePathFile(lua_State* pLuaState);
	static int GetUserPinPath(lua_State* pLuaState);
	// ReadFileToString 将指定全路径的文件读入到一个string中。
	// WriteStringToFile 将string全部内容写入到一个文件中。
	static int ReadFileToString(lua_State* pLuaState);
	static int WriteStringToFile(lua_State* pLuaState);

	
	//注册表操作
	static int QueryRegValue(lua_State* pLuaState);
	static int DeleteRegValue(lua_State* pLuaState);
	static int DeleteRegKey(lua_State* pLuaState);
	static int CreateRegKey(lua_State* pLuaState);
	static int SetRegValue(lua_State* pLuaState);
	static int QueryRegKeyExists(lua_State* pLuaState); //2011-12-14添加
	static int EnumRegLeftSubKey(lua_State* pLuaState);
	static int EnumRegRightSubKey(lua_State* pLuaState);
	static int QueryRegValue64(lua_State* pLuaState);
	static int DeleteRegValue64(lua_State* pLuaState);
	static int DeleteRegKey64(lua_State* pLuaState);
	static int CreateRegKey64(lua_State* pLuaState);
	static int SetRegValue64(lua_State* pLuaState);	

	//时间函数
	static int GetCurTimeSpan(lua_State* pLuaState);
	static int FormatCrtTime(lua_State* pLuaState);
	static int GetLocalDateTime(lua_State* pLuaState);
	static int GetCurrentUTCTime(lua_State* pLuaState);
	static int DateTime2Seconds(lua_State* pLuaState);
	static int Seconds2DateTime(lua_State* pLuaState);
	static int FileTime2LocalTime(lua_State* pLuaState);
	static int InternetTimeToUTCTime(lua_State* pLuaState);
	
	//互斥量函数
	static int CreateNamedMutex(lua_State* pLuaState);
	static int CloseNamedMutex(lua_State* pLuaState);

	
	//系统，进程
	static int FGetCurrentProcessId(lua_State* pLuaState);
	static int FGetAllSystemInfo(lua_State* pLuaState);
	static int FGetProcessIdFromHandle(lua_State* pLuaState);
	static int GetTotalTickCount(lua_State* pLuaState);
	static int GetOSVersionInfo(lua_State* pLuaState);
	static int QueryProcessExists(lua_State* pLuaState);
	static int IsWindows8Point1(lua_State* pLuaState);
	static int GetProcessElevation(lua_State* pLuaState);

	//功能
	static int CreateShortCutLinkEx(lua_State* pLuaState);
	static int OpenURL(lua_State* pLuaState);
	static int OpenURLIE(lua_State* pLuaState);	
	static int ShellExecuteEX(lua_State* pLuaState);

	static int EncryptAESToFile(lua_State* pLuaState);
	static int DecryptFileAES(lua_State* pLuaState);
	
	static int GetIEHistoryInfo(lua_State* pLuaState);
	
	static int DownloadFileByIE(lua_State* pLuaState);

	//INI配置文件操作
	static int ReadINI(lua_State* pLuaState);
	static int WriteINI(lua_State* pLuaState);
	static int ReadStringUtf8(lua_State* pLuaState);
	static int ReadSections(lua_State* pLuaState);
	static int ReadKeyValueInSection(lua_State* pLuaState);
	static int ReadINIInteger(lua_State* pLuaState);
	
	//文件对话框操作
	static int FileDialog(lua_State* pLuaState);
	//static int FolderDialog(lua_State* pLuaState);
	static int BrowserForFile(lua_State* pLuaState);

	//IE菜单
	static int IEMenu_SaveAs(lua_State* pLuaState);
	static int IEMenu_Zoom(lua_State* pLuaState);
	static int IEFavorite_Organize(lua_State* pLuaState);

	// 变速相关
	//static int YbSpeedInitialize(lua_State* pLuaState);
	//static int YbSpeedHook(lua_State* pLuaState);
	//static int YbSpeedUnhook(lua_State* pLuaState);
	//static int YbSpeedChangeRate(lua_State* pLuaState);

	static int FSetKeyboardHook(lua_State* pLuaState);
	static int FDelKeyboardHook(lua_State* pLuaState);

	static int AttachBrowserEvent(lua_State* pLuaState);
	static int DetachBrowserEvent(lua_State* pLuaState);

	static int PinToStartMenu4XP(lua_State* pLuaState);
	static int TrackPopUpSysMenu(lua_State* pLuaState);
	static int RefleshIcon(lua_State* pLuaState);

	//提权注册表
	static int ElevateOperate(lua_State* pLuaState);
	static int SetRegSecurity(lua_State* pLuaState);
	static int SetFileSecurity(lua_State* pLuaState);


	//
	static int WebBrowserExecuteScript(lua_State* pLuaState);

	//
	static int RunSH(lua_State* pLuaState);
	static int RegisterCOM(lua_State* pLuaState);
	static int UnRegisterCOM(lua_State* pLuaState);
	static int FSetProcessWorkingSetSize(lua_State* pLuaState);
	static int FSetEnvironmentVariable(lua_State *pLuaState);
	static int FGetEnvironmentVariable(lua_State *pLuaState);
private:
	static XLLRTGlobalAPI sm_LuaMemberFunctions[];
	static mapwebInterface m_mapweb;
	static AddinHelper m_addinHelper;
};
