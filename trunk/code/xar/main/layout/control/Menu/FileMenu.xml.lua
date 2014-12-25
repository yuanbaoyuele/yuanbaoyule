local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-------事件---
function OnSelect_AddNewTab(self)
	local strHomePage = tFunHelper.GetHomePage()
	tFunHelper.OpenURL(strHomePage)
end

function OnSelect_Exit(self)
	tFunHelper.ExitProcess()
end

function OnSelect_Open(self)
	
end



-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


