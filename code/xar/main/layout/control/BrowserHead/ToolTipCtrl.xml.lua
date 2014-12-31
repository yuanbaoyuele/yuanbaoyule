local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-----方法----
function SetToolTipText(self, strText)
	local objText = self:GetControlObject("ToolTipCtrl.Text")
	objText:SetText(strText)
	AdjustTextPos(self)
end

function ShowToolTip(self, bShow)
	if bShow then
		self:SetVisible(true)
		self:SetChildrenVisible(true)
		StartTimerToHide(self)
	else
		self:SetVisible(false)
		self:SetChildrenVisible(false)
	end
end


-----事件----
function OnInitControl(self)
	self:ShowToolTip(false)
end


function OnClickCloseBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:ShowToolTip(false)
end

----
function AdjustTextPos(self)
	local objRootCtrl = self
	local objText = objRootCtrl:GetControlObject("ToolTipCtrl.Text")
	local nSuitWidth, nSuitHeight = objText:GetTextExtent()

	local nRootLeft, nRootTop, nRootRight, nRootBottom = objRootCtrl:GetObjPos()
	local nRootWidth = nRootRight - nRootLeft
	local nRootHeight = nRootBottom - nRootTop
	
	objRootCtrl:SetObjPos(nRootRight- nSuitWidth - 50, nRootTop,  nRootRight , nRootBottom)
end


function StartTimerToHide(objRootCtrl)
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetOnceTimer(function(item, id)
			objRootCtrl:ShowToolTip(false)
		end, 3000)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end