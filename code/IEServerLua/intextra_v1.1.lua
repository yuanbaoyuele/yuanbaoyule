local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")

local tipUtil = XLGetObject("API.Util")
local apiAsyn = XLGetObject("API.AsynUtil")


function GTV(obj)
	return "[" .. type(obj) .. "`" .. tostring(obj) .. "]"
end

function Log(str)
	tipUtil:Log(tostring(str))
end

function IsNilString(AString)
	if AString == nil or AString == "" then
		return true
	end
	return false
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


function FetchValueByPath(obj, path)
	local cursor = obj
	for i = 1, #path do
		cursor = cursor[path[i]]
		if cursor == nil then
			return nil
		end
	end
	return cursor
end


function SetHomePageBySrc()
	local tPageMap = {
		["0001"] = "http://www.baidu.com",
		["0002"] = "http://www.hao123.com",
		["0003"] = "http://www.hao360.com",
	}
	
	local strSrc = FunctionObj.GetInstallSrc()
	if IsNilString(strSrc) then
		return
	end 
	
	local strHomePage = tPageMap[strSrc]
	if not IsRealString(strHomePage) then
		return
	end
	
	FunctionObj.SetHomePage(strHomePage)
end

function SetSearchEngine()
	local tUserConfig = FunctionObj.ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["SearchEngine"] = {
		[1] = {
			["url"] = "http://www.baidu.com/s\?wd={searchword}", 
			["name"] = "baidu", 
			["displayName"] = "2百度一下 (默认)", 
		}, 
		[2] = {
			["url"] = "http://www.google.com/q={searchword}", 
			["name"] = "google", 
			["displayName"] = "2Google", 
		}, 
		[3] = {
			["url"] = "http://cn.bing.com/search\?q={searchword}", 
			["name"] = "bing", 
			["displayName"] = "2Live Search", 
		}, 
	}, 
	for i, v in ipairs(tUserConfig["SearchEngine"]) do
		FunctionObj.DownLoadSearchEngineIco(v["url"], function() end)
	end
	FunctionObj.SaveConfigToFileByKey("tUserConfig")
end

------------------------------------	

function main()
	if type(FunctionObj) ~= "table" or tipUtil == nil 
		or apiAsyn == nil then
		return
	end

	SetHomePageBySrc()
	SetSearchEngine()
end

main()


