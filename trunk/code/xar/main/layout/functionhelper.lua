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


function ExitProcess()
	SaveAllConfig()

	TipLog("************ Exit ************")
	tipUtil:Exit("Exit")
end


function FailExitTipWnd(self, iExitCode)
	local tStatInfo = {}
		
	tStatInfo.Exit = true
		
	TipConvStatistic(tStatInfo)
end


function TipConvStatistic(tStat)
	local rdRandom = tipUtil:GetCurrentUTCTime()
	local tStatInfo = tStat or {}
	
	local strUrl = ""
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


----UI相关---
local g_bIsBrowserFullScrn = false

function GetMainWndInst()
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objMainWnd = hostwndManager:GetHostWnd("YBYLTipWnd.MainFrame")
	return objMainWnd
end


function GetHomePage()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local strHomePage = tUserConfig["strHomePage"]
	return strHomePage
end


function IsBrowserFullScrn()
	return g_bIsBrowserFullScrn
end


function SetBrowserFullScrnState(bFullScreen)
	g_bIsBrowserFullScrn = bFullScreen
	local objCaption = GetMainCtrlChildObj("root.layout")
	if objCaption then
		local bEnableCap = not bFullScreen
		objCaption:SetCaption(bEnableCap)
	end
end

function SetWindowFullScrnState(bFullScreen)
	g_bIsBrowserFullScrn = bFullScreen
end

function SetWindowFullScrn()
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
	
	local nDiffW = nBrowserL + (nRootR-nBrowserR)
	local nDiffH = nBrowserT + (nRootB-nBrowserB)
	
	local nWidth, nHeight = tipUtil:GetScreenSize()
	local nNewWidth = nWidth+nDiffW
	local nNewHeight = nHeight+nDiffH
	
	local objMainWnd = GetMainWndInst()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainWnd:GetWindowRect()
	RecordWndSize(nMainWndL, nMainWndT, nMainWndR, nMainWndB)
	
	SetBrowserFullScrnState(true)
	objMainWnd:SetMaxTrackSize(nNewWidth, nNewHeight)
	objMainWnd:Move(0-nBrowserL, 0-nBrowserT, nNewWidth, nNewHeight)	
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
	
	local nDiffW = nBrowserL + (nRootR-nBrowserR)
	local nDiffH = nBrowserT + (nRootB-nBrowserB)
	
	local nWidth, nHeight = tipUtil:GetScreenSize()
	local nNewWidth = nWidth+nDiffW
	local nNewHeight = nHeight+nDiffH
	
	local objMainWnd = GetMainWndInst()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainWnd:GetWindowRect()
	RecordWndSize(nMainWndL, nMainWndT, nMainWndR, nMainWndB)
	
	SetBrowserFullScrnState(true)
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
		SetWindowFullScrnState(false)
		objMainWnd:Move(nLeft, nTop, nWidth, nHeight)
	end
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


function GetActiveTabCtrl()
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	local objTabCtrl = objTabContainer:GetActiveTabCtrl()
	return objTabCtrl 
end


function OpenURL(strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	objTabContainer:OpenURL(strURL, true)
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

------------UI--

-------文件操作---
local g_bLoadCfgSucc = false
local g_tConfigFileStruct = {
	["tUserConfig"] = {
		["strFileName"] = "UserConfig.dat",
		["tContent"] = {}, 
	},
	["tUserCollect"] = {
		["strFileName"] = "UserCollect.dat",
		["tContent"] = {},
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
		local infoTable = LoadTableFromFile(strCfgPath)
		if type(infoTable) ~= "table" then
			TipLog("[ReadAllConfigInfo] GetConfigFile failed! "..tostring(strFileName))
			return false
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
	local tContent = g_tConfigFileStruct[strKey]["tContent"]
	local strConfigPath = GetCfgPathWithName(strFileName)
	if IsRealString(strConfigPath) and type(tContent) == "table" then
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

------------------文件--


local obj = {}
obj.tipUtil = tipUtil
obj.tipAsynUtil = tipAsynUtil

obj.TipLog = TipLog
obj.FailExitTipWnd = FailExitTipWnd
obj.TipConvStatistic = TipConvStatistic
obj.ExitProcess = ExitProcess

obj.NewAsynGetHttpFile = NewAsynGetHttpFile
obj.GetProgramTempDir = GetProgramTempDir

obj.OpenURL = OpenURL
obj.GetHomePage = GetHomePage
obj.GetActiveTabCtrl = GetActiveTabCtrl
obj.GetMainCtrlChildObj = GetMainCtrlChildObj

obj.SetBrowserFullScrn = SetBrowserFullScrn
obj.RestoreWndSize = RestoreWndSize
obj.RecordWndSize = RecordWndSize
obj.IsBrowserFullScrn = IsBrowserFullScrn

obj.GetCfgPathWithName = GetCfgPathWithName
obj.ReadConfigFromMemByKey = ReadConfigFromMemByKey
obj.SaveConfigToFileByKey = SaveConfigToFileByKey
obj.ReadAllConfigInfo = ReadAllConfigInfo


XLSetGlobal("YBYL.FunctionHelper", obj)



