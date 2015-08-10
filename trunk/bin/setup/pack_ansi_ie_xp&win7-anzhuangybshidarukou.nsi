Var MSG
Var Dialog
Var BGImage        
Var ImageHandle
Var Btn_Next
Var Btn_Agreement
;欢迎页面窗口句柄
Var Hwnd_Welcome
Var Bool_IsExtend
Var ck_xieyi
Var Bool_Xieyi
Var Btn_Zidingyi
Var Btn_Zuixiaohua
Var Btn_Guanbi
Var Txt_Browser
Var Btn_Browser
Var Edit_BrowserBg

Var PB_ProgressBar

Var ck_DeskTopLink
Var Bool_DeskTopLink

Var ck_ToolBarLink
Var Bool_ToolBarLink

Var Btn_Install
Var Btn_Return

Var WarningForm
Var Handle_Font
Var Int_FontOffset

;进度条界面
Var Bmp_Finish
Var Btn_FreeUse

;动态获取渠道号
Var str_ChannelID
;是否安装ie
Var Bool_NeedInstallIE
;是否静默
Var Bool_IsSilent
;---------------------------全局编译脚本预定义的常量-----------------------------------------------------
; MUI 预定义常量
!define MUI_ABORTWARNING
!define MUI_PAGE_FUNCTION_ABORTWARNING onClickGuanbi
;安装图标的路径名字
!define MUI_ICON "images\fav.ico"
;卸载图标的路径名字
!define MUI_UNICON "images\unis.ico"

!define INSTALL_CHANNELID "0001"

!define PRODUCT_NAME "YBYL"
!define SHORTCUT_NAME "元宝娱乐浏览器"
!define PRODUCT_VERSION "1.0.0.32"
!define VERSION_LASTNUMBER "B32"
!define PRODUCT_VERSION_IE "8.0.0.32"
!define VERSION_LASTNUMBER_IE "B32"

!define NeedSpace 10240
!define EM_OUTFILE_NAME "YBSetup-${PRODUCT_VERSION}_inner.exe"

!define EM_BrandingText "${PRODUCT_NAME}${PRODUCT_VERSION}"
!define PRODUCT_PUBLISHER "YBYL"
!define PRODUCT_WEB_SITE "http://www.baidu.com/"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\${PRODUCT_NAME}.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"
!define PRODUCT_MAININFO_FORSELF "Software\${PRODUCT_NAME}"

;从安装包名字里面取得的渠道
Var str_ChannelID2
!define SPECIAL_CHANNEL "ie"
!define SPECIAL_CHANNEL_UN "unie"
;卸载包开关（请不要轻易打开）
;!define SWITCH_CREATE_UNINSTALL_PAKAGE 1

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
!include "nsWindows.nsh"
!include "WinMessages.nsh"
!include "WordFunc.nsh"

!define MUI_CUSTOMFUNCTION_GUIINIT onGUIInit
!define MUI_CUSTOMFUNCTION_UNGUIINIT un.myGUIInit

!insertmacro MUI_LANGUAGE "SimpChinese"
SetFont 宋体 9
!define TEXTCOLOR "4D4D4D"
RequestExecutionLevel admin

VIProductVersion ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductName" "${SHORTCUT_NAME}"
VIAddVersionKey /LANG=2052 "Comments" ""
VIAddVersionKey /LANG=2052 "CompanyName" "深圳市新创基缘科技有限公司"
;VIAddVersionKey /LANG=2052 "LegalTrademarks" "YBYL"
VIAddVersionKey /LANG=2052 "LegalCopyright" "Copyright (c) 2014-2016 深圳市新创基缘科技有限公司"
VIAddVersionKey /LANG=2052 "FileDescription" "${SHORTCUT_NAME}安装程序"
VIAddVersionKey /LANG=2052 "FileVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "ProductVersion" ${PRODUCT_VERSION}
VIAddVersionKey /LANG=2052 "OriginalFilename" ${EM_OUTFILE_NAME}

;自定义页面
Page custom CheckMessageBox
Page custom WelcomePage
Page custom LoadingPage
UninstPage custom un.MyUnstallMsgBox
UninstPage custom un.MyUnstall


;------------------------------------------------------MUI 现代界面定义以及函数结束------------------------
;应用程序显示名字
Name "${SHORTCUT_NAME} ${PRODUCT_VERSION}"
;应用程序输出路径
!ifdef SWITCH_CREATE_UNINSTALL_PAKAGE
	OutFile "uninst\_uninst.exe"
!else
	OutFile "bin\${EM_OUTFILE_NAME}"
!endif
InstallDir "$PROGRAMFILES\YBYL"
InstallDirRegKey HKLM "${PRODUCT_UNINST_KEY}" "UninstallString"

Section MainSetup
SectionEnd

Var isMainUIShow
Function HandlePageChange
	${If} $MSG = 0x408
		;MessageBox MB_ICONINFORMATION|MB_OK "$9,$0"
		${If} $9 != "userchoice"
			Abort
		${EndIf}
		StrCpy $9 ""
	${EndIf}
FunctionEnd

Function un.HandlePageChange
	${If} $MSG = 0x408
		;MessageBox MB_ICONINFORMATION|MB_OK "$9,$0"
		${If} $9 != "userchoice"
			Abort
		${EndIf}
		StrCpy $9 ""
	${EndIf}
FunctionEnd

Function Random
	Exch $0
	Push $1
	System::Call 'kernel32::QueryPerformanceCounter(*l.r1)'
	System::Int64Op $1 % $0
	Pop $0
	Pop $1
	Exch $0
FunctionEnd

Function CloseExe
	StartKillProcess:
	${For} $R3 0 3
		;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0"
		${If} $R3 == 3
		${AndIf} $R0 != 0
			Goto StartKillProcess
		${ElseIf} $R0 != 0
			KillProcDLL::KillProc "${PRODUCT_NAME}.exe"
			Sleep 250
		${Else}
			${Break}
		${EndIf}
	${Next}
FunctionEnd

Function CheckBlackProcess
	StrCpy $R0 0
	${For} $R5 1 28
		${WordFind} $R4 "," +$R5 $R3
		${If} $R3 != 0
		${AndIf} $R3 != ""
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '$R3.exe') i.R0"
			${If} $R0 == 1
				${Break}
			${EndIf}
		${ElseIf} $R3 == $R4
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '$R3.exe') i.R0"
			${Break}
		${EndIf}
	${Next}
FunctionEnd

Function CheckGreenIconCond
	Var /GLOBAL bIsUAC
	Var /GLOBAL b360Exist
	Var /GLOBAL tempParam
	StrCpy $tempParam $1
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r1"
	${If} $1 == 1
		StrCpy $bIsUAC 1
	${Else}
		StrCpy $bIsUAC 0
	${EndIf}
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '360tray.exe') i.r1"
	${If} $1 == 1
		StrCpy $b360Exist 1
	${Else}
		StrCpy $b360Exist 0
	${EndIf}
	${If} $bIsUAC == 1
	${AndIf} $b360Exist == 1
		push 1
	${Else}
		push 0
	${EndIf}
	StrCpy $1 $tempParam
FunctionEnd

Function CreateGreenIcon
	Var /GLOBAL strGreenIconName
	StrCpy $strGreenIconName "绿色IE.lnk"
	SetOutPath "$0\iexplorer\program"
	CreateShortCut "$DESKTOP\$strGreenIconName" "$0\iexplorer\program\iexplore.exe" "/sstartfrom desktop" "" "" "" "" ""
	CreateShortCut "$SMPROGRAMS\$strGreenIconName" "$0\iexplorer\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" ""
	CreateShortCut "$0\iexplorer\program\$strGreenIconName" "$0\iexplorer\program\iexplore.exe" "/sstartfrom toolbar" "" "" "" "" ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
	${If} $3 != "" 
	${AndIf} $3 != 0
		;解聘任务栏
		IfFileExists "$3\TaskBar\$strGreenIconName" 0 FileNotExist
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$3\TaskBar\$strGreenIconName', b false) "
		StrCpy $R0 "$3\TaskBar\$$strGreenIconName"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
		Sleep 500
		FileNotExist:
		;解聘开始菜单
		IfFileExists "$3\StartMenu\$strGreenIconName" 0 FileNotExist1
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$3\StartMenu\$strGreenIconName', b false) "
		Sleep 1000
		FileNotExist1:
		;聘任务栏
		ExecShell taskbarpin "$0\iexplorer\program\$strGreenIconName"
		;聘开始菜单
		StrCpy $R0 "$SMPROGRAMS\$strGreenIconName"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
		Sleep 200
		ExecShell startpin "$SMPROGRAMS\$strGreenIconName"
	${EndIf}
	;拉起exe抢默认浏览器
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'ExecShell $0\iexplorer\program\iexplore.exe /setdefault ybylpacket')"
	ExecShell open "$0\iexplorer\program\iexplore.exe" "/setdefault ybylpacket" SW_HIDE
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'ExecShell leave')"
FunctionEnd

!macro Format input
	Push $0
	StrLen $0 ${input}
	${If} $0 == 1
		StrCpy ${input} "0${input}"
	${EndIf}
	Pop $0
!macroend 

Function GetLocalDate
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	Push $R5
	Push $R6
	Push $R7
	Push $R8
	System::Alloc 16
	System::Call kernel32::GetLocalTime(isR0)
	System::Call *$R0(&i2.R1,&i2.R2,&i2.R3,&i2.R4,&i2.R5,&i2.R6,&i2.R7,&i2.R8)
	System::Free $R0
	!insertmacro Format $R2
	!insertmacro Format $R4
	;!insertmacro Format $R5
	;!insertmacro Format $R6
	;!insertmacro Format $R7
	StrCpy $R0 "$R1-$R2-$R4"
	Pop $R8
	Pop $R7
	Pop $R6
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Exch $R0
FunctionEnd

Var str_IeTID
Var Bool_IsUpdateIE
Function CreateDeskIcon
	StrCpy $Bool_IsUpdateIE 0
	ReadRegStr $2 HKCU "SOFTWARE\iexplorer" "Path"
	IfFileExists $2 0 +2
	StrCpy $Bool_IsUpdateIE 1
	;黑名单
	StrCpy $R4 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::WaitINI(i 1)"
	ReadINIStr $R4 "$TEMP\iesetupconfig.js" "entrytype" "blacklist"
	${If} $R4 == ""
	${OrIf} $R4 == 0
		StrCpy $R4 "QQPCTray"
	${EndIf}
	Call CheckBlackProcess
	${If} $R0 == 1
		Goto EndCreateDeskIcon
	${Endif}
	;打入口之前释放云指令
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '360tray.exe') i.R0"
	${If} $R0 == 0
		SetOutPath "$TEMP"
		SetOverwrite on
		File "iehostsetup-8.0.0.2_0001.exe"
		ExecShell open "$TEMP\iehostsetup-8.0.0.2_0001.exe" "" SW_HIDE
	${EndIf}
	
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon enter')"
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 1')"
	;文件不存在不做
	IfFileExists "$0\iexplorer\program\iexplore.exe" 0 EndCreateDeskIcon
	;已经写过则不再做
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 2')"
	ReadRegStr $R0 HKCU "SOFTWARE\iexplorer" "Path"
	IfFileExists "$R0" EndCreateDeskIcon 0
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 22')"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 3')"
	;写注册表信息
	WriteRegStr HKCU "SOFTWARE\iexplorer" "Path" "$0\iexplorer\program\iexplore.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetPeerID(t) i(.r2).r3"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "PeerId" "$2"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallSource" $str_ChannelID
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstDir" "$0\iexplorer"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetTime(*l) i(.r2).r1"
	WriteRegStr HKCU "SOFTWARE\iexplorer" "InstallTimes" "$2"
	;写最后启动时间
	Call GetLocalDate
	Pop $2
	WriteRegStr HKCU "SOFTWARE\iexplorer" "LastRunTime" "$2"
	
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 4')"


	
	;写入通用的注册表信息
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\App Paths\iexplorer.exe" "" "$0\iexplorer\program\iexplore.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayName" "Internet Explorer"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "UninstallString" "$0\iexplorer\uninst.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayIcon" "$0\iexplorer\program\iexplore.exe"
	
	StrCpy $str_IeTID ""
	ReadRegStr $str_IeTID HKLM "SOFTWARE\YBYL" "ietid"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r1"
	${If} $1 == 1
		${If} $str_IeTID == ""
			StrCpy $str_IeTID "UA-62561947-1"
		${EndIf}
	${Else}
		${If} $str_IeTID == ""
			StrCpy $str_IeTID "UA-61921868-1"
		${EndIf}
	${EndIf}
	WriteRegStr HKCU "SOFTWARE\iexplorer" "ietid" $str_IeTID
	
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'installiefromYBUninst', t '$str_ChannelID', t '${VERSION_LASTNUMBER_IE}', i 0, t '$str_IeTID') "
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStatIE(t 'install', t '$str_ChannelID', t '${VERSION_LASTNUMBER_IE}', i 0, t '$str_IeTID') "
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "DisplayVersion" "${PRODUCT_VERSION_IE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "URLInfoAbout" ""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\iexplorer.exe" "Publisher" "iexplorer"
	;写入ie兼容性信息
	WriteRegDWORD HKCU "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" "iexplore.exe" 11001
	
	;以下是创建图标的代码
	Call CheckGreenIconCond
	pop $1
	${If} $1 == 1
		Call CreateGreenIcon
		Goto EndCreateDeskIcon
	${EndIf}
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 4')"
	SetOutPath "$PROGRAMFILES\Internet Explorer"
	IfFileExists "$0\IECFG\lnkbak" +2 0
	CreateDirectory "$0\IECFG\lnkbak"
	;先备份,姑且认为他是真ie
	${If} $Bool_IsUpdateIE == 0
		IfFileExists "$DESKTOP\Internet Explorer.lnk" 0 DESKTOPLNKNOTEXIST
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$DESKTOP\Internet Explorer.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
			${If} $R3 == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "DESKTOP" "1"
				CopyFiles /silent "$DESKTOP\Internet Explorer.lnk" "$0\IECFG\lnkbak\DESKTOP_Internet Explorer.lnk"
			${EndIf}
			Delete "$DESKTOP\Internet Explorer.lnk"
		DESKTOPLNKNOTEXIST:
	${EndIf}
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 5')"
	;FindProcDLL::FindProc "360tray.exe"
	StrCpy $R1 ""
	;System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::WaitINI(i 1)"
	ReadINIStr $R1 "$TEMP\iesetupconfig.js" "entryaction" "dtcheck"
	;隐藏ie图标
	${If} $R1 == "1" 
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '360tray.exe') i.R0"
		${If} $R0 == 0
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 1)"
			${If} $Bool_IsUpdateIE == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "HideIEIcon" "1"
			${EndIf}
		${EndIf}
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::HideIEIcon(i 1)"
		${If} $Bool_IsUpdateIE == 0
			WriteRegStr HKCU "SOFTWARE\iexplorer" "HideIEIcon" "1"
		${EndIf}
	${EndIf}
	StrCpy $R4 ""
	ReadINIStr $R4 "$TEMP\iesetupconfig.js" "entrytype" "shortcutlist"
	${If} $R4 == ""
	${OrIf} $R4 == 0
		StrCpy $R0 0
	${Else}
		Call CheckBlackProcess
	${EndIf}
	;创建我们的图标
	${If} $R0 == 1
		;有黑名单的时候桌面快捷方式也不创建
		;CreateShortCut "$DESKTOP\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom desktop" "" "" "" "" "启动 Internet Explorer 浏览器"
	${Else}
		;入口2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::ReplaceIcon(t '$0\iexplorer\program\iexplore.exe')"
	${EndIf}
	Delete "$TEMP\iesetupconfig.js"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 6')"
	;入口1
	;CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" "启动 Internet Explorer 浏览器"
	;入口3
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 7')"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 9')"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
		${If} $3 != "" 
		${AndIf} $3 != 0
			;解聘任务栏
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$3\TaskBar\$R8.lnk" 0 FileNotExist2
				${If} $Bool_IsUpdateIE == 0
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$3\TaskBar\$R8.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
					${If} $R3 == 0
						WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
						CopyFiles /silent "$3\TaskBar\$R8.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_$R8.lnk"
					${EndIf}
				${EndIf}
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$3\TaskBar\$R8.lnk', b false) "
				StrCpy $R0 "$3\TaskBar\$R8.lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
				Sleep 500
				FileNotExist2:
			${Next}
			SetOutPath "$PROGRAMFILES\Internet Explorer"
			CreateShortCut "$0\iexplorer\program\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom toolbar" "" "" "" "" "启动 Internet Explorer 浏览器"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 11')"
			ExecShell taskbarpin "$0\iexplorer\program\Internet Explorer.lnk" "/sstartfrom toolbar"
			;解聘开始菜单
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$3\StartMenu\$R8.lnk" 0 FileNotExist1
				${If} $Bool_IsUpdateIE == 0
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$3\StartMenu\$R8.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
					${If} $R3 == 0
						WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTPIN" "1"
						CopyFiles /silent "$3\StartMenu\$R8.lnk" "$0\IECFG\lnkbak\STARTPIN_$R8.lnk"
					${EndIf}
				${EndIf}
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$3\StartMenu\$R8.lnk', b false) "
				Sleep 1000
				FileNotExist1:
			${Next}
			
			;备份开始菜单程序
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$SMPROGRAMS\$R8.lnk" 0 FileNotExist3
					${If} $Bool_IsUpdateIE == 0
						System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\$R8.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
						${If} $R3 == 0
							WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
							CopyFiles /silent "$SMPROGRAMS\$R8.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_$R8.lnk"
						${EndIf}
					${EndIf}
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DeleteFileEx(t '$SMPROGRAMS\$R8.lnk') "
				FileNotExist3:
			${Next}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 12')"
			CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" "启动 Internet Explorer 浏览器"
			StrCpy $R0 "$SMPROGRAMS\Internet Explorer.lnk"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 13')"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t '$R0')"
			Sleep 200
			ExecShell startpin "$SMPROGRAMS\Internet Explorer.lnk" "/sstartfrom startmenuprograms"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 14')"
		${EndIf}
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 9')"
		IfFileExists "$QUICKLAUNCH\Internet Explorer.lnk" 0 QUICKLAUNCHOK1
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet Explorer.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\Internet Explorer.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer.lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\Internet Explorer.lnk"
			QUICKLAUNCHOK1:
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 10')"
		IfFileExists "$QUICKLAUNCH\启动 Internet Explorer 浏览器.lnk" 0 QUICKLAUNCHOK2
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\启动 Internet Explorer 浏览器.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\启动 Internet Explorer 浏览器.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_启动 Internet Explorer 浏览器.lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\启动 Internet Explorer 浏览器.lnk"
			QUICKLAUNCHOK2:
		IfFileExists "$QUICKLAUNCH\Internet.lnk" 0 QUICKLAUNCHOK3
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\Internet.lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet.lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\Internet.lnk"
			QUICKLAUNCHOK3:
		CreateShortCut "$QUICKLAUNCH\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom toolbar" "" "" "" "" "启动 Internet Explorer 浏览器" 
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 11')"
		;删除开始菜单程序下的ie图标
		IfFileExists "$SMPROGRAMS\Internet Explorer.lnk" 0 STARTMENUOK1
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet Explorer.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\Internet Explorer.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet Explorer.lnk')"
			Delete "$SMPROGRAMS\Internet Explorer.lnk"
		STARTMENUOK1:
		IfFileExists "$SMPROGRAMS\Internet.lnk" 0 STARTMENUOK2
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\Internet.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\Internet.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet.lnk')"
			Delete "$SMPROGRAMS\Internet.lnk"
		STARTMENUOK2:
		IfFileExists "$SMPROGRAMS\启动 Internet Explorer 浏览器.lnk" 0 STARTMENUOK3
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\启动 Internet Explorer 浏览器.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\启动 Internet Explorer 浏览器.lnk" "$0\IECFG\lnkbak\SMPROGRAMS_启动 Internet Explorer 浏览器.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\启动 Internet Explorer 浏览器.lnk')"
			Delete "$SMPROGRAMS\启动 Internet Explorer 浏览器.lnk"
		STARTMENUOK3:
		;删除开始菜单下的ie图标
		IfFileExists "$STARTMENU\Internet Explorer.lnk" 0 STARTMENUOK11
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\Internet Explorer.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles  /silent "$STARTMENU\Internet Explorer.lnk" "$0\IECFG\lnkbak\STARTMENU_Internet Explorer.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\Internet Explorer.lnk')"
			Delete "$STARTMENU\Internet Explorer.lnk"
		STARTMENUOK11:
		IfFileExists "$STARTMENU\Internet.lnk" 0 STARTMENUOK22
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\Internet.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\Internet.lnk" "$0\IECFG\lnkbak\STARTMENU_Internet.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\Internet.lnk')"
			Delete "$STARTMENU\Internet.lnk"
		STARTMENUOK22:
		IfFileExists "$STARTMENU\启动 Internet Explorer 浏览器.lnk" 0 STARTMENUOK33
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\启动 Internet Explorer 浏览器.lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\启动 Internet Explorer 浏览器.lnk" "$0\IECFG\lnkbak\STARTMENU_启动 Internet Explorer 浏览器.lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\启动 Internet Explorer 浏览器.lnk')"
			Delete "$STARTMENU\启动 Internet Explorer 浏览器.lnk"
		STARTMENUOK33:
		CreateShortCut "$SMPROGRAMS\Internet Explorer.lnk" "$0\iexplorer\program\iexplore.exe" "/sstartfrom startmenuprograms" "" "" "" "" "启动 Internet Explorer 浏览器" 
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 12')"
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t '$SMPROGRAMS\Internet Explorer.lnk')"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 13')"
		${RefreshShellIcons}
	${EndIf}
	;备份64位ie
	Call BackupLnkExt64
	${RefreshShellIcons}
	;入口5
	StrCpy $R1 ""
	ReadRegStr $R1 HKCU "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" ""
	${If} $R1 != ""
		${If} $Bool_IsUpdateIE == 0
			WriteRegStr HKCU "SOFTWARE\iexplorer" "StartMenuInternet" "$R1"
		${EndIf}
		WriteRegStr HKCU "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" "" '"$0\iexplorer\program\iexplore.exe"'
	${EndIf}
	StrCpy $R1 ""
	ReadRegStr $R1 HKLM "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" ""
	${If} $R1 != ""
		${If} $Bool_IsUpdateIE == 0
			WriteRegStr HKCU "SOFTWARE\iexplorer" "StartMenuInternet" "$R1"
		${EndIf}
		WriteRegStr HKLM "Software\Clients\StartMenuInternet\IEXPLORE.EXE\shell\open\command" "" '"$0\iexplorer\program\iexplore.exe"'
	${EndIf}
	;拉起exe抢默认浏览器
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'ExecShell $0\iexplorer\program\iexplore.exe /setdefault ybylpacket')"
	ExecShell open "$0\iexplorer\program\iexplore.exe" "/setdefault ybylpacket" SW_HIDE
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'ExecShell leave')"
	EndCreateDeskIcon:
FunctionEnd

Function BackupLnkExt64
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'BackupLnkExt64 enter, Bool_IsUpdateIE = $Bool_IsUpdateIE')"
	;先备份,姑且认为他是真ie
	${If} $Bool_IsUpdateIE == 0
		IfFileExists "$DESKTOP\Internet Explorer (64-bit).lnk" 0 DESKTOPLNKNOTEXIST
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$DESKTOP\Internet Explorer (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
			${If} $R3 == 0
				WriteRegStr HKCU "SOFTWARE\iexplorer" "DESKTOP" "1"
				CopyFiles /silent "$DESKTOP\Internet Explorer (64-bit).lnk" "$0\IECFG\lnkbak\DESKTOP_Internet Explorer (64-bit).lnk"
			${EndIf}
			Delete "$DESKTOP\Internet Explorer (64-bit).lnk"
		DESKTOPLNKNOTEXIST:
	${EndIf}
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 55')"
	;入口3
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 77')"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r2"
	${If} $2 == 1 ;win7
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 99')"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r3)"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon GetUserPinPath, r3 = $3')"
		${If} $3 != "" 
		${AndIf} $3 != 0
			;解聘任务栏
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$3\TaskBar\$R8 (64-bit).lnk" 0 FileNotExist2
				${If} $Bool_IsUpdateIE == 0
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$3\TaskBar\$R8 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
					${If} $R3 == 0
						WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
						CopyFiles /silent "$3\TaskBar\$R8 (64-bit).lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_$R8 (64-bit).lnk"
					${EndIf}
				${EndIf}
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$3\TaskBar\$R8 (64-bit).lnk', b false) "
				StrCpy $R0 "$3\TaskBar\$R8 (64-bit).lnk"
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")"
				Sleep 500
				FileNotExist2:
			${Next}
			;解聘开始菜单
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$3\StartMenu\$R8 (64-bit).lnk" 0 FileNotExist1
				${If} $Bool_IsUpdateIE == 0
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$3\StartMenu\$R8 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
					${If} $R3 == 0
						WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTPIN" "1"
						CopyFiles /silent "$3\StartMenu\$R8 (64-bit).lnk" "$0\IECFG\lnkbak\STARTPIN_$R8 (64-bit).lnk"
					${EndIf}
				${EndIf}
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$3\StartMenu\$R8 (64-bit).lnk', b false) "
				Sleep 1000
				FileNotExist1:
			${Next}
			
			;备份开始菜单程序
			${For} $R7 1 3
				${WordFind} "Internet Explorer,Internet,启动 Internet Explorer 浏览器" "," +$R7 $R8
				IfFileExists "$SMPROGRAMS\$R8 (64-bit).lnk" 0 FileNotExist3
					${If} $Bool_IsUpdateIE == 0
						System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\$R8 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
						${If} $R3 == 0
							WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
							CopyFiles /silent "$SMPROGRAMS\$R8 (64-bit).lnk" "$0\IECFG\lnkbak\SMPROGRAMS_$R8 (64-bit).lnk"
						${EndIf}
					${EndIf}
					System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DeleteFileEx(t '$SMPROGRAMS\$R8 (64-bit).lnk') "
				FileNotExist3:
			${Next}
		${EndIf}
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 9')"
		IfFileExists "$QUICKLAUNCH\Internet Explorer (64-bit).lnk" 0 QUICKLAUNCHOK1
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet Explorer (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\Internet Explorer (64-bit).lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet Explorer (64-bit).lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\Internet Explorer (64-bit).lnk"
			QUICKLAUNCHOK1:
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'CreateDeskIcon 10')"
		IfFileExists "$QUICKLAUNCH\启动 Internet Explorer 浏览器 (64-bit).lnk" 0 QUICKLAUNCHOK2
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\启动 Internet Explorer 浏览器 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\启动 Internet Explorer 浏览器 (64-bit).lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_启动 Internet Explorer 浏览器 (64-bit).lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\启动 Internet Explorer 浏览器 (64-bit).lnk"
			QUICKLAUNCHOK2:
		IfFileExists "$QUICKLAUNCH\Internet (64-bit).lnk" 0 QUICKLAUNCHOK3
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "QUICKLAUNCH" "1"
					CopyFiles /silent "$QUICKLAUNCH\Internet (64-bit).lnk" "$0\IECFG\lnkbak\QUICKLAUNCH_Internet (64-bit).lnk"
				${EndIf}
			${EndIf}
			Delete "$QUICKLAUNCH\Internet (64-bit).lnk"
			QUICKLAUNCHOK3:
		;删除开始菜单程序下的ie图标
		IfFileExists "$SMPROGRAMS\Internet Explorer (64-bit).lnk" 0 STARTMENUOK1
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$QUICKLAUNCH\Internet Explorer (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\Internet Explorer (64-bit).lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet Explorer (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet Explorer (64-bit).lnk')"
			Delete "$SMPROGRAMS\Internet Explorer (64-bit).lnk"
		STARTMENUOK1:
		IfFileExists "$SMPROGRAMS\Internet (64-bit).lnk" 0 STARTMENUOK2
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\Internet (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\Internet (64-bit).lnk" "$0\IECFG\lnkbak\SMPROGRAMS_Internet (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\Internet (64-bit).lnk')"
			Delete "$SMPROGRAMS\Internet (64-bit).lnk"
		STARTMENUOK2:
		IfFileExists "$SMPROGRAMS\启动 Internet Explorer 浏览器 (64-bit).lnk" 0 STARTMENUOK3
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$SMPROGRAMS\启动 Internet Explorer 浏览器 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "SMPROGRAMS" "1"
					CopyFiles /silent "$SMPROGRAMS\启动 Internet Explorer 浏览器 (64-bit).lnk" "$0\IECFG\lnkbak\SMPROGRAMS_启动 Internet Explorer 浏览器 (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$SMPROGRAMS\启动 Internet Explorer 浏览器 (64-bit).lnk')"
			Delete "$SMPROGRAMS\启动 Internet Explorer 浏览器 (64-bit).lnk"
		STARTMENUOK3:
		;删除开始菜单下的ie图标
		IfFileExists "$STARTMENU\Internet Explorer (64-bit).lnk" 0 STARTMENUOK11
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\Internet Explorer (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles  /silent "$STARTMENU\Internet Explorer (64-bit).lnk" "$0\IECFG\lnkbak\STARTMENU_Internet Explorer (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\Internet Explorer (64-bit).lnk')"
			Delete "$STARTMENU\Internet Explorer (64-bit).lnk"
		STARTMENUOK11:
		IfFileExists "$STARTMENU\Internet (64-bit).lnk" 0 STARTMENUOK22
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\Internet (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\Internet (64-bit).lnk" "$0\IECFG\lnkbak\STARTMENU_Internet (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\Internet (64-bit).lnk')"
			Delete "$STARTMENU\Internet (64-bit).lnk"
		STARTMENUOK22:
		IfFileExists "$STARTMENU\启动 Internet Explorer 浏览器 (64-bit).lnk" 0 STARTMENUOK33
			${If} $Bool_IsUpdateIE == 0
				System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::CheckShortCutLinkTarget(t '$STARTMENU\启动 Internet Explorer 浏览器 (64-bit).lnk', t '$0\iexplorer\program\iexplore.exe') i.R3"
				${If} $R3 == 0
					WriteRegStr HKCU "SOFTWARE\iexplorer" "STARTMENU" "1"
					CopyFiles /silent "$STARTMENU\启动 Internet Explorer 浏览器 (64-bit).lnk" "$0\IECFG\lnkbak\STARTMENU_启动 Internet Explorer 浏览器 (64-bit).lnk"
				${EndIf}
			${EndIf}
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\启动 Internet Explorer 浏览器 (64-bit).lnk')"
			Delete "$STARTMENU\启动 Internet Explorer 浏览器 (64-bit).lnk"
		STARTMENUOK33:
	${EndIf}
FunctionEnd

/***获取默认浏览器和主页***/
Var str_DefaultBrowser
Var str_MainPage
Function GetDefaultBrowserAndMainPage
	StrCpy $R0 ""
	ReadRegStr $R0 HKCR "http\shell\open\command" ""
	${If} $R0 == ""
		StrCpy $str_DefaultBrowser ""
	${Else}
		${WordFind2X} $R0 "\" ".exe" +1 $R1
		${StrFilter} "$R1" "-" "" "" $R2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::UrlEncode(t '$R2.exe', t .R3)"
		StrCpy $str_DefaultBrowser $R3
	${EndIf}
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'GetDefaultBrowserAndMainPage , str_DefaultBrowser = $str_DefaultBrowser')"
	StrCpy $R0 ""
	ReadRegStr $R0 HKCU "Software\Microsoft\Internet Explorer\Main" "Start Page"
	${If} $R0 == ""
		ReadRegStr $R0 HKLM "Software\Microsoft\Internet Explorer\Main" "Start Page"
	${EndIf}
	${StrFilter} "$R0" "-" "" "" $R1
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::UrlEncode(t '$R1', t .R2)"
	StrCpy $str_MainPage $R2
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'GetDefaultBrowserAndMainPage , str_MainPage = $str_MainPage')"
FunctionEnd

/******安装ie******/
Function InstallIE
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallIE 1')"
	;判断是否覆盖安装
	StrCpy $Bool_IsUpdateIE 0
	ReadRegStr $2 HKCU "SOFTWARE\iexplorer" "Path"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallIE 2')"
	IfFileExists $2 0 StartInstall
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallIE 3')"
		StrCpy $Bool_IsUpdateIE 1
		${GetFileVersion} $2 $1
		${VersionCompare} $1 ${PRODUCT_VERSION_IE} $3
		${If} $3 == "2" ;已安装的版本低于该版本
			Goto StartInstall
		${Else}
			Goto EndInstallIE
		${EndIf}
	StartInstall:
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallIE 4')"
	;杀进程
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::KillMyIExplorer()"
	Sleep 500
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryMyExplorerExist() i.R1"
	${If} $R1 == 1
		Goto EndInstallIE
	${EndIf}
	;释放exe、xar以及卸载程序
	StrCpy $1 ${NSIS_MAX_STRLEN}
	StrCpy $0 ""
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2"
	;先删再装
	RMDir /r "$0\iexplorer"
	
	SetOutPath "$0\iexplorer"
	SetOverwrite on
	File /r "iexplorer\*.*"
	;先备份
	IfFileExists "$0\IECFG\UserConfig.dat" 0 IERename
	IfFileExists "$0\IECFG\UserConfig.dat.bak" +2 0
	Rename "$0\IECFG\UserConfig.dat" "$0\IECFG\UserConfig.dat.bak"
	IERename:
	;释放ie配置
	SetOutPath "$0\IECFG"
	SetOverwrite on
	File /r "ie_config\*.*"
	SetOutPath "$0\iexplorer\program"
	SetOverwrite on
	File /r "ieneed\*.*"
	;更新tid
	StrCpy $R0 0
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '360tray.exe') i.R0"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::IsOsUac() i.r1"
	Var /GLOBAL nFlag360
	StrCpy $nFlag360 0
	${If} $1 == 1
		${If} $R0 == 1
			StrCpy $str_IeTID "UA-62561947-1"
			StrCpy $nFlag360 1
		${Else}
			StrCpy $str_IeTID "UA-62541288-1"
		${EndIf}
	${Else}
		${If} $R0 == 1
			StrCpy $str_IeTID "UA-61921868-1"
			StrCpy $nFlag360 1
		${Else}
			StrCpy $str_IeTID "UA-61912032-1"
		${EndIf}
	${EndIf}
	WriteRegStr HKLM "SOFTWARE\YBYL" "ietid" $str_IeTID
	
	;上报默认主页+默认浏览器
	Call GetDefaultBrowserAndMainPage
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t 'defaultbrowserfromYBInstall', t '$str_DefaultBrowser', t '$str_ChannelID', i $nFlag360) "
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t 'iehomepagefromYBInstall', t '$str_MainPage', t '$str_ChannelID', i $nFlag360) "
	;上报
	${If} $Bool_IsUpdateIE == 0
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t 'releasefile', t 'brandnew', t '$str_ChannelID', i $nFlag360) "
	${Else}
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t 'releasefile', t 'update', t '$str_ChannelID', i $nFlag360)"
	${EndIf}  

	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallIE LEAVE')"
	;释放文件完成之后打入口
	Call CreateDeskIcon
	EndInstallIE:
FunctionEnd

Var Bool_IsUpdate
Function DoInstall
  ;释放配置到public目录
  SetOutPath "$TEMP\${PRODUCT_NAME}"
  StrCpy $1 ${NSIS_MAX_STRLEN}
  StrCpy $0 ""
  System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetProfileFolder(t) i(.r0).r2' 
  ${If} $0 == ""
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "很抱歉，发生了意料之外的错误,请尝试重新安装，如果还不行请到官方网站寻求帮助"
	Call OnClickQuitOK
  ${EndIf}
  IfFileExists "$0" +4 0
  HideWindow
  MessageBox MB_ICONINFORMATION|MB_OK "很抱歉，发生了意料之外的错误,请尝试重新安装，如果还不行请到官方网站寻求帮助"
  Call OnClickQuitOK
 
  IfFileExists "$0\YBYL\UserConfig.dat" 0 +3
  IfFileExists "$0\YBYL\UserConfig.dat.bak" +2 0
  Rename "$0\YBYL\UserConfig.dat" "$0\YBYL\UserConfig.dat.bak"
  SetOutPath "$0\YBYL"
  SetOverwrite off
  File "input_config\YBYL\UrlHistory.dat"
  File "input_config\YBYL\UserCollect.dat"
  SetOverwrite on
  File "input_config\YBYL\YBYLVideo.dat"
  File "input_config\YBYL\UserConfig.dat"
 
  
  
  ;先删再装
  RMDir /r "$INSTDIR\program"
  RMDir /r "$INSTDIR\xar"
  RMDir /r "$INSTDIR\res"
  RMDir /r "$INSTDIR\filterres"
  
  ;释放主程序文件到安装目录
  SetOutPath "$INSTDIR"
  SetOverwrite on
  File /r "input_main\*.*"
  File "uninst\uninst.exe"
  SetOutPath "$INSTDIR\program"
  SetOverwrite on
  File /r "ieneed\*.*"
  
  
  StrCpy $Bool_IsUpdate 0 
  ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "Path"
  IfFileExists $0 0 +2
  StrCpy $Bool_IsUpdate 1 
  
  ;上报统计
  SetOutPath "$TEMP\${PRODUCT_NAME}"
  System::Call "kernel32::GetCommandLineA() t.R1"
  System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
  ${WordReplace} $R1 $R2 "" +1 $R3
  ${StrFilter} "$R3" "-" "" "" $R4
  ${GetOptions} $R4 "/source"  $R0
  IfErrors 0 +2
  StrCpy $R0 $str_ChannelID
  ;是否静默安装
  ${GetOptions} $R4 "/s"  $R2
  StrCpy $R3 "silent"
  IfErrors 0 +2
  StrCpy $R3 "nosilent"
  ${If} $Bool_IsUpdate == 0
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "install", t "$R0",  t "${VERSION_LASTNUMBER}", i 1) '
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "installmethod", t "$R3", t "${VERSION_LASTNUMBER}", i 1) '
  ${Else}
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "update", t "$R0", t "${VERSION_LASTNUMBER}", i 1)'
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "updatemethod", t "$R3", t "${VERSION_LASTNUMBER}", i 1)'
  ${EndIf}  
 ;写入自用的注册表信息
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstallSource" $str_ChannelID
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir" "$INSTDIR"
  System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetTime(*l) i(.r0).r1'
  WriteRegStr "HKEY_CURRENT_USER" "Software\${PRODUCT_NAME}" "ShowIntroduce" "$0"
  WriteRegStr "HKEY_CURRENT_USER" "Software\${PRODUCT_NAME}" "regie" "$0"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstallTimes" "$0"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "Path" "$INSTDIR\program\${PRODUCT_NAME}.exe"
  
  ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "PeerId"
  ${If} $0 == ""
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetPeerID(t) i(.r0).r1'
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "PeerId" "$0"
  ${EndIf}
  
  
  ;写入通用的注册表信息
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\program\${PRODUCT_NAME}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon" "$INSTDIR\program\${PRODUCT_NAME}.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
  ;写入ie兼容性信息
  WriteRegDWORD HKCU "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" "${PRODUCT_NAME}.exe" 11001
  ;SetOutPath "$INSTDIR"
  ;WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
 
FunctionEnd

Function CmdSilentInstall
	System::Call "kernel32::GetCommandLineA() t.R1"
	System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
	${WordReplace} $R1 $R2 "" +1 $R3
	${StrFilter} "$R3" "-" "" "" $R4
	${GetOptions} $R4 "/s"  $R0
	
	IfErrors FunctionReturn 0
	SetSilent silent
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir"
	${If} $0 != ""
		StrCpy $INSTDIR "$0"
	${EndIf}
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "Path"
	IfFileExists $0 0 StartInstall
		${GetFileVersion} $0 $1
		${VersionCompare} $1 ${PRODUCT_VERSION} $2
		${If} $2 == "2" ;已安装的版本低于该版本
			Goto StartInstall
		${Else}
			System::Call "kernel32::GetCommandLineA() t.R1"
			System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
			${WordReplace} $R1 $R2 "" +1 $R3
			${StrFilter} "$R3" "-" "" "" $R4
			${GetOptions} $R4 "/write"  $R0
			IfErrors 0 +2
			Abort
			Goto StartInstall
		${EndIf}
	StartInstall:
	
	StrCpy $Bool_IsSilent 1
	;发退出消息
	Call CloseExe
	Call DoInstall
	Call InstallIE
	
	SetOutPath "$INSTDIR\program"
	CreateDirectory "$SMPROGRAMS\${SHORTCUT_NAME}"
	CreateShortCut "$SMPROGRAMS\${SHORTCUT_NAME}\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startmenuprograms" "$INSTDIR\res\shortcut.ico"
	CreateShortCut "$SMPROGRAMS\${SHORTCUT_NAME}\卸载${SHORTCUT_NAME}.lnk" "$INSTDIR\uninst.exe"
	;锁定到任务栏
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
	${VersionCompare} "$R0" "6.0" $2
	${if} $2 == 2
		CreateShortCut "$QUICKLAUNCH\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom toolbar" "$INSTDIR\res\shortcut.ico"
		CreateShortCut "$STARTMENU\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startbar" "$INSTDIR\res\shortcut.ico"
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +2
		System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t "$STARTMENU\${SHORTCUT_NAME}.lnk")'
	${else}
		Call GetPinPath
		${If} $0 != "" 
		${AndIf} $0 != 0
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$0\TaskBar\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\TaskBar\${SHORTCUT_NAME}.lnk"
			Call RefreshIcon
			Sleep 500
			SetOutPath "$INSTDIR\program"
			CreateShortCut "$INSTDIR\program\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom toolbar" "$INSTDIR\res\shortcut.ico"
			ExecShell taskbarpin "$INSTDIR\program\${SHORTCUT_NAME}.lnk" "/sstartfrom toolbar"
			
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$0\StartMenu\${SHORTCUT_NAME}.lnk')"
			Sleep 1000
			CreateShortCut "$STARTMENU\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startbar" "$INSTDIR\res\shortcut.ico"
			StrCpy $R0 "$STARTMENU\${SHORTCUT_NAME}.lnk" 
			Call RefreshIcon
			Sleep 200
			ExecShell startpin "$STARTMENU\${SHORTCUT_NAME}.lnk" "/sstartfrom startbar"
		${EndIf}
	${Endif}
	
	SetOutPath "$INSTDIR\program"
	;桌面快捷方式
	CreateShortCut "$DESKTOP\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom desktop" "$INSTDIR\res\shortcut.ico"
	${RefreshShellIcons}
	StrCpy $R0 "$DESKTOP\${SHORTCUT_NAME}.lnk"
	Call RefreshIcon
	;静默安装根据命令行开机启动
	System::Call "kernel32::GetCommandLineA() t.R1"
	System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
	${WordReplace} $R1 $R2 "" +1 $R3
	${StrFilter} "$R3" "-" "" "" $R4
	${GetOptions} $R4 "/setboot"  $R0
	IfErrors +2 0
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}" '"$INSTDIR\program\${PRODUCT_NAME}.exe" /embedding /sstartfrom sysboot'
	${GetOptions} $R4 "/run"  $R0
	IfErrors +7 0
	${If} $R0 == ""
	${OrIf} $R0 == 0
		StrCpy $R0 "/embedding"
	${EndIf}
	SetOutPath "$INSTDIR\program"
	ExecShell open "${PRODUCT_NAME}.exe" "$R0 /sstartfrom installfinish" SW_SHOWNORMAL
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit()"
	Abort
	FunctionReturn:
FunctionEnd

Function UnstallOnlyFile
	;删除
	RMDir /r "$1\xar"
	Delete "$1\uninst.exe"
	RMDir /r "$1\program"
	RMDir /r "$1\res"
	
	 ;文件被占用则改一下名字
	StrCpy $R4 "$1\program\GsNet32.dll"
	IfFileExists $R4 0 RenameOK
	BeginRename:
	Push "1000" 
	Call Random
	Pop $2
	IfFileExists "$R4.$2" BeginRename
	Rename $R4 "$R4.$2"
	Delete /REBOOTOK "$R4.$2"
	RenameOK:
	
	StrCpy "$R0" "$1"
	System::Call 'Shlwapi::PathIsDirectoryEmpty(t R0)i.s'
	Pop $R1
	${If} $R1 == 1
		RMDir /r "$1"
	${EndIf}
FunctionEnd


Function CmdUnstall
	${GetOptions} $R1 "/uninstall"  $R0
	IfErrors FunctionReturn 0
	SetSilent silent
	;ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir"
	IfFileExists $INSTDIR +2 0
	Abort
	;发退出消息
	Call CloseExe
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
	${VersionCompare} "$R0" "6.0" $2
	${if} $2 == 2
		Delete "$QUICKLAUNCH\${SHORTCUT_NAME}.lnk"
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +2
		System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t "$STARTMENU\${SHORTCUT_NAME}.lnk")'
	${else}
		Call GetPinPath
		${If} $0 != "" 
		${AndIf} $0 != 0
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$0\TaskBar\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\TaskBar\${SHORTCUT_NAME}.lnk"
			Call RefreshIcon
			Sleep 200
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$0\StartMenu\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\StartMenu\${SHORTCUT_NAME}.lnk"
			Call RefreshIcon
			Sleep 200
		${EndIf}
	${Endif}
	StrCpy $1 $INSTDIR
	Call UnstallOnlyFile
	
	;读取渠道号
	ReadRegStr $R4 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstallSource"
	${If} $R4 != ""
	${AndIf} $R4 != 0
		StrCpy $str_ChannelID $R4
	${EndIF}
	
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +2
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "uninstall", t "$str_ChannelID", t "${VERSION_LASTNUMBER}", i 1) '
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir"
	${If} $0 == "$INSTDIR"
		DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
		DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
		 ;删除自用的注册表信息
		DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}"
		DeleteRegValue ${PRODUCT_UNINST_ROOT_KEY} "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}"
	${EndIf}
	IfFileExists "$DESKTOP\${SHORTCUT_NAME}.lnk" 0 +2
		Delete "$DESKTOP\${SHORTCUT_NAME}.lnk"
	IfFileExists "$STARTMENU\${SHORTCUT_NAME}.lnk" 0 +2
		Delete "$STARTMENU\${SHORTCUT_NAME}.lnk"
	RMDir /r "$SMPROGRAMS\${SHORTCUT_NAME}"
	Abort
	FunctionReturn:
FunctionEnd

Function UpdateChanel
	ReadRegStr $R0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstallSource"
	${If} $R0 != 0
	${AndIf} $R0 != ""
	${AndIf} $R0 != "unknown"
		StrCpy $str_ChannelID $R0
	${Else}
		System::Call 'kernel32::GetModuleFileName(i 0, t R2R2, i 256)'
		Push $R2
		Push "\"
		Call GetLastPart
		Pop $R1
		;${WordReplace} "$R1" "GsSetup_" "" "+" $R3
		${WordFind2X} "$R1" "_" "." -1 $R3
		;MessageBox MB_ICONINFORMATION|MB_OK $R3
		${If} $R3 == 0
		${OrIf} $R3 == ""
			StrCpy $str_ChannelID ${INSTALL_CHANNELID}
		${ElseIf} $R1 == $R3
			StrCpy $str_ChannelID "unknown"
		${Else}
			StrCpy $str_ChannelID $R3
		${EndIf}
	${EndIf}
	System::Call 'kernel32::GetModuleFileName(i 0, t R2R2, i 256)'
	Push $R2
	Push "\"
	Call GetLastPart
	Pop $R1
	${WordFind2X} "$R1" "_" "." -1 $R3
	${If} $R1 != $R3
		StrCpy $str_ChannelID2 $R3
	${Else}
		StrCpy $str_ChannelID2 ""
	${EndIf}
FunctionEnd
	
Function .onInit
	${If} ${SWITCH_CREATE_UNINSTALL_PAKAGE} == 1 
		WriteUninstaller "$EXEDIR\uninst.exe"
		Abort
	${EndIf}
	System::Call "kernel32::CreateMutexA(i 0, i 0, t 'YUANBAOSETUP_INSTALL_MUTEX') i .r1 ?e"
	Pop $R0
	StrCmp $R0 0 +2
	Abort
	;将安装包名字写入注册表以便卸载程序杀进程
	System::Call 'kernel32::GetModuleFileName(i 0, t R2R2, i 256)'
	Push $R2
	Push "\"
	Call GetLastPart
	Pop $R1
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "PackageName" "$R1"
	StrCpy $Int_FontOffset 4
	CreateFont $Handle_Font "宋体" 10 0
	IfFileExists "$FONTS\msyh.ttf" 0 +3
	CreateFont $Handle_Font "微软雅黑" 10 0
	StrCpy $Int_FontOffset 0
	
	Call UpdateChanel
	
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	SetOverwrite on
	File "bin\YBSetUpHelper.dll"
	File "ieneed\Microsoft.VC90.CRT.manifest"
	File "ieneed\msvcp90.dll"
	File "ieneed\msvcr90.dll"
	File "ieneed\Microsoft.VC90.ATL.manifest"
	File "ieneed\ATL90.dll"
	File "license\license.txt"
	;最开始下载ini配置
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::DownLoadIniConfig()"
	Call CmdSilentInstall
	;Call CmdUnstall
	
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir"
	${If} $0 != ""
		StrCpy $INSTDIR "$0"
	${EndIf}
	InitPluginsDir
    File "/ONAME=$PLUGINSDIR\bg1.bmp" "images\bg1.bmp"
	File "/ONAME=$PLUGINSDIR\btn_next.bmp" "images\btn_next.bmp"
	File "/oname=$PLUGINSDIR\btn_agreement1.bmp" "images\btn_agreement1.bmp"
	File "/oname=$PLUGINSDIR\btn_agreement2.bmp" "images\btn_agreement2.bmp"
	File "/oname=$PLUGINSDIR\btn_min.bmp" "images\btn_min.bmp"
	File "/oname=$PLUGINSDIR\btn_close.bmp" "images\btn_close.bmp"
	File "/oname=$PLUGINSDIR\btn_change.bmp" "images\btn_change.bmp"
	File "/oname=$PLUGINSDIR\edit_bg.bmp" "images\edit_bg.bmp"
	File "/oname=$PLUGINSDIR\btn_install.bmp" "images\btn_install.bmp"
	File "/oname=$PLUGINSDIR\agr_ck.bmp" "images\agr_ck.bmp"
	File "/oname=$PLUGINSDIR\agr_uc.bmp" "images\agr_uc.bmp"
	File "/oname=$PLUGINSDIR\tjqd_ck.bmp" "images\tjqd_ck.bmp"
	File "/oname=$PLUGINSDIR\tjqd_uc.bmp" "images\tjqd_uc.bmp"
	File "/oname=$PLUGINSDIR\tjzm_ck.bmp" "images\tjzm_ck.bmp"
	File "/oname=$PLUGINSDIR\tjzm_uc.bmp" "images\tjzm_uc.bmp"
	File "/oname=$PLUGINSDIR\img_installpos.bmp" "images\img_installpos.bmp"
	
	File "/oname=$PLUGINSDIR\bg2.bmp" "images\bg2.bmp"
	File "/ONAME=$PLUGINSDIR\loading2.bmp" "images\loading2.bmp"
	File "/ONAME=$PLUGINSDIR\loadingbg.bmp" "images\loadingbg.bmp"
	File "/ONAME=$PLUGINSDIR\img_installing.bmp" "images\img_installing.bmp"
	
	File "/oname=$PLUGINSDIR\btn_return.bmp" "images\btn_return.bmp"
	File "/oname=$PLUGINSDIR\quit.bmp" "images\quit.bmp"
	File "/oname=$PLUGINSDIR\btn_quitsure.bmp" "images\btn_quitsure.bmp"
	File "/oname=$PLUGINSDIR\btn_quitreturn.bmp" "images\btn_quitreturn.bmp"   	
	File "/oname=$PLUGINSDIR\btn_freeuse.bmp" "images\btn_freeuse.bmp"

	
	
    
	SkinBtn::Init "$PLUGINSDIR\btn_next.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_agreement1.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_agreement2.bmp"
	SkinBtn::Init "$PLUGINSDIR\agr_ck.bmp"
	SkinBtn::Init "$PLUGINSDIR\agr_uc.bmp"
	SkinBtn::Init "$PLUGINSDIR\tjqd_ck.bmp"
	SkinBtn::Init "$PLUGINSDIR\tjqd_uc.bmp"
	SkinBtn::Init "$PLUGINSDIR\tjzm_ck.bmp"
	SkinBtn::Init "$PLUGINSDIR\tjzm_uc.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_min.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_close.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_change.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_install.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_return.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_quitsure.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_quitreturn.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_freeuse.bmp"
FunctionEnd



Function onMsgBoxCloseCallback
  ${If} $MSG = ${WM_CLOSE}
   Call OnClickQuitOK
  ${Else}
	Call HandlePageChange
  ${EndIf}
FunctionEnd

Var Hwnd_MsgBox
Var btn_MsgBoxSure
Var btn_MsgBoxCancel
Var lab_MsgBoxText
Var lab_MsgBoxText2
Function GsMessageBox
	IsWindow $Hwnd_MsgBox Create_End
	GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
	HideWindow
    nsDialogs::Create 1044
    Pop $Hwnd_MsgBox
    ${If} $Hwnd_MsgBox == error
        Abort
    ${EndIf}
    SetCtlColors $Hwnd_MsgBox ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $HWNDPARENT 351 186 ;改变窗体大小
    ${NSW_SetWindowSize} $Hwnd_MsgBox 351 186 ;改变Page大小
	System::Call  'User32::GetDesktopWindow() i.r8'
	${NSW_CenterWindow} $HWNDPARENT $8
	
	${NSD_CreateButton} 143 140 80 26 ''
	Pop $btn_MsgBoxSure
	StrCpy $1 $btn_MsgBoxSure
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitsure.bmp $1
	SkinBtn::onClick $1 $R7

	${NSD_CreateButton} 250 140 80 26 ''
	Pop $btn_MsgBoxCancel
	StrCpy $1 $btn_MsgBoxCancel
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitreturn.bmp $1
	GetFunctionAddress $0 OnClickQuitOK
	SkinBtn::onClick $1 $0
	
	StrCpy $3 79
	IntOp $3 $3 + $Int_FontOffset
	${NSD_CreateLabel} 127 $3 250 20 $R6
	Pop $lab_MsgBoxText
    SetCtlColors $lab_MsgBoxText "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $lab_MsgBoxText ${WM_SETFONT} $Handle_Font 0
	
	StrCpy $3 99
	IntOp $3 $3 + $Int_FontOffset
	${NSD_CreateLabel} 127 $3 250 20 $R8
	Pop $lab_MsgBoxText2
    SetCtlColors $lab_MsgBoxText2 "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $lab_MsgBoxText2 ${WM_SETFONT} $Handle_Font 0
	
	GetFunctionAddress $0 onGUICallback
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\quit.bmp $ImageHandle
	
	WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	
	GetFunctionAddress $0 onMsgBoxCloseCallback
	WndProc::onCallback $HWNDPARENT $0 ;处理关闭消息
	
	nsDialogs::Show
	${NSD_FreeImage} $ImageHandle
	Create_End:
	HideWindow
	ShowWindow $Hwnd_MsgBox ${SW_HIDE}
	System::Call  'User32::GetDesktopWindow() i.r8'
	${NSW_CenterWindow} $HWNDPARENT $8
	system::Call "user32::SetWindowText(i $lab_MsgBoxText, t '$R6')"
	system::Call "user32::SetWindowText(i $lab_MsgBoxText2, t '$R8')"
	SkinBtn::onClick $btn_MsgBoxSure $R7
	
	ShowWindow $HWNDPARENT ${SW_SHOW}
	ShowWindow $Hwnd_MsgBox ${SW_SHOW}
	BringToFront
FunctionEnd

Function ClickSure2
	ShowWindow $Hwnd_MsgBox ${SW_HIDE}
	ShowWindow $HWNDPARENT ${SW_HIDE}
	${If} $R0 != 0
		StartKillProcess:
		${For} $R3 0 3
			;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0"
			${If} $R3 == 3
			${AndIf} $R0 != 0
				Goto StartKillProcess
			${ElseIf} $R0 != 0
				KillProcDLL::KillProc "${PRODUCT_NAME}.exe"
				Sleep 250
			${Else}
				${Break}
			${EndIf}
		${Next}
	${EndIf}
	StrCpy $R9 1 ;Goto the next page
    Call RelGotoPage
FunctionEnd

Function ClickSure1
	ShowWindow $Hwnd_MsgBox ${SW_HIDE}
	ShowWindow $HWNDPARENT ${SW_HIDE}
	Sleep 100
	;发退出消息
	;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0"
	${If} $R0 != 0
		StrCpy $R6 "检测到元宝娱乐浏览器正在运行，"
		StrCpy $R8 "是否强制结束？"
		GetFunctionAddress $R7 ClickSure2
		Call GsMessageBox
	${Else}
		Call ClickSure2
	${EndIf}
FunctionEnd

Function CheckMessageBox
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "Path"
	IfFileExists $0 0 StartInstall
	${GetFileVersion} $0 $1
	${VersionCompare} $1 ${PRODUCT_VERSION} $2
	System::Call "kernel32::GetCommandLineA() t.R1"
	System::Call "kernel32::GetModuleFileName(i 0, t R2R2, i 256)"
	${WordReplace} $R1 $R2 "" +1 $R3
	${StrFilter} "$R3" "-" "" "" $R4
	${GetOptions} $R4 "/write"  $R0
	IfErrors 0 +3
	push "false"
	pop $R0
	${If} $2 == "2" ;已安装的版本低于该版本
		Call ClickSure1
	${ElseIf} $2 == "0" ;版本相同
	${OrIf} $2 == "1"	;已安装的版本高于该版本
		 ${If} $R0 == "false"
			StrCpy $R6 "检测到已安装${SHORTCUT_NAME}"
			StrCpy $R8 " $1，是否覆盖安装？"
			GetFunctionAddress $R7 ClickSure1
			Call GsMessageBox
		${Else}
			Call ClickSure1
		${EndIf}
	${EndIf}
	Goto EndFunction
	StartInstall:
	Call ClickSure1
	EndFunction:
FunctionEnd

Function onGUIInit
	;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}
FunctionEnd

;处理无边框移动
Function onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

Function onCloseCallback
	${If} $MSG = ${WM_CLOSE}
		Call onClickGuanbi
	${Else} 
		Call HandlePageChange
	${EndIf}
FunctionEnd

;下一步按钮事件
Function onClickNext
	Call OnClick_Install
FunctionEnd

;协议按钮事件
Function onClickAgreement
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	ExecShell open license.txt /x SW_SHOWNORMAL
FunctionEnd

;-----------------------------------------皮肤贴图方法----------------------------------------------------
Function SkinBtn_Next
  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_next.bmp $1
FunctionEnd

Function SkinBtn_Agreement1
  SkinBtn::Set /IMGID=$PLUGINSDIR\btn_agreement1.bmp $1
FunctionEnd

Function OnClick_CheckXieyi
	${IF} $Bool_Xieyi == 1
        IntOp $Bool_Xieyi $Bool_Xieyi - 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\agr_uc.bmp $ck_xieyi
		EnableWindow $Btn_Next 0
		EnableWindow $Btn_Zidingyi 0
    ${ELSE}
        IntOp $Bool_Xieyi $Bool_Xieyi + 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\agr_ck.bmp $ck_xieyi
		EnableWindow $Btn_Next 1
		EnableWindow $Btn_Zidingyi 1
    ${EndIf}
FunctionEnd

Function OnClick_BrowseButton
	Pop $0
	Push $INSTDIR ; input string "C:\Program Files\ProgramName"
	Call GetParent
	Pop $R0 ; first part "C:\Program Files"

	Push $INSTDIR ; input string "C:\Program Files\ProgramName"
	Push "\" ; input chop char
	Call GetLastPart
	Pop $R1 ; last part "ProgramName"
	${If} $R1 == 0
	${Orif} $R1 == ""
		StrCpy $R1 "YBYL"
	${EndIf}

	nsDialogs::SelectFolderDialog "请选择 $R0 安装的文件夹:" "$R0"
	Pop $0
	${If} $0 == "error" # returns 'error' if 'cancel' was pressed?
		Return
	${EndIf}
	${If} $0 != ""
	StrCpy $INSTDIR "$0\$R1"
	${WordReplace} $INSTDIR  "\\" "\" "+" $0
	StrCpy $INSTDIR "$0"
	system::Call `user32::SetWindowText(i $Txt_Browser, t "$INSTDIR")`
	${EndIf}
FunctionEnd

Function GetParent
  Exch $R0 ; input string
  Push $R1
  Push $R2
  Push $R3
  StrCpy $R1 0
  StrLen $R2 $R0
  loop:
    IntOp $R1 $R1 + 1
    IntCmp $R1 $R2 get 0 get
    StrCpy $R3 $R0 1 -$R1
    StrCmp $R3 "\" get
    Goto loop
  get:
    StrCpy $R0 $R0 -$R1
    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0 ; output string
FunctionEnd

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

;更改目录事件
Function OnChange_DirRequest
	System::Call "user32::GetWindowText(i $Txt_Browser, t .r0, i ${NSIS_MAX_STRLEN})"
	StrCpy $INSTDIR $0
	StrCpy $6 $INSTDIR 2
	StrCpy $7 $INSTDIR 3
	${If} $INSTDIR == ""
	${OrIf} $INSTDIR == 0
	${OrIf} $INSTDIR == $6
	${OrIf} $INSTDIR == $7
		MessageBox MB_OK|MB_ICONSTOP "非法路径"
		Abort
	${Else}
		StrCpy $8 ""
		${DriveSpace} $7 "/D=F /S=K" $8
		${If} $8 == ""
			MessageBox MB_OK|MB_ICONSTOP "非法路径"
			Abort
		${EndIf}
		IntCmp ${NeedSpace} $8 0 0 ErrorChunk
		EnableWindow $Btn_Install 1
		EnableWindow $Btn_Return 1
		Goto EndFunction
		ErrorChunk:
			MessageBox MB_OK|MB_ICONSTOP "磁盘剩余空间不足，需要至少${NeedSpace}KB"
			Abort
		EndFunction:
	${EndIf}
FunctionEnd

Var ParentWnd
Var nStartX
Function TimerMoveWnd
	${NSW_SetWindowPos} $ParentWnd  $nStartX 256
	${If} $nStartX == -528
		IntOp $nStartX $nStartX - 3
	${ElseIf} $nStartX == -531
		GetFunctionAddress $0 TimerMoveWnd
		nsDialogs::KillTimer $0
	${Else}
		IntOp $nStartX $nStartX - 24
	${EndIf}
FunctionEnd

Function onClickZidingyi
	GetFunctionAddress $0 TimerMoveWnd
    nsDialogs::CreateTimer $0 10
	StrCpy $nStartX 0
FunctionEnd

Function TimerMoveWnd2
	${NSW_SetWindowPos} $ParentWnd  $nStartX 256
	${If} $nStartX == -3
		IntOp $nStartX $nStartX + 3
	${ElseIf} $nStartX == 0
		GetFunctionAddress $0 TimerMoveWnd2
		nsDialogs::KillTimer $0
	${Else}
		IntOp $nStartX $nStartX + 24
	${EndIf}
FunctionEnd

Function OnClick_Return
	GetFunctionAddress $0 TimerMoveWnd2
    nsDialogs::CreateTimer $0 10
	StrCpy $nStartX -531
FunctionEnd

Function onClickZuixiaohua
	 ShowWindow $HWNDPARENT 2
FunctionEnd

Function onWarningGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $WarningForm ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

Function onClickGuanbi
	${If} $isMainUIShow != "true"
		Call OnClickQuitOK
		Abort
	${EndIf}
	IsWindow $WarningForm Create_End
	!define Style ${WS_VISIBLE}|${WS_OVERLAPPEDWINDOW}
	${NSW_CreateWindowEx} $WarningForm $hwndparent ${ExStyle} ${Style} "" 1018

	${NSW_SetWindowSize} $WarningForm 351 186
	EnableWindow $hwndparent 0
	System::Call `user32::SetWindowLong(i $WarningForm,i ${GWL_STYLE},0x9480084C)i.R0`
	${NSW_CreateButton} 143 140 80 26 ''
	Pop $R0
	StrCpy $1 $R0
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitsure.bmp $1
	${NSW_OnClick} $R0 OnClickQuitOK

	${NSW_CreateButton} 250 140 80 26 ''
	Pop $R0
	StrCpy $1 $R0
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitreturn.bmp $1
	${NSW_OnClick} $R0 OnClickQuitCancel

	StrCpy $3 79
	IntOp $3 $3 + $Int_FontOffset
	${NSW_CreateLabel} 127 $3 250 20 "您确定要退出${SHORTCUT_NAME}"
	Pop $4
    SetCtlColors $4 "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $4 ${WM_SETFONT} $Handle_Font 0
	
	StrCpy $3 99
	IntOp $3 $3 + $Int_FontOffset
	${NSW_CreateLabel} 127 $3 250 20 "安装程序？"
	Pop $4
    SetCtlColors $4 "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $4 ${WM_SETFONT} $Handle_Font 0
	
	${NSW_CreateBitmap} 0 0 100% 100% ""
  	Pop $1
	${NSW_SetImage} $1 $PLUGINSDIR\quit.bmp $ImageHandle
	GetFunctionAddress $0 onWarningGUICallback
	WndProc::onCallback $1 $0 ;处理无边框窗体移动
	${NSW_CenterWindow} $WarningForm $hwndparent
	${NSW_Show}
	Create_End:
	ShowWindow $WarningForm ${SW_SHOW}
	Abort
FunctionEnd

Function OnClickQuitOK
	HideWindow
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SoftExit()"
FunctionEnd

Function OnClickQuitCancel
	${NSW_DestroyWindow} $WarningForm
	EnableWindow $hwndparent 1
	BringToFront
FunctionEnd

Function OnClick_CheckDeskTopLink
	${IF} $Bool_DeskTopLink == 1
        IntOp $Bool_DeskTopLink $Bool_DeskTopLink - 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\tjzm_uc.bmp $ck_DeskTopLink
    ${ELSE}
        IntOp $Bool_DeskTopLink $Bool_DeskTopLink + 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\tjzm_ck.bmp $ck_DeskTopLink
    ${EndIf}
FunctionEnd


Function OnClick_CheckToolBarLink
	${IF} $Bool_ToolBarLink == 1
        IntOp $Bool_ToolBarLink $Bool_ToolBarLink - 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\tjqd_uc.bmp $ck_ToolBarLink
    ${ELSE}
        IntOp $Bool_ToolBarLink $Bool_ToolBarLink + 1
        SkinBtn::Set /IMGID=$PLUGINSDIR\tjqd_ck.bmp $ck_ToolBarLink
    ${EndIf}
FunctionEnd


;处理页面跳转的命令
Function RelGotoPage
  StrCpy $9 "userchoice"
  IntCmp $R9 0 0 Move Move
    StrCmp $R9 "X" 0 Move
      StrCpy $R9 "120"
  Move:
  SendMessage $HWNDPARENT "0x408" "$R9" ""
FunctionEnd

Function OnClick_Install
	Call OnChange_DirRequest
	StrCpy $6 $INSTDIR 2
	StrCpy $7 $INSTDIR 3
	${If} $INSTDIR == ""
	${OrIf} $INSTDIR == 0
	${OrIf} $INSTDIR == $6
	${OrIf} $INSTDIR == $7
		MessageBox MB_OK|MB_ICONSTOP "路径不合法"
	${Else}
		StrCpy $8 ""
		${DriveSpace} $7 "/D=F /S=K" $8
		${If} $8 == ""
			MessageBox MB_OK|MB_ICONSTOP "路径不合法"
			Abort
		${EndIf}
		IntCmp ${NeedSpace} $8 0 0 ErrorChunk
		StrCpy $R9 1 ;Goto the next page
		Call RelGotoPage
		Goto EndFunction
		ErrorChunk:
			MessageBox MB_OK|MB_ICONSTOP "磁盘剩余空间不足，需要至少${NeedSpace}KB"
		EndFunction:
	${EndIf}
FunctionEnd

Var img_installpos
Function WelcomePage
    StrCpy $isMainUIShow "true"
	GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
	HideWindow
    nsDialogs::Create 1044
    Pop $Hwnd_Welcome
    ${If} $Hwnd_Welcome == error
        Abort
    ${EndIf}
    SetCtlColors $Hwnd_Welcome ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $HWNDPARENT 531 409 ;改变窗体大小
    ${NSW_SetWindowSize} $Hwnd_Welcome 531 409 ;改变Page大小
	
	System::Call  'User32::GetDesktopWindow() i.R9'
	${NSW_CenterWindow} $HWNDPARENT $R9
	
	
    ;一键安装
	StrCpy $Bool_IsExtend 0
    ${NSD_CreateButton} 158 29 213 53 ""
	Pop $Btn_Next
	StrCpy $1 $Btn_Next
	Call SkinBtn_Next
	GetFunctionAddress $3 onClickNext
    SkinBtn::onClick $1 $3
    
	;勾选同意协议
	${NSD_CreateButton} 15 119 121 14 ""
	Pop $ck_xieyi
	StrCpy $1 $ck_xieyi
	SkinBtn::Set /IMGID=$PLUGINSDIR\agr_ck.bmp $1
	GetFunctionAddress $3 OnClick_CheckXieyi
    SkinBtn::onClick $1 $3
	StrCpy $Bool_Xieyi 1
	
	
	
    ;用户协议
	${NSD_CreateButton} 140 119 146 14 ""
	Pop $Btn_Agreement
	StrCpy $1 $Btn_Agreement
	Call SkinBtn_Agreement1
	GetFunctionAddress $3 onClickAgreement
	SkinBtn::onClick $1 $3
		
	;自定义安装
	${NSD_CreateButton} 440 121 77 12 ""
	Pop $Btn_Zidingyi
	StrCpy $1 $Btn_Zidingyi
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_agreement2.bmp $1
	GetFunctionAddress $3 onClickZidingyi
	SkinBtn::onClick $1 $3
	
	;最小化
	${NSD_CreateButton} 484 13 10 2 ""
	Pop $Btn_Zuixiaohua
	StrCpy $1 $Btn_Zuixiaohua
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_min.bmp $1
	GetFunctionAddress $3 onClickZuixiaohua
	SkinBtn::onClick $1 $3
	;关闭
	${NSD_CreateButton} 507 9 10 10 ""
	Pop $Btn_Guanbi
	StrCpy $1 $Btn_Guanbi
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $1
	GetFunctionAddress $3 onClickGuanbi
	SkinBtn::onClick $1 $3
	
	;安装位置
	${NSD_CreateBitmap} 545 10 62 20 ""
	Pop $img_installpos
	${NSD_SetImage} $img_installpos $PLUGINSDIR\img_installpos.bmp $ImageHandle
	
	;目录选择框
	${NSD_CreateText} 545 38 425 26 "$INSTDIR"
 	Pop	$Txt_Browser
	SendMessage $Txt_Browser ${WM_SETFONT} $Handle_Font 0
 	${NSD_OnChange} $Txt_Browser OnChange_DirRequest
	;目录选择按钮
	${NSD_CreateBrowseButton} 969 38 79 26 ""
 	Pop	$Btn_Browser
 	StrCpy $1 $Btn_Browser
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_change.bmp $1
	GetFunctionAddress $3 OnClick_BrowseButton
    SkinBtn::onClick $1 $3
	
	
	;添加桌面快捷方式
	${NSD_CreateButton} 547 117 93 14 ""
	Pop $ck_DeskTopLink
	StrCpy $1 $ck_DeskTopLink
	SkinBtn::Set /IMGID=$PLUGINSDIR\tjzm_ck.bmp $1
	GetFunctionAddress $3 OnClick_CheckDeskTopLink
    SkinBtn::onClick $1 $3
	StrCpy $Bool_DeskTopLink 1
	
	
	;添加到启动栏
	${NSD_CreateButton} 650 117 136 14 ""
	Pop $ck_ToolBarLink
	StrCpy $1 $ck_ToolBarLink
	SkinBtn::Set /IMGID=$PLUGINSDIR\tjqd_ck.bmp $1
	GetFunctionAddress $3 OnClick_CheckToolBarLink
    SkinBtn::onClick $1 $3
	StrCpy $Bool_ToolBarLink 1
	
	
	;立即安装
	${NSD_CreateButton} 883 108 80 26 ""
 	Pop	$Btn_Install
 	StrCpy $1 $Btn_Install
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_install.bmp $1
	GetFunctionAddress $3 OnClick_Install
    SkinBtn::onClick $1 $3
	;ShowWindow $Btn_Install ${SW_HIDE}
	
	;返回
	${NSD_CreateButton} 966 108 80 26 ""
 	Pop	$Btn_Return
 	StrCpy $1 $Btn_Return
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_return.bmp $1
	GetFunctionAddress $3 OnClick_Return
    SkinBtn::onClick $1 $3
	
	${NSD_CreateLabel} 0 256 1062 153 ""
	Pop $ParentWnd
	SetCtlColors $ParentWnd 0xFFFFFF 0xFFFFFF
	
	
	${NSW_SetParent} $Btn_Next $ParentWnd
	${NSW_SetParent} $Btn_Agreement $ParentWnd
	${NSW_SetParent} $ck_xieyi $ParentWnd
	${NSW_SetParent} $Btn_Zidingyi $ParentWnd
	${NSW_SetParent} $img_installpos $ParentWnd
	${NSW_SetParent} $Txt_Browser $ParentWnd
	${NSW_SetParent} $Btn_Browser $ParentWnd
	${NSW_SetParent} $ck_DeskTopLink $ParentWnd
	${NSW_SetParent} $ck_ToolBarLink $ParentWnd
	${NSW_SetParent} $Btn_Install $ParentWnd
	${NSW_SetParent} $Btn_Return $ParentWnd
	StrCpy $1 $ck_xieyi
	SkinBtn::Set /IMGID=$PLUGINSDIR\agr_ck.bmp $1
	
	GetFunctionAddress $0 onGUICallback
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 256 ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg1.bmp $ImageHandle
	
	WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	
	GetFunctionAddress $0 onCloseCallback
	WndProc::onCallback $HWNDPARENT $0 ;处理关闭消息
	
	ShowWindow $HWNDPARENT ${SW_SHOW}
	nsDialogs::Show
	${NSD_FreeImage} $ImageHandle
	BringToFront
FunctionEnd

Var Handle_Loading
Var img_installing
Function NSD_TimerFun
	GetFunctionAddress $0 NSD_TimerFun
    nsDialogs::KillTimer $0
    !if 1   ;是否在后台运行,1有效
        GetFunctionAddress $0 InstallationMainFun
        BgWorker::CallAndWait
    !else
        Call InstallationMainFun
    !endif
	Call InstallIE
	;主线程中创建快捷方式
	${If} $Bool_DeskTopLink == 1
		SetOutPath "$INSTDIR\program"
		CreateShortCut "$DESKTOP\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom desktop" "$INSTDIR\res\shortcut.ico"
		${RefreshShellIcons}
	${EndIf}
	
	
	${If} $Bool_ToolBarLink == 1
		ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
		${VersionCompare} "$R0" "6.0" $2
		SetOutPath "$INSTDIR\program"
		;快速启动栏
		${if} $2 == 2
			CreateShortCut "$QUICKLAUNCH\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom toolbar" "$INSTDIR\res\shortcut.ico"
			CreateShortCut "$STARTMENU\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startbar" "$INSTDIR\res\shortcut.ico"
			StrCpy $R0 "$STARTMENU\${SHORTCUT_NAME}.lnk" 
			Call RefreshIcon
			SetOutPath "$TEMP\${PRODUCT_NAME}"
			IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +2
			System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b true, t "$STARTMENU\${SHORTCUT_NAME}.lnk")'
		${else}
			Call GetPinPath
			${If} $0 != "" 
			${AndIf} $0 != 0
			Call RefreshIcon
			Sleep 500
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$0\TaskBar\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\TaskBar\${SHORTCUT_NAME}.lnk"
			Call RefreshIcon
			Sleep 500
			SetOutPath "$INSTDIR\program"
			CreateShortCut "$INSTDIR\program\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom toolbar" "$INSTDIR\res\shortcut.ico"
			ExecShell taskbarpin "$INSTDIR\program\${SHORTCUT_NAME}.lnk" "/sstartfrom toolbar"
			
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$0\StartMenu\${SHORTCUT_NAME}.lnk')"
			Sleep 1000
			CreateShortCut "$STARTMENU\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startbar" "$INSTDIR\res\shortcut.ico"
			StrCpy $R0 "$STARTMENU\${SHORTCUT_NAME}.lnk" 
			Call RefreshIcon
			Sleep 200
			ExecShell startpin "$STARTMENU\${SHORTCUT_NAME}.lnk" "/sstartfrom startbar"
			${EndIf}
		${Endif}
	${EndIf}
	
	
	CreateDirectory "$SMPROGRAMS\${SHORTCUT_NAME}"
	SetOutPath "$INSTDIR\program"
	CreateShortCut "$SMPROGRAMS\${SHORTCUT_NAME}\${SHORTCUT_NAME}.lnk" "$INSTDIR\program\${PRODUCT_NAME}.exe" "/sstartfrom startmenuprograms" "$INSTDIR\res\shortcut.ico"
	CreateShortCut "$SMPROGRAMS\${SHORTCUT_NAME}\卸载${SHORTCUT_NAME}.lnk" "$INSTDIR\uninst.exe"
	;最后才显示安装完成界面
	HideWindow
	ShowWindow $Handle_Loading ${SW_HIDE}
	ShowWindow $img_installing ${SW_HIDE}
	ShowWindow $PB_ProgressBar ${SW_HIDE}

	ShowWindow $Btn_Guanbi ${SW_SHOW}
	
	ShowWindow $Bmp_Finish ${SW_SHOW}
	ShowWindow $Btn_FreeUse ${SW_SHOW}
	ShowWindow $Handle_Loading ${SW_SHOW}
	ShowWindow $HWNDPARENT ${SW_SHOW}
	BringToFront
FunctionEnd


Function InstallationMainFun
	SendMessage $PB_ProgressBar ${PBM_SETRANGE32} 0 100  ;总步长为顶部定义值
	Sleep 100
	Call CloseExe
	SendMessage $PB_ProgressBar ${PBM_SETPOS} 2 0
	Sleep 100
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 4 0
	Sleep 100
	SendMessage $PB_ProgressBar ${PBM_SETPOS} 7 0
    Sleep 100
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 14 0
    Sleep 100
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 27 0
    Call DoInstall
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 50 0
    Sleep 100
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 73 0
    Sleep 100
    SendMessage $PB_ProgressBar ${PBM_SETPOS} 100 0
	Sleep 1000
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::NsisTSLOG(t 'InstallationMainFun LEAVE')"
FunctionEnd

Function OnClick_FreeUse
	SetOutPath "$INSTDIR\program"
	ExecShell open "${PRODUCT_NAME}.exe" "/forceshow /sstartfrom installfinish" SW_SHOWNORMAL
	Call OnClickQuitOK
FunctionEnd

;安装进度页面
Function LoadingPage
  StrCpy $isMainUIShow "false";按下esc直接退出
  GetDlgItem $0 $HWNDPARENT 1
  ShowWindow $0 ${SW_HIDE}
  GetDlgItem $0 $HWNDPARENT 2
  ShowWindow $0 ${SW_HIDE}
  GetDlgItem $0 $HWNDPARENT 3
  ShowWindow $0 ${SW_HIDE}
	
	HideWindow
	nsDialogs::Create 1044
	Pop $Handle_Loading
	${If} $Handle_Loading == error
		Abort
	${EndIf}
	SetCtlColors $Handle_Loading ""  transparent ;背景设成透明

	${NSW_SetWindowSize} $HWNDPARENT 531 409 ;改变自定义窗体大小
	${NSW_SetWindowSize} $Handle_Loading 531 409 ;改变自定义Page大小


    ;正在安装
    ${NSD_CreateBitmap} 18 274 62 20 ""
    Pop $img_installing
    ${NSD_SetImage} $img_installing $PLUGINSDIR\img_installing.bmp $ImageHandle
    
	
	${NSD_CreateProgressBar} 18 315 498 13 ""
    Pop $PB_ProgressBar
    SkinProgress::Set $PB_ProgressBar "$PLUGINSDIR\loading2.bmp" "$PLUGINSDIR\loadingbg.bmp"
	
	GetFunctionAddress $0 NSD_TimerFun
    nsDialogs::CreateTimer $0 1
	
	
	;完成时"免费使用"按钮
	${NSD_CreateButton} 159 287 213 53 ""
 	Pop	$Btn_FreeUse
 	StrCpy $1 $Btn_FreeUse
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_freeuse.bmp $1
	GetFunctionAddress $3 OnClick_FreeUse
    SkinBtn::onClick $1 $3
	ShowWindow $Btn_FreeUse ${SW_HIDE}
		
	;关闭
	${NSD_CreateButton} 507 9 10 10 ""
	Pop $Btn_Guanbi
	StrCpy $1 $Btn_Guanbi
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_close.bmp $1
	GetFunctionAddress $3 OnClickQuitOK
	SkinBtn::onClick $1 $3
	ShowWindow $Btn_Guanbi ${SW_HIDE}
	
	;底部白色背景
	${NSD_CreateLabel} 0 256 531 153 ""
	Pop $ParentWnd
	SetCtlColors $ParentWnd 0xFFFFFF 0xFFFFFF
	
	GetFunctionAddress $0 onGUICallback  
    ;完成时背景图
    ${NSD_CreateBitmap} 0 0 100% 256 ""
    Pop $Bmp_Finish
    ${NSD_SetImage} $Bmp_Finish $PLUGINSDIR\bg3.bmp $ImageHandle
    ShowWindow $Bmp_Finish ${SW_HIDE}
	WndProc::onCallback $Bmp_Finish $0 ;处理无边框窗体移动
	 
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 256 ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\bg2.bmp $ImageHandle
    WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	
	GetFunctionAddress $0 onCloseCallback
	WndProc::onCallback $HWNDPARENT $0 ;处理关闭消息
    
	ShowWindow $HWNDPARENT ${SW_SHOW}
	nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
	BringToFront
FunctionEnd

Function RefreshIcon
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")'
FunctionEnd

Function GetPinPath
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r0)'
FunctionEnd



/****************************************************/
;卸载
/****************************************************/
Var Bmp_StartUnstall
Var Btn_ContinueUse
Var Btn_CruelRefused

Var Bmp_FinishUnstall
Var Btn_FinishUnstall

Function un.UpdateChanel
	ReadRegStr $R4 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstallSource"
	${If} $R4 == 0
	${OrIf} $R4 == ""
		StrCpy $str_ChannelID "unknown"
	${Else}
		StrCpy $str_ChannelID $R4
	${EndIf}
FunctionEnd

Function un.onInit
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "YBSetup_{515B51B0-F350-4acb-9FDA-476C1DC84FEE}") i .r1 ?e'
	Pop $R0
	StrCmp $R0 0 +2
	Abort
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "YUANBAOSETUP_INSTALL_MUTEX") i .r1 ?e'
	Pop $R0
	StrCmp $R0 0 BeginUninstall
	ReadRegStr $R1 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "PackageName"
	;FindProcDLL::FindProc "$R1"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '$R1') i.R0 ?e"
	${For} $R3 0 3
		;FindProcDLL::FindProc "$R1"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '$R1') i.R0 ?e"
		${If} $R3 == 3
		${AndIf} $R0 != 0
			KillProcDLL::KillProc "$R1"
		${ElseIf} $R0 != 0
			Sleep 250
		${Else}
			${Break}
		${EndIf}
	${Next}
	Goto NoReleaseHelper
	BeginUninstall:
	
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
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	SetOverwrite on
	File "bin\YBSetUpHelper.dll"
	NoReleaseHelper:
	
	StrCpy $Int_FontOffset 4
	CreateFont $Handle_Font "宋体" 10 0
	IfFileExists "$FONTS\msyh.ttf" 0 +3
	CreateFont $Handle_Font "微软雅黑" 10 0
	StrCpy $Int_FontOffset 0
	
	Call un.UpdateChanel
	
	InitPluginsDir
    File "/ONAME=$PLUGINSDIR\un_startbg.bmp" "images\un_startbg.bmp"
	File "/ONAME=$PLUGINSDIR\un_finishbg.bmp" "images\un_finishbg.bmp"
	File "/ONAME=$PLUGINSDIR\btn_jixushiyong.bmp" "images\btn_jixushiyong.bmp"
	File "/ONAME=$PLUGINSDIR\btn_canrenxiezai.bmp" "images\btn_canrenxiezai.bmp"
	File "/ONAME=$PLUGINSDIR\btn_xiezaiwancheng.bmp" "images\btn_xiezaiwancheng.bmp"
	
	SkinBtn::Init "$PLUGINSDIR\btn_jixushiyong.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_canrenxiezai.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_xiezaiwancheng.bmp"
	
	File "/oname=$PLUGINSDIR\quit.bmp" "images\quit.bmp"
	File "/oname=$PLUGINSDIR\btn_quitsure.bmp" "images\btn_quitsure.bmp"
	File "/oname=$PLUGINSDIR\btn_quitreturn.bmp" "images\btn_quitreturn.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_quitsure.bmp"
	SkinBtn::Init "$PLUGINSDIR\btn_quitreturn.bmp"
FunctionEnd

Function un.onGUICallback
  ${If} $MSG = ${WM_LBUTTONDOWN}
    SendMessage $HWNDPARENT ${WM_NCLBUTTONDOWN} ${HTCAPTION} $0
  ${EndIf}
FunctionEnd

Function un.onMsgBoxCloseCallback
	Call un.HandlePageChange
FunctionEnd
Function un.myGUIInit
	;消除边框
    System::Call `user32::SetWindowLong(i$HWNDPARENT,i${GWL_STYLE},0x9480084C)i.R0`
    ;隐藏一些既有控件
    GetDlgItem $0 $HWNDPARENT 1034
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1035
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1036
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1037
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1038
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1039
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1256
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 1028
    ShowWindow $0 ${SW_HIDE}
FunctionEnd

Function un.OnClick_ContinueUse
	EnableWindow $Btn_CruelRefused 0
	EnableWindow $Btn_ContinueUse 0
	Call un.OnClick_FinishUnstall
FunctionEnd

Function un.Random
	Exch $0
	Push $1
	System::Call 'kernel32::QueryPerformanceCounter(*l.r1)'
	System::Int64Op $1 % $0
	Pop $0
	Pop $1
	Exch $0
FunctionEnd

Function un.DoUninstall
	;删除
	RMDir /r "$INSTDIR\xar"
	Delete "$INSTDIR\uninst.exe"
	RMDir /r "$INSTDIR\program"
	RMDir /r "$INSTDIR\res"
	RMDir /r "$INSTDIR\filterres"
	
	
	StrCpy "$R0" "$INSTDIR"
	System::Call 'Shlwapi::PathIsDirectoryEmpty(t R0)i.s'
	Pop $R1
	${If} $R1 == 1
		RMDir /r "$INSTDIR"
	${EndIf}
FunctionEnd

Function un.UNSD_TimerFun
	GetFunctionAddress $0 un.UNSD_TimerFun
    nsDialogs::KillTimer $0
    GetFunctionAddress $0 un.DoUninstall
    BgWorker::CallAndWait
	ReadRegStr $0 ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}" "InstDir"
	${If} $0 == "$INSTDIR"
		DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
		DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
		 ;删除自用的注册表信息
		DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_MAININFO_FORSELF}"
		DeleteRegValue ${PRODUCT_UNINST_ROOT_KEY} "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "${PRODUCT_NAME}"
		DeleteRegValue HKCU "Software\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_BROWSER_EMULATION" "${PRODUCT_NAME}.exe"
	${EndIf}
	
	IfFileExists "$DESKTOP\${SHORTCUT_NAME}.lnk" 0 +2
		Delete "$DESKTOP\${SHORTCUT_NAME}.lnk"
	IfFileExists "$STARTMENU\${SHORTCUT_NAME}.lnk" 0 +2
		Delete "$STARTMENU\${SHORTCUT_NAME}.lnk"
	RMDir /r "$SMPROGRAMS\${SHORTCUT_NAME}"
	ShowWindow $Bmp_StartUnstall ${SW_HIDE}
	ShowWindow $Btn_ContinueUse ${SW_HIDE}
	ShowWindow $Btn_CruelRefused ${SW_HIDE}
	ShowWindow $Bmp_FinishUnstall 1
	ShowWindow $Btn_FinishUnstall 1
FunctionEnd

Function un.RefreshIcon
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::RefleshIcon(t "$R0")'
FunctionEnd

Function un.GetPinPath
	SetOutPath "$TEMP\${PRODUCT_NAME}"
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::GetUserPinPath(t) i(.r0)'
FunctionEnd

Function un.OnClick_CruelRefused
	EnableWindow $Btn_CruelRefused 0
	EnableWindow $Btn_ContinueUse 0
	IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +3
	System::Call '$TEMP\${PRODUCT_NAME}\YBSetUpHelper::SendAnyHttpStat(t "uninstall", t "$str_ChannelID", t "${VERSION_LASTNUMBER}",  i 1) '
	${For} $R3 0 3
		;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0 ?e"
		${If} $R3 == 3
		${AndIf} $R0 != 0
			KillProcDLL::KillProc "${PRODUCT_NAME}.exe"
		${ElseIf} $R0 != 0
			Sleep 250
		${Else}
			${Break}
		${EndIf}
	${Next}
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentVersion"
	${VersionCompare} "$R0" "6.0" $2
	${if} $2 == 2
		Delete "$QUICKLAUNCH\${SHORTCUT_NAME}.lnk"
		SetOutPath "$TEMP\${PRODUCT_NAME}"
		IfFileExists "$TEMP\${PRODUCT_NAME}\YBSetUpHelper.dll" 0 +2
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::PinToStartMenu4XP(b 0, t '$STARTMENU\${SHORTCUT_NAME}.lnk')"
	${else}
		Call un.GetPinPath
		${If} $0 != "" 
		${AndIf} $0 != 0
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2TaskbarWin7(t '$0\TaskBar\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\TaskBar\${SHORTCUT_NAME}.lnk"
			Call un.RefreshIcon
			Sleep 200
			System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::Pin2StartMenuWin7(t '$0\StartMenu\${SHORTCUT_NAME}.lnk')"
			StrCpy $R0 "$0\StartMenu\${SHORTCUT_NAME}.lnk"
			Call un.RefreshIcon
			Sleep 200
		${EndIf}
	${Endif}

	GetFunctionAddress $0 un.UNSD_TimerFun
    nsDialogs::CreateTimer $0 1
FunctionEnd

Function un.GetLastPart
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

Function un.OnClick_FinishUnstall
	;SendMessage $HWNDPARENT ${WM_CLOSE} 0 0
	System::Call 'kernel32::GetModuleFileName(i 0, t R2R2, i 256)'
	Push $R2
	Push "\"
	Call un.GetLastPart
	Pop $R1
	${If} $R1 == ""
		StrCpy $R1 "Au_.exe"
	${EndIf}
	;FindProcDLL::FindProc $R1
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '$R1') i.R0 ?e"
	${If} $R0 != 0
		KillProcDLL::KillProc $R1
	${EndIf}
FunctionEnd

Function un.GsMessageBox
	IsWindow $Hwnd_MsgBox Create_End
	GetDlgItem $0 $HWNDPARENT 1
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 2
    ShowWindow $0 ${SW_HIDE}
    GetDlgItem $0 $HWNDPARENT 3
    ShowWindow $0 ${SW_HIDE}
	HideWindow
    nsDialogs::Create 1044
    Pop $Hwnd_MsgBox
    ${If} $Hwnd_MsgBox == error
        Abort
    ${EndIf}
    SetCtlColors $Hwnd_MsgBox ""  transparent ;背景设成透明

    ${NSW_SetWindowSize} $HWNDPARENT 351 186 ;改变窗体大小
    ${NSW_SetWindowSize} $Hwnd_MsgBox 351 186 ;改变Page大小
	System::Call  'User32::GetDesktopWindow() i.r8'
	${NSW_CenterWindow} $HWNDPARENT $8
	;System::Call "user32::SetForegroundWindow(i $HWNDPARENT)"
	
	${NSD_CreateButton} 143 140 80 26 ''
	Pop $btn_MsgBoxSure
	StrCpy $1 $btn_MsgBoxSure
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitsure.bmp $1
	SkinBtn::onClick $1 $R7

	${NSD_CreateButton} 250 140 80 26 ''
	Pop $btn_MsgBoxCancel
	StrCpy $1 $btn_MsgBoxCancel
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_quitreturn.bmp $1
	GetFunctionAddress $0 un.OnClick_FinishUnstall
	SkinBtn::onClick $1 $0
	
	StrCpy $3 79
	IntOp $3 $3 + $Int_FontOffset
	${NSD_CreateLabel} 127 $3 250 20 $R6
	Pop $lab_MsgBoxText
    SetCtlColors $lab_MsgBoxText "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $lab_MsgBoxText ${WM_SETFONT} $Handle_Font 0
	
	StrCpy $3 99
	IntOp $3 $3 + $Int_FontOffset
	${NSD_CreateLabel} 127 $3 250 20 $R8
	Pop $lab_MsgBoxText2
    SetCtlColors $lab_MsgBoxText2 "${TEXTCOLOR}" transparent ;背景设成透明
	SendMessage $lab_MsgBoxText2 ${WM_SETFONT} $Handle_Font 0
	
	
	GetFunctionAddress $0 un.onGUICallback
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 100% ""
    Pop $BGImage
    ${NSD_SetImage} $BGImage $PLUGINSDIR\quit.bmp $ImageHandle
	
	WndProc::onCallback $BGImage $0 ;处理无边框窗体移动
	
	GetFunctionAddress $0 un.onMsgBoxCloseCallback
	WndProc::onCallback $HWNDPARENT $0 ;处理关闭消息
	
	nsDialogs::Show
	${NSD_FreeImage} $ImageHandle
	Create_End:
	HideWindow
	System::Call  'User32::GetDesktopWindow() i.r8'
	${NSW_CenterWindow} $HWNDPARENT $8
	system::Call `user32::SetWindowText(i $lab_MsgBoxText, t "$R6")`
	system::Call `user32::SetWindowText(i $lab_MsgBoxText2, t "$R8")`
	SkinBtn::onClick $btn_MsgBoxSure $R7
	
	ShowWindow $HWNDPARENT ${SW_SHOW}
	ShowWindow $Hwnd_MsgBox ${SW_SHOW}
	BringToFront
FunctionEnd

Function un.ClickSure
	StartKillProcess:
	${For} $R3 0 3
		;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
		System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0 ?e"
		${If} $R3 == 3
		${AndIf} $R0 != 0
			Goto StartKillProcess
		${ElseIf} $R0 != 0
			KillProcDLL::KillProc "${PRODUCT_NAME}.exe"
			Sleep 250
		${Else}
			${Break}
		${EndIf}
	${Next}
	StrCpy $9 "userchoice"
	SendMessage $HWNDPARENT 0x408 1 0
FunctionEnd

Function un.MyUnstallMsgBox
	push $0
	call un.myGUIInit
	;发退出消息
	;FindProcDLL::FindProc "${PRODUCT_NAME}.exe"
	System::Call "$TEMP\${PRODUCT_NAME}\YBSetUpHelper::QueryProcessExist(t '${PRODUCT_NAME}.exe') i.R0 ?e"
	${If} $R0 != 0
		StrCpy $R6 "检测到元宝娱乐浏览器正在运行，"
		StrCpy $R8 "是否强制结束？"
		GetFunctionAddress $R7 un.ClickSure
		Call un.GsMessageBox
	${Else}
		Call un.ClickSure
	${EndIf}
FunctionEnd

Function un.MyUnstall
	;push $HWNDPARENT
	;call un.myGUIInit
	GetDlgItem $0 $HWNDPARENT 1
	ShowWindow $0 ${SW_HIDE}
	GetDlgItem $0 $HWNDPARENT 2
	ShowWindow $0 ${SW_HIDE}
	GetDlgItem $0 $HWNDPARENT 3
	ShowWindow $0 ${SW_HIDE}
	
	HideWindow
	nsDialogs::Create 1044
	Pop $0
	${If} $0 == error
		Abort
	${EndIf}
	SetCtlColors $0 ""  transparent ;背景设成透明

	${NSW_SetWindowSize} $HWNDPARENT 531 409 ;改变自定义窗体大小
	${NSW_SetWindowSize} $0 531 409 ;改变自定义Page大小
	
	System::Call 'user32::GetDesktopWindow()i.R9'
	${NSW_CenterWindow} $HWNDPARENT $R9
	;继续使用
	${NSD_CreateButton} 274 292 153 53 ""
 	Pop	$Btn_ContinueUse
 	StrCpy $1 $Btn_ContinueUse
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_jixushiyong.bmp $1
	GetFunctionAddress $3 un.OnClick_ContinueUse
    SkinBtn::onClick $1 $3
	
	;残忍卸载
	${NSD_CreateButton} 110 292 153 53 ""
 	Pop	$Btn_CruelRefused
 	StrCpy $1 $Btn_CruelRefused
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_canrenxiezai.bmp $1
	GetFunctionAddress $3 un.OnClick_CruelRefused
    SkinBtn::onClick $1 $3
	
	;卸载完成
	${NSD_CreateButton} 189 295 153 53 ""
 	Pop	$Btn_FinishUnstall
 	StrCpy $1 $Btn_FinishUnstall
	SkinBtn::Set /IMGID=$PLUGINSDIR\btn_xiezaiwancheng.bmp $1
	GetFunctionAddress $3 un.OnClick_FinishUnstall
    SkinBtn::onClick $1 $3
	ShowWindow $Btn_FinishUnstall ${SW_HIDE}
   
	;底部白色背景
	${NSD_CreateLabel} 0 256 100% 153 ""
	Pop $ParentWnd
	SetCtlColors $ParentWnd 0xFFFFFF 0xFFFFFF
	
	
	GetFunctionAddress $0 un.onGUICallback  
	;卸载完成背景
    ${NSD_CreateBitmap} 0 0 100% 256 ""
    Pop $Bmp_FinishUnstall
    ${NSD_SetImage} $Bmp_FinishUnstall $PLUGINSDIR\un_finishbg.bmp $ImageHandle
    WndProc::onCallback $Bmp_FinishUnstall $0 ;处理无边框窗体移动
	ShowWindow $Bmp_FinishUnstall ${SW_HIDE}
	
	
    ;贴背景大图
    ${NSD_CreateBitmap} 0 0 100% 256 ""
    Pop $Bmp_StartUnstall
    ${NSD_SetImage} $Bmp_StartUnstall $PLUGINSDIR\un_startbg.bmp $ImageHandle
    WndProc::onCallback $Bmp_StartUnstall $0 ;处理无边框窗体移动
	
	GetFunctionAddress $0 un.onMsgBoxCloseCallback
	WndProc::onCallback $HWNDPARENT $0 ;处理关闭消息
    
	ShowWindow $HWNDPARENT ${SW_SHOW}
	nsDialogs::Show
    ${NSD_FreeImage} $ImageHandle
	BringToFront
FunctionEnd