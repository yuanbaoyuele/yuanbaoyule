local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


---方法---
function ProcessTabChange(self, objTabCtrl)
	UpdateTitle(self, objTabCtrl)
end


function SetMaxBtnStyle(objRootCtrl, bShowMax)	
	local objMax = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.MaxBtn")
	local objRestore = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.Restore")
	local bShowRestore = not bShowMax
	
	objMax:SetVisible(bShowMax)
	objMax:SetChildrenVisible(bShowMax)
	objRestore:SetVisible(bShowRestore)
	objRestore:SetChildrenVisible(bShowRestore)
end


function SetTitleText(objRootCtrl, strText)	
	local objTitle = objRootCtrl:GetControlObject("BrowserTitleCtrl.Title")
	if not objTitle then
		return
	end
	
	strText = strText.." - Windows Internet Explorer"
	objTitle:SetText(strText)
end


function SetFocusStyle(self, bFocus)
	local objRootCtrl = self

	local objMax = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.MaxBtn")
	local objMin = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.MinBtn")
	local objClose = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.CloseBtn")
	local objRestore = objRootCtrl:GetControlObject("BrowserTitleCtrl.Caption.Restore")
	
	local bDisable = not bFocus
	SetBtnStyleDisable(objMax, bDisable)
	SetBtnStyleDisable(objMin, bDisable)
	SetBtnStyleDisable(objClose, bDisable)
	SetBtnStyleDisable(objRestore, bDisable)
end


----事件--
function OnClickCpationClose(self)
	local tLocalUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local objTabContainer = tFunHelper.GetHeadCtrlChildObj("MainPanel.TabContainer")
	local nCurrentNum = objTabContainer:GetTotalShowTabNum()
	if tLocalUserConfig["bCheckCloseAllTab"] or nCurrentNum <= 1 then
		tFunHelper.ReportAndExit()
	else
		tFunHelper.ShowModalDialog("TipCloseAllTabWnd", "TipCloseAllTabWndInstance", "TipCloseAllTabWndTree", "TipCloseAllTabWndInstance")
	end
end

function OnDbClickLogo(self)
	tFunHelper.ReportAndExit()
end


function OnClickCpationMin(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if objHostWnd then
		objHostWnd:Min()
	end
end


function OnClickCpationMax(self)
	tFunHelper.SetWindowMax()
end


function OnClickCpationRestore(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if objHostWnd then
		objHostWnd:Restore()
	end
	
	local objRootCtrl = self:GetOwnerControl()
	SetMaxBtnStyle(objRootCtrl, true)
	tFunHelper.SetResizeEnable(true)
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
		
		if not tFunHelper.IsUACOS() then
			tFunHelper.EnableCaptionDrag(false)
		end		
	else
		SetMaxBtnStyle(self, true)
		tFunHelper.SetResizeEnable(true)
		
		if not tFunHelper.IsBrowserFullScrn() then
			tFunHelper.EnableCaptionDrag(true)
		end
	end
end

--------
function UpdateTitle(objRootCtrl, objTabCtrl)
	if not objTabCtrl or objTabCtrl == 0 then
		return
	end

	local strTabTitle = objTabCtrl:GetTabText()
	if not IsRealString(strTabTitle) then
		return
	end
	
	objRootCtrl:SetTitleText(strTabTitle)
end



function SetBtnStyleDisable(objBtn, bDisable)
	local attr = objBtn:GetAttribute()

	if bDisable then
		attr.NormalBkgID = attr.DisableBkgID
	else
		attr.NormalBkgID = attr.ExtraBkgID
	end	
	
	objBtn:Updata()
end

------辅助函数---
function GetHostWndByUIElem(objUIElem)
	local objTree = objUIElem:GetOwner()
	if objTree then
		return objTree:GetBindHostWnd()
	end
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


