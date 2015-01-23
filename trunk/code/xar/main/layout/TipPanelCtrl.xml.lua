local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

----方法----
function SetTipData(self, infoTab) 
	tipUtil:FSetKeyboardHook()
	CreateFilterListener(self)
	return true
end


---事件--
--tabcontainer事件
function OnActiveTabChange(self, strEvntName,objActiveTab)
	if not objActiveTab then
		return
	end

	local objRootCtrl = self:GetOwnerControl()
	local objHeadCtrl = objRootCtrl:GetControlObject("MainPanel.Head")
	if not objHeadCtrl then
		tFunHelper.TipLog("[OnActiveTabChange] get objHeadCtrl failed")
		return
	end
	objHeadCtrl:ProcessTabChange(objActiveTab)
end


--安装后第一次启动展示介绍
function OnInitTipIntroduce(self)
	local strRegPath = "HKEY_CURRENT_USER\\SOFTWARE\\YBYL\\ShowIntroduce"
	local strValue = tFunHelper.RegQueryValue(strRegPath)
	
	if not IsNilString(strValue) then
		self:SetObjPos(0, 0, "father.width", "father.height")
		self:SetVisible(true)
		self:SetChildrenVisible(true)
	else
		self:SetVisible(false)
		self:SetChildrenVisible(false)
	end
end



--监听事件
function CreateFilterListener(objRootCtrl)
	local objFactory = XLGetObject("APIListen.Factory")
	if not objFactory then
		tFunHelper.TipLog("[CreateFilterListener] not support APIListen.Factory")
		return
	end
	
	local objListen = objFactory:CreateInstance()	
	objListen:AttachListener(
		function(key,...)	

			tFunHelper.TipLog("[CreateFilterListener] key: " .. tostring(key))
			
			local tParam = {...}	
			if tostring(key) == "OnFilterResult" then
				OnFilterResult(tParam)
			elseif tostring(key) == "OnKeyDown" then
				OnKeyDown(tParam)
			end
		end
	)
end


--检测到过滤广告， 弹tooltip
function OnFilterResult(tParam)
	local bFilterSucc = tParam[1]
	local strDomain = tParam[2]
	
	if not bFilterSucc then
		return
	end
	
	tFunHelper.PopupToolTipOneDay()
end


--快捷键
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")
local g_tShortKeyFun = {
	["001_84"] = function() ShortK_AddNewTab() end, --Ctrl+T  
	["001_78"] = function() ShortK_AddNewWindow() end, --Ctrl+N  
	["001_79"] = function() ShortK_Open() end, --Ctrl+O  
	["001_83"] = function() ShortK_SaveAs() end, --Ctrl+S  
	["001_80"] = function() ShortK_PageSetup() end, --Ctrl+P  
}

function OnKeyDown(tParam)
	local hFocus = tParam[1]
	local lalt = tParam[2]
	local lshift = tParam[3]
	local lctrl = tParam[4]
	local nKeyCode = tParam[5]

	local strFunKey = tostring(lalt)..tostring(lshift)..tostring(lctrl).."_"..tostring(nKeyCode)
	local funProcessKey = g_tShortKeyFun[strFunKey]
	if type(funProcessKey) == "function" then
		funProcessKey()
	end
end


function ShortK_AddNewTab()
	local strHomePage = tFunHelper.GetDfltNewTabURL()
	tFunHelper.OpenURLInNewTab(strHomePage)
end


function ShortK_AddNewWindow(self)
	tFunHelper.OpenURLInNewWindow()
end

function ShortK_Open(self)
	local strURL = tIEMenuHelper:ExecuteCMD("Open")
	tFunHelper.OpenURLInNewTab(strURL)
end

function ShortK_SaveAs(self)
	InitMenuHelper()
	tIEMenuHelper:ExecuteCMD("SaveAS")
end

function ShortK_PageSetup(self)
	InitMenuHelper()
	tIEMenuHelper:ExecuteCMD("PageSetup")
end


function InitMenuHelper()
	local objActiveTab = tFunHelper.GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		return
	end
	
	local objBrowserCtrl = objActiveTab:GetBindBrowserCtrl()
	if objBrowserCtrl then
		local objUEBrowser = objBrowserCtrl:GetControlObject("browser")
		tIEMenuHelper:Init(objUEBrowser)
	end
end


function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end


function IsRealString(AString)
    return type(AString) == "string" and AString ~= ""
end

