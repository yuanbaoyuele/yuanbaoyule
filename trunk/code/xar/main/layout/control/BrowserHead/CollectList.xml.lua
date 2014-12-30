local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-----方法----
function UpdateCollectList(self)
	DestroyOldList(self)
	ShowUserCollect(self)
end

-----事件----
function OnInitControl(self)
	ShowUserCollect(self)
end


---collect item--
function OnLButtonUpItem(self)
	self:SetTextureID("YBYL.Head.Collect.Sel.Normal")
	
	local objURL = self:GetChildByIndex(2)
	if not objURL then
		return
	end
	
	local strURL = objURL:GetText()
	tFunHelper.OpenURL(strURL)
end

function OnLButtonDownItem(self)
	self:SetTextureID("YBYL.Head.Collect.Sel.Hover")
end

function OnMouseEnterItem(self)
	self:SetTextureID("YBYL.Head.Collect.Sel.Normal")
end

function OnMouseLeaveItem(self)
	self:SetTextureID("")
end

----

function ShowUserCollect(objRootCtrl)
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect") or {}
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objContainer = objRootCtrl:GetControlObject("CollectList.Container")
	if not objContainer then
		return false
	end

	local nMaxShowCollect = tUserConfig["nMaxShowCollect"] or 9
	if nMaxShowCollect > #tUserCollect then
		nMaxShowCollect = #tUserCollect
	end
	
	for nIndex=1, nMaxShowCollect do
		local tCollectInfo = tUserCollect[nIndex]
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
	
	objLayout:AddChild(objImage)
	objLayout:AddChild(objText)
	objLayout:AddChild(objURL)
	
	objImage:SetObjPos(5, "(father.height-16)/2", 21, "(father.height-16)/2+16")
	objText:SetObjPos(3+21, 0, "father.width", "father.height")
	objURL:SetObjPos(0, 0, 0, 0)
	
	objLayout:SetCursorID("IDC_HAND")
	
	objText:SetTextColorResID("color.menubar.text")
	objText:SetTextFontResID("font.menubar.text")
	objText:SetVAlign("center")
	objText:SetHAlign("left")
	objText:SetEndEllipsis(true)
	
	objImage:SetDrawMode(1)
	objImage:SetAntialias(2)
	
	objText:SetText(tCollectInfo["strLocationName"])
	objURL:SetText(tCollectInfo["strURL"])
	SetIcoImage(objImage, tCollectInfo)
	
	objLayout:AttachListener("OnLButtonUp", false, OnLButtonUpItem)
	objLayout:AttachListener("OnLButtonDown", false, OnLButtonDownItem)
	objLayout:AttachListener("OnMouseEnter", false, OnMouseEnterItem)
	objLayout:AttachListener("OnMouseLeave", false, OnMouseLeaveItem)
	
	return objLayout
end

function SetIcoImage(objImage, tCollectInfo)
	local strIcoName = tCollectInfo["strIcoName"]
	local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	objImage:SetResID(strDefaultImgID)
	
	local objBitmap = tFunHelper.GetIcoBitmapObj(strIcoName)
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
	
	local nLastR = 0
	local nLastObjIndex = nIndex-2
	if nLastObjIndex >= 0 then   --取上一个空间的right
		local objContainer = objRootCtrl:GetControlObject("CollectList.Container") 
		local objLastItem = objContainer:GetChildByIndex(nLastObjIndex)
		local nL, _, nR, _ = objLastItem:GetObjPos()
		nLastR = nR
	end
	
	local nL = nLastR+nSpan
	local nR = nL + nWidth

	objMenuItem:SetObjPos(nL, 0, nR, "father.height")
	
	local nRootL, _, nRootR, _ = objRootCtrl:GetObjPos()
	if nR > nRootR then
		objMenuItem:SetVisible(false)
		objMenuItem:SetChildrenVisible(false)
	end
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



------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end