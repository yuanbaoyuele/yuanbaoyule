local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

-----方法----


-----事件----
function OnClickAccelerate(self)



end

function OnClickAdvFilter(self)



end

function OnSelectItemChanged(self)



end


function OnInitComboBox(self)
	local nListItem = 5
	local strBaseText = "游戏加速 "
	self:SetText("游戏加速 1x")
	local cbattr = self:GetAttribute()
    local data = {}
    cbattr.insert = true
	
	for i=1, nListItem do 
		local strText = strBaseText .. tostring(i) .. "x"
		data[i] = {IconResID="", IconWidth=0, LeftMargin=0, TopMargin=0, Text=strText}
	end
  	
    cbattr.data = data
end


----


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end