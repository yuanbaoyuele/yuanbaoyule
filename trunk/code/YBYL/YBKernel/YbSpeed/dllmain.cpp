// dllmain.cpp : Defines the entry point for the DLL application.
#include "YbSpeedHook.h"

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		YbSpeedHook::Initialize();
		YbSpeedHook::AttachHook();
		break;
	case DLL_THREAD_ATTACH:
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		YbSpeedHook::DetachHook();
		break;
	}
	return TRUE;
}
