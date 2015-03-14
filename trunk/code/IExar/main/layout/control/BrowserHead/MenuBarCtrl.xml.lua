local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

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
end


function OnLButtonDownMenuItem(self)
	-- self:SetCaptureMouse(true)
	FocusOnItem(self, true)
end


function OnMouseLeaveMenuItem(self)
	FocusOnItem(self, false)
end


function OnFocusMenuItem(self, bFocus)
	FocusOnItem(self, bFocus)
end

------
--对同一个菜单按钮连续点击时，点击次数为偶数则不显示菜单
function PopupMenu(objMenuBtn, nTopSpan, strMenuName, tMenuOpenFlag)
	FocusOnItem(objMenuBtn, true)
	
	if type(tMenuOpenFlag) ~= "table" then
		tMenuOpenFlag = {}
	end
	if tMenuOpenFlag.bShow then
		return
	end
	tMenuOpenFlag.bShow = true
	
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(objMenuBtn, strMenuName)
	tFunHelper.CreateAndShowMenu(objMenuBtn, strMenuName, nTopSpan)
	
	FocusOnItem(objMenuBtn, false)
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	if tMenuOpenFlag.hTimer then
		timeMgr:KillTimer(tMenuOpenFlag.hTimer)
	end
	
	tMenuOpenFlag.hTimer = timeMgr:SetTimer(function(Itm, id)
		tMenuOpenFlag.bShow = false
		Itm:KillTimer(id)
	end, 300)	
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
	if not objBkg then
		return
	end
	
	local l, t, r, b = objMenuItem:GetObjPos()
	objBkg:SetObjPos(l, t, r, b)
	objBkg:SetVisible(bShow)
	if IsRealString(strTextureID) then
		objBkg:SetTextureID(strTextureID)
	end
end


function FocusOnItem(objItem, bOnFocus)
	if bOnFocus then
		ShowMenuItemBkg(objItem, true, "YBYL.Menu.Select.Bkg")
		objItem:SetTextColorResID("system.white")
	else
		ShowMenuItemBkg(objItem, false, "")
		objItem:SetTextColorResID("color.menubar.text")
	end
end



------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end