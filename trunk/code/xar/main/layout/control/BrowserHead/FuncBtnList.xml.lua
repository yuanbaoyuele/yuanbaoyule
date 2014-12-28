local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-----方法----


-----事件----
function OnClickAccelerate(self)
	tFunHelper.TryDestroyOldMenu(self, "AccelerateMenu")
	tFunHelper.CreateAndShowMenu(self, "AccelerateMenu")
end

function OnClickAdvFilter(self)
	


end


----


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end