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

function GetCommandStrValue(strKey)
	local bRet, strValue = false, nil
	local cmdString = tipUtil:GetCommandLine()
	
	if string.find(cmdString, strKey .. " ") then
		local cmdList = tipUtil:CommandLineToList(cmdString)
		if cmdList ~= nil then	
			for i = 1, #cmdList, 2 do
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


function ExitProcess()
	SaveAllConfig()

	TipLog("************ Exit ************")
	tipUtil:Exit("Exit")
end


function IsUserFullScreen()
	local bRet = false
	if type(tipUtil.IsNowFullScreen) == "function" then
		bRet = tipUtil:IsNowFullScreen()
	end
	return bRet
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


function RegQueryValue(sPath)
	if IsRealString(sPath) then
		local sRegRoot, sRegPath, sRegKey = string.match(sPath, "^(.-)[\\/](.*)[\\/](.-)$")
		if IsRealString(sRegRoot) and IsRealString(sRegPath) then
			return tipUtil:QueryRegValue(sRegRoot, sRegPath, sRegKey or "") or ""
		end
	end
	return ""
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
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objMainWnd = hostwndManager:GetHostWnd("YBYLTipWnd.MainFrame")
	return objMainWnd
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


function GetCurrentURL()
	local strURL = GetHomePage()
	local objActiveTabCtrl = GetActiveTabCtrl()
		
	if objActiveTabCtrl ~= nil and objActiveTabCtrl ~= 0 then
		strURL = objActiveTabCtrl:GetLocalURL()
	end
	
	return strURL
end


function OpenURL(strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	objTabContainer:OpenURL(strURL, true)
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


function GetIcoBitmapObj(strIcoName)
	if not IsRealString(strIcoName) then
		return nil
	end

	local strIcoDir = GetIcoDir()
	local strIcoPath = tipUtil:PathCombine(strIcoDir, strIcoName)
	if not tipUtil:QueryFileExists(strIcoPath) then
		return nil	
	end
	
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local objBitmap = xlgraphic:CreateBitmap(strIcoPath,"ARGB32")
	return objBitmap
end

function GetDefaultIcoImgID()
	local strDefaultImgID = "YBYL.UrlIco.Default"
	return strDefaultImgID
end


------------UI--

----菜单--
function TryDestroyOldMenu(objMenuText, strMenuKey)
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")
	local strHostWndName = strMenuKey..".HostWnd.Instance" 
	local strObjTreeName = strMenuKey..".Tree.Instance"

	if uHostWndMgr:GetHostWnd(strHostWndName) then
		uHostWndMgr:RemoveHostWnd(strHostWndName)
	end
	
	if uObjTreeMgr:GetUIObjectTree(strObjTreeName) then
		uObjTreeMgr:DestroyTree(strObjTreeName)
	end
end


function CreateAndShowMenu(objMenuText, strMenuKey)
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
			local bSucc = ShowMenuHostWnd(objMenuText, uHostWnd, uObjTree)
			
			if bSucc and uHostWnd:GetMenuMode() == "manual" then
				uObjTreeMgr:DestroyTree(strObjTreeName)
				uHostWndMgr:RemoveHostWnd(strHostWndName)
			end
		end
	end
end


function ShowMenuHostWnd(objMenuText, uHostWnd, uObjTree)
	uHostWnd:BindUIObjectTree(uObjTree)
					
	local objMainLayout = uObjTree:GetUIObject("Menu.MainLayout")
	if not objMainLayout then
	    return false
	end	
	local nL, nT, nR, nB = objMainLayout:GetObjPos()				
	local nMenuContainerWidth = nR - nL
	local nMenuContainerHeight = nB - nT
	local nMenuLeft, nMenuTop = GetScreenAbsPos(objMenuText)
	
	uHostWnd:SetFocus(false) --先失去焦点，否则存在菜单不会消失的bug
	
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



-----



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


function GetHomePage()
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	local strHomePage = tUserConfig["strHomePage"]
	return strHomePage
end

function SetHomePage(strURL)
	local tUserConfig = ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["strHomePage"] = strURL
	SaveConfigToFileByKey("tUserConfig")
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
		
			if not IsRealString(tInfo["strLocationName"]) then
				tFileInfo[nIndex]["strLocationName"] = strLctnName
				SaveConfigToFileByKey(tFileInfo)
			end
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


function RemoveUserCollectURL(strInputURL)
	local strURL = FormatURL(strInputURL)
	
	local tUserCollect = ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return
	end

	for nIndex, tCollectInfo in pairs(tUserCollect) do
		if type(tCollectInfo) == "table" and tCollectInfo["strURL"] == strURL then
			table.remove(tUserCollect, nIndex)
			SaveConfigToFileByKey("tUserCollect")
			break
		end
	end
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


------------------文件--
local obj = {}
obj.tipUtil = tipUtil
obj.tipAsynUtil = tipAsynUtil

obj.TipLog = TipLog
obj.FailExitTipWnd = FailExitTipWnd
obj.TipConvStatistic = TipConvStatistic
obj.ExitProcess = ExitProcess
obj.GetCommandStrValue = GetCommandStrValue

obj.NewAsynGetHttpFile = NewAsynGetHttpFile
obj.GetProgramTempDir = GetProgramTempDir
obj.GetYBYLVersion = GetYBYLVersion
obj.AccelerateFlash = AccelerateFlash

obj.OpenURL = OpenURL
obj.FormatURL = FormatURL
obj.OpenURLInNewWindow = OpenURLInNewWindow
obj.GetHomePage = GetHomePage
obj.SetHomePage = SetHomePage
obj.GetActiveTabCtrl = GetActiveTabCtrl
obj.GetMainCtrlChildObj = GetMainCtrlChildObj
obj.ShowPopupWndByName = ShowPopupWndByName

obj.SaveUserCollectURL = SaveUserCollectURL
obj.RemoveUserCollectURL = RemoveUserCollectURL
obj.SaveUrlToHistory = SaveUrlToHistory
obj.ClearFileInfo = ClearFileInfo
obj.SaveLctnNameToFile = SaveLctnNameToFile
obj.SaveIcoNameToFile = SaveIcoNameToFile
obj.GetIcoDir = GetIcoDir
obj.GetIcoBitmapObj = GetIcoBitmapObj
obj.GetDefaultIcoImgID = GetDefaultIcoImgID
obj.UpdateCollectList = UpdateCollectList

obj.TryDestroyOldMenu = TryDestroyOldMenu
obj.CreateAndShowMenu = CreateAndShowMenu

obj.SetBrowserFullScrn = SetBrowserFullScrn
obj.RestoreWndSize = RestoreWndSize
obj.RecordWndSize = RecordWndSize
obj.IsBrowserFullScrn = IsBrowserFullScrn

obj.GetCfgPathWithName = GetCfgPathWithName
obj.ReadConfigFromMemByKey = ReadConfigFromMemByKey
obj.SaveConfigToFileByKey = SaveConfigToFileByKey
obj.ReadAllConfigInfo = ReadAllConfigInfo


XLSetGlobal("YBYL.FunctionHelper", obj)



