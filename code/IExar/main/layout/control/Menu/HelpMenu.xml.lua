local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---

function OnSelect_Help(self)
	
end

function OnSelect_NewFunction(self)
	
end

function OnSelect_Support(self)
	
end

function OnSelect_ReportSet(self)
	
end

function OnSelect_About(self)
	-- tFunHelper.ShowPopupWndByName("TipAboutWnd.Instance", true)
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


