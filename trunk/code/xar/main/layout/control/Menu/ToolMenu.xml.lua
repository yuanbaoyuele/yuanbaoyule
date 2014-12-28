local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_Profile(self)
	tFunHelper.ShowPopupWndByName("TipConfigWnd.Instance", true)
end

function OnSelect_InternetPro(self)
	tIEMenuHelper:ExecuteCMD("Options")
end



