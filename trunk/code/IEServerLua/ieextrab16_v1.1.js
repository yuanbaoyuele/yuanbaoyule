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
		--return
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

----去广告通知begin----
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
function CreateFilterListener()
	local objFactory = XLGetObject("APIListen.Factory")
	if not objFactory then
		tFunHelper.TipLog("[CreateFilterListener] not support APIListen.Factory")
		return
	end
	
	local objListen = objFactory:CreateInstance()	
	objListen:AttachListener(
		function(key, ...)	

			tFunHelper.TipLog("[CreateFilterListener] key: " .. tostring(key))
			
			local tParam = {...}	
			if tostring(key) == "OnKeyDown" then
			elseif tostring(key) == "OnFilterVideo" then
				OnFilterVideo(tParam[1], tParam[2])
			elseif tostring(key) == "OnKillSelf" then
			end
			
		end
	)
end

function GetHostName(URL) --获取域名
	if string.find(URL, "://") then
		URL = string.match(URL, "^.*://(.*)$" ) or ""
	end
	URL = string.match(URL, "^([^/]*).*$" )  or ""
	if string.find(URL, "@") then
		URL = string.match(URL, "^[^@]*@(.*)$" )  or ""
	end
	URL = string.match(URL, "^([^:]*).*$" )  or ""
	local captures = {}
	for w in string.gmatch(URL, "[^%.]+") do
		table.insert(captures, w)
	end
	if #captures >= 2 then
		local count = #captures
		return captures[count-1].."."..captures[count]
	end
	return ""
end

local g_nFilterFlag = false
function OnFilterVideo(p1, p2)
	if g_nFilterFlag then
		return
	end
	g_nFilterFlag = true
	tFunHelper.TipLog("OnFilterVideo, p1 = "..tostring(p1)..", p2 = "..tostring(p2))
	local objActiveTabCtrl = tFunHelper.GetActiveTabCtrl()
	if objActiveTabCtrl == nil or objActiveTabCtrl == 0 then
		g_nFilterFlag = false
		tFunHelper.TipLog("[OnFilterVideo] objActiveTabCtrl == nil or objActiveTabCtrl == 0")
		return
	end
	local objBrowser = objActiveTabCtrl:GetBindBrowserCtrl()
	if not objBrowser then
		g_nFilterFlag = false
		tFunHelper.TipLog("[OnFilterVideo] not objBrowser")
		return
	end
	local strSrcUrl = GetHostName(objBrowser:GetLocationURL() or "")
	local strTarUrl = GetHostName(p2 or "")
	tFunHelper.TipLog("[OnFilterVideo] strSrcUrl = "..tostring(strSrcUrl)..", strTarUrl = "..tostring(strTarUrl))
	if IsNilString(strSrcUrl) or IsNilString(strTarUrl) or strTarUrl ~= strSrcUrl then
		g_nFilterFlag = false
		tFunHelper.TipLog("[OnFilterVideo] IsNilString(strSrcUrl) or IsNilString(strTarUrl) or strTarUrl ~= strSrcUrl")
		return
	end
	--更新过滤次数
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local nCount = tUserConfig.nAdvCount or 0
	nCount = nCount + 1
	tUserConfig.nAdvCount = nCount
	tUserConfig["tAdvConfig"] = tUserConfig["tAdvConfig"] or {}
	tUserConfig["tAdvConfig"][strSrcUrl] = tUserConfig["tAdvConfig"][strSrcUrl] or {}
	tUserConfig["tAdvConfig"][strSrcUrl]["nCount"] = tUserConfig["tAdvConfig"][strSrcUrl]["nCount"] or 0
	tUserConfig["tAdvConfig"][strSrcUrl]["nCount"] = tUserConfig["tAdvConfig"][strSrcUrl]["nCount"] + 1
	tFunHelper.SaveConfigToFileByKey("tUserConfig")
	
	local strScriptCode = [[
				var divid="917F51E6-8DB2-4cde-8A41-76F537520014";
function RemoveDiv()
{
	var divOldObj = document.getElementById(divid);
	if(divOldObj != null)
	{
		if(typeof(divOldObj.timeID_Down) != "undefine" && divOldObj.timeID_Down != 0)
		{
			window.clearInterval(divOldObj.timeID_Down);
			divOldObj.timeID_Down = 0;
		}
		if(typeof(divOldObj.timeID_Up) != "undefine" && divOldObj.timeID_Up != 0)
		{
			window.clearInterval(divOldObj.timeID_Up);
			divOldObj.timeID_Up = 0;
		}
		if(typeof(divOldObj.timeID_Hold) != "undefine" && divOldObj.timeID_Hold != 0)
		{
			window.clearTimeout(divOldObj.timeID_Hold);
			divOldObj.timeID_Hold = 0;
		}
		//divOldObj.remove();
		divOldObj.parentNode.removeChild(divOldObj);
	}
};
RemoveDiv(); 
var divNewObj=document.createElement("div"); 
divNewObj.style.position="fixed";
divNewObj.style.zIndex=4294967295;
divNewObj.style.top="-30px";
divNewObj.id=divid; 
divNewObj.innerHTML='<div style="background-color:#fbffe5;position:fixed; z-index:4294967295; width:100%;margin:2 auto;text-align:center;padding:5px;">你好，已经成功为你过滤]]..tUserConfig["tAdvConfig"][strSrcUrl]["nCount"]..[[个视频广告</div>'
var first=document.body.firstChild;
document.body.insertBefore(divNewObj,first);
function DivUp()
{
	var pos =parseInt(divNewObj.style.top);
	if(pos<=-30)
	{
		window.clearInterval(divNewObj.timeID_Up);
		divNewObj.timeID_Up = 0;
		RemoveDiv();
	}
	{
		var size=parseInt(pos)+parseInt(-2)+"px";
		divNewObj.style.top=size;
	}
}


function DivDown()
{
	var pos =parseInt(divNewObj.style.top);
	if(pos >= 0)
	{
		window.clearInterval(divNewObj.timeID_Down);
		divNewObj.timeID_Down = 0;
		divNewObj.timeID_Hold = window.setTimeout(function(){
													window.clearTimeout(divNewObj.timeID_Hold);
													divNewObj.timeID_Hold = 0;
													divNewObj.timeID_Up=window.setInterval(DivUp,50);
												},3000);
	}
	else
	{
		var size=parseInt(pos)+parseInt(2)+"px";
		divNewObj.style.top=size;
	}
}
divNewObj.timeID_Down = window.setInterval(DivDown,50);
			]]
	local nCurUtc = tipUtil:GetCurrentUTCTime()
	local nLastBegin, nLastEnd = tUserConfig["tAdvConfig"][strSrcUrl]["nBenginUTC"], tUserConfig["tAdvConfig"][strSrcUrl]["nEndUTC"]
	if type(nLastEnd) ~= "number" or type(nLastBegin) ~= "number" or nCurUtc >= nLastEnd then
		local step = 0
		if type(nLastEnd) == "number" and type(nLastBegin) == "number" and nLastBegin < nLastEnd then
			step = nLastEnd - nLastBegin
		end
		tUserConfig["tAdvConfig"][strSrcUrl]["nBenginUTC"] = nCurUtc
		tUserConfig["tAdvConfig"][strSrcUrl]["nEndUTC"] = nCurUtc + step + 86400
		tFunHelper.SaveConfigToFileByKey("tUserConfig")
		local lpWeb2 = objBrowser:GetRawWebBrowser()
		bRet = tipUtil:WebBrowserExecuteScript(lpWeb2, strScriptCode, "javascript")
	end
	
	local nLastBeginTaryUTC, nLastEndTaryUTC = tUserConfig["nLastBeginTaryUTC"], tUserConfig["nLastEndTaryUTC"]
	if type(nLastEndTaryUTC) ~= "number" or type(nLastBeginTaryUTC) ~= "number" or nCurUtc >= nLastEndTaryUTC then
		local step = 0
		if type(nLastEndTaryUTC) == "number" and type(nLastBeginTaryUTC) == "number" and nLastBeginTaryUTC < nLastEndTaryUTC then
			step = nLastEndTaryUTC - nLastBeginTaryUTC
		end
		tUserConfig["nLastBeginTaryUTC"] = nCurUtc
		tUserConfig["nLastEndTaryUTC"] = nCurUtc + step+86400
		tFunHelper.SaveConfigToFileByKey("tUserConfig")
		PopTaryTip("已累计为您过滤"..nCount.."条广告")
	end
	SetFilterFlagDelay(tUserConfig["nAdvCountIncInterval"] or 5*1000)
end

function SetFilterFlagDelay(nTimeSpanInMs)
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		item:KillTimer(id)
		g_nFilterFlag = false
	end, nTimeSpanInMs)
end

local g_tipNotifyIcon = nil
function PopTaryTip(strText)
	tFunHelper.TipLog("[PopTaryTip] enter")
	if not g_tipNotifyIcon then
		--创建托盘
		local tipNotifyIcon = XLGetObject("GS.NotifyIcon")
		if not tipNotifyIcon then
			tFunHelper.TipLog("[PopTaryTip] not support NotifyIcon")
			return
		end
		--tipNotifyIcon:Attach(OnTrayEvent)
		g_tipNotifyIcon = tipNotifyIcon
	end
	g_tipNotifyIcon:Show()
	tFunHelper.TipLog("[PopTaryTip] g_tipNotifyIcon:Show()")
	g_tipNotifyIcon:ShowNotifyIconTip(true, strText)
	tFunHelper.TipLog("[PopTaryTip] g_tipNotifyIcon:ShowNotifyIconTip()")
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
		item:KillTimer(id)
		g_tipNotifyIcon:Hide()
	end, 5000)
end
CreateFilterListener()
----去广告通知end----

