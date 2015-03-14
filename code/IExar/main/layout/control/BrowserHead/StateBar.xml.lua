local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


-----方法----
function OnInitControl(self)

end

-----事件----


----


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end