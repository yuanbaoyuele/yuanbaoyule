local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnInitControl(self)
	ShowUserCollect(self)
end

--

function ShowUserCollect(self)
	local tCollectInfo = GetCollectInfo(self)
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end

	local nMaxShowCollect = tUserConfig["nMaxShowCollect"] or 9
		
	local nTotalCount = 0
	for nIndex=1, #tCollectInfo do
		local tCollectInfo = tCollectInfo[nIndex]
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
	local menuTemplate = templateMananger:GetTemplate("collectbarmenu.context", "ObjectTemplate")
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
	attr.DeleteImgVisible = false
	
	SetIcoImage(objMenuItem, tCollectInfo)
	objMenuItem:AttachListener("OnSelect", false, OpenURL)
	objMenuItem:AttachListener("OnRButtonUp", false, OnRButtonUpMenuItem)
	return objMenuItem
end


function SetIcoImage(objMenuItem, tCollectInfo)
	local attr = objMenuItem:GetAttribute() 
	attr.IconPos = 5
	attr.IconWidth = 17
	attr.IconHeight = 17
	
	local objBitmap = tCollectInfo["objBitmap"]
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objMenuItem:SetIconID(strDefaultImgID)
		
	local objImage = objMenuItem:GetControlObject("icon")
	if objBitmap and objImage then
		objMenuItem:SetIconBitmap(objBitmap)
	end
end


function OpenURL(objMenuItem)
	local strURL = objMenuItem:GetExtraData()
	tFunHelper.OpenURLInNewTab(strURL)
end


function OnRButtonUpMenuItem(objMenuItem)
	-- local bRButtonPopup = true
	-- tFunHelper.TryDestroyOldMenu(objMenuItem, "RBtnCollectMenu")
	-- tFunHelper.CreateAndShowMenu(objMenuItem, "RBtnCollectMenu", 0, bRButtonPopup)
end


--从CollectList控件获取数据
function GetCollectInfo(objContext)
	local objMenuBarCtrl = GetMenuBarCtrl(objContext)
	if not objMenuBarCtrl then
		return {}
	end

	local tHideCollectList = objMenuBarCtrl:GetHideMenuList()
	local tCollectInfo = {}
	
	for _, objCollectLayout in pairs(tHideCollectList) do
		if objCollectLayout then
			local objImg = objCollectLayout:GetChildByIndex(0)
			local objText = objCollectLayout:GetChildByIndex(1)
			local objURL = objCollectLayout:GetChildByIndex(2)
				
			local nIndex = #tCollectInfo+1
			tCollectInfo[nIndex] = {}
			tCollectInfo[nIndex]["objBitmap"] = objImg:GetBitmap()
			tCollectInfo[nIndex]["strURL"] = objURL:GetText()
			tCollectInfo[nIndex]["strLocationName"] = objText:GetText()
		end
	end
	
	return tCollectInfo
end


function BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	local attr = self:GetAttribute()
	attr.nLinePerPage = nMaxShowHistory
	attr.nTotalLineCount = nTotalCount

	self:OnInitControl(objMenuContainer)
end


function GetMenuBarCtrl(objMenuItem)
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objMenuBarCtrl = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectList")
	return objMenuBarCtrl
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


