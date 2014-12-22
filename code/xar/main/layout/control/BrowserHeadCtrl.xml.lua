local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

----事件--
function OnClickCpationClose(self)
	tFunHelper.ExitProcess()	
end

function OnClickCpationMin(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if objHostWnd then
		objHostWnd:Min()
	end
end


function OnClickCpationMax(self)
	local objHostWnd = GetHostWndByUIElem(self)
	if objHostWnd then
		objHostWnd:Max()
	end
end



------辅助函数---
function GetHostWndByUIElem(objUIElem)
	local objTree = objUIElem:GetOwner()
	if objTree then
		return objTree:GetBindHostWnd()
	end
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end




