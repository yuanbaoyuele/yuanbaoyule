local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


-----方法----
function OnInitControl(self)

end

-----事件----

function OnMouseEnterEarth(self)
	tFunHelper.ShowToolTip(true, "双击更改安全性设置")
end


function HideToolTip()
	tFunHelper.ShowToolTip(false)
end

----


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end