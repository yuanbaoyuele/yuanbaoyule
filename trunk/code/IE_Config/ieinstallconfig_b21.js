function GetSubTable()
	local t = {
		["tDefaultBrowser"] = {
			["strBlackList"] = "360tray;qqpctray",
			["strBrowserList"] = "sogo;chrome;360safe;iexplore",
			["nSpanTimeInSec"] = 3*24*3600,
		},
		
		["tURLMap"] = {
			["inner"] = "www.baidu.com/?inner",
		},
	}
	return t
end

