// dllmain.h : Declaration of module class.

class CiekernelModule : public CAtlDllModuleT< CiekernelModule >
{
public :
	DECLARE_LIBID(LIBID_iekernelLib)
	DECLARE_REGISTRY_APPID_RESOURCEID(IDR_IEKERNEL, "{E041CCC0-BCA4-45A5-976E-0FA1CB53FCE8}")
};

extern class CiekernelModule _AtlModule;
