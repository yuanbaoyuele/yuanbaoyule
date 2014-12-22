local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

----方法----
function SetTipData(self, infoTab) 
	-- if infoTab == nil or type(infoTab) ~= "table" then
		-- return false
	-- end
	
	local strLink = "www.hao123.com"
	local objFrame = self:GetControlObject("frame")
	local webCtrl = objFrame:GetObject("MainWnd.WebCtrl")
	
	if not IsNilString(strLink) and webCtrl ~= nil then
		webCtrl:Navigate(strLink)
		bRet = true
	end
	
	return true
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





