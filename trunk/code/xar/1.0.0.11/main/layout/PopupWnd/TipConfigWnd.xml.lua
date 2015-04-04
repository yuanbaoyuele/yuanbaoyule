local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

function OnCreate( self )
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	local selfleft, selftop, selfright, selfbottom = self:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	local objtree = self:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	local webleft, webtop, webright, webbottom = objRootCtrl:GetAbsPos()
	local webwidth, webheight = webright - webleft, webbottom - webtop
	local wndleft = ((workright-workleft)-webwidth)/2-webleft
	local wndtop = ((workbottom-worktop)-webheight)/2-webtop
	self:Move(wndleft, wndtop, wndwidth, wndheight)
end

function OnClickCloseBtn(self)
	HideWindow(self)
end


function OnClickEnterBtn(self)
	SetHomePageURL(self)
	HideWindow(self)
end

function OnClickCancelBtn(self)
	HideWindow(self)
end

function OnHomePageKeyDown(self, nKeyCode)
	if nKeyCode ~= 13 then --只处理回车
		return
	end
	
	SetHomePageURL(self)
	HideWindow(self)
end

---------
function HideWindow(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	objHostWnd:Show(0)
end


function SetHomePageURL(objUIElem)
	local objTree = objUIElem:GetOwner() 
	local objRootLayout = objTree:GetUIObject("root.layout")
	local objEdit = objRootLayout:GetObject("TipConfig.NoShadowBkg:TipConfig.InputValue.Bkg:TipConfig.InputValue")
	
	if not objEdit then
		return
	end
	local strURL = objEdit:GetText()
	if not IsRealString(strURL) then
		return
	end
	
	tFunHelper.SetHomePage(strURL)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end






