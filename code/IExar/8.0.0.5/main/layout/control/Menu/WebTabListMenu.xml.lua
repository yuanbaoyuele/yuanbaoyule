local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	

-------事件---
function OnInitControl(self)
	AdjustSelfPos(self)
	ShowWebTabList(self)
end

----
function AdjustSelfPos(self)
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	local nAddBarL, nAddBarT, nAddBarR, nAddBarB = objAddressBar:GetObjPos()
	local nMenuHeight = GetMenuHeight(self)
		
	local nSelfL, nSelfT, nSelfR, nSelfB = self:GetObjPos()
	self:SetObjPos(nSelfL, nSelfT, nSelfR, nSelfT+nMenuHeight )
end

function ShowWebTabList(self)
	local objTabContainer = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	if not objTabContainer then
		return
	end
	
	local tWebTabList = objTabContainer:GetTotalShowTabList()
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowHistory = GetMaxCount(self)
	
	local nTotalCount = 0
	for nIndex=1, #tWebTabList do
		local objWebTab = tWebTabList[nIndex]
		if objWebTab then
			local tWebTabInfo = {} 
			tWebTabInfo["strTitle"] = objWebTab:GetTabText()
			tWebTabInfo["strIcoName"] = objWebTab:GetIcoName()
			tWebTabInfo["nWebTabID"] = objWebTab:GetSelfID()
			tWebTabInfo["objWebTab"] = objWebTab
			
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
	attr.ExtraData = tWebTabInfo["nWebTabID"]
	attr.FontColorNormal = "system.black"
	attr.FontColorHover = "system.white"
	attr.TextPos = 24
	attr.DeleteImgVisible = false
	
	attr.IconPos = 5
	attr.IconWidth = 16
	attr.IconHeight = 16
	attr.IconVisible = true
	
	SetIcoImage(objMenuItem, tWebTabInfo)
	TrySetActiveItem(objMenuItem, tWebTabInfo)
	objMenuItem:AttachListener("OnSelect", false, SetActiveTab)
	return objMenuItem
end


function SetIcoImage(objMenuItem, tWebTabInfo)
	local strIcoName = tWebTabInfo["strIcoName"]
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objMenuItem:SetIconID(strDefaultImgID)
	
	local objBitmap, nRet = tFunHelper.GetIcoBitmapObj(strIcoName)
	if nRet == -2 then
		tFunHelper.DownLoadIco(tWebTabInfo["strURL"], function() end)
		return
	end	
	
	if objBitmap then
		objMenuItem:SetIconID("")
		objMenuItem:SetIconBitmap(objBitmap)
	end
end


function TrySetActiveItem(objMenuItem, tWebTabInfo)
	local objWebTab = tFunHelper.GetActiveTabCtrl()
	if objWebTab:GetID() ~= tWebTabInfo.objWebTab:GetID() then
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
end


function SetActiveTab(objMenuItem)
	local attr = objMenuItem:GetAttribute()
	local nWebTabID = attr.ExtraData
	local objTabContainer = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	if not objTabContainer then
		return
	end
	objTabContainer:SetActiveTab(nWebTabID)
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


function GetMaxCount(objRootCtrl)
	local nRealHeight = GetMenuHeight(objRootCtrl)
	return math.floor(nRealHeight/20)
end


function GetMenuHeight(objRootCtrl)
	local objMainWnd = tFunHelper.GetMainWndInst()
	local l, t, r, b = objMainWnd:GetWindowRect()
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	
	return workbottom
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


