local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")

local gStatCount = 0
local gForceExit = nil


function IsRealString(str)
	return type(str) == "string" and str ~= ""
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

function ExitProcess()
	TipLog("************ Exit ************")
	tipUtil:Exit("Exit")
end


function OpenURL(strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local objTabContainer = GetMainCtrlChildObj("MainPanel.TabContainer")
	objTabContainer:OpenURL(strURL, true)
end


function GetMainCtrlChildObj(strObjName)
	local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local objMainWnd = hostwndManager:GetHostWnd("YBYLTipWnd.MainFrame")
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



function TipLog(strLog)
	if type(tipUtil.Log) == "function" then
		tipUtil:Log("@@YBYL_Log: " .. tostring(strLog))
	end
end


local obj = {}
obj.tipUtil = tipUtil
obj.tipAsynUtil = tipAsynUtil
obj.TipLog = TipLog
obj.OpenURL = OpenURL
obj.FailExitTipWnd = FailExitTipWnd
obj.TipConvStatistic = TipConvStatistic
obj.ExitProcess = ExitProcess
obj.GetMainCtrlChildObj = GetMainCtrlChildObj
obj.NewAsynGetHttpFile = NewAsynGetHttpFile
obj.GetProgramTempDir = GetProgramTempDir

XLSetGlobal("YBYL.FunctionHelper", obj)


