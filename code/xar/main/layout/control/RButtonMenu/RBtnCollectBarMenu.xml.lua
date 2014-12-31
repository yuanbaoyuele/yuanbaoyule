local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")


-------事件---
function OnSelect_Open(self)
	local objCollectURL = GetCollectObject(self)
	if not objCollectURL then
		return
	end
	
	local strURL = objCollectURL:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURL(strURL)
	end
end


function OnSelect_Delete(self)
	local objCollectURL = GetCollectObject(self)
	if not objCollectURL then
		return
	end
	
	local strURL = objCollectURL:GetText()
	if not IsRealString(strURL) then
		return
	end

	local objCollectRoot = objCollectURL:GetOwnerControl()
	if not objCollectRoot then
		return
	end
	
	tFunHelper.RemoveUserCollectURL(strURL)
	objCollectRoot:UpdateCollectList()
end


function GetCollectObject(objMenuItem)
	local objTree = objMenuItem:GetOwner()
	local objMainLayout = objTree:GetUIObject("Menu.MainLayout")
	local objNormalCtrl = objMainLayout:GetObject("Menu.Context")

	local objCollectLayout = objNormalCtrl:GetRelateObject()
	local objCollectURL = objCollectLayout:GetChildByIndex(2)
	
	return objCollectURL
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end



