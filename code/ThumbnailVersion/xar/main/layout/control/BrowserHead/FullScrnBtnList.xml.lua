local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-----方法----


-----事件----
function OnClickMin(self)
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	objMainHostWnd:Min()
end

function OnClickRestore(self)
	tFunHelper.RestoreWndSize()
end

function OnClickClose(self)
	tFunHelper.ReportAndExit()	
end

------辅助函数---

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end

