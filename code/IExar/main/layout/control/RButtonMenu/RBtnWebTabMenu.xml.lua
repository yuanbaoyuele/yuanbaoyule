local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnInit_CloseTab(self)
	local objTabContainer = tFunHelper.GetMainCtrlChildObj("MainPanel.TabContainer")
	if not objTabContainer then
		return
	end
	
	local nShowNum = objTabContainer:GetTotalShowTabNum()
	if nShowNum == 1 then
		self:SetEnable(0)
	end	
end


function OnSelect_CloseTab(self)
	local objWebTab = GetBindWebTab(self)
	if objWebTab then
		objWebTab:CloseTab()
	end
end


function OnSelect_CloseTabGroup(self)
	
end


function OnSelect_CloseOtherTab(self)
	
end


function OnSelect_CancleGroup(self)

end


function OnSelect_Refresh(self)
	local objWebTab = GetBindWebTab(self)
	if not objWebTab then
		return
	end
	
	local objBrowser = objWebTab:GetBindBrowserCtrl()
	if objBrowser then
		objBrowser:Refresh()
	end
end



function OnSelect_RefreshAll(self)
	
end


function OnSelect_NewTab(self)
	local strHomePage = tFunHelper.GetDfltNewTabURL()
	tFunHelper.OpenURLInNewTab(strHomePage)
end


function OnSelect_CopyTab(self)
	local strURL = tFunHelper.GetCurrentURL()
	tFunHelper.OpenURLInNewTab(strURL)
end


function GetBindWebTab(objMenuItem)
	local objTree = objMenuItem:GetOwner()
	local objMainLayout = objTree:GetUIObject("Menu.MainLayout")
	local objNormalCtrl = objMainLayout:GetObject("Menu.Context")

	local objWebTab = objNormalCtrl:GetRelateObject()
	return objWebTab
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end
