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

local gTableMap = {
		TempFile=8,
		Cookie=2,
		Histroy=1,
		Form=16,
		PassWord=32,
		TempFile=8,
		DeleteAll=255,
	}
	
local gTableCheck = {}
function OnClickCheckBox(obj)
	local attr = obj:GetAttribute()
	local strID = obj:GetID()
	if attr == nil or strID == nil then
		return
	end
	local tKey = SplitStringBySeperator(strID,"%.")
	local strKey = tKey[2]
	if not IsRealString(strKey) then
		return
	end
	if attr.NormalBkgID == "checkbox.normal" then
		attr.NormalBkgID = "checkbox.check.hover"
		attr.HoverBkgID = "checkbox.check.normal"
		attr.DownBkgID = "checkbox.check.hover"
		gTableCheck[strKey] = true
	else
		attr.NormalBkgID = "checkbox.normal"
		attr.HoverBkgID = "checkbox.hover"
		attr.DownBkgID = "checkbox.normal"
		gTableCheck[strKey] = nil
	end
	obj:Updata()
end

function OnCheckFav(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckTempFile(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckCookie(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckTempFile(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckHistroy(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckForm(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckPassWord(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end	
end

function OnCheckInPrivate(self)
	local strSelfID = self:GetID()
	if not IsRealString(strSelfID) then
		return
	end
	if string.find(strSelfID,"%.Content$") ~= nil then
		local ctrlParent = self:GetFather()
		if ctrlParent then
			local obj = ctrlParent:GetChildByIndex(0)
			if obj then
				OnClickCheckBox(obj)
			end	
		end		
	else
		OnClickCheckBox(self)
	end
end



function OnCheckAbout(self)
	local strTextureID = self:GetTextureID()
	if strTextureID == "Tool.DelHistroy.About.Normal" then
		self:SetTextureID("Tool.DelHistroy.About.Click")
	end
	local strResDir = tFunHelper.GetResourceDir()
	if not IsRealString(strResDir) then
		return
	end
	local strIEHelp_chm = tipUtil:PathCombine(strResDir, "iexplore.chm")
	if not tipUtil:QueryFileExists(strIEHelp_chm) then
		return
	end
	local strCmd = "mk:@MSITStore:" .. strIEHelp_chm .. "::/ie_del_browsing_hist_it.htm"
	tipUtil:ShellExecute(0, "open", "HH.exe", strCmd, 0, "SW_SHOW")
end

function OnCheckDelete(self)
	--
	for key, value in pairs(gTableCheck) do
		if type(key) == "string" and value then
			if gTableMap[key] ~= nil then
				local strCmd = "InetCpl.cpl,ClearMyTracksByProcess " .. tostring(gTableMap[key])
				tipUtil:ShellExecute(0, "open", "rundll32.exe", strCmd, 0, "SW_SHOW")
			end	
		end
	end
end

function OnClickCancel(self)
	HideWindow(self)
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




