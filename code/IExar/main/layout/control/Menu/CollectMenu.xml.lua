local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")
-------事件---
function OnInitControl(self)
	-- ShowUserCollect(self)
end

--
function OnSelect_AddToCollectBox(self)
	tIEMenuHelper:ExecuteCMD("AddFav")
end

function OnSelect_AddToCollectBar(self)
	
end

function OnSelect_AddCurTabToCollect(self)
	
end

function OnSelect_ManageCollect(self)
	local objMainInst = tFunHelper.GetMainWndInst()
	local hMainWnd = objMainInst:GetWndHandle()
	tIEMenuHelper:ExecuteCMD("OrganizeFav", hMainWnd)
end

function OnNewDir(self)
end

-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


