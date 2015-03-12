function SetText(self, strText, bSlide)
	local objText = self:GetControlObject("ShortCutText.Text")
	objText:SetText(strText)	
	objText:SetVAlign("center")	
	objText:SetHAlign("center")	
end

function GetText(self)
	local objText = self:GetControlObject("ShortCutText.Text")
	return objText:GetText()
end


function IsTextOverFlow(self)
	local objText = self:GetControlObject("ShortCutText.Text")
	local objLayout = self:GetControlObject("ShortCutText.Layout")
	local nLeft, nTop, nRight, nBottom = objLayout:GetObjPos()
	local nWidth = nRight - nLeft
	local nSuitWidth = objText:GetTextExtent()
	
	if nWidth < nSuitWidth then
		return true
	else
		return false
	end
end


function SlideText(self)
	local objText = self:GetControlObject("ShortCutText.Text")
	local objLayout = self:GetControlObject("ShortCutText.Layout")
	local timeMgr = XLGetObject("Xunlei.UIEngine.TimerManager")
	local attr = self:GetAttribute()
	local nTimeSpan = tonumber(attr.timespanms)
	local nTextLeft, nTextTop, nTextRight, nTextBottom = objText:GetObjPos()
	local nLayoutLeft, nLayoutTop, nLayoutRight, nLayoutBottom = objLayout:GetObjPos()
	local nTextWidth = nTextRight - nTextLeft
	local nLayoutWidth = nLayoutRight - nLayoutLeft
	
	local nDiff = 5
	local nShowLeft = nTextLeft
	timeMgr:SetTimer(function(Itm, id)
		objText:SetObjPos(nShowLeft, nTextTop, nShowLeft+nTextWidth, nTextBottom)
		nShowLeft = nShowLeft - nDiff
		
		if nShowLeft+nTextWidth <= nLayoutWidth-15 then
			nShowLeft = nTextLeft
		end
	end, nTimeSpan)
end


function OnInitControl(self)
	SetMainTextAttr(self)
	SetKeyTextAttr(self)
	SetKeyLayoutPos(self)
	SetAlignStyle(self)
end


function SetTextFontResID(self, strFontID)
	if not IsRealString(strFontID) then
		return
	end
	local objRootCtrl = self
	local attr = objRootCtrl:GetAttribute()
	attr.Font = strFontID
	
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")	
	objText:SetTextFontResID(attr.Font)
	
	local lefttext = objRootCtrl:GetControlObject("lefttext")
	local righttext = objRootCtrl:GetControlObject("righttext")
	lefttext:SetTextFontResID(attr.Font)
	righttext:SetTextFontResID(attr.Font)
end


function SetTextColorResID(self, strColorID)
	if not IsRealString(strColorID) then
		return
	end
	local objRootCtrl = self
	local attr = objRootCtrl:GetAttribute()
	attr.Textcolor = strColorID
	
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")	
	objText:SetTextColorResID(attr.Textcolor)
	
	local lefttext = objRootCtrl:GetControlObject("lefttext")
	local righttext = objRootCtrl:GetControlObject("righttext")
	local keytext = objRootCtrl:GetControlObject("keytext")
	lefttext:SetTextColorResID(attr.Textcolor)
	righttext:SetTextColorResID(attr.Textcolor)
	keytext:SetTextColorResID(attr.Textcolor)
end


function SetText(self, strText)
	local objRootCtrl = self
	local attr = objRootCtrl:GetAttribute()
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")
	
	objText:SetText(strText)
	SetKeyLayoutPos(objRootCtrl)
end


function SetShortCutKey(self, strKey)
	local objRootCtrl = self
	local keytext = objRootCtrl:GetControlObject("keytext")
	local attr = objRootCtrl:GetAttribute()
	attr.Key = strKey
	
	SetKeyTextAttr(objRootCtrl)
	SetKeyLayoutPos(objRootCtrl)
end


function SetKeyFont(self, strKeyFont)
	if not IsRealString(strKeyFont) then
		return
	end
	
	local objRootCtrl = self
	local attr = objRootCtrl:GetAttribute()
	local keytext = objRootCtrl:GetControlObject("keytext")
	attr.KeyFont = strKeyFont
	keytext:SetTextFontResID(attr.KeyFont)
end


function SetMainTextAttr(objRootCtrl)
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")
	local attr = objRootCtrl:GetAttribute()
	
	objText:SetEndEllipsis(attr.Endellipsis)
	objText:SetText(attr.Text)
	objText:SetTextColorResID(attr.Textcolor)
	objText:SetTextFontResID(attr.Font)
end


function SetKeyTextAttr(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	local objKeyLayout = objRootCtrl:GetControlObject("ShortCutText.Key")
	if not IsRealString(attr.Key) then
		objKeyLayout:SetVisible(false)
		objKeyLayout:SetChildrenVisible(false)
		return
	else
		objKeyLayout:SetVisible(true)
		objKeyLayout:SetChildrenVisible(true)
	end
	
	local lefttext = objRootCtrl:GetControlObject("lefttext")
	local keytext = objRootCtrl:GetControlObject("keytext")
	local righttext = objRootCtrl:GetControlObject("righttext")
	
	lefttext:SetTextColorResID(attr.Textcolor)
	lefttext:SetTextFontResID(attr.Font)
	righttext:SetTextColorResID(attr.Textcolor)
	righttext:SetTextFontResID(attr.Font)
	
	keytext:SetText(attr.Key)
	keytext:SetTextColorResID(attr.Textcolor)
	keytext:SetTextFontResID(attr.KeyFont)
end


function SetKeyLayoutPos(objRootCtrl)
	local objMainLayout = objRootCtrl:GetControlObject("ShortCutText.Layout")
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")
	local objKeyLayout = objRootCtrl:GetControlObject("ShortCutText.Key")
	
	local nSuitWidth = objText:GetTextExtent()
	local nTextL, nTextT, nTextR, nTextB = objText:GetObjPos()
	local nNewTextR = nTextL+nSuitWidth
	
	local nRootL, nRootT, nRootR, nRootB = objMainLayout:GetObjPos()
	objText:SetObjPos(nTextL, nTextT, nNewTextR, nRootB)

	local nKeyL, nKeyT, nKeyR, nKeyB = objKeyLayout:GetObjPos()
	local nKeyWidth = nKeyR - nKeyL
	local nNewKeyL = nNewTextR
	objKeyLayout:SetObjPos(nNewKeyL, nKeyT, nNewKeyL+nKeyWidth, nRootB)
end


function SetHAlign(self, strStyle)	
	local objRootCtrl = self
	local objLayout = objRootCtrl:GetControlObject("ShortCutText.Layout")
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()
	local nRootW = nRootR-nRootL
	
	local objText = objRootCtrl:GetControlObject("ShortCutText.Text")
	local objKeyLayout = objRootCtrl:GetControlObject("ShortCutText.Key")
	
	local nTextL, nTextT, nTextR, nTextB = objText:GetObjPos()
	local nKeyL, nKeyT, nKeyR, nKeyB = objKeyLayout:GetObjPos()
	local nTextW = nTextR-nTextL
	local nKeyW = nKeyR-nKeyL
	local nTotalW = nTextW+nKeyW
	local nNewRootL = 0
	
	if tostring(strStyle) == "center" then
		nNewRootL = (nRootW-nTotalW)/2
	elseif tostring(strStyle) == "left" then
		nNewRootL = 0
	elseif tostring(strStyle) == "right" then 
		nNewRootL = nRootW-nTotalW
	end
	
	objLayout:SetObjPos(nNewRootL, 0, nNewRootL+nTotalW, "father.height")
end


function SetAlignStyle(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	local strHalign = attr.Halign
	
	if IsRealString(strHalign) then
		SetHAlign(objRootCtrl, strHalign)
	end
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end
