#pragma once

#include <shlobj.h>
#include <list>

class CYBPretender
{
public:
	CYBPretender() : m_bInitOK(FALSE), m_hYBKernel(NULL)
	{


		const TCHAR *rgszFileName[] = { 
			_T("xlluaruntime.dll"), 
			_T("xlue.dll")
		};
		HMODULE rghmodDeps[_countof(rgszFileName)] = {NULL};
		PreLoadDll(rgszFileName, _countof(rgszFileName), rghmodDeps);
		BOOL bAllOk = TRUE;
		for (int i = 0; i < _countof(rghmodDeps); ++i)
		{
			if (NULL == rghmodDeps[i])
			{
				bAllOk = FALSE;
			}
		}
		if (!bAllOk) return;
		for (int i = 0; i < _countof(rghmodDeps); ++i)
		{
			m_modList.push_back(rghmodDeps[i]);
		}


		m_hYBKernel = LoadLibrary(_T("YBKernel.dll"));
		if (NULL == m_hYBKernel)
		{
			return;
		}
		m_bInitOK = TRUE;
	}

	~CYBPretender()
	{
		if (m_hYBKernel)
		{
			FreeLibrary(m_hYBKernel);
			m_hYBKernel = NULL;
		}

		for (std::list< HMODULE >::reverse_iterator rit = m_modList.rbegin();
			rit != m_modList.rend();
			++rit)
		{
			if (*rit)
			{
				TSDEBUG(_T("About to FreeLibrary(0x%p)"), *rit);
				::FreeLibrary(*rit);
			}
		}
	}

	static void PreLoadDll(const TCHAR **rgszFileName, ULONG nFileCount, HMODULE *pResult)
	{
		for (unsigned int i = 0; i < nFileCount; ++i)
		{
			pResult[i] = ::LoadLibrary(rgszFileName[i]);
			DWORD dwLastError = ::GetLastError();
			TSDEBUG(_T("LoadLibrary(%s) return 0x%p, dwLastError = %lu"), rgszFileName[i], pResult[i], dwLastError);
		}
	}

	BOOL Init(LPTSTR lpCmdLine = NULL)
	{
		BOOL bRet = FALSE;
		if (m_bInitOK)
		{
			typedef BOOL (STDAPICALLTYPE * PInitXLUE)(wchar_t*);
			PInitXLUE pInitXLUE = (PInitXLUE)GetProcAddress(m_hYBKernel, "InitXLUE");
			if (pInitXLUE)
			{
				bRet = pInitXLUE(lpCmdLine);
			}
		}
		return bRet;
	}
private:

private:
	HMODULE m_hYBKernel;
	BOOL	m_bInitOK;
	std::list< HMODULE > m_modList;
};