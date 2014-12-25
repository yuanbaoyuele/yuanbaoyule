local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnSelect_Stop(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	if objTabCtrl == nil or objTabCtrl == 0 then
		return
	end
	
	local objCurBrowser = objTabCtrl:GetBindBrowserCtrl()
	if objCurBrowser then
		objCurBrowser:Stop()
	end	
end

function OnSelect_Refresh(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	if objTabCtrl == nil or objTabCtrl == 0 then
		return
	end
	
	local objCurBrowser = objTabCtrl:GetBindBrowserCtrl()
	if objCurBrowser then
		objCurBrowser:Refresh()
	end	
end


function OnSelect_Zoom(self)
	
end


function OnSelect_SourceCode(self)
	
end


function OnSelect_FullScreen(self)
	tFunHelper.FullScreen()
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


