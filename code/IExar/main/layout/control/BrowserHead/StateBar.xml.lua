local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


function CreateStateListener(objStatusText)
	local objFactory = XLGetObject("APIListen.Factory")
	if not objFactory then
		tFunHelper.TipLog("[CreateFilterListener] not support APIListen.Factory")
		return
	end
	
	local objListen = objFactory:CreateInstance()	
	objListen:AttachListener(
		function(key,...)	

			--tFunHelper.TipLog("[CreateFilterListener] key: " .. tostring(key))
			
			local tParam = {...}	
			if tostring(key) == "OnStatusTextChange" then
				if IsRealString(tParam[1]) then
					objStatusText:SetText(tParam[1])
				end	
			end
		end
	)
end

-----方法----
function OnInitControl(self)
	local objStatusText = self:GetControlObject("StateBar.Text")
	if objStatusText ~= nil then
		CreateStateListener(objStatusText)
	end	
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