local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

function OnCreate( self )
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	local selfleft, selftop, selfright, selfbottom = self:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	local hMainWnd = tFunHelper.GetMainWndInst()
	local MainWndleft, MainWndtop, MainWndright, MainWndbottom = hMainWnd:GetWindowRect()

	local wndleft = ((MainWndright-MainWndleft)-wndwidth)/2+MainWndleft
	if wndleft < workleft then
		wndleft = workleft
	elseif wndleft+wndwidth > workright then
		wndleft = workright - wndwidth
	end
	
	local wndtop = ((MainWndbottom-MainWndtop)-wndheight)/2+MainWndtop
	if wndtop < worktop then
		wndtop = worktop
	elseif wndtop+wndheight > workbottom then
		wndtop = workbottom - wndheight
	end
	self:Move(wndleft, wndtop, wndwidth, wndheight)
	
	local objtree = self:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	SetVersionText(objRootCtrl)
end

function OnClickCloseBtn(self)
	HideWindow(self)
end

function SetVersionText(objRootCtrl)
	local objYBYLVer = objRootCtrl:GetObject("TipAbout.YBYLVersion")
	local objIEVer = objRootCtrl:GetObject("TipAbout.IEVersion")
	
	local strYBYLVer = tFunHelper.GetExeVersion()
	if objYBYLVer and IsRealString(strYBYLVer) then
		objYBYLVer:SetText(strYBYLVer)
	end
	
	local strIEVer = GetIEVersion()
	if objIEVer and IsRealString(strIEVer) then
		objIEVer:SetText(strIEVer)
	end
end

function OnClickSysInfo(self)
end

function OnClicksure(self)
	HideWindow(self)
end

function OnClicklink(self)
	local attr  = self:GetAttribute()
	if not attr.clickflag then
		attr.clickflag = true
		attr.NormalBkgID = "about.link.2"
		attr.HoverBkgID = "about.link.2"
		attr.DownBkgID = "about.link.4"
		self:Updata()
	end
	local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
	tFunHelper.OpenURLInNewWindow("http://www.microsoft.com/en-us/legal/intellectualproperty/copyright/default.aspx")
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
	if type(objHostWnd.EndDialog) == "function" then
		objHostWnd:EndDialog(0)
	end
	objHostWnd:Show(0)
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end






