local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	

-------事件---
function OnInitControl(self)
	ShowWebTabList(self)
end

----
function ShowWebTabList(self)
	local objTabContainer = tFunHelper.GetMainCtrlChildObj("MainPanel.TabContainer")
	if not objTabContainer then
		return
	end
	
	local tWebTabList = objTabContainer:GetTotalShowTabList()
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowHistory = 6
	
	local nTotalCount = 0
	for nIndex=1, #tWebTabList do
		local objWebTab = tWebTabList[nIndex]
		if objWebTab then
			local tWebTabInfo = {} 
			tWebTabInfo["strTitle"] = objWebTab:GetTabText()
			tWebTabInfo["strIcoName"] = objWebTab:GetIcoName()
			tWebTabInfo["strURL"] = objWebTab:GetLocalURL()
			
			local objMenuItem = CreateMenuItem(tWebTabInfo, nIndex)	
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
		BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	end
end


function CreateMenuContainer(objNormalMenuCtrl)
	local menuTemplate = templateMananger:GetTemplate("webtablistmenu.context", "ObjectTemplate")
	if menuTemplate == nil then
		return nil
	end
	local objMenu = menuTemplate:CreateInstance( "context_menu" )
	return objMenu
end


function CreateMenuItem(tWebTabInfo, nIndex)	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	
	local objMenuItem = objMenuItemTempl:CreateInstance( "WebTab_"..tostring(nIndex) )
	if not objMenuItem then
		return nil
	end

	local attr = objMenuItem:GetAttribute()
	attr.Text = tWebTabInfo["strTitle"]
	attr.ExtraData = tWebTabInfo["strURL"]
	attr.FontColorNormal = "system.black"
	attr.FontColorHover = "system.white"
	attr.TextPos = 24
	attr.DeleteImgVisible = false
	
	attr.IconPos = 5
	attr.IconWidth = 10
	attr.IconHeight = 10
	attr.IconVisible = true
	
	SetIcoImage(objMenuItem, tWebTabInfo)
	TrySetActiveItem(objMenuItem, nIndex)
	objMenuItem:AttachListener("OnSelect", false, OpenURL)
	return objMenuItem
end


function SetIcoImage(objMenuItem, tWebTabInfo)
	local strIcoName = tWebTabInfo["strIcoName"]
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objMenuItem:SetIconID(strDefaultImgID)
	
	local objBitmap = tFunHelper.GetIcoBitmapObj(strIcoName)
	if objBitmap and objBitmap == -2 then
		tFunHelper.DownLoadIco(tWebTabInfo["strURL"], function() end)
		return
	end	
	
	if objBitmap then
		objMenuItem:SetIconBitmap(objBitmap)
	end
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


