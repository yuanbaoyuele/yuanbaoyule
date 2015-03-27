// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently,
// but are changed infrequently

#pragma once

#ifndef STRICT
#define STRICT
#endif

#include "targetver.h"

#define _ATL_APARTMENT_THREADED
#define _ATL_NO_AUTOMATIC_NAMESPACE

#define _ATL_CSTRING_EXPLICIT_CONSTRUCTORS	// some CString constructors will be explicit

#include "resource.h"
#include <atlbase.h>
#include <atlcom.h>
#include <atlctl.h>

using namespace ATL;

#include <windows.h>
// TODO: 在此处引用程序要求的附加头文件
// Windows Header Files:
#include <windows.h>
#include <shellapi.h>
#include <Shlobj.h>
#include <wininet.h>
#include <mapidbg.h>
// C RunTime Header Files
#include <stdlib.h>
#include <malloc.h>
#include <memory.h>
#include <tchar.h>
#include <time.h>
// STL Header Files
#pragma warning(disable:4702)
#include <string>
#include <vector>
#include <list>
#include <map>
#include <fstream>
#include <algorithm>
#pragma warning(default:4702)
//// ATL Header Files
//#include <atlbase.h>
//#include <atlcom.h>
//#include <atlctl.h>
//#include <atlwin.h>
//#include <atltypes.h>
//#include <atlfile.h>
//#include <atlcoll.h>
//#include <atlstr.h>
//#include <atlsecurity.h>
//#include <atltime.h>
// WTL Header Files
#include <WTL/atlapp.h>
#include <WTL/atldlgs.h>
#include <WTL/atlcrack.h>

// xlue Header Files
#include <XLI18N.h>
#include <XLUE.h>
#include <XLGraphic.h>
#include <XLGraphicPlus.h>
#include <XLLuaRuntime.h>

#include <XLFS.h>

// TODO: reference additional headers your program requires here
#define TSLOG
#define YB_GROUP "YB"	//可选,默认为 "TSLOG"
#include <tslog/tslog.h>

#include "LuaAPIHelper.h"

