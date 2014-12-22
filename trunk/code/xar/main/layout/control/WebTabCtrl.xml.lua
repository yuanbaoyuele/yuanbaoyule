local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-----方法----
function SetTabText(self, strText)
	local objText = self:GetControlObject("WebTabCtrl.Text")
	if objText then
		objText:SetText(tostring(strText))
	end
end


function SetSelfID(self, nID)
	local attr = self:GetAttribute()
	attr.bTabID = tonumber(nID)
end

function GetSelfID(self)
	local attr = self:GetAttribute()
	return attr.bTabID
end


function SetActiveStyle(self, bActive)
	local objActvieBkg = self:GetControlObject("WebTabCtrl.Active.Bkg")
	
	if bActive then
		objActvieBkg:SetTextureID("YBYL.Tab.Active")
		self:SetCursorID("IDC_ARROW")
	else
		objActvieBkg:SetTextureID("")
		self:SetCursorID("IDC_HAND")
	end
		
	ShowMouseEnterBkg(self, false)
	SetActiveState(self, bActive)
end


function BindBrowserCtrl(self, objWebBrowser)
	if not objWebBrowser then
		return
	end

	local attr = self:GetAttribute()
	attr.objBrowserCtrl = objWebBrowser
	
	attr.objBrowserCtrl:AttachListener("Fire_OnNavigateComplete2", false, 
		function (objBrowser, strEventName, strURL)
			SetTabIco(self, strURL)
		end)
	
	attr.objBrowserCtrl:AttachListener("Fire_OnTitleChange", false, 
		function (objBrowser, strEventName, strTitle)
			SetTabTitle(self, strTitle)
		end)
end


function GetBindBrowserCtrl(self, objWebBrowser)
	local attr = self:GetAttribute()	
	return attr.objBrowserCtrl
end


-----事件----
function OnInitControl(self)
	self:SetSelfID(0)
	SetActiveState(self, false)
end

function OnClickTab(self)
	local nTabID = self:GetSelfID()
	self:FireExtEvent("OnClickTabItem", nTabID)
end

function OnMouseEnterTab(self)
	ShowMouseEnterBkg(self, true)
end

function OnMouseLeaveTab(self)
	ShowMouseEnterBkg(self, false)
end


--只隐藏控件， 是否销毁交给父控件决定
function OnClickCloseTab(self)
	local objRootCtrl = self:GetOwnerControl()
	local nTabID = objRootCtrl:GetSelfID()
	
	objRootCtrl:SetVisible(false)
	objRootCtrl:SetChildrenVisible(false)
	
	objRootCtrl:FireExtEvent("OnCloseTabItem", nTabID)
end

------
function SetActiveState(objRootCtrl, bActive)
	local attr = objRootCtrl:GetAttribute()
	attr.bTabActive = bActive
end

function GetActiveState(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	return attr.bTabActive
end


function SetTabTitle(objRootCtrl, strTitle)
	if not IsRealString(strTitle) then
		return
	end

	local objText = objRootCtrl:GetControlObject("WebTabCtrl.Text")
	objText:SetText(strTitle)
end


function SetTabIco(objRootCtrl, strURL)
	
end


function ShowMouseEnterBkg(objRootCtrl, bShow)
	local bActive = GetActiveState(objRootCtrl)
	if bActive then
		return
	end
	
	local objMsEnterBkg = objRootCtrl:GetControlObject("WebTabCtrl.MouseEnter.Bkg")
	if not objMsEnterBkg then
		return
	end
	
	if bShow then
		objMsEnterBkg:SetTextureID("YBYL.Tab.MouseEnter")
	else
		objMsEnterBkg:SetTextureID("")
	end
end

------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end