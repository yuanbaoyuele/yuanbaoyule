local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-----方法----


-----事件----
function OnClickHideBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	local nBtnL, nBtnT, nBtnR, nBtnB = self:GetObjPos()
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()
	
	local nBtnW = nBtnR-nBtnL+10
	local nRootW = nRootR-nRootL
	local nNewLeft = nRootW-nBtnW
	
	objRootLayout:SetObjPos(nNewLeft, 0, "father.width", "father.height")
	SetHideBtnStyle(objRootCtrl, false)
end


function OnClickShowBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	objRootLayout:SetObjPos(0, 0, "father.width", "father.height")
	
	SetHideBtnStyle(objRootCtrl, true)
end


function OnClickFile(self)
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(self, "FileMenu")
	tFunHelper.CreateAndShowMenu(self, "FileMenu")
end


function OnClickLookup(self)
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(self, "LookupMenu")
	tFunHelper.CreateAndShowMenu(self, "LookupMenu")
end


function OnClickCollect(self)
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(self, "CollectMenu")
	tFunHelper.CreateAndShowMenu(self, "CollectMenu")
end


function OnClickTool(self)
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(self, "ToolMenu")
	tFunHelper.CreateAndShowMenu(self, "ToolMenu")
end


function OnClickHelp(self)
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(self, "HelpMenu")
	tFunHelper.CreateAndShowMenu(self, "HelpMenu")
end

----

function InitMenuHelper()
	local objActiveTab = tFunHelper.GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		return
	end
	
	local objBrowserCtrl = objActiveTab:GetBindBrowserCtrl()
	if objBrowserCtrl then
		local objUEBrowser = objBrowserCtrl:GetControlObject("browser")
		tIEMenuHelper:Init(objUEBrowser)
	end
end


function SetHideBtnStyle(objRootCtrl, bHideBtnVsbl)
	local objHideBtn = objRootCtrl:GetControlObject("MenuBarCtrl.HideBtn")
	local objShowBtn = objRootCtrl:GetControlObject("MenuBarCtrl.ShowBtn")
	local bShowBtnVsbl = not bHideBtnVsbl
	
	objHideBtn:SetVisible(bHideBtnVsbl)
	objHideBtn:SetChildrenVisible(bHideBtnVsbl)
	objShowBtn:SetVisible(bShowBtnVsbl)
	objShowBtn:SetChildrenVisible(bShowBtnVsbl)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end