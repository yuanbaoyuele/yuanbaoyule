local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnInitControl(self)
	ShowUrlHistory(self)
end

--

function ShowUrlHistory(self)
	local tUrlHistory = tFunHelper.ReadConfigFromMemByKey("tUrlHistory") or {}
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowHistory = tUserConfig["nMaxShowHistory"] or 9
	if nMaxShowHistory > #tUrlHistory then
		nMaxShowHistory = #tUrlHistory
	end
	
	for nIndex=1, nMaxShowHistory do
		local tHistoryInfo = tUrlHistory[nIndex]
		if type(tHistoryInfo) == "table" then
			local objMenuItem = CreateMenuItem(tHistoryInfo, nIndex)	
			if objMenuItem then
				objMenuContainer:AddChild(objMenuItem)
			end			
		end	
	end
	
	BindMenuContainer(self, objMenuContainer)
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
	local objImage = objMenuItem:GetControlObject("icon")
	if objBitmap and objImage then
		objMenuItem:SetIconBitmap(objBitmap)
	end
end


function OpenURL(objMenuItem)
	local strURL = objMenuItem:GetText()
	tFunHelper.OpenURL(strURL)
end



function BindMenuContainer(self, objMenuContainer)
	self:OnInitControl(objMenuContainer)
end

-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end

