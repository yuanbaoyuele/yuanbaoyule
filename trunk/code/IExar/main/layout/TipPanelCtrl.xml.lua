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

function OnInitErrorPage(self)
	self:Navigate("res://ieframe.dll/http_303_webOC.htm")
	self:SetVisible(false)
	self:SetChildrenVisible(false)
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
	["001_84"]  = function() ShortK_AddNewTab() end, --Ctrl+T  
	["001_75"]  = function() ShortK_CopyTab() end, --Ctrl+K
	["001_78"]  = function() ShortK_AddNewWindow() end, --Ctrl+N  
	["001_79"]  = function() ShortK_Open() end, --Ctrl+O  
	["001_80"]  = function() ShortK_PageSetup() end, --Ctrl+P  
	["001_83"]  = function() ShortK_SaveAs() end, --Ctrl+S  
	["001_87"]  = function() ShortK_CloseTab() end, --Ctrl+W
	["000_116"] = function() ShortK_Refresh() end, --F5
	["000_122"] = function() ShortK_FullScreen() end, --F11
	["100_76"]  = function() ShortK_HelpMenu() end, --Alt+L
	["100_77"]  = function() ShortK_MainPageMenu() end, --Alt+M
	["100_82"]  = function() ShortK_PrinterMenu() end, --Alt+R
	["100_68"]  = function() ShortK_AddrEditFocus() end, --Alt+D
	["000_115"] = function() ShortK_AddrEditFocus() end, --F4
	["000_112"] = function() ShortK_IEHelp() end, --F1
	["011_46"]  = function() ShortK_ClearHistory() end, --Ctrl+Shift+Del
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
	tFunHelper.OpenNewTabDefault()
end

function ShortK_CopyTab()
	local strURL = tFunHelper.GetCurrentURL()
	tFunHelper.OpenURLInNewTab(strURL)
end

function ShortK_CloseTab()
	local objTabCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	objTabCtrl:CloseCurrentTab()
end

function ShortK_Refresh()
	InitMenuHelper()
	tIEMenuHelper:ExecuteCMD("Refresh")
end

function ShortK_HelpMenu()
	OpenToolBarMenu("Layout.Help.Btn", "HelpMenu")
end

function ShortK_MainPageMenu()
	OpenToolBarMenu("Layout.MainPage.Left", "MainPageMenu")
end

function ShortK_PrinterMenu()
	OpenToolBarMenu("Layout.Printer.Left", "PrintMenu")
end

function ShortK_AddrEditFocus()
	local objHead = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	local objAddressBar = objHead and objHead:GetControlObject("BrowserHeadCtrl.AddressBar")
	local objUrlEdit = objAddressBar and objAddressBar:GetControlObject("AddressBarCtrl.UrlEdit")
	if not objUrlEdit then
		return
	end
	objUrlEdit:SetFocus(true)
	objUrlEdit:SetSelAll()
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

function ShortK_IEHelp(self)
	local strResDir = tFunHelper.GetResourceDir()
	if not IsRealString(strResDir) then
		return
	end
	local strIEHelp_chm = tipUtil:PathCombine(strResDir, "iexplore.chm")
	if not tipUtil:QueryFileExists(strIEHelp_chm) then
		return
	end
	tipUtil:ShellExecute(0, "open", strIEHelp_chm, "", 0, "SW_SHOW")
end

function ShortK_ClearHistory(self)
	tFunHelper.ShowModalDialog("TipDeleteExplorerHistroyWnd", "TipDeleteExplorerHistroyWndInstance", "TipDeleteExplorerHistroyWndTree", "TipDeleteExplorerHistroyWndTreeInstance")
end

--------------------------------------------------
function OpenToolBarMenu(strBtnName, strMenuName)
	local objToolBar = tFunHelper.GetHeadCtrlChildObj("head.toolbar.instance")  
	if not objToolBar then
		return 
	end
	local objHelpBtn = objToolBar:GetControlObject(strBtnName)
	if not objHelpBtn then
		return
	end
	
	tFunHelper.TryDestroyOldMenu(objHelpBtn, strMenuName)
	tFunHelper.CreateAndShowMenu(objHelpBtn, strMenuName, 26, false, true)
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

function OnTitleRButtonUp(self)
	local hUEMainWnd = tFunHelper:GetMainWndInst()
	if hUEMainWnd ~= nil then
		hMainWnd = hUEMainWnd:GetWndHandle()
		tipUtil:TrackPopUpSysMenu(hMainWnd,0,0)
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
