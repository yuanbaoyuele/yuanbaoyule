local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnInitControl(self)
	ShowUserCollect(self)
end

--

function ShowUserCollect(self)
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect") or {}
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowCollect = tUserConfig["nMaxShowCollect"] or 9
		
	local nTotalCount = 0
	for nIndex=1, #tUserCollect do
		local tCollectInfo = tUserCollect[nIndex]
		if type(tCollectInfo) == "table" then
			local objMenuItem = CreateMenuItem(tCollectInfo, nIndex)	
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
		BindMenuContainer(self, objMenuContainer, nMaxShowCollect, nTotalCount)
	end
end


function CreateMenuContainer(objNormalMenuCtrl)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local menuTemplate = templateMananger:GetTemplate("usercollectmenu.context", "ObjectTemplate")
	if menuTemplate == nil then
		return nil
	end
	local objMenu = menuTemplate:CreateInstance( "context_menu" )
	return objMenu
end


function CreateMenuItem(tCollectInfo, nIndex)	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	
	local objMenuItem = objMenuItemTempl:CreateInstance( "UserCollect_"..tostring(nIndex) )
	if not objMenuItem then
		return nil
	end

	local attr = objMenuItem:GetAttribute()
	attr.Text = tCollectInfo["strLocationName"]
	attr.ExtraData = tCollectInfo["strURL"]
	attr.FontColorNormal = "404040"
	attr.TextPos = 27
	
	SetIcoImage(objMenuItem, tCollectInfo)
	objMenuItem:AttachListener("OnSelect", false, OpenURL)
	objMenuItem:AttachListener("OnRButtonUp", false, OnRButtonUpMenuItem)
	return objMenuItem
end

function SetIcoImage(objMenuItem, tCollectInfo)
	local strIcoName = tCollectInfo["strIcoName"]
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
	local strURL = objMenuItem:GetExtraData()
	tFunHelper.OpenURL(strURL)
end


function OnRButtonUpMenuItem(objMenuItem)
	-- local bRButtonPopup = true
	-- tFunHelper.TryDestroyOldMenu(objMenuItem, "RBtnCollectMenu")
	-- tFunHelper.CreateAndShowMenu(objMenuItem, "RBtnCollectMenu", 0, bRButtonPopup)
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


