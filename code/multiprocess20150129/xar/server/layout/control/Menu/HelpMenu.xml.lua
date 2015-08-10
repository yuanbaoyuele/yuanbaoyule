local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnSelect_About(self)
	tFunHelper.ShowPopupWndByName("TipAboutWnd.Instance", true)
end

function OnSelect_CheckUpdate(self)
	
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


