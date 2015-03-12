local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnSelect_Cut(self)
	-- tFunHelper.ShowPopupWndByName("TipAboutWnd.Instance", true)
end

function OnSelect_Copy(self)
	
end

function OnSelect_Paste(self)
	
end

function OnSelect_SelectAll(self)
	
end

function OnSelect_Find(self)
	
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


