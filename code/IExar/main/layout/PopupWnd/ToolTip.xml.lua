function SetToolTipText(self, strText)
	local objText = self:GetControlObject("ToolTipText")
	objText:SetText(strText)	
	objText:SetHAlign("center")
	objText:SetVAlign("top")
	
	AdjustTextPos(self)
end


function GetToolTipWidth(self)
	local objRootCtrl = self
	local nRootLeft, nRootTop, nRootRight, nRootBottom = objRootCtrl:GetObjPos()
	return nRootRight - nRootLeft
end

function AdjustTextPos(self)
	local objRootCtrl = self
	local objText = objRootCtrl:GetControlObject("ToolTipText")
	local nSuitWidth, nSuitHeight = objText:GetTextExtent()

	local nRootLeft, nRootTop, nRootRight, nRootBottom = objRootCtrl:GetObjPos()
	local nRootWidth = nRootRight - nRootLeft
	local nRootHeight = nRootBottom - nRootTop
	
	objRootCtrl:SetObjPos(nRootLeft, nRootTop, nRootLeft + nSuitWidth+8, nRootTop+nSuitHeight+5)
end



function OnMouseEnter_Root(self)
	local objTree = self:GetOwner()
	local objMainWnd = objTree:GetBindHostWnd()
	objMainWnd:SetVisible(false)
end