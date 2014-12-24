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
	end		
end

function OnClickGoForwardBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if objCurrentBrowser then
		objCurrentBrowser:GoForward()
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
	if objWebTabCtrl then
		return objWebTabCtrl:GetBindBrowserCtrl()
	end
end


function UnBindLastBrowser(objRootCtrl)
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if not objCurrentBrowser then
		return
	end

	local attr = objRootCtrl:GetAttribute()
	objCurrentBrowser:RemoveListener("Fire_OnCommandStateChange", attr.hEvntListener)
end


function SetBtnListStyle(objRootCtrl, objWebTabCtrl)
	local objGoBack = objRootCtrl:GetControlObject("NavgateBtnList.GobackBtn")
	local objGoForward = objRootCtrl:GetControlObject("NavgateBtnList.GoForwardBtn")
	local objRefresh = objRootCtrl:GetControlObject("NavgateBtnList.RefreshBtn")
	local objStop = objRootCtrl:GetControlObject("NavgateBtnList.StopBtn")
	
	if tonumber(objWebTabCtrl) ~= nil and objWebTabCtrl == 0 then
		objGoBack:Enable(false)
		objGoForward:Enable(false)
		objRefresh:Enable(false)
		objStop:Enable(false)
		return
	end

	if not objWebTabCtrl then
		return 
	end
	
	objRefresh:Enable(true)
	
	local bState = objWebTabCtrl:GetGoBackState()
	objGoBack:Enable(bState)
	
	local bState = objWebTabCtrl:GetGoForwardState()
	objGoForward:Enable(bState)
	
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if not objCurrentBrowser then
		return
	end
	
	local attr = objRootCtrl:GetAttribute()
	--后退与前进
	attr.hEvntListener = objCurrentBrowser:AttachListener("Fire_OnCommandStateChange", false, 
		function (objBrowser, strEventName, strCommand, bEnable)
			if strCommand == "navigateback" then
				objGoBack:Enable(bEnable)
				objWebTabCtrl:SetGoBackState(bEnable)
			elseif strCommand == "navigateforward" then
				objGoForward:Enable(bEnable)
				objWebTabCtrl:SetGoForwardState(bEnable)
			end
		end)	
		
	--停止
	objStop:Enable(true)
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
			if objCurrentBrowser:GetBusy() then
				objStop:Enable(true)
			else
				objStop:Enable(false)
				item:KillTimer(id)	
			end
			
		end, 500)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end