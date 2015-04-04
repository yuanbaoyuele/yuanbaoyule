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
	
	SetVersionText(objRootCtrl)
end

function OnClickCloseBtn(self)
	HideWindow(self)
end

function SetVersionText(objRootCtrl)
	local objYBYLVer = objRootCtrl:GetObject("TipAbout.YBYLVersion")
	local objIEVer = objRootCtrl:GetObject("TipAbout.IEVersion")
	
	local strYBYLVer = tFunHelper.GetYBYLVersion()
	if objYBYLVer and IsRealString(strYBYLVer) then
		objYBYLVer:SetText(strYBYLVer)
	end
	
	local strIEVer = GetIEVersion()
	if objIEVer and IsRealString(strIEVer) then
		objIEVer:SetText(strIEVer)
	end
end


function GetIEVersion()
	local strDir = tipUtil:GetSpecialFolderPathEx(0x26)   --CSIDL_PROGRAM_FILES
	local IEPath = tipUtil:PathCombine(strDir or "", "Internet Explorer\\iexplore.exe")
	if not IsRealString(IEPath) or not tipUtil:QueryFileExists(IEPath) then
		return ""
	end

	return tipUtil:GetFileVersionString(IEPath)
end
	
	
---------
function HideWindow(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	objHostWnd:Show(0)
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end






