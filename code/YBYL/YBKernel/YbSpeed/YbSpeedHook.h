#pragma once
#include <Windows.h>
#include "Lock.h"

class YbSpeedHook {
	typedef DWORD (WINAPI* GetTickCount_FuncType)();
	typedef DWORD (WINAPI* timeGetTime_FuncType)();
	typedef BOOL (WINAPI* QueryPerformanceCounter_FuncType)(LARGE_INTEGER *lpPerformanceCount);
private:
	static GetTickCount_FuncType Real_GetTickCount;
	static timeGetTime_FuncType Real_timeGetTime;
	static QueryPerformanceCounter_FuncType Real_QueryPerformanceCounter;
private:
	static XMLib::CriticalSection cs;
	static DWORD dwLastGetTickCountRealValue;
	static DWORD dwLastGetTickCountCheatValue;
	static DWORD dwLasttimeGetTimeRealValue;
	static DWORD dwLasttimeGetTimeCheatValue;
	static LONGLONG llLastQueryPerformanceCounterRealValue;
	static LONGLONG llLastQueryPerformanceCounterCheatValue;
	static double Rate;
public:
	static DWORD WINAPI Hooked_GetTickCount();
	static DWORD WINAPI Hooked_timeGetTime();
	static BOOL WINAPI Hooked_QueryPerformanceCounter(LARGE_INTEGER *lpPerformanceCount);
public:
	static void Initialize();
	static bool AttachHook();
	static bool DetachHook();
	static double ChangeSpeedRate(double rate);
};
