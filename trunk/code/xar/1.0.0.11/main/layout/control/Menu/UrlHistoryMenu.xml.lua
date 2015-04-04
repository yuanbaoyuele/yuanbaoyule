local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnInitControl(self)
	AdjustSelfPos(self)
	ShowUrlHistory(self)
end

----
function AdjustSelfPos(self)
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	local nAddBarL, nAddBarT, nAddBarR, nAddBarB = objAddressBar:GetObjPos()
	local nAddBarW = nAddBarR - nAddBarL
		
	local nSelfL, nSelfT, nSelfR, nSelfB = self:GetObjPos()
	self:SetObjPos(nSelfL, nSelfT, nSelfL+nAddBarW, nSelfB )
end



function ShowUrlHistory(self)
	local tUrlHistory = tFunHelper.ReadConfigFromMemByKey("tUrlHistory") or {}
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowHistory = 6
	
	local nTotalCount = 0
	for nIndex=1, #tUrlHistory do
		local tHistoryInfo = tUrlHistory[nIndex]
		if type(tHistoryInfo) == "table" and tHistoryInfo["bInAddressBar"] then
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
		BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	end
end


function CreateMenuContainer(objNormalMenuCtrl)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local menuTemplate = templateMananger:GetTemplate("urlhistorymenu.context", "ObjectTemplate")
	if menuTemplate == nil then
		return nil
	end
	local objMenu = menuTemplate:CreateInstance( "context_menu" )
	return objMenu
end


function CreateMenuItem(tHistoryInfo, nIndex)	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	
	local objMenuItem = objMenuItemTempl:CreateInstance( "UrlHistory_"..tostring(nIndex) )
	if not objMenuItem then
		return nil
	end

	local attr = objMenuItem:GetAttribute()
	attr.Text = tHistoryInfo["strURL"]
	attr.RightText = tHistoryInfo["strLocationName"]
	attr.RightTextColor = "404040"
	attr.RightTextHAligh = "left"
	attr.TextRightWidth = 40
	attr.FontColorNormal = "949494"
	attr.TextPos = 30
	attr.DeleteImgVisible = true
	
	SetIcoImage(objMenuItem, tHistoryInfo)
	objMenuItem:AttachListener("OnSelect", false, OpenURL)
	return objMenuItem
end


function SetIcoImage(objMenuItem, tHistoryInfo)
	local strIcoName = tHistoryInfo["strIcoName"]
	local attr = objMenuItem:GetAttribute() 
	attr.IconPos = 5
	attr.IconWidth = 17
	attr.IconHeight = 17
	
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objMenuItem:SetIconID(strDefaultImgID)
	
	local objBitmap = tFunHelper.GetIcoBitmapObj(strIcoName)
	if objBitmap then
		objMenuItem:SetIconBitmap(objBitmap)
	end
end


function OpenURL(objMenuItem)
	local strURL = objMenuItem:GetText()
	tFunHelper.OpenURLInNewTab(strURL)
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


