local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

local g_bHasShowMenu = false
local g_strCruMenuName = ""
local g_strLastMenuBtn = nil
local g_hTimer = nil
local g_bForbidShowTwice = false

-----方法----


-----事件----
function OnClickHideBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	local nBtnL, nBtnT, nBtnR, nBtnB = self:GetObjPos()
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()
	
	local nBtnW = nBtnR-nBtnL+10
	local nRootW = nRootR-nRootL
	local nNewLeft = nRootW-nBtnW
	
	objRootLayout:SetObjPos(nNewLeft, 0, "father.width", "father.height")
	SetHideBtnStyle(objRootCtrl, false)
end


function OnClickShowBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	objRootLayout:SetObjPos(0, 0, "father.width", "father.height")
	
	SetHideBtnStyle(objRootCtrl, true)
end


local g_tShowFileMenu = {bShow=false}
function OnClickFile(self)
	PopupMenu(self, 18, "FileMenu", g_tShowFileMenu)
end

local g_tShowEditMenu = {bShow=false}
function OnClickEdit(self)
	PopupMenu(self, 18, "EditMenu", g_tShowEditMenu)
end


local g_tShowLookupMenu = {bShow=false}
function OnClickLookup(self)
	PopupMenu(self, 18, "LookupMenu", g_tShowLookupMenu)
end


local g_tShowCollectMenu = {bShow=false}
function OnClickCollect(self)
	PopupMenu(self, 18, "CollectMenu", g_tShowCollectMenu)
end


local g_tShowToolMenu = {bShow=false}
function OnClickTool(self)
	PopupMenu(self, 18, "ToolMenu", g_tShowToolMenu)
end


local g_tShowHelpMenu = {bShow=false}
function OnClickHelp(self)
	PopupMenu(self, 18, "HelpMenu", g_tShowHelpMenu)
end


function OnMouseEnterMenuItem(self)
	FocusOnItem(self, true)

	local strID = self:GetID()
	local strMenuName = string.match(strID, ".*%.([^%.]+)$")
	
	if g_bHasShowMenu and strMenuName ~= g_strCruMenuName then
		FocusOnItem(g_strLastMenuBtn, false)
		FocusOnItem(self, true)
		g_bHasShowMenu = false
		tFunHelper.TryDestroyOldMenu(g_strLastMenuBtn, g_strCruMenuName)
		PopupMenu(self, 18, strMenuName)
	end
end


function OnLButtonDownMenuItem(self)
	FocusOnItem(self, true)
end


function OnMouseLeaveMenuItem(self)
	local objMainWnd = tFunHelper.GetMainWndInst()
	local nCursorX, nCursorY = tipUtil:GetCursorPos() 	
	local l, t, r, b = self:GetAbsPos()
	local left,top,right,bottom = objMainWnd:HostWndRectToScreenRect(l, t, r, b)
			
	local bShowMenu = IsCurBtnShowMenu(self)
	if bShowMenu then--and nCursorY > bottom  then
		return
	end

	FocusOnItem(self, false)
end


function OnFocusMenuItem(self, bFocus)
	if g_bHasShowMenu then
		return
	end

	if not bFocus then
		-- FocusOnItem(self, false)
	end
end

------
--对同一个菜单按钮连续点击时，点击次数为偶数则不显示菜单
function PopupMenu(objMenuBtn, nTopSpan, strMenuName, tMenuOpenFlag)
	if g_bHasShowMenu then
		FocusOnItem(objMenuBtn, true)
		return
	end
	g_bHasShowMenu = true
	g_strCruMenuName = strMenuName
	g_strLastMenuBtn = objMenuBtn
	
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(objMenuBtn, strMenuName)
	tFunHelper.CreateAndShowMenu(objMenuBtn, strMenuName, nTopSpan)
	
	g_strCruMenuName = ""
	
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	if g_hTimer then
		timeMgr:KillTimer(g_hTimer)
	end
	
	g_hTimer = timeMgr:SetTimer(function(Itm, id)
		Itm:KillTimer(id)
		g_bHasShowMenu = false
		FocusOnItem(g_strLastMenuBtn, false)
		
	end, 300)	
	
	-- g_bHasShowMenu = false
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


function SetHideBtnStyle(objRootCtrl, bHideBtnVsbl)
	local objHideBtn = objRootCtrl:GetControlObject("MenuBarCtrl.HideBtn")
	local objShowBtn = objRootCtrl:GetControlObject("MenuBarCtrl.ShowBtn")
	local bShowBtnVsbl = not bHideBtnVsbl
	
	objHideBtn:SetVisible(bHideBtnVsbl)
	objHideBtn:SetChildrenVisible(bHideBtnVsbl)
	objShowBtn:SetVisible(bShowBtnVsbl)
	objShowBtn:SetChildrenVisible(bShowBtnVsbl)
end


function ShowMenuItemBkg(objMenuItem, bShow, strTextureID)
	local objRootCtrl = objMenuItem:GetOwnerControl()
	local objBkg = objRootCtrl:GetControlObject("MenuBarCtrl.MenuItem.Bkg")
	
	local l, t, r, b = objMenuItem:GetObjPos()
	objBkg:SetObjPos(l, t, r, b)
	objBkg:SetVisible(bShow)
	if IsRealString(strTextureID) then
		objBkg:SetTextureID(strTextureID)
	end
end


function FocusOnItem(objItem, bOnFocus)
	if not objItem then
		return
	end
	
	if bOnFocus then
		objItem:SetTextColorResID("system.white")
		ShowMenuItemBkg(objItem, true, "YBYL.Menu.Select.Bkg")
	else
		objItem:SetTextColorResID("color.menubar.text")
		ShowMenuItemBkg(objItem, false, "")
	end
end


function IsCurBtnShowMenu(objBtn)
	local strID = objBtn:GetID()
	local strMenuName = string.match(strID, ".*%.([^%.]+)$")
	
	if g_bHasShowMenu and strMenuName == g_strCruMenuName then
		return true
	end
	
	return false
end




------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end