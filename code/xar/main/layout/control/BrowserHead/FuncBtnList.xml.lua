local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-----方法----


-----事件----
function OnInitAccText(self)
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local nAccelerateRate = tonumber(tUserConfig["nAccelerateRate"]) or 1

	local strText = "游戏加速"..tostring(nAccelerateRate).."x"
	self:SetText(strText)
	
	tFunHelper.AccelerateFlash(nAccelerateRate)
end

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