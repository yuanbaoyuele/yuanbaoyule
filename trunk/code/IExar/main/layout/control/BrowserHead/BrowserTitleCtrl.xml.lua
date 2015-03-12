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
	
	objTitle:SetText(strText)
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


