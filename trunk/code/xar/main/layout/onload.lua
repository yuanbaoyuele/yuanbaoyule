local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")

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


function ShowMainTipWnd(objMainWnd)
	objMainWnd:Show(5)
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
		tipUtil:CreateDir(strWebRootDir)
	end
	
	tipUtil:FYbSetWebRoot(strWebRootDir)
end



--µ¯³ö´°¿Ú--
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
			FunctionObj.OpenURL(strURL)
		end
	end
end


function ProcessCommandLine()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bRet, strURL = FunctionObj.GetCommandStrValue("/openlink")
	if bRet and IsRealString(strURL) then
		FunctionObj.OpenURL(strURL)
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
	if not RegisterFunctionObject() then
		tipUtil:Exit("Exit")
	end
	
	LoadIEHelper()
	
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
	FunctionObj.ReadAllConfigInfo()
	
	InitAdvFilter()
	
	CreateMainTipWnd()
	CreatePopupTipWnd()
	ProcessCommandLine()
end


TipMain()
