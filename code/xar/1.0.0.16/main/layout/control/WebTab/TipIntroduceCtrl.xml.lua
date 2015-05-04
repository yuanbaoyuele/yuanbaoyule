local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local g_nCurrentPage = 1

function OnClickCloseBtn(self)
	HideCtrl(self)
	tFunHelper.OpenURLWhenStup()
	
	local strRegPath = "HKEY_CURRENT_USER\\SOFTWARE\\YBYL\\ShowIntroduce"
	local strValue = tFunHelper.RegQueryValue(strRegPath)
	tFunHelper.RegDeleteValue(strRegPath)
end


function OnClickLeftBtn(self)
	ChangePanel(self)
end

function OnClickRightBtn(self)
	ChangePanel(self)
end

function OnLButtonUpPanel1(self)
	ChangePanel(self)
end

function OnLButtonUpPanel2(self)
	ChangePanel(self)
end


---------
function ChangePanel(objUIElem)
	local objRootCtrl = objUIElem:GetOwnerControl()
	
	local objPanel1 = objRootCtrl:GetControlObject("TipIntroduce.Panel1")
	local objPanel2 = objRootCtrl:GetControlObject("TipIntroduce.Panel2")
	
	local nCurIndex = math.mod(g_nCurrentPage+1, 2)
	if nCurIndex == 0 then
		nCurIndex = 2
	end
	
	if nCurIndex == 1 then
		objPanel1:SetVisible(true)
		objPanel2:SetVisible(false)
	
	elseif nCurIndex == 2 then
		objPanel1:SetVisible(false)
		objPanel2:SetVisible(true)
	end
	
	g_nCurrentPage = nCurIndex
end


function HideCtrl(objUIElem)
	local objRootCtrl = objUIElem:GetOwnerControl()
	objRootCtrl:SetVisible(false)
	objRootCtrl:SetChildrenVisible(false)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end

