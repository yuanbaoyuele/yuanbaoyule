local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-----方法----
function SetCurrentWebTab(self, objWebTabCtrl)
	UnBindLastBrowser(self)

	local attr = self:GetAttribute()
	attr.objCurrentWebTab = objWebTabCtrl
	
	SetBtnListStyle(self, objWebTabCtrl)
end

-----事件----
function OnClickGobackBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if objCurrentBrowser then
		objCurrentBrowser:GoBack()
		AddCurURLIndex(objRootCtrl,1)
	end		
end

function OnClickGoForwardBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if objCurrentBrowser then
		objCurrentBrowser:GoForward()
		AddCurURLIndex(objRootCtrl,-1)
	end	
end

function OnClickStopBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if objCurrentBrowser then
		objCurrentBrowser:Stop()
	end	
end

function OnClickRefreshBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if objCurrentBrowser then
		objCurrentBrowser:Refresh()
	end	
end

----
function GetCurrentBrowser(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	local objWebTabCtrl = attr.objCurrentWebTab
	if objWebTabCtrl and objWebTabCtrl ~= 0 then
		return objWebTabCtrl:GetBindBrowserCtrl()
	end
end

function AddCurURLIndex(objRootCtrl, nDiff)
	local attr = objRootCtrl:GetAttribute()
	local objWebTabCtrl = attr.objCurrentWebTab
	if objWebTabCtrl and objWebTabCtrl ~= 0 then
		objWebTabCtrl:AddCurURLIndex(nDiff)
	end
end



function UnBindLastBrowser(objRootCtrl)
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if not objCurrentBrowser then
		return
	end

	local attr = objRootCtrl:GetAttribute()
	objCurrentBrowser:RemoveListener("OnCommandStateChange", attr.hEvntListener)
end


function SetBtnListStyle(objRootCtrl, objWebTabCtrl)
	local objGoBack = objRootCtrl:GetControlObject("NavgateBtnList.GobackBtn")
	local objGoForward = objRootCtrl:GetControlObject("NavgateBtnList.GoForwardBtn")
	
	if tonumber(objWebTabCtrl) ~= nil and objWebTabCtrl == 0 then
		objGoBack:Enable(false)
		objGoForward:Enable(false)
		return
	end

	if not objWebTabCtrl then
		return 
	end
	
	local bBackState = objWebTabCtrl:GetGoBackState()
	objGoBack:Enable(bBackState)
	
	local bFowdState = objWebTabCtrl:GetGoForwardState()
	objGoForward:Enable(bFowdState)
	
	SetDropArrowActive(objRootCtrl, bBackState or bFowdState)
	
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if not objCurrentBrowser then
		return
	end
	
	local attr = objRootCtrl:GetAttribute()
	--后退与前进
	attr.hEvntListener = objCurrentBrowser:AttachListener("OnCommandStateChange", false, 
		function (objBrowser, strEventName, strCommand, bEnable)
			if strCommand == "navigateback" then
				objGoBack:Enable(bEnable)
				objWebTabCtrl:SetGoBackState(bEnable)
			elseif strCommand == "navigateforward" then
				objGoForward:Enable(bEnable)
				objWebTabCtrl:SetGoForwardState(bEnable)
			end
			
			if bEnable then
				SetDropArrowActive(objRootCtrl, true)
			end
		end)	
end


function OnClickDropArrow(self)
	local objRootCtrl = self:GetOwnerControl()
	local objBkg = objRootCtrl:GetControlObject("NavgateBtnList.Bkg")

	local nTopSpan = 30
	tFunHelper.TryDestroyOldMenu(objBkg, "BrowserHistoryMenu")
	tFunHelper.CreateAndShowMenu(objBkg, "BrowserHistoryMenu", nTopSpan)
end


------辅助函数---
function SetDropArrowActive(objRootCtrl, bActive)
	local objArrowBkg = objRootCtrl:GetControlObject("DropArrow.Bkg")
	local objArrowDisable = objArrowBkg:GetObject("DropArrow.Disable")
	objArrowBkg:SetEnable(bActive)
	objArrowDisable:SetVisible(not bActive)
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end

