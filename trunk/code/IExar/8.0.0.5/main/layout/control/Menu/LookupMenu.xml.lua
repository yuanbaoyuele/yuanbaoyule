local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_ToolBar(self)
	
end

function OnSelect_FastNavigate(self)
	
end

function OnSelect_Stop(self)
	tIEMenuHelper:ExecuteCMD("StopDownLoad")
end

function OnSelect_Refresh(self)
	tIEMenuHelper:ExecuteCMD("Refresh")
end

function OnSelect_InsertCursor(self)
	
end

function OnSelect_SourceCode(self)
	tIEMenuHelper:ExecuteCMD("ViewSource")
end

function OnSelect_Report(self)
	
end

function OnSelect_UniversalSite(self)
	
end

function OnSelect_PrivacyPolicy(self)
	
end

function OnSelect_FullScreen(self)
	tFunHelper.SetBrowserFullScrn()
end

------工具栏子菜单 ToolBarMenu.xml.lua


-----浏览器栏子菜单
function OnSelect_CollectBox(self)
	local bFix = true
	local nTabIndex = 1
	local bForceShow = true
	tFunHelper.ShowCollectWnd(nTabIndex, bFix, bForceShow)
end

function OnSelect_Source(self)
	local bFix = true
	local nTabIndex = 2
	local bForceShow = true
	tFunHelper.ShowCollectWnd(nTabIndex, bFix, bForceShow)
end

function OnSelect_History(self)
	local bFix = true
	local nTabIndex = 3
	local bForceShow = true
	tFunHelper.ShowCollectWnd(nTabIndex, bFix, bForceShow)
end


-----转到子菜单
function OnInit_Back(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	local bState = objTabCtrl:GetGoBackState()
	
	self:SetEnable(bState)
end


function OnInit_Forward(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	local bState = objTabCtrl:GetGoForwardState()
	self:SetEnable(bState)
end

function OnSelect_Back(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	local objBrowser = objTabCtrl:GetBindBrowserCtrl()
	objBrowser:GoBack()
end

function OnSelect_Forward(self)
	local objTabCtrl = tFunHelper.GetActiveTabCtrl()
	local objBrowser = objTabCtrl:GetBindBrowserCtrl()
	objBrowser:GoForward()
end

function OnSelect_HomePage(self)
	tFunHelper.OpenHomePage(4)	
end


-----缩放子菜单
function OnSelect_Enlage(self)
	local nFactor = tFunHelper.GetZoomFactor()
	local nNewFactor = nFactor+25
	if nNewFactor > 1000 then
		nNewFactor = 1000
	end
	
	tIEMenuHelper:ExecuteCMD("Zoom", nNewFactor)
	tFunHelper.SetZoomFactor(nNewFactor)
end

function OnSelect_Narrow(self)
	local nFactor = tFunHelper.GetZoomFactor()
	local nNewFactor = nFactor-25
	if nNewFactor < 25 then
		nNewFactor = 25
	end
	
	tIEMenuHelper:ExecuteCMD("Zoom", nNewFactor)
	tFunHelper.SetZoomFactor(nNewFactor)
end

function OnSelect_Zoom50(self)
	local nFactor = 50
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom75(self)
	local nFactor = 75
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom100(self)
	local nFactor = 100
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom125(self)
	local nFactor = 125
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom150(self)
	local nFactor = 150
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end

function OnSelect_Zoom200(self)
	local nFactor = 200
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end

function OnSelect_Zoom400(self)
	local nFactor = 400
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end

function OnSelect_Custom(self)
	
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end