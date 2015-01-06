local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


---方法---
function ProcessTabChange(self, objTabCtrl)
	ProecssAddressBar(self, objTabCtrl)
	ProecssNavgateBtnList(self, objTabCtrl)
end


----事件--
function OnClickCpationClose(self)
	tFunHelper.ReportAndExit()	
end

function OnClickCpationMin(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if objHostWnd then
		objHostWnd:Min()
	end
end


function OnClickCpationMax(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if not objHostWnd then
		return
	end

	objHostWnd:Max()
	
	local objRootCtrl = self:GetOwnerControl()
	SetMaxBtnStyle(objRootCtrl, false)
	tFunHelper.SetResizeEnable(false)
end


function OnClickCpationRestore(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if not objHostWnd then
		return
	end

	objHostWnd:Restore()
	
	local objRootCtrl = self:GetOwnerControl()
	SetMaxBtnStyle(objRootCtrl, true)
	tFunHelper.SetResizeEnable(true)
end


function OnClickLogo(self)
	tFunHelper.ShowPopupWndByName("TipAboutWnd.Instance", true)
end


function OnPosChange(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if not objHostWnd then
		return
	end
	
	local strState = objHostWnd:GetWindowState()
	if strState == "max" then
		SetMaxBtnStyle(self, false)
		tFunHelper.SetResizeEnable(false)
	else
		SetMaxBtnStyle(self, true)
		tFunHelper.SetResizeEnable(true)
	end
	
	SetToolTipPos(self)
end

--------
function ProecssAddressBar(objRootCtrl, objTabCtrl)
	local objAddressBar = objRootCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if objAddressBar then
		objAddressBar:ProcessTabChange(objTabCtrl)
	end
end

function ProecssNavgateBtnList(objRootCtrl, objTabCtrl)
	local objNavgateBtnList = objRootCtrl:GetControlObject("BrowserHeadCtrl.NavgateBtnList")
	if objNavgateBtnList then
		objNavgateBtnList:SetCurrentWebTab(objTabCtrl)
	end
end


------辅助函数---
function GetHostWndByUIElem(objUIElem)
	local objTree = objUIElem:GetOwner()
	if objTree then
		return objTree:GetBindHostWnd()
	end
end


function SetMaxBtnStyle(objRootCtrl, bShowMax)	
	local objMax = objRootCtrl:GetControlObject("BrowserHeadCtrl.Caption.MaxBtn")
	local objRestore = objRootCtrl:GetControlObject("BrowserHeadCtrl.Caption.Restore")
	local bShowRestore = not bShowMax
	
	objMax:SetVisible(bShowMax)
	objMax:SetChildrenVisible(bShowMax)
	objRestore:SetVisible(bShowRestore)
	objRestore:SetChildrenVisible(bShowRestore)
end


function SetToolTipPos(objRootCtrl)
	local objToolTip = objRootCtrl:GetControlObject("BrowserHeadCtrl.ToolTipCtrl")
	local nTipL, nTipT, nTipR, nTipB = objToolTip:GetObjPos()
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()

	local nTooltipW = nTipR-nTipL
	objToolTip:SetObjPos(nRootR-nTooltipW, nTipT, nRootR, nTipB)
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


