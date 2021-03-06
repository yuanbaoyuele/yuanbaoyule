#include <string>
#include <vector>
#ifdef YBNETFILTER_EXPORTS
#define YBNETFILTER_API extern "C"  __declspec(dllexport)
#else
#define YBNETFILTER_API extern "C" __declspec(dllimport)
#endif

YBNETFILTER_API BOOL YbEnable(BOOL bEnable, USHORT listen_port);
YBNETFILTER_API HANDLE YbStartProxy(USHORT* listen_port);
YBNETFILTER_API BOOL YbSetHook();
YBNETFILTER_API BOOL YbSetWebRoot(const wchar_t* root_path);
YBNETFILTER_API VOID GsEnableRedirect(BOOL bEnable);

//YBNETFILTER_API bool YbUpdateConfigVideoHost(const std::string& url,int istate = 0);
//YBNETFILTER_API bool YbUpdateConfigWhiteHost(const std::string& url,bool bEnable);
//YBNETFILTER_API bool YbGetWebRules(const std::wstring& filename);
YBNETFILTER_API bool YbGetVideoRules(const std::wstring& filename);
//YBNETFILTER_API bool YbGetUsersRules(const std::wstring& filename);
YBNETFILTER_API bool GsGetRedirectRules(const std::wstring& filename);
