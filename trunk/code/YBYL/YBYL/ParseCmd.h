class CParseCmd
{
private:
	CParseCmd(){};
	~CParseCmd(){};

public:
	static BOOL PreHandleCmdline(LPTSTR lpstrCmdLine)
	{
		if (lpstrCmdLine[0] == L'' || NULL == lpstrCmdLine)
			return FALSE;
		int args;
		LPWSTR* lpwszArgv = CommandLineToArgvW(lpstrCmdLine, &args);
		if(args == 1)
		{
			if(0 == _tcsicmp(_T("/setdefault"), lpwszArgv[0]))
			{	
				TCHAR szExePath[MAX_PATH] = {0};
				if (0 != GetModuleFileName(NULL, szExePath, MAX_PATH))
				{
					TCHAR szOpenCmd[MAX_PATH] = {0};
					_stprintf(szOpenCmd,_T("\"%s\" /url \"%%1\""),szExePath);
					long lRet = 0;
					HKEY hKey;
					lRet = RegCreateKeyEx(HKEY_CLASSES_ROOT ,_T("YBYLHTML\\DefaultIcon"),NULL,NULL,REG_OPTION_NON_VOLATILE,KEY_READ|KEY_WRITE,NULL,&hKey,NULL);
					if (ERROR_SUCCESS == lRet)
					{
						TCHAR szIconValue[MAX_PATH] = {0};
						_stprintf(szIconValue,_T("%s,0"),szExePath);
						lRet = RegSetValueEx(hKey,NULL,NULL,REG_SZ,reinterpret_cast<const BYTE*>(szIconValue),MAX_PATH);
						if (ERROR_SUCCESS == lRet)
						{
							lRet = RegCreateKeyEx(HKEY_CLASSES_ROOT ,_T("YBYLHTML\\shell\\open\\command"),NULL,NULL,REG_OPTION_NON_VOLATILE,KEY_READ|KEY_WRITE,NULL,&hKey,NULL);
							if (ERROR_SUCCESS == lRet)
							{
								lRet = RegSetValueEx(hKey,NULL,NULL,REG_SZ,reinterpret_cast<const BYTE*>(szOpenCmd),MAX_PATH);
								if (ERROR_SUCCESS == lRet)
								{
									lRet = RegOpenKeyEx(HKEY_CURRENT_USER,_T("Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice"),NULL,KEY_WRITE,&hKey);
									if (lRet == ERROR_SUCCESS)
									{
										TCHAR * szProgidValue = _T("YBYLHTML");
										lRet = RegSetValueEx(hKey,_T("Progid"),NULL,REG_SZ,reinterpret_cast<const BYTE*>(szProgidValue),(lstrlen(szProgidValue)+1)*sizeof(TCHAR));
										if (lRet == ERROR_SUCCESS)
										{
											lRet = RegOpenKeyEx(HKEY_CLASSES_ROOT,_T("http\\shell\\open\\command"),NULL,KEY_WRITE,&hKey);
											if (lRet == ERROR_SUCCESS)
											{
												lRet = RegSetValueEx(hKey,NULL,NULL,REG_SZ,reinterpret_cast<const BYTE*>(szOpenCmd),MAX_PATH);
												if (lRet == ERROR_SUCCESS)
												{
													//::MessageBox(NULL,_T("…Ë÷√ƒ¨»œ‰Ø¿¿∆˜≥…π¶"),_T("‘™±¶”È¿÷‰Ø¿¿∆˜"),MB_OK);
												}
											}
										}
									}
								}
							}
						}
					}
					return TRUE;
				}
				return TRUE;
			}
		}
		return FALSE;
	}
};