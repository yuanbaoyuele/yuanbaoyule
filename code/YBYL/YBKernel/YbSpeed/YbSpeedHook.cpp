
#include "YbSpeedHook.h"
#include "detours.h"
#include <sstream>
#include <string>
#include <cfloat>
#define TSLOG
#define YB_GROUP "YB"
#include <tslog/tslog.h>

YbSpeedHook::GetTickCount_FuncType YbSpeedHook::Real_GetTickCount = ::GetTickCount;
YbSpeedHook::timeGetTime_FuncType YbSpeedHook::Real_timeGetTime = ::timeGetTime;
YbSpeedHook::QueryPerformanceCounter_FuncType YbSpeedHook::Real_QueryPerformanceCounter = ::QueryPerformanceCounter;

XMLib::CriticalSection YbSpeedHook::cs;
DWORD YbSpeedHook::dwLastGetTickCountRealValue = 0;
DWORD YbSpeedHook::dwLastGetTickCountCheatValue = 0;
DWORD YbSpeedHook::dwLasttimeGetTimeRealValue = 0;
DWORD YbSpeedHook::dwLasttimeGetTimeCheatValue = 0;
LONGLONG YbSpeedHook::llLastQueryPerformanceCounterRealValue = 0;
LONGLONG YbSpeedHook::llLastQueryPerformanceCounterCheatValue = 0;
double YbSpeedHook::Rate = 1.0;

DWORD WINAPI YbSpeedHook::Hooked_GetTickCount()
{
	// TSAUTO();
	XMLib::CriticalSectionLockGuard lck(cs);
	DWORD dwTickCount = YbSpeedHook::Real_GetTickCount();
	if(dwTickCount > dwLastGetTickCountRealValue) {
		dwLastGetTickCountCheatValue = static_cast<DWORD>(static_cast<double>(dwLastGetTickCountCheatValue) + (static_cast<double>(dwTickCount) - static_cast<double>(dwLastGetTickCountRealValue)) * Rate);
		dwLastGetTickCountRealValue = dwTickCount;
	}
	return dwLastGetTickCountCheatValue;
}

DWORD WINAPI YbSpeedHook::Hooked_timeGetTime()
{
	// TSAUTO();
	XMLib::CriticalSectionLockGuard lck(cs);
	DWORD dwTime = YbSpeedHook::Real_timeGetTime();
	if(dwTime > dwLasttimeGetTimeRealValue) {
		dwLasttimeGetTimeCheatValue = static_cast<DWORD>(static_cast<double>(dwLasttimeGetTimeCheatValue) + (static_cast<double>(dwTime) - static_cast<double>(dwLasttimeGetTimeRealValue)) * Rate);
		dwLasttimeGetTimeRealValue = dwTime;
	}
	return  dwLasttimeGetTimeCheatValue;
}

BOOL WINAPI YbSpeedHook::Hooked_QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCount)
{
	// TSAUTO();
	XMLib::CriticalSectionLockGuard lck(cs);
	BOOL ret = YbSpeedHook::Real_QueryPerformanceCounter(lpPerformanceCount);
	if(ret) {
		double local_rate = Rate;
		if(_isnan(local_rate)) {
			return FALSE;
		}
		if(lpPerformanceCount->QuadPart > llLastQueryPerformanceCounterRealValue) {
			llLastQueryPerformanceCounterCheatValue = static_cast<LONGLONG>(static_cast<double>(llLastQueryPerformanceCounterCheatValue) + static_cast<double>(lpPerformanceCount->QuadPart - llLastQueryPerformanceCounterRealValue) * local_rate);
			llLastQueryPerformanceCounterRealValue = lpPerformanceCount->QuadPart;
		}
		lpPerformanceCount->QuadPart = llLastQueryPerformanceCounterCheatValue;
	}
	return ret;
}

void YbSpeedHook::Initialize()
{
	TSAUTO();
	XMLib::CriticalSectionLockGuard lck(cs);
	dwLastGetTickCountRealValue = Real_GetTickCount();
	dwLastGetTickCountCheatValue = dwLastGetTickCountRealValue;
	dwLasttimeGetTimeRealValue = Real_timeGetTime();
	dwLasttimeGetTimeCheatValue = dwLasttimeGetTimeRealValue;
	LARGE_INTEGER liTime;
	Real_QueryPerformanceCounter(&liTime);
	llLastQueryPerformanceCounterRealValue = liTime.QuadPart;
	llLastQueryPerformanceCounterCheatValue = llLastQueryPerformanceCounterRealValue;
	YbSpeedHook::Rate = 1.0;
}

bool YbSpeedHook::AttachHook()
{
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	// DetourAttach(reinterpret_cast<LPVOID*>(&Real_GetTickCount), Hooked_GetTickCount);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_timeGetTime), Hooked_timeGetTime);
	DetourAttach(reinterpret_cast<LPVOID*>(&Real_QueryPerformanceCounter), Hooked_QueryPerformanceCounter);
	DetourTransactionCommit();
	return true;
}

bool YbSpeedHook::DetachHook()
{
	DetourTransactionBegin();
	DetourUpdateThread(GetCurrentThread());
	// DetourDetach(reinterpret_cast<LPVOID*>(&Real_GetTickCount), Hooked_GetTickCount);
	DetourDetach(reinterpret_cast<LPVOID*>(&Real_timeGetTime), Hooked_timeGetTime);
	DetourDetach(reinterpret_cast<LPVOID*>(&Real_QueryPerformanceCounter), Hooked_QueryPerformanceCounter);
	DetourTransactionCommit();
	return true;
}

double YbSpeedHook::ChangeSpeedRate(double rate)
{
	XMLib::CriticalSectionLockGuard lck(cs);
	double old_value = YbSpeedHook::Rate;
	YbSpeedHook::Rate = rate;
	return old_value;
}
