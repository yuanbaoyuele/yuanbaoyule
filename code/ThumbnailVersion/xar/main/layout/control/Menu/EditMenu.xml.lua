local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_Cut(self)
	tIEMenuHelper:ExecuteCMD("Cut")
end

function OnSelect_Copy(self)
	tIEMenuHelper:ExecuteCMD("Copy")
end

function OnSelect_Paste(self)
	tIEMenuHelper:ExecuteCMD("Paste")
end

function OnSelect_SelectAll(self)
	tIEMenuHelper:ExecuteCMD("SelectAll")
end

function OnSelect_Find(self)
	-- tIEMenuHelper:ExecuteCMD("SelectAll")
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


