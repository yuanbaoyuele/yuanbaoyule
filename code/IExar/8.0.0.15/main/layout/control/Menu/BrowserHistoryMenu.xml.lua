local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	

-------事件---
function OnInitControl(self)
	ShowUrlHistory(self)
end

----
function ShowUrlHistory(self)
	local objWebCtrl = tFunHelper.GetActiveTabCtrl()
	local attr = objWebCtrl:GetAttribute()
	local tUrlHistory = attr.tCurURLList or {}
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowHistory = 60
	
	local nTotalCount = 0
	for nIndex=1, #tUrlHistory do
		local tHistoryInfo = tUrlHistory[nIndex]
		if type(tHistoryInfo) == "table" then
			local objMenuItem = CreateMenuItem(tHistoryInfo, nIndex)	
			if objMenuItem then
				objMenuContainer:AddChild(objMenuItem)				
				nTotalCount = nTotalCount+1
			end			
		end	
	end
	
	if nTotalCount < 1 then
		self:SetVisible(false)
		self:SetChildrenVisible(false)
	else
		CreateExtraItem(objMenuContainer)
		BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	end
end


function CreateMenuContainer(objNormalMenuCtrl)
	local menuTemplate = templateMananger:GetTemplate("browserhistorymenu.context", "ObjectTemplate")
	if menuTemplate == nil then
		return nil
	end
	local objMenu = menuTemplate:CreateInstance( "context_menu" )
	return objMenu
end


function CreateMenuItem(tHistoryInfo, nIndex)	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	
	local objMenuItem = objMenuItemTempl:CreateInstance( "UrlHistory_"..tostring(nIndex) )
	if not objMenuItem then
		return nil
	end

	local attr = objMenuItem:GetAttribute()
	attr.Text = tHistoryInfo["strTitle"]
	attr.ExtraData = tHistoryInfo["strURL"]
	attr.FontColorNormal = "system.black"
	attr.FontColorHover = "system.white"
	attr.TextPos = 24
	attr.DeleteImgVisible = false
	
	attr.IconPos = 5
	attr.IconWidth = 10
	attr.IconHeight = 10
	attr.IconVisible = true
	
	objMenuItem:SetIconID("ArrowLeft")
	TrySetActiveItem(objMenuItem, nIndex)
	objMenuItem:AttachListener("OnSelect", false, OpenURL)
	return objMenuItem
end


function CreateExtraItem(objMenuContainer)
	local objSplitterTempl = templateMananger:GetTemplate("menu.splitter", "ObjectTemplate")
	if objSplitterTempl == nil then
		return nil
	end
	
	local objMenuItem = objSplitterTempl:CreateInstance("Splitter")
	if not objMenuItem then
		return nil
	end
	objMenuContainer:AddChild(objMenuItem)
	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	local objMenuItem = objMenuItemTempl:CreateInstance( "HistoryBtn" )
	if not objMenuItem then
		return nil
	end
	local attr = objMenuItem:GetAttribute()
	attr.Text = "历史记录"
	attr.TextPos = 24
	
	attr.RightText = "Ctrl+Shift+H"
	attr.RightTextColor = "system.black"
	attr.RightTextHAligh = "font.text12"
	attr.TextRightWidth = 40
	attr.FontColorNormal = "system.black"
	attr.FontColorHover = "system.white"
	
	attr.DeleteImgVisible = false
	attr.IconPos = 5
	attr.IconWidth = 17
	attr.IconHeight = 17
	attr.IconVisible = true
	objMenuItem:SetIconID("History.Logo")
	objMenuItem:AttachListener("OnSelect", false, OpenHistory)
	objMenuContainer:AddChild(objMenuItem)
end


function TrySetActiveItem(objMenuItem, nIndex)
	local objWebTab = tFunHelper.GetActiveTabCtrl()
	local attr = objWebTab:GetAttribute()
	local nActiveIndex = attr.nCurURLIndex
	
	if nActiveIndex ~= nIndex then
		return
	end
	
	local attr = objMenuItem:GetAttribute()
	attr.IconPos = 8
	attr.IconWidth = 7
	attr.IconHeight = 7
	attr.IconVisible = true
	attr.Icon = "Menu.Check.Black"
	attr.IconHover = "Menu.Check.White"
	
	objMenuItem:SetIconID("Menu.Check.Black")
	objMenuItem:SetFont("font.menuitem.bold")
	objMenuItem:SetBkgResID("MenuItem.Active")
end


function OpenURL(objMenuItem)
	local attr = objMenuItem:GetAttribute()
	local strURL = attr.ExtraData
	
	tFunHelper.OpenURLInCurTab(strURL)
	local objWebCtrl = tFunHelper.GetActiveTabCtrl()
	objWebCtrl:SetNewURLState(false)
	
	local strKey = objMenuItem:GetID()
	local nIndex = tonumber(string.match(strKey, "[^%d]*(%d+)"))
	if not nIndex then
		return
	end
	
	local attr = objWebCtrl:GetAttribute()
	attr.nCurURLIndex = nIndex
end


function OpenHistory(objMenuItem)
	local bFix = true
	local nTabIndex = 3
	tFunHelper.ShowCollectWnd(nTabIndex, bFix)
end


function BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	local attr = self:GetAttribute()
	attr.nLinePerPage = nMaxShowHistory
	attr.nTotalLineCount = nTotalCount

	self:OnInitControl(objMenuContainer)
end

-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


