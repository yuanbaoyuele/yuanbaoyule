local g_nLastItemRight = 0
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-----方法----
function UpdateCollectList(self)
	DestroyOldList(self)
	ShowUserCollect(self)
	TryShowArrowBtn(self)
end

function GetHideMenuList(self)
	local attr = self:GetAttribute()
	if type(attr.tHideMenuList) ~= "table" then
		attr.tHideMenuList = {}
	end
	return attr.tHideMenuList
end


-----事件----
function OnInitControl(self)
	ShowUserCollect(self)
	TryShowArrowBtn(self)
end

function OnPosChange(self)
	UpdateCollectList(self)
end


function OnClickArrowBtn(self)
	local bRButtonPopup = false
	tFunHelper.TryDestroyOldMenu(self, "CollectBarMenu")
	tFunHelper.CreateAndShowMenu(self, "CollectBarMenu", 10, bRButtonPopup)
end


function OnClickAddBtn(self)
	tFunHelper.AddCurWebToCollect()
	UpdateCollectList(self:GetOwnerControl())
end

---collect item--
function OnLButtonUpItem(self)
	self:SetTextureID("")
	
	local objURL = self:GetChildByIndex(2)
	if not objURL then
		return
	end
	
	local strURL = objURL:GetText()
	tFunHelper.OpenURLInCurTab(strURL)
end

function OnLButtonDownItem(self)
	self:SetTextureID("Collect.Button.Bkg.Down")
end

function OnMouseEnterItem(self)
	self:SetTextureID("Collect.Button.Bkg.Hover")
end

function OnMouseLeaveItem(self)
	self:SetTextureID("")
end

function OnRButtonUpItem(self)
	local bRButtonPopup = true
	tFunHelper.TryDestroyOldMenu(self, "RBtnCollectBarMenu")
	tFunHelper.CreateAndShowMenu(self, "RBtnCollectBarMenu", 0, bRButtonPopup)
end

----

function ShowUserCollect(objRootCtrl)
	local tUserCollect = tFunHelper.GetUserCollectList()
	if type(tUserCollect) ~= "table" then
		return
	end
	
	local objContainer = objRootCtrl:GetControlObject("CollectList.Container")
	if not objContainer then
		return false
	end
	
	g_nLastItemRight = 0
	ClearHideMenuItem(objRootCtrl)
	
	for nIndex, tCollectInfo in ipairs(tUserCollect) do
		if type(tCollectInfo) == "table" then
			local objMenuItem = CreateMenuItem(tCollectInfo, nIndex)	
			if objMenuItem then
				objContainer:AddChild(objMenuItem)
				SetMenuItemPos(objRootCtrl, objMenuItem, nIndex)
			end			
		end	
	end
end


function CreateMenuItem(tCollectInfo, nIndex)	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local objLayout = objFactory:CreateUIObject("ItemLayout_"..tostring(nIndex), "TextureObject")
	local objImage = objFactory:CreateUIObject("ItemImage_"..tostring(nIndex), "ImageObject")
	local objText = objFactory:CreateUIObject("ItemText_"..tostring(nIndex), "TextObject")
	local objURL = objFactory:CreateUIObject("ItemURL_"..tostring(nIndex), "TextObject")
	local objFilePath = objFactory:CreateUIObject("ItemFilePath_"..tostring(nIndex), "TextObject")
	
	objLayout:AddChild(objImage)
	objLayout:AddChild(objText)
	objLayout:AddChild(objURL)
	objLayout:AddChild(objFilePath)
	
	objImage:SetObjPos(5, "(father.height-16)/2", 21, "(father.height-16)/2+16")
	objText:SetObjPos(3+21, 0, "father.width", "father.height")
	objURL:SetObjPos(0, 0, 0, 0)
	objFilePath:SetObjPos(0, 0, 0, 0)
	
	-- objLayout:SetCursorID("IDC_HAND")
	
	objText:SetTextColorResID("color.menubar.text")
	objText:SetTextFontResID("font.menubar.text")
	objText:SetVAlign("center")
	objText:SetHAlign("left")
	objText:SetEndEllipsis(true)
	
	objImage:SetDrawMode(1)
	objImage:SetAntialias(2)
	
	objText:SetText(tCollectInfo["strLocationName"])
	objURL:SetText(tCollectInfo["strURL"])
	objFilePath:SetText(tCollectInfo["strFilePath"])
	SetIcoImage(objImage, tCollectInfo)
	
	objLayout:AttachListener("OnLButtonUp", false, OnLButtonUpItem)
	objLayout:AttachListener("OnLButtonDown", false, OnLButtonDownItem)
	objLayout:AttachListener("OnMouseEnter", false, OnMouseEnterItem)
	objLayout:AttachListener("OnMouseLeave", false, OnMouseLeaveItem)
	objLayout:AttachListener("OnRButtonUp", false, OnRButtonUpItem)
	
	return objLayout
end

function SetIcoImage(objImage, tCollectInfo)
	local strIcoName = tCollectInfo["strIcoName"]
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objImage:SetResID(strDefaultImgID)
	
	local objBitmap, nRet = tFunHelper.GetIcoBitmapObj(strIcoName)
	if nRet == -2 then
		tFunHelper.DownLoadIco(tCollectInfo["strURL"], function() end)
		return
	end	
	
	if objBitmap and objImage then
		objImage:SetBitmap(objBitmap)
	end
end


--nIndex 从1 开始
function SetMenuItemPos(objRootCtrl, objMenuItem, nIndex)
	local attr = objRootCtrl:GetAttribute()
	local nMaxWidth = attr.ItemWidth
	local nSpan = attr.RightSpan
	local nWidth = GetSuitWidth(objMenuItem, nMaxWidth)
	
	local nLastR = GetAddBtnWidth(objRootCtrl) - nSpan  ---最左侧是添加按钮
	local nLastObjIndex = nIndex-2
	if nLastObjIndex >= 0 then   --取上一个控件的right
		local objContainer = objRootCtrl:GetControlObject("CollectList.Container") 
		local objLastItem = objContainer:GetChildByIndex(nLastObjIndex)
		local nL, _, nR, _ = objLastItem:GetObjPos()
		nLastR = nR
	end
	
	local nL = nLastR+nSpan
	local nR = nL + nWidth

	objMenuItem:SetObjPos(nL, 0, nR, "father.height")
	
	local nRootL, _, nRootR, _ = objRootCtrl:GetObjPos()
	local nRootWidth = nRootR - nRootL
	
	if nR > nRootWidth-7 then
		if g_nLastItemRight == 0 then
			g_nLastItemRight = nLastR
		end
		
		objMenuItem:SetVisible(false)
		objMenuItem:SetChildrenVisible(false)
		PushHideMenuItem(objRootCtrl, objMenuItem)
	end
end


function GetAddBtnWidth(objRootCtrl)  
	local objAddBtn = objRootCtrl:GetControlObject("CollectList.AddBtn")
	local l, t, r, b = objAddBtn:GetObjPos()
	return r-l
end


function GetSuitWidth(objMenuItem, nMaxWidth)
	local objImage = objMenuItem:GetChildByIndex(0)
	local objText = objMenuItem:GetChildByIndex(1)

	local nImgL, nImgT, nImgR, nImgB = objImage:GetObjPos()
	local nTextWidth, _ = objText:GetTextExtent()
	
	local nSuitWidth = nImgR+nTextWidth+5
	if nSuitWidth > nMaxWidth then
		nSuitWidth = nMaxWidth
	end
	
	return nSuitWidth
end


function DestroyOldList(objRootCtrl)
	local objContainer = objRootCtrl:GetControlObject("CollectList.Container")
	if not objContainer then
		return false
	end 
	
	objContainer:RemoveAllChild()
end


function PushHideMenuItem(objRootCtrl, objMenuItem)
	local tHideMenuList = objRootCtrl:GetHideMenuList()
	table.insert(tHideMenuList, objMenuItem)
end

function ClearHideMenuItem(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	attr.tHideMenuList = {}
end


function TryShowArrowBtn(objRootCtrl)
	local tHideMenuList = objRootCtrl:GetHideMenuList()
	local objArrowBtn = objRootCtrl:GetControlObject("CollectList.ArrowBtn")
	
	if not objArrowBtn then
		return
	end
	
	-- local nArrowL, nArrowT, nArrowR, nArrowB = objArrowBtn:GetObjPos() 
	-- local nArrowW = nArrowR - nArrowL
	-- local nNewLeft = g_nLastItemRight+10
	
	-- objArrowBtn:SetObjPos(nNewLeft, nArrowT, nNewLeft+nArrowW, nArrowB)

	if type(tHideMenuList) ~= "table" or #tHideMenuList<1 then		
		objArrowBtn:SetVisible(false)
		objArrowBtn:SetChildrenVisible(false)
	else
		objArrowBtn:SetVisible(true)
		objArrowBtn:SetChildrenVisible(true)
	end
end



------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end