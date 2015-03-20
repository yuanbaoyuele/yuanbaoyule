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

function OnOnLButtonDownYesText(self, x, y)
	local parent = self:GetParent()
	local attr = parent:GetAttribute()
	attr.textbtndown = true
end
function OnLButtonUpYesText(self, x, y)
	local parent = self:GetParent()
	local attr = parent:GetAttribute()
	if attr.textbtndown then
		attr.textbtndown = false
		parent:FireExtEvent("OnClick", x, y)
	end
end

function OnMouseLeaveYesText(self, x, y)
	local parent = self:GetParent()
	local attr = parent:GetAttribute()
	attr.textbtndown = false
end

function OnClickSysInfo(self)
end

function OnClicksure(self)
	local owner = self:GetOwner()
	local thatradio = owner:GetUIObject("TipFeedback.no")
	local attr = thatradio:GetAttribute()
	local selfattr = self:GetAttribute()
	if not selfattr.select or selfattr.NormalBkgID == "radiobox.1" then
		selfattr.select = true
		selfattr.NormalBkgID = "radiobox.2"
		selfattr.HoverBkgID = "radiobox.4"
		selfattr.DownBkgID = "radiobox.4"
		attr.NormalBkgID = "radiobox.1"
		attr.HoverBkgID = "radiobox.3"
		attr.DownBkgID = "radiobox.3"
		self:Updata()
		thatradio:Updata()
	end
end

function OnClickRadioNo(self)
	local owner = self:GetOwner()
	local thatradio = owner:GetUIObject("TipFeedback.yes")
	local attr = thatradio:GetAttribute()
	local selfattr = self:GetAttribute()
	if attr.select or attr.NormalBkgID == "radiobox.2" then
		attr.select = false
		attr.NormalBkgID = "radiobox.1"
		attr.HoverBkgID = "radiobox.3"
		attr.DownBkgID = "radiobox.3"
		selfattr.NormalBkgID = "radiobox.2"
		selfattr.HoverBkgID = "radiobox.4"
		selfattr.DownBkgID = "radiobox.4"
		self:Updata()
		thatradio:Updata()
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
	if type(objHostWnd.EndDialog) == "function" then
		objHostWnd:EndDialog(0)
	end
	objHostWnd:Show(0)
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end






