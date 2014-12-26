local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

----方法----
function SetTipData(self, infoTab) 
	
	return true
end


---事件--
function OnLButtonDbClick(self)
	
end

--tabcontainer事件
function OnActiveTabChange(self, strEvntName,objActiveTab)
	if not objActiveTab then
		return
	end

	local objRootCtrl = self:GetOwnerControl()
	local objHeadCtrl = objRootCtrl:GetControlObject("MainPanel.Head")
	if not objHeadCtrl then
		tFunHelper.TipLog("[OnActiveTabChange] get objHeadCtrl failed")
		return
	end
	objHeadCtrl:ProcessTabChange(objActiveTab)
end


function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end


function IsRealString(AString)
    return type(AString) == "string" and AString ~= ""
end





