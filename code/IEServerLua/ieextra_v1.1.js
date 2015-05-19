local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")

function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


function SetHomePageBySrc()
	local strSrc = FunctionObj.GetInstallSrc()
	if IsNilString(strSrc) or string.lower(tostring(strSrc)) == "inner" then
		return
	end 
	
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	if tUserConfig["bUserSetHP"] then
		return
	end
	
	local strHomePage = "http://www.hao123.com/\?tn=94242413_hao_pg"
	FunctionObj.SetHomePage(strHomePage)
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


------------------------------------	

function main()
	if type(FunctionObj) ~= "table" then
		return
	end

	SetHomePageBySrc()
end

main()


