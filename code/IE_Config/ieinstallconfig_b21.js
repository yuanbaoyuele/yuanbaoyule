function GetSubTable()
	local t = {
		["tDefaultBrowser"] = {
			["strBlackList"] = "360tray;qqpctray",
			["strBrowserList"] = "ucbrowser;qqbrowser;2345explorer;liebao;baidubrowser;hao123juzi;sogouexplorer;f1browser;2345chrome;maxthon;yyexplorer;hao123browser;taobrowser;yidian;iexplore",
			["nSpanTimeInSec"] = 365*24*3600,
		},
		
		["tURLMap"] = {
			["inner"] = "http://www.hao123.com/index.html\?tn=99579714_hao_pg",
            ["outer"] = "http://www.hao123.com/index.html\?tn=99579714_hao_pg",
		},
	}
	return t
end

