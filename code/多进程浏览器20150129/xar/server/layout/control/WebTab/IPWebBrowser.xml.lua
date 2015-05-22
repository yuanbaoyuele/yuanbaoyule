local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

local function ArrayToStr(...)
	local arr = {...}
	local str = ""
	for i = 1, #arr do
		if i > 1 then
			str = str .. ","
		end
		str = str .. tostring(arr[i])
	end
	return str
end
function SyncIPCCall(self, event, ...)
	local attr = self:GetAttribute()	
	if attr.ClientSession then 
		return  attr.ClientSession:SyncCallTimeout("defaultInterface", "IPCCall", 30000, event, ...)
		-- tFunHelper.TipLog("SyncIPCCall "..tostring(event).." "..tostring(ret))
		-- return ret 
	end 
end


function RegisterMethod(self)
	local attr	= self:GetAttribute()
	tFunHelper.TipLog("RegisterMethod")
	-- 一个接口就够了，第一个参数表示方法名
	attr.ClientSession:RegisterInterface("defaultInterface")
	attr.ClientSession:RegisterMethod("defaultInterface", "IPCCall", function(event, ...) return OnIPCCall(self, event, ...) end)
end 
function AcceptSession(self)
	RegisterMethod(self)

	local attr	= self:GetAttribute()
	attr.ClientSession:SetCloseCallback(function()
		tFunHelper.TipLog("session closed")
	end)
end 

function InitServer(objRootCtrl)
	local attr	= objRootCtrl:GetAttribute()	
	local ipcfactory = XLGetObject("Xunlei.UIEngine.IPC.Factory")
	local Server = ipcfactory:StartServer(attr.ServerID, 0, nil,  nil)	
	local Session, res = Server:AcceptSession()	
	tFunHelper.TipLog("InitServer res= ",res," Session=",Session)
	if res ~= 0 or not Session then
		-- 连接失败
	else
		attr.ClientSession = Session		
		local RealObject = objRootCtrl:GetControlObject("RealObject")				
		local url = attr.NavigateUrl or ""
		local res, wnd = SyncIPCCall(objRootCtrl,"Init", attr.ServerID, url, RealObject:GetRealObjectHostWnd(), "YBYL_CMD_HELPER{528CAAED-070E-4b6e-88CE-4414D846BE37}_1.0")	
		tFunHelper.TipLog("InitServer res= ",res," wnd=",wnd)
		if res ~= 0 or not wnd then
		else
			AcceptSession(objRootCtrl)
			RealObject:SetWindow(wnd)
			RealObject:SetVisible(true)
			return true
		end		
	end
end
function InitIPCWeb(objRootCtrl)
	-- 拉起一个新YBYL.exe进程，作webbrowser
	local attr = objRootCtrl:GetAttribute()
	
	local BinPath = tFunHelper:GetExePath()
	local Params  = " /connect "..tostring(attr.ServerID)	
	tFunHelper.TipLog("CreareIPCWeb Params="  ,Params)
	tipUtil:ShellExecute(0, "open", BinPath, Params, 0, "SW_SHOW")
end 

function InitAttr(self)
	local attr = self:GetAttribute()	
	math.randomseed(tipUtil:GetCurrentUTCTime())	
	attr.ServerID = tipUtil:GeneralGUID()
	self:Show(attr.Visible)
end 

function OnInitControl(self) 
	AsynCall(function()
		-- 初始化属性
		InitAttr(self)
		-- 初始化远程Web
		InitIPCWeb(self)	
		-- 初始化服务
		InitServer(self)	
	end)	
end 

function OnIPCCall(self, event, ...)
	local id = 0	
	if event == "CallFunction" then
		if true then return true end 
				
		local params = {...}
		local funcName = params[1]
		if type(funcName) ~= "string" then
			YBYL.Helper.Assert(false, "OnIPCCall CallFunction funcName="..tostring(funcName))
			return
		end
		local fun = loadstring("return "..funcName)()
		if type(fun) == "function" then
			table.remove(params, 1)
			return fun(unpack(params))
		end
	elseif event == "GetGlobal" then
		local params = {...}
		local globalName = params[1]
		if type(globalName) ~= "string" then
			YBYL.Helper.Assert(false, "OnIPCCall GetGlobal globalName="..tostring(globalName))
			return
		end
		return loadstring("return "..globalName)()
	elseif event == "AttachListener" then		
		
	end
	local retTable = nil
	if event == "OnNewWindow3" or 
		event == "OnTitleChange" or 
		event == "OnCommandStateChange" or 
		event == "OnDownload" or 
		event == "OnHotKey2" or 
		event == "OnTranslateAccelerator" or 
		event == "OnTranslateUrl" or 
		event == "OnNavigateComplete2" or 
		event == "onload" or 
		event == "onscroll" or 
		event == "OnWindowClosing" or 
		event == "OnBeforeNavigate2" or 
		event == "OnVideoSnifferEvent" or
		event == "OnJsCommand" or
		event == "OnAddNewTab" or
		event == "OnProgressChange" then
		
		-- 处理浏览器事件
		tFunHelper.TipLog("OnIPCCall event=", event, ", ", ArrayToStr(...))	
		retTable = {self:FireExtEvent(event,...)}
	end
	
	-- 再发到感兴趣的地方处理
	local callRetTable = {self:FireExtEvent("OnIPCCall", event, id, ...)}
	if retTable == nil then
		-- 返回第一个参数是表示是否处理过的
		table.remove(callRetTable, 1)
		retTable = callRetTable
	end
	return unpack(retTable)
end


function Navigate(self,url)	
	local attr = self:GetAttribute()
	attr.NavigateUrl = url
	SyncIPCCall(self, "Navigate", url)
end 

function Stop(self)	
	SyncIPCCall(self, "Stop")
end 
function Refresh(self)	
	SyncIPCCall(self, "Refresh")
end 
function GoBack(self)	
	SyncIPCCall(self, "GoBack")
end 
function GoForward(self)	
	SyncIPCCall(self, "GoForward")
end 
function GetBusy(self)	
	local _,busy = SyncIPCCall(self, "GetBusy")
	return busy
end 
function Show(self, visible)
	local attr = self:GetAttribute()
	attr.Visible = visible
	self:SetVisible(visible)
	self:SetChildrenVisible(visible)
end
function SetURL(self, url)
	local attr = self:GetAttribute()
	attr.NavigateUrl = url
end

function SetRealFocus(self, focus)
	SyncIPCCall(self, "SetRealFocus", focus)
end
function GetLocationURL(self)
	local ret,url = SyncIPCCall(self, "GetLocationURL")	
	return url
end

function CloseWebBrowser(self)
	local attr = self:GetAttribute()
	if attr.ClientSession then 
		attr.ClientSession:Close()
	end 	
end

function SnapshotWindowBitmap(self,...)
	local ret,url = SyncIPCCall(self, "SnapshotWindowBitmap",...)
end

function GetRawWebBrowser(self,...)
	local ret, objRawWebBrowser = SyncIPCCall(self, "GetRawWebBrowser",...)
	return objRawWebBrowser
end


function GetWindow(self,...)
	local ret, hWindow = SyncIPCCall(self, "GetWindow",...)
	return hWindow
end




