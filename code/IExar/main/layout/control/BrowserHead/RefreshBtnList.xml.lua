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


function UnBindLastBrowser(objRootCtrl)
	local objCurrentBrowser = GetCurrentBrowser(objRootCtrl)
	if not objCurrentBrowser then
		return
	end

	local attr = objRootCtrl:GetAttribute()
	-- objCurrentBrowser:RemoveListener("OnCommandStateChange", attr.hEvntListener)
end


function SetBtnListStyle(objRootCtrl, objWebTabCtrl)
	local objCompatBtn = objRootCtrl:GetControlObject("RefreshBtnList.CompatBtn")
	local objRefresh = objRootCtrl:GetControlObject("RefreshBtnList.RefreshBtn")
	local objStop = objRootCtrl:GetControlObject("RefreshBtnList.StopBtn")
	
	objRefresh:Enable(true)
	objStop:Enable(true)
	objCompatBtn:Enable(true)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end