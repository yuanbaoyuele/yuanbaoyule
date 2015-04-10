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
end

function OnClickCloseBtn(self)
	HideWindow(self)
end

function OnCloseAll(self)
	HideWindow(self)
	tFunHelper.ReportAndExit()
end

function OnCloseCurrent(self)
	HideWindow(self)
	local objWebCtrl = tFunHelper.GetActiveTabCtrl()
	objWebCtrl:CloseTab()
	--HideWindow(self)
end

function OnClickCheckBox(self)
	local obj = self
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	local ctrlParent = self:GetFather()
	if ctrlParent == nil then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrl = ctrlParent:GetObject("TipCloseAllTabWnd.CheckBox")
		if ctrl == nil then
			return
		end
		obj = ctrl	
	end	
	
	
	local attr = obj:GetAttribute()
	if attr == nil then
		return
	end
	
	if attr.NormalBkgID == "checkbox.normal" then
		attr.NormalBkgID = "checkbox.check.normal"
		attr.HoverBkgID = "checkbox.check.hover"
		attr.DownBkgID = "checkbox.check.normal"
		local btnCurrent = ctrlParent:GetObject("TipCloseAllTabWnd.Close.Current")
		if btnCurrent == nil then
			return
		end
		btnCurrent:Enable(false)
		local tLocalUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
		tLocalUserConfig["bCheckCloseAllTab"] = true
	else
		attr.NormalBkgID = "checkbox.normal"
		attr.HoverBkgID = "checkbox.hover"
		attr.DownBkgID = "checkbox.normal"
		local btnCurrent = ctrlParent:GetObject("TipCloseAllTabWnd.Close.Current")
		if btnCurrent == nil then
			return
		end
		btnCurrent:Enable(true)
		local tLocalUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
		tLocalUserConfig["bCheckCloseAllTab"] = false
	end
	obj:Updata()
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

function SplitStringBySeperator(strToSplit, strSeperator)
	local tResult = {}
	
	if type(strToSplit) == "string" and type(strSeperator) == "string" then
		local nSepStartPos = 0
		local nSepEndPos = 0
		local nLastSepStartPos = 0
		local nLastSepEndPos = 0
		while true do
			nLastSepStartPos = nSepStartPos
			nLastSepEndPos = nSepEndPos
			nSepStartPos, nSepEndPos = string.find(strToSplit, strSeperator, nLastSepEndPos + 1)
			if type(nSepStartPos) ~= "number" or type(nSepEndPos) ~= "number" then
				tResult[#tResult + 1] = string.sub(strToSplit, nLastSepEndPos + 1, -1)
				break
			end
			tResult[#tResult + 1] = string.sub(strToSplit, nLastSepEndPos + 1, nSepStartPos - 1)
		end
	end

	return tResult
end




