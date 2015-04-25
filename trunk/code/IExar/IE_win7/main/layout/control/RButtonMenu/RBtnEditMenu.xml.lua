local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")


-------事件---

function OnSelect_Undo(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:Undo()
	end
end


function OnSelect_Clear(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:Clear()
	end
end


function OnSelect_Copy(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:Copy()
	end
end


function OnSelect_Cut(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:Cut()
	end
end

function OnSelect_Paste(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:Paste()
	end
end


function OnSelect_SelAll(self)
	local objEdit = GetEditObject(self)
	if objEdit then
		objEdit:SetSelAll()
	end
end


function GetEditObject(objMenuItem)
	local objTree = objMenuItem:GetOwner()
	local objMainLayout = objTree:GetUIObject("Menu.MainLayout")
	local objNormalCtrl = objMainLayout:GetObject("Menu.Context")

	local objEdit = objNormalCtrl:GetRelateObject()
	return objEdit
end



function IsRealString(str)
	return type(str) == "string" and str ~= ""
end



