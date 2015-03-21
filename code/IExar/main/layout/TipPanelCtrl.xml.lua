local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

----方法----
function SetTipData(self, infoTab) 
	tipUtil:FSetKeyboardHook()
	CreateFilterListener(self)
	return true
end


---事件--

function OnInitHeadWnd(self)
	
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
			if tostring(key) == "OnKeyDown" then
				OnKeyDown(tParam)
			end
		end
	)
end



--快捷键
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")
local g_tShortKeyFun = {
	["001_84"] = function() ShortK_AddNewTab() end, --Ctrl+T  
	["001_78"] = function() ShortK_AddNewWindow() end, --Ctrl+N  
	["001_79"] = function() ShortK_Open() end, --Ctrl+O  
	["001_83"] = function() ShortK_SaveAs() end, --Ctrl+S  
	["001_80"] = function() ShortK_PageSetup() end, --Ctrl+P  
	["000_122"] = function() ShortK_FullScreen() end, --F11
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

function ShortK_FullScreen(self)
	local bIsFullScreen = tFunHelper.IsBrowserFullScrn()
	if not bIsFullScreen then
		tFunHelper.SetBrowserFullScrn()
	else
		tFunHelper.RestoreWndSize()
	end
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

