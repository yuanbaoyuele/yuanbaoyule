local tipUtil = XLGetObject("API.Util")
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

function OnInitControl(self)
	
end

function Show(self)
	RemoveAllItem(self)
	UpdateItemList(self)
end


function OnFocusChange(self, bFocus)
	if not bFocus then
		HideControl(self)
	end
end


function OnClickThumb(self)
	SetActiveTab(self)
	
	local objRootCtrl = self:GetOwnerControl()
	HideControl(objRootCtrl)
end


function OnClickClose(self)
	local objThumbItem = self:GetOwnerControl()
	local attr = objThumbItem:GetAttribute()
	local objWebTab = attr.objWebTab
	
	if not objWebTab then
		return
	end
	
	objWebTab:CloseTab()
	
	local objRootCtrl = objThumbItem:GetOwnerControl()
	objRootCtrl:Show()
end


function OnMouseEnterItem(self)
	self:SetCursorID("IDC_HAND")
	local objRootCtrl = self
	local objBkg = objRootCtrl:GetControlObject("Item.Bkg")
	objBkg:SetVisible(true)
end

function OnMouseLeaveItem(self)
	local objRootCtrl = self
	local objBkg = objRootCtrl:GetControlObject("Item.Bkg")
	objBkg:SetVisible(false)
end


function RemoveAllItem(self)
	local objRootCtrl = self
	local objContainer = objRootCtrl:GetControlObject("Layout.Container")
	if not objContainer then
		return false
	end

	objContainer:RemoveAllChild()
end


function UpdateItemList(objRootCtrl)
	local objContainer = objRootCtrl:GetControlObject("Layout.Container")
	if not objContainer then
		return false
	end
	
	local objTabCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	if not objTabCtrl then
		return
	end
	local tTabList = objTabCtrl:GetTotalShowTabList()
			
	for nIndex, objWebTab in ipairs(tTabList) do
		if objWebTab then
			local objItem = CreateItem(objWebTab, nIndex)	
			if objItem then
				objContainer:AddChild(objItem)
				SetItemPos(objRootCtrl, objItem, nIndex)
			end			
		end	
	end
end
----------------------
function CreateItem(objWebTab, nIndex)	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local objItem = objFactory:CreateUIObject("Item_"..tostring(nIndex), "ie.thumb.item")
	if not objItem then
		return nil
	end
	
	local hBitmap = objWebTab:GetWindowBitmap()
	if hBitmap then
		local objBitmap = objItem:GetControlObject("Item.BrowserImg")
		objBitmap:SetBitmap(hBitmap)
	end	
		
	local strTitle = objWebTab:GetTabText() or ""
	local objText = objItem:GetControlObject("Item.BrowserText")
	objText:SetText(strTitle)
		
	local attr = objItem:GetAttribute()
	attr.objWebTab = objWebTab
		
	return objItem
end


function SetItemPos(objRootCtrl, objItem, nIndex)
	local nItemLeft, nItemWidth, nItemHeight, nItemSpanW = GetItemPosInfo(objRootCtrl)
	local nItemTop = 10
	local nLine = math.ceil(nIndex/3)
	local nCol = math.mod(nIndex, 3)
	if nCol == 0 then
		nCol = 3
	end
	
	local nLeft = nItemLeft+(nCol-1)*(nItemWidth+nItemSpanW)
	local nTop = nItemTop+(nLine-1)*nItemHeight
	
	objItem:SetObjPos(nLeft, nTop, nLeft+nItemWidth, nTop+nItemHeight)
end


function GetItemPosInfo(objRootCtrl)
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()
	local nRootW = nRootR - nRootL
	local nRootH = nRootB - nRootT

	local nItemLeft = math.floor(nRootW/30)
	local nItemWidth = math.floor(nRootW/3.7)
	local nItemHeight = math.floor(nRootH/2.7)
	local nItemSpanW = math.floor(nRootW/18)
	
	return nItemLeft, nItemWidth, nItemHeight, nItemSpanW
end


function SetActiveTab(objItem)
	local attr = objItem:GetAttribute()
	local objWebTab = attr.objWebTab
	if not objWebTab then
		return
	end
	
	local nWebTabID = objWebTab:GetSelfID()
	local objTabContainer = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	if not objTabContainer then
		return
	end
	objTabContainer:SetActiveTab(nWebTabID)
end


function HideControl(objRootCtrl)
	objRootCtrl:SetVisible(false)
	objRootCtrl:SetChildrenVisible(false)
	
	local webbrowser = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	webbrowser:SetVisible(true)
	webbrowser:SetChildrenVisible(true)
end


