local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")

local gStatCount = 0
local gForceExit = nil
local g_tWindowSize = {left=0,right=0,top=0,bottom=0}

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end

function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end

function TipLog(strLog)
	if type(tipUtil.Log) == "function" then
		tipUtil:Log("@@YBYL_Log: " .. tostring(strLog))
	end
end


function IsUACOS()
	local bRet = true
	local iMax, iMin = tipUtil:GetOSVersion()
	if type(iMax) == "number" and iMax <= 5 then
		bRet = false
	end
	return bRet
end


function LoadTableFromFile(strDatFilePath)
	local tResult = nil

	if IsRealString(strDatFilePath) and tipUtil:QueryFileExists(strDatFilePath) then
		local tMod = XLLoadModule(strDatFilePath)
		if type(tMod) == "table" and type(tMod.GetSubTable) == "function" then
			local tDat = tMod.GetSubTable()
			if type(tDat) == "table" then
				tResult = tDat
			end
		end
	end
	
	return tResult
end

function SaveTableToFile(tDat, strDatFilePath)
	local bSuc = false
	if type(tDat) == "table" and IsRealString(strDatFilePath) then
		local strDir = string.match(strDatFilePath, "^(.*)[\\/][^\\/]*$")
		if IsRealString(strDir) then
			if not tipUtil:QueryFileExists(strDir) then
				tipUtil:CreateDir(strDir)
			end
			if tipUtil:QueryFileExists(strDir) then
				tipUtil:SaveLuaTableToLuaFile(tDat, strDatFilePath)
				bSuc = true
			end
		end
	end
	
	return bSuc
end

function FetchValueByPath(obj, path)
	local cursor = obj
	for i = 1, #path do
		cursor = cursor[path[i]]
		if cursor == nil then
			return nil
		end
	end
	return cursor
end

function GetCommandStrValue(strKey)
	local bRet, strValue = false, nil
	local cmdString = tipUtil:GetCommandLine()
	
	if string.find(cmdString, strKey .. " ") then
		local cmdList = tipUtil:CommandLineToList(cmdString)
		if cmdList ~= nil then	
			for i = 1, #cmdList, 1 do
				local strTmp = tostring(cmdList[i])
				if strTmp == strKey 
					and not string.find(tostring(cmdList[i + 1]), "^/") then		
					bRet = true
					strValue = tostring(cmdList[i + 1])
					break
				end
			end
		end
	end
	return bRet, strValue
end


function GetFileNameFromPath(strFilePath, bWithExt)
	if not IsRealString(strFilePath) then
		return ""
	end

	local npos1, npos2
	npos1, npos2, strFileName = string.find(strFilePath, "\\([^\\]*)$")
	if not bWithExt then
		npos1, npos2, strFileName = string.find(tostring(strFileName), "(.*)%.[^%.]*$")
	end
	
	return strFileName
end


function ExitProcess()
	SaveAllConfig()

	TipLog("************ Exit ************")
	tipUtil:Exit("Exit")
end

function HideMainWindow()
	local objMainWnd = GetMainWndInst()
	if objMainWnd then
		objMainWnd:Show(0)
	end
end


local g_bHasExit = false
function ReportAndExit()
	local tStatInfo = {}
	HideMainWindow()		
	SendRunTimeReport(0, true)
	
	function FinalExit()
		tStatInfo.strEC = "exit"	
		tStatInfo.strEA = GetInstallSrc() or ""
		tStatInfo.Exit = true
		TipConvStatistic(tStatInfo)
	end
	
	StartExitTimer(FinalExit)
	
	TryBeforeExit( function (bRet)
		if g_bHasExit then
			return
		end
		g_bHasExit = true
		FinalExit()
	end)
end


function StartExitTimer(fnFinalExit)
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	timeMgr:SetTimer(function(Itm, id)
			Itm:KillTimer(id)

			if g_bHasExit then
				return
			end
			g_bHasExit = true
			fnFinalExit()
		end, 10 * 1000)
end


function TryBeforeExit(fnCallBack)
	local tExtraHelper = XLGetGlobal("YBYL.ExtraHelper")
	if type(tExtraHelper) == "table" 
		and type(tExtraHelper.BeforeExit) == "function" then
		tExtraHelper.BeforeExit(fnCallBack)
		return
	end
	
	fnCallBack(true)
end


function SendRunTimeReport(nTimeSpanInSec, bExit)
	local tStatInfo = {}
	tStatInfo.strEC = "runtime"
	tStatInfo.strEA = GetInstallSrc() or ""
	
	local nRunTime = 0
	local nLastReportRunTmUTC = XLGetGlobal("YBYL.LastReportRunTime") 
	if bExit and nLastReportRunTmUTC ~= 0 then
		nRunTime = math.abs(tipUtil:GetCurrentUTCTime() - nLastReportRunTmUTC)
	else
		nRunTime = nTimeSpanInSec
	end
	tStatInfo.strEV = nRunTime
	
	TipConvStatistic(tStatInfo)
end


function IsUserFullScreen()
	local bRet = false
	if type(tipUtil.IsNowFullScreen) == "function" then
		bRet = tipUtil:IsNowFullScreen()
	end
	return bRet
end

function FileTime2LocalTime(tFileTime)
	local nUTCInSec, strWeekDay = 0, ""
	if type(tFileTime) == "table" and type(tFileTime.dwLowDateTime) == "number" and type(tFileTime.dwHighDateTime) == "number" then
		local nYear, nMonth, nDay, nHour, nMin, nSec, nDayOfWeek = tipUtil:FileTime2LocalTime(tFileTime.dwLowDateTime, tFileTime.dwHighDateTime)
		local tDayWeekMap = {[1]="星期一", [2]="星期二", [3]="星期三", [4]="星期四", [5]="星期五", [6]="星期六", [7]="星期日"}
		strWeekDay = tDayWeekMap[nDayOfWeek]
		if type(nYear) == "number" and type(nMonth) == "number" and type(nDay) == "number" 
			and type(nHour) == "number" and type(nMin) == "number" and type(nSec) == "number" 
			then
			local nResult = tipUtil:DateTime2Seconds(nYear, nMonth, nDay, nHour, nMin, nSec)
			if type(nResult) == "number" then
				nUTCInSec = nResult
			end
		end
	end
	
	return nUTCInSec, strWeekDay
end

function CheckIsNewVersion(strNewVer, strCurVer)
	if not IsRealString(strNewVer) or not IsRealString(strCurVer) then
		return false
	end

	local a,b,c,d = string.match(strNewVer, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
	local A,B,C,D = string.match(strCurVer, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
	return a>A or (a==A and (b>B or (b==B and (c>C or (c==C and d>D)))))
end


function GetPeerID()
	local strPeerID = RegQueryValue("HKEY_LOCAL_MACHINE\\Software\\YBYL\\PeerId")
	if IsRealString(strPeerID) then
		return strPeerID
	end

	local strRandPeerID = tipUtil:GetPeerId()
	if not IsRealString(strRandPeerID) then
		return ""
	end
	
	RegSetValue("HKEY_LOCAL_MACHINE\\Software\\YBYL\\PeerId", strRandPeerID)
	return strRandPeerID
end

--渠道
function GetInstallSrc()
	local strInstallSrc = RegQueryValue("HKEY_LOCAL_MACHINE\\Software\\YBYL\\InstallSource")
	if not IsNilString(strInstallSrc) then
		return tostring(strInstallSrc)
	end
	
	return ""
end


function FailExitTipWnd(self, iExitCode)
	local tStatInfo = {}
	tStatInfo.Exit = true
	TipConvStatistic(tStatInfo)
end


function CheckTimeIsAnotherDay(LastTime)
	local bRet = false
	local LYear, LMonth, LDay, LHour, LMinute, LSecond = tipUtil:FormatCrtTime(LastTime)
	local curTime = tipUtil:GetCurrentUTCTime()
	local CYear, CMonth, CDay, CHour, CMinute, CSecond = tipUtil:FormatCrtTime(curTime)
	if LYear ~= CYear or LMonth ~= CMonth or LDay ~= CDay then
		bRet = true
	end
	return bRet
end


function TipConvStatistic(tStat)
	local rdRandom = tipUtil:GetCurrentUTCTime()
	local tStatInfo = tStat or {}
	local strDefaultNil = "null"
	
	local strCID = GetPeerID()
	local strEC = tStatInfo.strEC 
	local strEA = tStatInfo.strEA 
	local strEL = tStatInfo.strEL
	local strEV = tStatInfo.strEV
	
	if IsNilString(strEC) then
		strEC = strDefaultNil
	end
	
	if IsNilString(strEA) then
		strEA = strDefaultNil
	end
	
	if IsNilString(strEL) then
		strEL = strDefaultNil
	end
	
	if tonumber(strEV) == nil then
		strEV = 1
	end
	
	local strUrl = "http://www.google-analytics.com/collect?v=1&tid=UA-60726208-1&cid="..tostring(strCID)
						.."&t=event&ec="..tostring(strEC).."&ea="..tostring(strEA)
						.."&el="..tostring(strEL).."&ev="..tostring(strEV)
	TipLog("TipConvStatistic: " .. tostring(strUrl))
	
	gStatCount = gStatCount + 1
	if not gForceExit and tStat.Exit then
		gForceExit = true
	end
	tipAsynUtil:AsynSendHttpStat(strUrl, function()
		gStatCount = gStatCount - 1
		if gStatCount == 0 and gForceExit then
			ExitProcess()
		end
	end)
	
	local iStatCount = gStatCount
	if gForceExit and iStatCount > 0 and gTimeoutTimerId == nil then	--开启定时退出定时器
		local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
		gTimeoutTimerId = timeMgr:SetTimer(function(Itm, id)
			Itm:KillTimer(id)
			ExitProcess()
		end, 15000 * iStatCount)
	end
end


function NewAsynGetHttpFile(strUrl, strSavePath, bDelete, funCallback, nTimeoutInMS)
	local bHasAlreadyCallback = false
	local timerID = nil
	
	tipAsynUtil:AsynGetHttpFile(strUrl, strSavePath, bDelete, 
		function (nRet, strTargetFilePath, strHeaders)
			if timerID ~= nil then
				tipAsynUtil:KillTimer(timerID)
			end
			if not bHasAlreadyCallback then
				bHasAlreadyCallback = true
				funCallback(nRet, strTargetFilePath, strHeaders)
			end
		end)
	
	timerID = tipAsynUtil:SetTimer(nTimeoutInMS or 2 * 60 * 1000,
		function (nTimerId)
			tipAsynUtil:KillTimer(nTimerId)
			timerID = nil
			if not bHasAlreadyCallback then
				bHasAlreadyCallback = true
				funCallback(-2)
			end
		end)
end


function GetProgramTempDir(strSubDir)
	local strSysTempDir = tipUtil:GetSystemTempPath()
	local strProgramTempDir = tipUtil:PathCombine(strSysTempDir, strSubDir)
	if not tipUtil:QueryFileExists(strProgramTempDir) then
		tipUtil:CreateDir(strProgramTempDir)
	end
	
	return strProgramTempDir
end


function GetFileSaveNameFromUrl(url)
	local _, _, strFileName = string.find(tostring(url), ".*/(.*)$")
	local npos = string.find(strFileName, "?", 1, true)
	if npos ~= nil then
		strFileName = string.sub(strFileName, 1, npos-1)
	end
	return strFileName
end


function QueryAllUsersDir()	
	local bRet = false
	local strPublicEnv = "%PUBLIC%"
	local strRet = tipUtil:ExpandEnvironmentStrings(strPublicEnv)
	if strRet == nil or strRet == "" or strRet == strPublicEnv then
		local nCSIDL_COMMON_APPDATA = 35 --CSIDL_COMMON_APPDATA(0x0023)
		strRet = tipUtil:GetSpecialFolderPathEx(nCSIDL_COMMON_APPDATA)
	end
	if not IsNilString(strRet) and tipUtil:QueryFileExists(strRet) then
		bRet = true
	end
	return bRet, strRet
end

function GetExePath()
	return RegQueryValue("HKEY_LOCAL_MACHINE\\Software\\YBYL\\path")
end

function GetYBYLVersion()
	local strEXEPath = GetExePath()
	if not IsRealString(strEXEPath) or not tipUtil:QueryFileExists(strEXEPath) then
		return ""
	end

	return tipUtil:GetFileVersionString(strEXEPath)
end


function GetMinorVer()
	local strVersion = GetYBYLVersion()
	if not IsRealString(strVersion) then
		return ""
	end
	
	local _, _, strMinorVer = string.find(strVersion, "%d+%.%d+%.%d+%.(%d+)")
	return strMinorVer
end


function RegQueryValue(sPath)
	if IsRealString(sPath) then
		local sRegRoot, sRegPath, sRegKey = string.match(sPath, "^(.-)[\\/](.*)[\\/](.-)$")
		if IsRealString(sRegRoot) and IsRealString(sRegPath) then
			return tipUtil:QueryRegValue(sRegRoot, sRegPath, sRegKey or "") or ""
		end
	end
	return ""
end


function RegDeleteValue(sPath)
	if IsRealString(sPath) then
		local sRegRoot, sRegPath = string.match(sPath, "^(.-)[\\/](.*)")
		if IsRealString(sRegRoot) and IsRealString(sRegPath) then
			return tipUtil:DeleteRegValue(sRegRoot, sRegPath)
		end
	end
	return false
end


function RegSetValue(sPath, value)
	if IsRealString(sPath) then
		local sRegRoot, sRegPath, sRegKey = string.match(sPath, "^(.-)[\\/](.*)[\\/](.-)$")
		if IsRealString(sRegRoot) and IsRealString(sRegPath) then
			return tipUtil:SetRegValue(sRegRoot, sRegPath, sRegKey or "", value or "")
		end
	end
	return false
end


local bHasInitAcc = false
function AccelerateFlash(fRate)
	if not bHasInitAcc then
		tipUtil:YbSpeedInitialize()
		tipUtil:YbSpeedHook()
		bHasInitAcc = true
	end
	tipUtil:YbSpeedChangeRate(fRate)
end


----UI相关---
local g_bIsBrowserFullScrn = false

function GetMainWndInst()
	local objMainWnd = GetWndInstByName("YBYLTipWnd.MainFrame")
	return objMainWnd
end


function GetWndInstByName(strWndName)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objMainWnd = hostwndManager:GetHostWnd(strWndName)
	return objMainWnd
end



function IsBrowserFullScrn()
	return g_bIsBrowserFullScrn
end


function EnableCaptionDrag(bEnableCap)
	local objCaption = GetMainCtrlChildObj("caption.drag")
	if objCaption then
		objCaption:SetCaption(bEnableCap)
	end
end


function SetBrowserFullScrnState(bFullScreen)
	g_bIsBrowserFullScrn = bFullScreen
	local bEnableCap = not bFullScreen
	EnableCaptionDrag(bEnableCap)
end


function GetWindowBorder()
	local objMainBkg = GetMainCtrlChildObj("bkg")
	if not objMainBkg then
		return
	end
	local objRootLayout = GetMainCtrlChildObj("root.layout")
	if not objRootLayout then
		return
	end
	
	local nBrowserL, nBrowserT, nBrowserR, nBrowserB = objMainBkg:GetAbsPos()
	local nRootL, nRootT, nRootR, nRootB = objRootLayout:GetAbsPos()
	
	local nLDiff = nBrowserL - nRootL
	local nTDiff = nBrowserT - nRootT
	local nRDiff = nRootR - nBrowserR
	local nBDiff = nRootB - nBrowserB

	return nLDiff, nTDiff, nRDiff, nBDiff
end
	

function SetWindowMax()
	local objHostWnd = GetMainWndInst()
	if objHostWnd then
		objHostWnd:Max()
	end

	local objHeadCtrl = GetMainCtrlChildObj("MainPanel.Title")
	objHeadCtrl:SetMaxBtnStyle(false)
	SetResizeEnable(false)
end	
		

function SetBrowserFullScrn()
	local objBrowserLayout = GetMainCtrlChildObj("MainPanel.Center")
	if not objBrowserLayout then
		return
	end
	local objRootLayout = GetMainCtrlChildObj("root.layout")
	if not objRootLayout then
		return
	end
	
	local nBrowserL, nBrowserT, nBrowserR, nBrowserB = objBrowserLayout:GetAbsPos()
	local nRootL, nRootT, nRootR, nRootB = objRootLayout:GetAbsPos()
	
	local nDiffW = (nBrowserL-nRootL) + (nRootR-nBrowserR)
	local nDiffH = (nBrowserT-nRootT) + (nRootB-nBrowserB)
	
	local nWidth, nHeight = tipUtil:GetScreenSize()
	local nNewWidth = nWidth+nDiffW
	local nNewHeight = nHeight+nDiffH
	
	local objMainWnd = GetMainWndInst()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainWnd:GetWindowRect()
	RecordWndSize(nMainWndL, nMainWndT, nMainWndR, nMainWndB)
	
	SetBrowserFullScrnState(true)
	SetResizeEnable(false)
	objMainWnd:SetMaxTrackSize(nNewWidth, nNewHeight)
	
	objMainWnd:Move(0-nBrowserL, 0-nBrowserT, nNewWidth, nNewHeight)	
end


function RestoreWndSize()
	local objMainWnd = GetMainWndInst()
	if type(g_tWindowSize) == "table" then
		local nLeft = g_tWindowSize.nLeft or 0
		local nTop = g_tWindowSize.nTop or 0
		local nRight = g_tWindowSize.nRight or 1024
		local nBottom = g_tWindowSize.nBottom or 768
	
		local nWidth = nRight-nLeft
		local nHeight = nBottom-nTop
		if nWidth <= 0 then
			nWidth = 1024
		end
		if nHeight <= 0 then
			nHeight = 768
		end
		
		SetBrowserFullScrnState(false)
		SetResizeEnable(true)
		
		ResetTrackSize(objMainWnd)
		objMainWnd:Move(nLeft, nTop, nWidth, nHeight)
	end
end


function ResetTrackSize(objMainWnd)
	if type(g_tWindowSize) ~= "table" then
		return
	end
	
	local nTrackWidth = g_tWindowSize.nMaxTrackWidth
	local nTrackHeight = g_tWindowSize.nMaxTrackHeight
	objMainWnd:SetMaxTrackSize(nTrackWidth, nTrackHeight)
end


function RecordWndSize(nLeft, nTop, nRight, nBottom)
	if type(g_tWindowSize) ~= "table" then
		g_tWindowSize={}
	end
	g_tWindowSize.nLeft = nLeft
	g_tWindowSize.nTop = nTop
	g_tWindowSize.nRight = nRight
	g_tWindowSize.nBottom = nBottom
end


function RecordTrackSize(nTrackWidth, nTrackHeight)
	if type(g_tWindowSize) ~= "table" then
		g_tWindowSize={}
	end
	g_tWindowSize.nMaxTrackWidth = nTrackWidth
	g_tWindowSize.nMaxTrackHeight = nTrackHeight
end


function SetResizeEnable(bEnable)
	local objFrame = GetMainCtrlChildObj("frame")
	if not objFrame then
		return
	end
	
	objFrame:SetEnable(bEnable)
	objFrame:SetChildrenEnable(bEnable)
	
	if bEnable then
		objFrame:SetObjPos(0, 0, "father.width", "father.height")
	else
		objFrame:SetObjPos(0, 0, 0, 0)
	end	
end


function GetActiveTabCtrl()
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	local objTabCtrl = objTabContainer:GetActiveTabCtrl()
	return objTabCtrl 
end


function GetCurBrowserBitmap()
	local objActiveTabCtrl = GetActiveTabCtrl()
	if objActiveTabCtrl == nil or objActiveTabCtrl == 0 then
		return nil
	end
	
	local objBrowser = objActiveTabCtrl:GetBindBrowserCtrl()
	return objBrowser:GetWindowBitmap()
end


function GetCurrentURL()
	local strURL = ""
	local objActiveTabCtrl = GetActiveTabCtrl()
		
	if objActiveTabCtrl ~= nil and objActiveTabCtrl ~= 0 then
		strURL = objActiveTabCtrl:GetLocalURL()
	end
	
	return strURL
end


function OpenURLWhenStup()
	local strCmd = tipUtil:GetCommandLine()
	
	if string.find(strCmd, "/noopenstup") then
		return
	end
	
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local tOpenStupURL = tUserConfig["tOpenStupURL"]
	if type(tOpenStupURL) ~= "table" then
		return
	end
	
	for key, strURL in pairs(tOpenStupURL) do
		if IsRealString(strURL) then
			OpenURLInNewTab(strURL)
		end
	end
end


function OpenURLInNewTab(strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	objTabContainer:OpenURL(strURL, true)
end


function OpenURLInCurTab(strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	objTabContainer:OpenURL(strURL, false)
end


function OpenURLInNewWindow(strURL)
	if not IsRealString(strURL) then
		strURL = GetCurrentURL()
	end

	local strBrowserExePath = GetExePath()
	strCMD = " /openlink "..tostring(strURL)
	tipUtil:ShellExecute(0, "open", strBrowserExePath, strCMD, 0, "SW_SHOW")
end


function GetMainCtrlChildObj(strObjName)
	local objMainWnd = GetMainWndInst()
	if not objMainWnd then
		return nil
	end
	
	local objTree = objMainWnd:GetBindUIObjectTree()
	
	if not objMainWnd or not objTree then
		TipLog("[GetMainCtrlChildObj] get main wnd or tree failed")
		return nil
	end
	
	local objRootCtrl = objTree:GetUIObject("root.layout:root.ctrl")
	if not objRootCtrl then
		TipLog("[GetMainCtrlChildObj] get objRootCtrl failed")
		return nil
	end 

	return objRootCtrl:GetControlObject(tostring(strObjName))
end

function ShowPopupWndByName(strWndName, bSetTop)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local frameHostWnd = hostwndManager:GetHostWnd(tostring(strWndName))

	if frameHostWnd == nil then
		TipLog("[ShowPopupWindow] GetHostWnd failed: "..tostring(strWndName))
		return
	end

	if not IsUserFullScreen() then
		if type(tipUtil.SetWndPos) == "function" then
			local hWnd = frameHostWnd:GetWndHandle()
			if hWnd ~= nil then
				TipLog("[ShowPopupWndByName] success")
				if bSetTop then
					frameHostWnd:SetTopMost(true)
					tipUtil:SetWndPos(hWnd, 0, 0, 0, 0, 0, 0x0043)
				else
					tipUtil:SetWndPos(hWnd, -2, 0, 0, 0, 0, 0x0043)
				end
			end
		end
	elseif type(tipUtil.GetForegroundProcessInfo) == "function" then
		local hFrontHandle, strPath = tipUtil:GetForegroundProcessInfo()
		if hFrontHandle ~= nil then
			frameHostWnd:BringWindowToBack(hFrontHandle)
		end
	end
	
	frameHostWnd:Show(5)
end

function ShowModalDialog(wndClass, wndID, treeClass, treeID, userData, xarName)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
    local modalHostWndTemplate = templateMananger:GetTemplate(wndClass,"HostWndTemplate")
    if modalHostWndTemplate == nil then
		XLMessageBox("找不到"..wndClass)
        return false
    end
    local modalHostWnd = modalHostWndTemplate:CreateInstance(wndID)
    if modalHostWnd == nil then
		XLMessageBox("无法创建"..wndID)
        return false
    end
	
    local objectTreeTemplate = templateMananger:GetTemplate(treeClass,"ObjectTreeTemplate")
    if objectTreeTemplate == nil then
		XLMessageBox("找不到"..treeClass)
        return false
    end
    local uiObjectTree = objectTreeTemplate:CreateInstance(treeID, xarName)
    if uiObjectTree == nil then
		XLMessageBox("无法创建"..treeID)
        return false
    end
	modalHostWnd:SetUserData(userData)
    modalHostWnd:BindUIObjectTree(uiObjectTree)

    local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
    local hostwnd = hostwndManager:GetHostWnd("YBYLTipWnd.MainFrame")
	local hostwndobjtree = hostwnd:GetBindUIObjectTree()
	local ctrl = hostwndobjtree:GetUIObject("root.layout:root.ctrl")
	if ctrl ~= nil then
		local bkg = ctrl:GetControlObject("bkg")
		bkg:SetTextureID("YBYL.MainWnd.Bkg.nofocus")
	end
    local nRes = modalHostWnd:DoModal(hostwnd)
	if ctrl ~= nil then
		local bkg = ctrl:GetControlObject("bkg")
		bkg:SetTextureID("YBYL.MainWnd.Bkg")
	end
    hostwndManager:RemoveHostWnd(modalHostWnd:GetID())
    local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")
    objtreeManager:DestroyTree(uiObjectTree)	

	return nRes
end
function CreateSubWndByName(strHostWndName, strTreeName, strInstFix)
	local bSuccess = false
	local strFix = strInstFix or ""
	local strInstWndName = strHostWndName..strFix
	local strInstTreeName = strTreeName..strFix
	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local frameHostWndTemplate = templateMananger:GetTemplate(strHostWndName, "HostWndTemplate" )
	if frameHostWndTemplate then
		local frameHostWnd = frameHostWndTemplate:CreateInstance(strInstWndName)
		if frameHostWnd then
			local objectTreeTemplate = nil
			objectTreeTemplate = templateMananger:GetTemplate(strTreeName, "ObjectTreeTemplate")
			if objectTreeTemplate then
				local uiObjectTree = objectTreeTemplate:CreateInstance(strInstTreeName)
				if uiObjectTree then
					frameHostWnd:BindUIObjectTree(uiObjectTree)
					local objMainWnd = GetMainWndInst()
					local iRet = frameHostWnd:Create(objMainWnd)					
					if iRet ~= nil and iRet ~= 0 then
						bSuccess = true
					end
				end
			end
		end
	end
	
	return bSuccess
end


function GetIcoBitmapObj(strIcoName)
	if not IsRealString(strIcoName) then
		return -1
	end

	local strIcoDir = GetIcoDir()
	local strIcoPath = tipUtil:PathCombine(strIcoDir, strIcoName)
	if not tipUtil:QueryFileExists(strIcoPath) then
		return -2	
	end
		
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local objBitmap = xlgraphic:CreateBitmap(strIcoPath,"ARGB32") --XGP做了隐试处理
	return objBitmap
end

function GetDefaultIcoImgID()
	local strDefaultImgID = "YBYL.UrlIco.Default"
	return strDefaultImgID
end

------------UI--

----菜单--
function TryDestroyOldMenu(objUIElem, strMenuKey)
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")
	local strHostWndName = strMenuKey..".HostWnd.Instance" 
	local strObjTreeName = strMenuKey..".Tree.Instance"

	local objHostWnd = uHostWndMgr:GetHostWnd(strHostWndName)
	if objHostWnd then
		objHostWnd:UnbindUIObjectTree()
		uHostWndMgr:RemoveHostWnd(strHostWndName)
	end
	
	if uObjTreeMgr:GetUIObjectTree(strObjTreeName) then
		uObjTreeMgr:DestroyTree(strObjTreeName)
	end
end


--nTopSpan: 离弹出控件的高度差
--bRBtnPopup：右键弹出菜单
function CreateAndShowMenu(objUIElem, strMenuKey, nTopSpan, bRBtnPopup)
	local uTempltMgr = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")

	if uTempltMgr and uHostWndMgr and uObjTreeMgr then
		local uHostWnd = nil
		local strHostWndName = strMenuKey..".HostWnd.Instance"
		local strHostWndTempltName = "MenuHostWnd"
		local strHostWndTempltClass = "HostWndTemplate"
		local uHostWndTemplt = uTempltMgr:GetTemplate(strHostWndTempltName, strHostWndTempltClass)
		if uHostWndTemplt then
			uHostWnd = uHostWndTemplt:CreateInstance(strHostWndName)
		end

		local uObjTree = nil
		local strObjTreeTempltName = strMenuKey.."Tree"
		local strObjTreeTempltClass = "ObjectTreeTemplate"
		local strObjTreeName = strMenuKey..".Tree.Instance"
		local uObjTreeTemplt = uTempltMgr:GetTemplate(strObjTreeTempltName, strObjTreeTempltClass)
		if uObjTreeTemplt then
			uObjTree = uObjTreeTemplt:CreateInstance(strObjTreeName)
		end
		if uHostWnd and uObjTree then
			--函数会阻塞
			local bSucc = ShowMenuHostWnd(objUIElem, uHostWnd, uObjTree, nTopSpan, bRBtnPopup)
			
			if bSucc and uHostWnd:GetMenuMode() == "manual" then
				uObjTreeMgr:DestroyTree(strObjTreeName)
				uHostWndMgr:RemoveHostWnd(strHostWndName)
			end
		end
	end
end


function ShowMenuHostWnd(objUIElem, uHostWnd, uObjTree, nTopSpan, bRBtnPopup)
	uHostWnd:BindUIObjectTree(uObjTree)
					
	local objMainLayout = uObjTree:GetUIObject("Menu.MainLayout")
	if not objMainLayout then
		TipLog("[ShowMenuHostWnd] find Menu.MainLayout obj failed")
	    return false
	end	
	
	local objNormalMenu = uObjTree:GetUIObject("Menu.Context")
	if not objNormalMenu then
		TipLog("[ShowMenuHostWnd] find normalmenu obj failed")
	    return false
	end	
	objNormalMenu:BindRelateObject(objUIElem)
	
	local nL, nT, nR, nB 
	local objMenuFrame = objNormalMenu:GetControlObject("menu.frame")
	if objMenuFrame then
		nL, nT, nR, nB = objMenuFrame:GetObjPos()				
	else
		nL, nT, nR, nB = objNormalMenu:GetObjPos()	
	end	
	
	local nMenuContainerWidth = nR - nL
	local nMenuContainerHeight = nB - nT

	local nMenuLeft, nMenuTop = 0, 0
	if bRBtnPopup then
		nMenuLeft, nMenuTop = tipUtil:GetCursorPos() 	
		nTopSpan = 0 
	else
		nMenuLeft, nMenuTop = GetScreenAbsPos(objUIElem)
	end
	
	local nMenuL, nMenuT, nMenuR, nMenuB = objUIElem:GetAbsPos()
	local nMenuHeight = nMenuB - nMenuT
	if tonumber(nTopSpan) == nil then
		nTopSpan = nMenuHeight
	end
	
	local nMenuLeft, nMenuTop = AdjustScreenEdge(nMenuLeft, nMenuTop, nMenuContainerWidth, nMenuContainerHeight, nTopSpan)
	
	--函数会阻塞
	local bOk = uHostWnd:TrackPopupMenu(objHostWnd, nMenuLeft, nMenuTop, nMenuContainerWidth, nMenuContainerHeight)
	return bOk
end


function GetScreenAbsPos(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	local nL, nT, nR, nB = objUIElem:GetAbsPos()
	return objHostWnd:HostWndPtToScreenPt(nL, nT)
end


function AdjustScreenEdge(nMenuLeft, nMenuTop, nMenuContainerWidth, nMenuContainerHeight, nTopSpan)
	local nScrnLeft, nScrnTop, nScrnRight, nScrnBottom = tipUtil:GetWorkArea()
	
	if nMenuLeft < nScrnLeft then
		nMenuLeft = nScrnLeft
	end
	
	if nMenuLeft+nMenuContainerWidth > nScrnRight then
		nMenuLeft = nScrnRight - nMenuContainerWidth
	end
	
	if nMenuTop < nScrnTop then
		nMenuTop = nTopSpan+nScrnTop
	elseif nMenuTop+nMenuContainerHeight+nTopSpan > nScrnBottom then
		nMenuTop = nMenuTop - nMenuContainerHeight
	else
		nMenuTop = nTopSpan+nMenuTop
	end	
		
	return nMenuLeft, nMenuTop
end


-----

function SetMainWndFocusStyle(bFocus)
	local objBkg = GetMainCtrlChildObj("bkg")
	if bFocus then
		objBkg:SetTextureID("YBYL.MainWnd.Bkg")	
	else
		local nX, nY = tipUtil:GetCursorPos() 	
		local objMainWndInst = GetMainWndInst()
		local l, t, r, b = objMainWndInst:GetWindowRect()
		if nX > l and nX < r and nY > t and nY < b then
			return
		end
		
		objBkg:SetTextureID("YBYL.MainWnd.Bkg.Disable")	
	end
end


------文件操作---
local g_bLoadCfgSucc = false
local g_tConfigFileStruct = {
	["tUserConfig"] = {
		["strFileName"] = "UserConfig.dat",
		["tContent"] = {}, 
		["fnMergeOldFile"] = function(infoTable, strFileName) return MergeOldUserCfg(infoTable, strFileName) end,
	},
	["tUrlHistory"] = {
		["strFileName"] = "UrlHistory.dat",
		["tContent"] = {},
	},
}


function ReadAllConfigInfo()
	for strKey, tConfig in pairs(g_tConfigFileStruct) do
		local strFileName = tConfig["strFileName"]
		local strCfgPath = GetCfgPathWithName(strFileName)
		local infoTable = LoadTableFromFile(strCfgPath) or {}
		
		if type(infoTable) ~= "table" then
			TipLog("[ReadAllConfigInfo] no content in file: "..tostring(strFileName))
		end
		
		local tContent = infoTable
		local bMerge = false
		local fnMergeOldFile = tConfig["fnMergeOldFile"]
		if type(fnMergeOldFile) == "function" then
			bMerge, tContent = fnMergeOldFile(infoTable, strFileName)
		end
		
		tConfig["tContent"] = tContent
		if bMerge then
			SaveConfigToFileByKey(strKey)
		end
	end
	
	g_bLoadCfgSucc = true
	TipLog("[ReadAllConfigInfo] success!")
	return true
end


function MergeOldUserCfg(tCurrentCfg, strFileName)
	local tOldCfg, strOldCfgPath = GetOldCfgContent(strFileName)
	if type(tOldCfg) ~= "table" then
		return false, tCurrentCfg
	end
	
	tCurrentCfg["nAccelerateRate"] = tOldCfg["nAccelerateRate"] or 1
	tCurrentCfg["bOpenFilter"] = tOldCfg["bOpenFilter"]
	tCurrentCfg["nLastCommonUpdateUTC"] = tOldCfg["nLastCommonUpdateUTC"]
	tCurrentCfg["nLastToolTipUTC"] = tOldCfg["nLastToolTipUTC"] 
		
	tipUtil:DeletePathFile(strOldCfgPath)
	return true, tCurrentCfg
end


function GetOldCfgContent(strCurFileName)
	local strOldFileName = strCurFileName..".bak"
	local strOldCfgPath = GetCfgPathWithName(strOldFileName)
	if not IsRealString(strOldCfgPath) or not tipUtil:QueryFileExists(strOldCfgPath) then
		return nil
	end
	
	local tOldCfg = LoadTableFromFile(strOldCfgPath)
	return tOldCfg, strOldCfgPath
end


function GetCfgPathWithName(strCfgName)
	local bOk, strBaseDir = QueryAllUsersDir()
	if not bOk then
		return ""
	end
	
	local strCfgFilePath = tipUtil:PathCombine(strBaseDir, "YBYL\\"..tostring(strCfgName))
	return strCfgFilePath or ""
end

function ReadConfigFromMemByKey(strKey)
	if not IsRealString(strKey) or type(g_tConfigFileStruct[strKey])~="table" then
		return nil
	end

	local tContent = g_tConfigFileStruct[strKey]["tContent"]
	return tContent
end


function SaveConfigToFileByKey(strKey)
	if not IsRealString(strKey) or type(g_tConfigFileStruct[strKey])~="table" then
		return
	end

	local strFileName = g_tConfigFileStruct[strKey]["strFileName"]
	local tContent = g_tConfigFileStruct[strKey]["tContent"] or {}
	local strConfigPath = GetCfgPathWithName(strFileName)
	if IsRealString(strConfigPath) then
		tipUtil:SaveLuaTableToLuaFile(tContent, strConfigPath)
	end
end


function SaveAllConfig()
	if g_bLoadCfgSucc then
		for strKey, tContent in pairs(g_tConfigFileStruct) do
			SaveConfigToFileByKey(strKey)
		end
	end
end


function GetDfltNewTabURL()
	local strURL = "about:blank"
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local strOpenTabURL = tUserConfig["strOpenTabURL"]
	if IsRealString(strOpenTabURL) then
		strURL = strOpenTabURL
	end
	
	return strURL
end


function GetHomePage()
	local strHomePage = RegQueryValue("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Main\\Start Page")
	if not IsRealString(strHomePage) then
		strHomePage = RegQueryValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Internet Explorer\\Main\\Start Page")
	end

	return strHomePage
end


function SetHomePage(strURL)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["strOpenTabURL"] = strURL
	SaveConfigToFileByKey("tUserConfig")
end


function GetZoomFactor()
	local strFactor = RegQueryValue("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Zoom\\ZoomFactor")
	local nFactor = tonumber(strFactor) or 100*1000
	
	return nFactor/1000
end

function SetZoomFactor(nFactor)
	if tonumber(nFactor) == nil then
		return
	end

	local nRealFactor = nFactor*1000
	RegSetValue("HKEY_CURRENT_USER\\Software\\Microsoft\\Internet Explorer\\Zoom\\ZoomFactor", nRealFactor)
end


--bInAddressBar 表示在用户地址栏中打开url
function SaveUrlToHistory(strInputURL, bInAddressBar)
	if not IsRealString(strInputURL) then
		return
	end
	
	local strURL = FormatURL(strInputURL)
	
	local nCurrentTime = tipUtil:GetCurrentUTCTime()
	local tHistInfo = {}
	tHistInfo["strURL"] = strURL
	tHistInfo["nVisitUTC"] = nCurrentTime
		
	local tUrlHistory = ReadConfigFromMemByKey("tUrlHistory") or {}
	for nIndex, tInfo in ipairs(tUrlHistory) do
		if type(tInfo) == "table" and tInfo["strURL"] == strURL then
			tHistInfo["strIcoName"] = tInfo["strIcoName"]
			tHistInfo["strLocationName"] = tInfo["strLocationName"]
			if tInfo["bInAddressBar"] ~= nil then
				tHistInfo["bInAddressBar"] = tInfo["bInAddressBar"]
			end
			
			table.remove(tUrlHistory, nIndex)
			break
		end	
	end
	
	if bInAddressBar then
		tHistInfo["bInAddressBar"] = bInAddressBar
	end
	
	table.insert(tUrlHistory, 1, tHistInfo)	
	
	LimitHistorySize(tUrlHistory)
	SaveConfigToFileByKey("tUrlHistory")
end


function SaveLctnNameToFile(strInputURL, strLctnName, strFileKey)
	if not IsRealString(strLctnName) or not IsRealString(strInputURL) 
		or not IsRealString(strFileKey) then
		return
	end
	
	local strURL = FormatURL(strInputURL)
	
	local tFileInfo = ReadConfigFromMemByKey(strFileKey) or {}
	for nIndex, tInfo in ipairs(tFileInfo) do
		if type(tInfo) == "table" and tInfo["strURL"] == strURL then
		
			-- if not IsRealString(tInfo["strLocationName"]) then
				tFileInfo[nIndex]["strLocationName"] = strLctnName
				SaveConfigToFileByKey(tFileInfo)
			-- end
			return
		end	
	end
end


function SaveIcoNameToFile(strInputURL, strIcoName, strFileKey)
	if not IsRealString(strIcoName) or not IsRealString(strInputURL) 
		or not IsRealString(strFileKey) then
		return
	end
	
	local strURL = FormatURL(strInputURL)
	
	local tFileInfo = ReadConfigFromMemByKey(strFileKey) or {}
	for nIndex, tInfo in ipairs(tFileInfo) do
		if type(tInfo) == "table" and tInfo["strURL"] == strURL then
		
			if not IsRealString(tInfo["strIcoName"]) then
				tFileInfo[nIndex]["strIcoName"] = strIcoName
				SaveConfigToFileByKey(strFileKey)
			end
			
			return
		end	
	end
end


function ClearFileInfo(strFileKey)
	if type(g_tConfigFileStruct[strFileKey]) ~= "table" then
		return
	end

	g_tConfigFileStruct[strFileKey]["tContent"] = {}
	SaveConfigToFileByKey(strFileKey)
end


---收藏夹
function GetFavoriteDir()
	local CSIDL_FAVORITES = 6
	local strCollectDir = tipUtil:GetSpecialFolderPathEx(CSIDL_FAVORITES)
	if IsRealString(strCollectDir) and tipUtil:QueryFileExists(strCollectDir) then
		return strCollectDir
	end
	
	return ""
end


function GetUserCollectDir()
	local strFavoriteDir = GetFavoriteDir()
	local strCollectDir = tipUtil:PathCombine(strFavoriteDir,"链接")
	
	if IsUACOS() then
		strCollectDir = tipUtil:PathCombine(strFavoriteDir,"Links")
	end

	return strCollectDir
end


function GetUserCollectList()
	local strCollectDir = GetUserCollectDir()
	
	if not IsRealString(strCollectDir) or not tipUtil:QueryFileExists(strCollectDir) then
		return nil
	end

	local tFileList = tipUtil:FindFileList(strCollectDir, "*.*")
	if type(tFileList) ~= "table" then
		return nil
	end
	
	local tUserCollectList = {}
	
	for i=1, #tFileList do
		local strFilePath = tFileList[i]
		if IsRealString(strFilePath) and tipUtil:QueryFileExists(strFilePath) then
			local strURL, bRet = tipUtil:ReadINI(strFilePath, "InternetShortcut", "URL")
			
			if IsRealString(strURL) then	
				local nCurIndex = #tUserCollectList+1
				tUserCollectList[nCurIndex] = {}
				tUserCollectList[nCurIndex]["strLocationName"] = GetFileNameFromPath(strFilePath)
				tUserCollectList[nCurIndex]["strURL"] = strURL
				tUserCollectList[nCurIndex]["strIcoName"] = GetIcoNameFromURL(strURL)
				tUserCollectList[nCurIndex]["strFilePath"] = strFilePath
			end
		end
	end
	
	return tUserCollectList
end


function AddCurWebToCollect()
	local objWebTab = GetActiveTabCtrl()
	local strCollectDir = GetUserCollectDir()
	local strText = objWebTab:GetTabText() or "空白页"
	local strFilePath = GetCollectFilePath(strCollectDir, strText, ".url")
	local strURL = objWebTab:GetLocalURL()
	
	tipUtil:WriteINI("InternetShortcut", "URL", strURL, strFilePath)
end


function GetCollectFilePath(strDir, strFileName, strExt)
	local nIndex = 2
	local strWithoutExt = tipUtil:PathCombine(strDir, strFileName)
	local strFilePath = strWithoutExt..tostring(strExt)

	local bExists = tipUtil:QueryFileExists(strFilePath)
	
	while(bExists) do
		strFilePath = strWithoutExt.." ("..tostring(nIndex)..")"..tostring(strExt)
		bExists = tipUtil:QueryFileExists(strFilePath)
		
		if not bExists then
			break
		end
		
		nIndex = nIndex+1
		if nIndex > 100 then
			break
		end
	end
	
	return strFilePath
end


local g_HasCreateCllctWnd = false
function GetCollectWndRootCtrl()
	if not g_HasCreateCllctWnd then
		local bSuccess = CreateSubWndByName("TipCollectWnd", "TipCollectTree", ".Instance")
		if bSuccess then
			 g_HasCreateCllctWnd = true
		else
			return
		end
	end
	
	local objWnd = GetWndInstByName("TipCollectWnd.Instance")
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootLayout = objtree:GetUIObject("root.layout")
	local objRootCtrl = objRootLayout:GetObject("CollectWndCtrl")
	return objRootCtrl
end


function ShowCollectWnd(nShowType, bFix)
	local objRootCtrl = GetCollectWndRootCtrl()
	local objWnd = GetWndInstByName("TipCollectWnd.Instance")
	
	if objWnd:GetVisible() then
		objRootCtrl:CloseCollectWnd()
		return
	end	
	
	ShowPopupWndByName("TipCollectWnd.Instance", false)
	objRootCtrl:SetFixStyle(bFix)
	objRootCtrl:ShowTab(nShowType)
end


--------------------

function GetIcoNameFromURL(strURL)
	local strDomain = string.match(strURL, "(http://[^/]+)")	
	if not IsRealString(strDomain) then
		strDomain = string.match(strURL, "(https://[^/]+)")	
	end

	if not IsRealString(strDomain) then	
		return ""
	end
	
	local strIconURL = strDomain .. "/favicon.ico"	
	local strIcoDir = GetIcoDir()
	local strIcoID = tipUtil:GetStringMD5(strIconURL)
	local strIcoName = tostring(strIcoID)..".ico" 
	
	return tostring(strIcoName)
end


function DownLoadIco(strURL, fnCallBack)
	if not IsRealString(strURL) then
		return 
	end
	
	local strDomain = string.match(strURL, "(http://[^/]+)")		
	if not IsRealString(strDomain) then	
		return
	end
	
	local strIconURL = strDomain .. "/favicon.ico"	
	local strIcoDir = GetIcoDir()
	local strIcoID = tipUtil:GetStringMD5(strIconURL)
	local strIcoName = tostring(strIcoID)..".ico" 
	local strSavePath = tipUtil:PathCombine(strIcoDir, strIcoName)
	
	if tipUtil:QueryFileExists(strSavePath) then
		fnCallBack(0, strSavePath, strIcoName)
	else
		NewAsynGetHttpFile(strIconURL, strSavePath, false, 
		function(bRet, strIcoPath)
			fnCallBack(bRet, strIcoPath, strIcoName)
		end, 60*1000)
	end			
end


function GetURLInfoFromHistory(strInputURL)
	local strURL = FormatURL(strInputURL)

	local tUrlHistory = ReadConfigFromMemByKey("tUrlHistory") or {}
	for nIndex, tInfo in ipairs(tUrlHistory) do
		if type(tInfo) == "table" and tInfo["strURL"] == strURL then
			return tInfo
		end	
	end

	return nil
end


function SaveUserCollectURL(strInputURL)
	if not IsRealString(strInputURL) then
		return 
	end	

	local strURL = FormatURL(strInputURL)

	local tCollectInfo = GetURLInfoFromHistory(strURL)
	if type(tCollectInfo) ~= "table" then
		TipLog("[SaveUserCollectURL] add collect failed:"..tostring(strURL))
		return
	end
	
	local nCurrentTime = tipUtil:GetCurrentUTCTime()
	tCollectInfo["nCollectUTC"] = nCurrentTime

	local tUserCollect = ReadConfigFromMemByKey("tUserCollect") or {}
	for nIndex, tInfo in ipairs(tUserCollect) do
		if type(tInfo) == "table" and tInfo["strURL"] == tostring(tCollectInfo["strURL"]) then
			table.remove(tUserCollect, nIndex)
			break
		end	
	end
		
	table.insert(tUserCollect, 1, tCollectInfo)	
	
	LimitCollectSize(tUserCollect)
	SaveConfigToFileByKey("tUserCollect")
end


function DeleteHistoryItem(strInputURL, strFileKey)
	local strURL = FormatURL(strInputURL)
	local tFileInfo = ReadConfigFromMemByKey(strFileKey)
	if type(tFileInfo) ~= "table" then
		tFileInfo= {}
		return
	end

	for nIndex, tInfo in pairs(tFileInfo) do
		if type(tInfo) == "table" and tInfo["strURL"] == strURL then
			table.remove(tFileInfo, nIndex)
			SaveConfigToFileByKey(strFileKey)
			break
		end
	end
end


function RemoveUserCollectURL(strInputURL)
	DeleteHistoryItem(strInputURL, "tUserCollect")
end


function RemoveHistoryURL(strInputURL)
	DeleteHistoryItem(strInputURL, "tUrlHistory")
end


function GetIcoDir()
	return GetProgramTempDir("webbrowser\\ico")
end

function LimitHistorySize(tUrlHistory)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local nMaxUrlHistroy = tUserConfig["nMaxUrlHistroy"] or 100
	
	if nMaxUrlHistroy >= #tUrlHistory then
		return
	end	

	for i=nMaxUrlHistroy+1, #tUrlHistory do
		table.remove(tUrlHistory, i)
	end	
end


function LimitCollectSize(tUserCollect)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local nMaxUserCollect = tUserConfig["nMaxUserCollect"] or 100
	
	if nMaxUserCollect >= #tUserCollect then
		return
	end	

	for i=nMaxUserCollect+1, #tUserCollect do
		table.remove(tUserCollect, i)
	end	
end


function UpdateCollectList()
	local objHeadCtrl = GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objCollectList = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectList")
	if not objCollectList then
		return
	end

	objCollectList:UpdateCollectList()
end


function FormatURL(strURL)
	if not IsRealString(strURL) then
		return nil
	end

	local strURLFix = string.gsub(strURL, "^http://", "")
	strURLFix = string.gsub(strURLFix, "^https://", "")
	strURLFix = string.gsub(strURLFix, "/$", "")
	
	return strURLFix
end


function SetToolTipText(strText)
	local objHeadCtrl = GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objToolTip = objHeadCtrl:GetControlObject("BrowserHeadCtrl.ToolTipCtrl")
	if not objToolTip then
		return
	end

	objToolTip:SetToolTipText(strText)
end


function ShowToolTip(bShow)
	local objHeadCtrl = GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objToolTip = objHeadCtrl:GetControlObject("BrowserHeadCtrl.ToolTipCtrl")
	if not objToolTip then
		return
	end

	objToolTip:ShowToolTip(bShow)
end


function PopupToolTipOneDay()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local nLastBubbleUTC = tonumber(tUserConfig["nLastToolTipUTC"]) 
	
	if not IsNilString(nLastBubbleUTC) and not CheckTimeIsAnotherDay(nLastBubbleUTC) then
		return
	end
	
	local nNoShowFilterBubble = tonumber(tUserConfig["nNoShowFilterBubble"]) 
	if not IsNilString(nNoShowFilterBubble) then
		return
	end

	SetToolTipText("已智能帮您去除广告")
	ShowToolTip(true)
	
	tUserConfig["nLastToolTipUTC"] = tipUtil:GetCurrentUTCTime()
	SaveConfigToFileByKey("tUserConfig")
end


function GetFilterState()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local bOpenFilter = tUserConfig["bOpenFilter"]

	return bOpenFilter
end


function SetFilterState(bOpenFilter)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
		
	tUserConfig["bOpenFilter"] = bOpenFilter
	tipUtil:FYBFilter(bOpenFilter)
	SaveConfigToFileByKey("tUserConfig")
end


---升级--
local g_bIsUpdating = false

function DownLoadNewVersion(tNewVersionInfo, fnCallBack)
	local strPacketURL = tNewVersionInfo.strPacketURL
	local strMD5 = tNewVersionInfo.strMD5
	if not IsRealString(strPacketURL) then
		return
	end
	
	local strFileName = GetFileSaveNameFromUrl(strPacketURL)
	if not string.find(strFileName, "%.exe$") then
		strFileName = strFileName..".exe"
	end
	local strSaveDir = tipUtil:GetSystemTempPath()
	local strSavePath = tipUtil:PathCombine(strSaveDir, strFileName)

	DownLoadFileWithCheck(strPacketURL, strSavePath, strMD5
	, function(bRet, strRealPath)
		TipLog("[DownLoadNewVersion] strPacketURL:"..tostring(strPacketURL)
		        .."  bRet:"..tostring(bRet).."  strRealPath:"..tostring(strRealPath))
				
		if 0 == bRet then
			fnCallBack(strRealPath, tNewVersionInfo)
			return
		end
		
		if 1 == bRet then	--安装包已经存在
			fnCallBack(strSavePath, tNewVersionInfo)
			return
		end
		
		fnCallBack(nil)
	end)	
end


function CheckCommonUpdateTime(nTimeInDay)
	return CheckUpdateTimeSpan(nTimeInDay, "nLastCommonUpdateUTC")
end

function CheckAutoUpdateTime(nTimeInDay)
	return CheckUpdateTimeSpan(nTimeInDay, "nLastAutoUpdateUTC")
end

function CheckUpdateTimeSpan(nTimeInDay, strUpdateType)
	if type(nTimeInDay) ~= "number" then
		return false
	end
	
	local nTimeInSec = nTimeInDay*24*3600
	local nCurTimeUTC = tipUtil:GetCurrentUTCTime()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local nLastUpdateUTC = tUserConfig[strUpdateType] or 0
	local nTimeSpan = math.abs(nCurTimeUTC - nLastUpdateUTC)
	
	if nTimeSpan > nTimeInSec then
		return true
	end	
	
	return false
end


function SaveCommonUpdateUTC()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["nLastCommonUpdateUTC"] = tipUtil:GetCurrentUTCTime()
	SaveConfigToFileByKey("tUserConfig")
end


function SaveAutoUpdateUTC()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["nLastAutoUpdateUTC"] = tipUtil:GetCurrentUTCTime()
	SaveConfigToFileByKey("tUserConfig")
end


function CheckIsUpdating()
	return g_bIsUpdating
end

function SetIsUpdating(bIsUpdating)
	if type(bIsUpdating) == "boolean" then
		g_bIsUpdating = bIsUpdating
	end
end

function CheckMD5(strFilePath, strExpectedMD5) 
	local bPassCheck = false
	
	if not IsNilString(strFilePath) then
		local strMD5 = tipUtil:GetMD5Value(strFilePath)
		TipLog("[CheckMD5] strFilePath = " .. tostring(strFilePath) .. ", strMD5 = " .. tostring(strMD5))
		if not IsRealString(strExpectedMD5) 
			or (not IsNilString(strMD5) and not IsNilString(strExpectedMD5) and string.lower(strMD5) == string.lower(strExpectedMD5))
			then
			bPassCheck = true
		end
	end
	
	TipLog("[CheckMD5] strFilePath = " .. tostring(strFilePath) .. ", strExpectedMD5 = " .. tostring(strExpectedMD5) .. ". bPassCheck = " .. tostring(bPassCheck))
	return bPassCheck
end


function DownLoadServerConfig(fnCallBack, nTimeInMs)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	
	local strConfigURL = tUserConfig["strServerConfigURL"]
	if not IsRealString(strConfigURL) then
		fnCallBack(-1)
		return
	end
	
	local strFileName = GetFileSaveNameFromUrl(strConfigURL)
	local strSavePath = GetCfgPathWithName(strFileName)
	if not IsRealString(strSavePath) then
		fnCallBack(-1)
		return
	end
	
	local nTime = tonumber(nTimeInMs) or 5*1000
		
	NewAsynGetHttpFile(strConfigURL, strSavePath, false
	, function(bRet, strRealPath)
		TipLog("[DownLoadServerConfig] bRet:"..tostring(bRet)
				.." strRealPath:"..tostring(strRealPath))
				
		if 0 == bRet then
			fnCallBack(0, strSavePath)
		else
			fnCallBack(bRet)
		end		
	end, nTime)
end

function DownLoadFileWithCheck(strURL, strSavePath, strCheckMD5, fnCallBack)
	if type(fnCallBack) ~= "function"  then
		return
	end

	if IsRealString(strCheckMD5) and CheckMD5(strSavePath, strCheckMD5) then
		TipLog("[DownLoadFileWithCheck]File Already existed")
		fnCallBack(1, strSavePath)
		return
	end
	
	NewAsynGetHttpFile(strURL, strSavePath, false, function(bRet, strDownLoadPath)
		TipLog("[DownLoadFileWithCheck] NewAsynGetHttpFile:bret = " .. tostring(bRet) 
				.. ", strURL = " .. tostring(strURL) .. ", strDownLoadPath = " .. tostring(strDownLoadPath))
		if 0 == bRet then
			strSavePath = strDownLoadPath
            if CheckMD5(strSavePath, strCheckMD5) then
				fnCallBack(bRet, strSavePath)
			else
				TipLog("[DownLoadFileWithCheck]Did Not Pass MD5 Check")
				fnCallBack(-2)
			end	
		else
			TipLog("[DownLoadFileWithCheck] DownLoad failed")
			fnCallBack(-3)
		end
	end)
end

--

------------------文件--

local obj = {}
obj.tipUtil = tipUtil
obj.tipAsynUtil = tipAsynUtil

--通用
obj.TipLog = TipLog
obj.IsUACOS = IsUACOS
obj.FailExitTipWnd = FailExitTipWnd
obj.TipConvStatistic = TipConvStatistic
obj.ExitProcess = ExitProcess
obj.ReportAndExit = ReportAndExit
obj.GetCommandStrValue = GetCommandStrValue
obj.GetExePath = GetExePath
obj.LoadTableFromFile = LoadTableFromFile
obj.SaveTableToFile = SaveTableToFile
obj.CheckIsNewVersion = CheckIsNewVersion
obj.FileTime2LocalTime = FileTime2LocalTime
obj.SendRunTimeReport = SendRunTimeReport

obj.NewAsynGetHttpFile = NewAsynGetHttpFile
obj.GetProgramTempDir = GetProgramTempDir
obj.GetYBYLVersion = GetYBYLVersion
obj.GetInstallSrc = GetInstallSrc
obj.GetMinorVer = GetMinorVer
obj.AccelerateFlash = AccelerateFlash
obj.EnableCaptionDrag = EnableCaptionDrag
obj.GetFileSaveNameFromUrl = GetFileSaveNameFromUrl
obj.DownLoadFileWithCheck = DownLoadFileWithCheck

--UI
obj.OpenURLInNewTab = OpenURLInNewTab
obj.OpenURLInCurTab = OpenURLInCurTab
obj.OpenURLWhenStup = OpenURLWhenStup
obj.GetCurrentURL = GetCurrentURL
obj.GetCurBrowserBitmap = GetCurBrowserBitmap
obj.FormatURL = FormatURL
obj.OpenURLInNewWindow = OpenURLInNewWindow
obj.GetHomePage = GetHomePage
obj.SetHomePage = SetHomePage
obj.GetZoomFactor = GetZoomFactor
obj.SetZoomFactor = SetZoomFactor
obj.GetDfltNewTabURL = GetDfltNewTabURL
obj.GetActiveTabCtrl = GetActiveTabCtrl
obj.GetMainCtrlChildObj = GetMainCtrlChildObj
obj.GetWndInstByName = GetWndInstByName
obj.GetMainWndInst = GetMainWndInst
obj.ShowPopupWndByName = ShowPopupWndByName
obj.ShowModalDialog = ShowModalDialog
obj.CreateSubWndByName = CreateSubWndByName
obj.SetMainWndFocusStyle = SetMainWndFocusStyle

obj.SetToolTipText = SetToolTipText
obj.ShowToolTip = ShowToolTip
obj.PopupToolTipOneDay = PopupToolTipOneDay
obj.GetFilterState = GetFilterState
obj.SetFilterState = SetFilterState

--文件
obj.GetCfgPathWithName = GetCfgPathWithName
obj.ReadConfigFromMemByKey = ReadConfigFromMemByKey
obj.SaveConfigToFileByKey = SaveConfigToFileByKey
obj.ReadAllConfigInfo = ReadAllConfigInfo

obj.SaveUserCollectURL = SaveUserCollectURL
obj.RemoveUserCollectURL = RemoveUserCollectURL
obj.RemoveHistoryURL = RemoveHistoryURL
obj.SaveUrlToHistory = SaveUrlToHistory
obj.ClearFileInfo = ClearFileInfo
obj.SaveLctnNameToFile = SaveLctnNameToFile
obj.SaveIcoNameToFile = SaveIcoNameToFile
obj.GetIcoDir = GetIcoDir
obj.GetIcoBitmapObj = GetIcoBitmapObj
obj.GetDefaultIcoImgID = GetDefaultIcoImgID
obj.UpdateCollectList = UpdateCollectList
obj.ShowCollectWnd = ShowCollectWnd
obj.GetCollectWndRootCtrl = GetCollectWndRootCtrl
obj.GetFavoriteDir = GetFavoriteDir
obj.GetUserCollectList = GetUserCollectList
obj.AddCurWebToCollect = AddCurWebToCollect
obj.GetIcoNameFromURL = GetIcoNameFromURL
obj.DownLoadIco = DownLoadIco

--菜单
obj.TryDestroyOldMenu = TryDestroyOldMenu
obj.CreateAndShowMenu = CreateAndShowMenu

--全屏\最大化
obj.GetWindowBorder = GetWindowBorder    
obj.SetWindowMax = SetWindowMax    
obj.SetBrowserFullScrn = SetBrowserFullScrn
obj.RestoreWndSize = RestoreWndSize
obj.RecordTrackSize = RecordTrackSize
obj.RecordWndSize = RecordWndSize
obj.IsBrowserFullScrn = IsBrowserFullScrn
obj.SetResizeEnable = SetResizeEnable

--升级
obj.DownLoadServerConfig = DownLoadServerConfig
obj.DownLoadNewVersion = DownLoadNewVersion
obj.CheckIsUpdating = CheckIsUpdating
obj.SetIsUpdating = SetIsUpdating
obj.CheckCommonUpdateTime = CheckCommonUpdateTime
obj.SaveCommonUpdateUTC = SaveCommonUpdateUTC
obj.SaveAutoUpdateUTC = SaveAutoUpdateUTC

--注册表
obj.RegQueryValue = RegQueryValue
obj.RegDeleteValue = RegDeleteValue


XLSetGlobal("YBYL.FunctionHelper", obj)

