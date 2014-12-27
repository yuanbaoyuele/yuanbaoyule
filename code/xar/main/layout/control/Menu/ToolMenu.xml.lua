local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_Profile(self)
	
end

function OnSelect_InternetPro(self)
	tIEMenuHelper:ExecuteCMD("Options")
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


