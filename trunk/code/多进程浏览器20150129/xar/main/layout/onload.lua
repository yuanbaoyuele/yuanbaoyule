local tipUtil = XLGetObject("API.Util")
local tipAsynUtil = XLGetObject("API.AsynUtil")
local gnLastReportRunTmUTC = 0

-----------------

function RegisterFunctionObject()
	local strFunhelpPath = __document.."\\..\\functionhelper.lua"
	XLLoadModule(strFunhelpPath)
	
	local tFunH = XLGetGlobal("YBYL.FunctionHelper")
	if type(tFunH) ~= "table" then
		return false
	else
		return true
	end
end


function LoadIEHelper()
	local strIEHelperPath = __document.."\\..\\IEMenuHelper.lua"
	XLLoadModule(strIEHelperPath)
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


function CheckIsClientPro()
	local FunctionObj = XLGetGlobal("YBYL.FunctionHelper") 
	local bRet, strServerID = FunctionObj.GetCommandStrValue("/connect")
	if bRet and IsRealString(strServerID) then
		return true
	end	
	
	return false
end


function LoadServerXAR()
	local objXARMan = XLGetObject("Xunlei.UIEngine.XARManager")
	objXARMan:LoadXAR("server")
end


function LoadClientXAR()
	local objXARMan = XLGetObject("Xunlei.UIEngine.XARManager")
	objXARMan:LoadXAR("client")
end


function main() 
	gnLastReportRunTmUTC = tipUtil:GetCurrentUTCTime()
	XLSetGlobal("YBYL.LastReportRunTime", gnLastReportRunTmUTC) 
	
	if not RegisterFunctionObject() then
		tipUtil:Exit("Exit")
	end
	LoadIEHelper()
	
	local bIsClient = CheckIsClientPro()
	if bIsClient then
		LoadClientXAR()
	else
		LoadServerXAR()
	end
end

main()



