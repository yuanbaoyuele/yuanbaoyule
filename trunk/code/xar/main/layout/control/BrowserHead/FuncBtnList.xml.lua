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
	local nTopSpan = 33
	tFunHelper.TryDestroyOldMenu(self, "AccelerateMenu")
	tFunHelper.CreateAndShowMenu(self, "AccelerateMenu", nTopSpan)
end

function OnClickAdvFilter(self)
	local bOpenFilter = tFunHelper:GetFilterState()
	if bOpenFilter then
		tFunHelper.SetToolTipText("视频去广告功能已关闭!")
		tFunHelper.ShowToolTip(true)
		tFunHelper.SetFilterState(false)
	else
		tFunHelper.SetToolTipText("已智能帮您去除广告!")
		tFunHelper.ShowToolTip(true)
		tFunHelper.SetFilterState(true)
	end
end


----


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end