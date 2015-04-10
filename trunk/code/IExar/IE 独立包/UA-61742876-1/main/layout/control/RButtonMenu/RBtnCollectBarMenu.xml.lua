local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnSelect_Open(self)
	local objCollectURL = GetCollectObject(self)
	if not objCollectURL then
		return
	end
	
	local strURL = objCollectURL:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURLInCurTab(strURL)
	end
end


function OnSelect_OpenInNewTab(self)
	local objCollectURL = GetCollectObject(self)
	if not objCollectURL then
		return
	end
	
	local strURL = objCollectURL:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURLInNewTab(strURL)
	end
end


function OnSelect_OpenInNewWindow(self)
	local objCollectURL = GetCollectObject(self)
	if not objCollectURL then
		return
	end
	
	local strURL = objCollectURL:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURLInNewWindow(strURL)
	end
end


function OnSelect_Cut(self)

end


function OnSelect_Copy(self)

end



function OnSelect_Delete(self)
	local objFilePath = GetCollectFilePath(self)
	if not objFilePath then
		return
	end
	
	local strFilePath = objFilePath:GetText()
	if not IsRealString(strFilePath) then
		return
	end

	local objCollectRoot = objFilePath:GetOwnerControl()
	if not objCollectRoot then
		return
	end
	
	tipUtil:DeletePathFile(strFilePath)
	objCollectRoot:UpdateCollectList()
end


function OnSelect_Rename(self)

end


function OnSelect_NewFolder(self)

end



function OnSelect_Profile(self)

end




function GetCollectObject(objMenuItem)
	local objTree = objMenuItem:GetOwner()
	local objMainLayout = objTree:GetUIObject("Menu.MainLayout")
	local objNormalCtrl = objMainLayout:GetObject("Menu.Context")

	local objCollectLayout = objNormalCtrl:GetRelateObject()
	local objCollectURL = objCollectLayout:GetChildByIndex(2)
	
	return objCollectURL
end

function GetCollectFilePath(objMenuItem)
	local objTree = objMenuItem:GetOwner()
	local objMainLayout = objTree:GetUIObject("Menu.MainLayout")
	local objNormalCtrl = objMainLayout:GetObject("Menu.Context")

	local objCollectLayout = objNormalCtrl:GetRelateObject()
	local objFilePath = objCollectLayout:GetChildByIndex(3)
	
	return objFilePath
end



function IsRealString(str)
	return type(str) == "string" and str ~= ""
end



