local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

local YBYL = {}
YBYL.IPC = {}
-- 错误码，可能是主进程，还没拉起线程等待
local XLIPC_RESULT_WAITTHREAD_NONE = 10
-- 尝试连接的次数
local XLIPC_CONNECT_TRY_TIMES = 3
-- 连接失败，重试的间隔
local XLIPC_CONNECT_FAILED_INTERVAL = 1000


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


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

-- 异步调用 webbrowser的远程方法
function YBYL.IPC:IPCCall(event, ...)
	if not self.Session then
		return false
	end
	tFunHelper.TipLog("IPCCall event=", event, ", ", ArrayToStr(...))
	local params = {...}
	if #params > 0 and (type(params[#params]) == "function" or (#params >= 2 and type(params[#params-1]) == "function")) then
		if #params >= 2 and type(params[#params-1]) == "function" then
			local func = params[#params-1]
			local userdata = params[#params]
			table.remove(params, #params)
			table.remove(params, #params)
			local res, callid = self.Session:AsynCallReply("defaultInterface", "IPCCall", event, unpack(params), function(...)
				func(userdata, ...)
			end)
			return true, res, callid
		else
			local res, callid = self.Session:AsynCallReply("defaultInterface", "IPCCall", event, unpack(params))
			return true, res, callid
		end
	else
		local res, callid = self.Session:AsynCall("defaultInterface", "IPCCall", event, unpack(params))
		return true, res, callid
	end
end

-- 同步调用 webbrowser的远程方法
function YBYL.IPC:SyncIPCCall(event, ...)
	if not self.Session then
		return false
	end
	return self.Session:SyncCallTimeout("defaultInterface", "IPCCall", 30000, event, ...)
end

function YBYL.IPC:OnTranslateAccelerator(_, hwnd, msg, wparam, lparam)	
	--[[
	self:IPCCall("OnTranslateAccelerator", hwnd, msg, wparam, lparam)	
	if msg ~= 0x100 and msg ~= 0x104 then -- WM_KEYDOWN
		return
	end
	local lctrl = (YBYL.YBYLPre.Utility:GetKeyState(0x11) < 0) and 1 or 0
	local lshift = (YBYL.YBYLPre.Utility:GetKeyState(0x10) < 0) and 1 or 0
	local lalt = (YBYL.YBYLPre.Utility:GetKeyState(0x12) < 0) and 1 or 0
	
	local mapKey = wparam * 0x10000
	if wparam ~= 16 and wparam ~= 17 and wparam ~= 18 then
		mapKey = BitOr(mapKey, lalt)
		mapKey = BitOr(mapKey, lctrl * 0x2)
		mapKey = BitOr(mapKey, lshift * 0x4)
	end
	for i = 1, #self.ShortcutTable do
		if self.ShortcutTable[i] == mapKey then			
			tFunHelper.TipLog("OnTranslateAccelerator HotKey OnKeyDown: mapKey", mapKey)
			self:IPCCall("OnHotKey2", mapKey)
			return 1
		end
	end
	--]]
end

function YBYL.IPC:OnTranslateUrl(_, dwTranslate, url)
	-- 转化一些url
	--[[local interURL = self:GetInternalURL(url)
	if interURL then
		return interURL
	end
	]]
end

function YBYL.IPC:AttachBrowserEvent()
	-- 标题
	self.WebBrowserObj:AttachListener("OnTitleChange", true, function(_, ...)
		self:IPCCall(...)
	end)
	-- 处理 前进/后退 按钮状态
	self.WebBrowserObj:AttachListener("OnCommandStateChange", false, function(_, ...)
		self:IPCCall(...)
	end)

	self.WebBrowserObj:AttachListener("OnNewWindow3", true, function(_, ...)
		return self:IPCCall(...)
	end)

	-- 去拉图标
	self.WebBrowserObj:AttachListener("OnNavigateComplete2", false, function(_, ...)
		self:IPCCall(...)
	end)
end


local SnapshotTimer = nil
function YBYL.IPC:SnapshotWindowBitmap(snapshotWidth, snapshotHeight, filePath)
	tFunHelper.TipLog("SnapshotWindowBitmap....")
	if not self.WebBrowserObj then
		YBYL.Helper.Assert(false)
		return
	end
	local browser = self.WebBrowserObj:GetWebBrowserObject()
	local theBitmap = browser:GetWindowBitmap()	
	if theBitmap then 
		YBYL.Helper.xlgraphicplusfactory:SaveXLBitmapToPngFile(theBitmap, filePath)
	end
	if SnapshotTimer == nil then 
		SnapshotTimer = SetOnceTimer(function()
			collectgarbage("collect")
			SnapshotTimer = nil
		end ,5000)
	end 	
	-- local bitmap = YBYL.YBYLPre.BrowserExternal:GetWindowBitmap(self.WebBrowserObj:GetRawWebBrowser())
	-- if not bitmap then
		
	-- end	
	-- local _, width, height = bitmap:GetInfo()
		
	-- if width > snapshotWidth then
		-- height = math.floor(height * snapshotWidth / width)
		-- width = snapshotWidth
	-- end
	
	-- if height > snapshotHeight then
		-- width = math.floor(width * snapshotHeight / height)
		-- height = snapshotHeight
	-- end
	
	-- local saveBitmap = YBYL.Helper.xlgraphicfactory:CreateBitmap("ARGB32", width, height)
	-- YBYL.YBYLPre.Utility:StretchBlend(saveBitmap, {0, 0, width, height}, bitmap, {BlendType = 1, ConstAlpha = 255, StretchType = 0x01})	
	-- YBYL.Helper.xlgraphicplusfactory:SaveXLBitmapToPngFile(saveBitmap, filePath)
	
	return true
end

function YBYL.IPC:OnIPCCall(event, ...)
	tFunHelper.TipLog("OnIPCCall event=", event, ", ", ArrayToStr(...))
	if event == "CallFunction" then
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
		local globalName = ...
		if type(globalName) ~= "string" then
			YBYL.Helper.Assert(false, "OnIPCCall GetGlobal globalName="..tostring(globalName))
			return
		end
		return loadstring("return "..globalName)()
	elseif event == "Init" then
		-- 服务器来获取初始化的信息
		local id, url, parentWnd, hidenWndClass = ...
		tFunHelper.TipLog("Init url : ", url, ", parentWnd : ", parentWnd, ", hidenWndClass : ", hidenWndClass)
		self.ID = id		
		self.ParentWnd = parentWnd				
		-- if not YBYL.YBYLPre.Utility:Call("IsWindow",self.ParentWnd) then
			-- tFunHelper.TipLog("ParentWnd is not window, handle : ", self.ParentWnd)
			-- AsynCall(YBYL.Exit)
			-- return
		-- end
		local bInit = self:Init()		
		if not bInit then
			tFunHelper.TipLog("Init failed!")
			AsynCall(YBYL.Exit)
			return
		end
		
		self.HostWnd:SetParent(self.ParentWnd)
		
		if url and #url > 0 then
			AsynCall(function()				
				self.WebBrowserObj:Navigate(url)
			end)
		end
		
		self.YBYLHidenWndClass = hidenWndClass
		
		self.WebBrowserObj:SetObjPos(0, 0, "father.width", "father.height")
		self.HostWnd:Show(4)
		self.HostWndHandle = tonumber(string.match(tostring(self.HostWnd:GetWndHandle()), "userdata: (.+)"), 16)		
		
		return self.HostWndHandle
	elseif event == "CoMarshalInterface" then
		-- local IWebBrowser2 = self.WebBrowserObj:GetRawWebBrowser()
		-- if not IWebBrowser2 then
			-- tFunHelper.TipLog("CoMarshalInterface GetRawWebBrowser null")
			-- return
		-- end
	
	elseif event == "SetRealFocus" then
		local focus = ...
		if self.WebBrowserObj then
			self.WebBrowserObj:SetRealFocus(focus)
		end
	elseif event == "GetAttribute" or
		event == "Navigate" or
		event == "GetURL" or
		event == "GetBusy" or
		event == "Stop" or
		event == "Refresh" or
		event == "Home" or
		event == "GoBack" or
		event == "GoForward" or
		event == "EnableContextMenu" or
		event == "RegisterAsDropTarget" or
		event == "GetLocationURL" or
		event == "EnableScriptError" or
		event == "Show" or
		event == "GetState" or
		event == "GetRawWebBrowser" or 
		event == "GetWindow" then
		-- 调用的是WebBrowser方法		
		if not self.WebBrowserObj then
			YBYL.Helper.Assert(false)
			return
		end
		
		local func = self.WebBrowserObj[event]		

		if type(func) == "function" then			
			return func(self.WebBrowserObj, ...)
		end
	elseif event == "get_ScrollTop" then
		if not self.ExternalObj then
			YBYL.Helper.Assert(false)
			return
		end
		return self.ExternalObj:Call(event, ...)
	elseif event == "SnapshotWindowBitmap" then
		if not self.WebBrowserObj then
			YBYL.Helper.Assert(false)
			return
		end
		return self:SnapshotWindowBitmap(...)
	else
		-- 其他事件到感兴趣的地方处理
		local retTable = {self:dispatchEvent("OnIPCCall", event, ...)}
		-- 返回第一个参数是表示是否处理过的
		table.remove(retTable, 1)
		return unpack(retTable)
	end
end

function YBYL.IPC:InitWebBrowser()		
	self.ExternalObj = YBYL.YBYLPre.BrowserExternal:Call("CreateExternal",YBYL.IPC.ID)	
	self.ExternalObj:SetSession(self.Session)
	self.WebBrowserObj:SetExternal(self.ExternalObj)
	
	self:AttachBrowserEvent()
	self:dispatchEvent("OnInitWebBrowser", self.WebBrowserObj)
end

function YBYL.IPC:OnWindowMessage(msg, wparam, lparam)	
	-- lResult = SendMessage(      // returns LRESULT 
	-- in lResult     (HWND) hWndControl,      // handle to destination control     
	-- (UINT) WM_DROPFILES,      // message ID    0x0233
	-- (WPARAM) wParam,      // = (WPARAM) (HDROP) hDrop;    
	-- (LPARAM) lParam      // = 0; not used, must be zero ); 	
	-- if msg == 0x0233 then 
		-- local files = YBYL.YBYLPre.Utility:DragQueryFile(wparam)
		-- tFunHelper.TipLog("DropTarget Receive " .. files.count .. " files")
		-- local _files = ""
		-- for k,v in pairs(files) do
			-- if tonumber(k) then
				-- _files = _files .." \"" .. files[k] .. "\" /sopenfrom IPCDrag"
			-- end
		-- end
		local hDestWnd = YBYL.YBYLPre.Utility:FindWnd(self.YBYLHidenWndClass)
		if hDestWnd and hDestWnd ~= 0 then
			-- 发 copydata 到 YBYL
			-- WM_COPYDATA 0x004a
			YBYL.YBYLPre.Utility:SendMessage(hDestWnd, msg, wparam, lparam)
		else
			tFunHelper.TipLog("YBYL HidenWnd NOT Found!!! Canel Drop!")
		end
	-- end
end

function YBYL.IPC:OnBrowserWndMsg(_, msgdesc, ...)	
	
	
	if "OnKeyDown" == msgdesc then
		
		local bCtr = (YBYL.YBYLPre.Utility:GetKeyState(0x11) < 0) and 1 or 0
		local bShift = (YBYL.YBYLPre.Utility:GetKeyState(0x10) < 0) and 1 or 0
		local bAlt = (YBYL.YBYLPre.Utility:GetKeyState(0x12) < 0) and 1 or 0
	
		local uChar = ...	
		local mapKey = uChar * 0x10000
		if uChar ~= 16 and uChar ~= 17 and uChar ~= 18 then
			mapKey = BitOr(mapKey, bAlt)
			mapKey = BitOr(mapKey, bCtr * 0x2)
			mapKey = BitOr(mapKey, bShift * 0x4)
		end
		for i = 1, #self.ShortcutTable do						
			if self.ShortcutTable[i] == mapKey then		
			
				tFunHelper.TipLog("OnBrowserWndMsg HotKey OnKeyDown: mapKey", mapKey)
				self:IPCCall("OnHotKey2", mapKey)
				return true
			end
		end
	end
	return true
end

function YBYL.IPC:ProcessWindowResize()

	local browser = self.WebBrowserObj:GetWebBrowserObject()	
	YBYL.WindowMsgManager:AddMsgSource(browser,nil,true)
	YBYL.WindowMsgManager:addEventListener("OnWindowMessage", self.OnBrowserWndMsg, self)
	-- self.ExternalObj:AddIEWindowResizeRect({left = 7, right = 7, bottom = 7}, hXmpBrowserWnd)
end

function YBYL.IPC:ProcessWindowMsg()	
	self:ProcessWindowResize()	
	-- YBYL.YBYLPre.Utility:DragAcceptFiles(self.HostWnd:GetWndHandle(),true)
	-- self.HostWnd:AddInputFilter(false, function(_, ...) return self:OnWindowMessage(...) end)	
end


function CreateWndByName(strHostWndName, strTreeName)
	local bSuccess = false
	local strInstWndName = strHostWndName..".Instance"
	local strInstTreeName = strTreeName..".Instance"
	local objHostWnd = nil
	local objTree = nil
	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local frameHostWndTemplate = templateMananger:GetTemplate(strHostWndName, "HostWndTemplate" )
	if frameHostWndTemplate then
		objHostWnd = frameHostWndTemplate:CreateInstance(strInstWndName)
		if objHostWnd then
			local objectTreeTemplate = nil
			objectTreeTemplate = templateMananger:GetTemplate(strTreeName, "ObjectTreeTemplate")
			if objectTreeTemplate then
				objTree = objectTreeTemplate:CreateInstance(strInstTreeName)
				if objTree then
					objHostWnd:BindUIObjectTree(objTree)
					local iRet = objHostWnd:Create()
					if iRet ~= nil and iRet ~= 0 then
						bSuccess = true
					end
				end
			end
		end
	end

	return bSuccess, objHostWnd, objTree
end


function YBYL.IPC:Init()
	-- 创建窗口	
	local bSuccess, objHostWnd, objTree = CreateWndByName("WebBrowserWnd", "WebBrowserWndTree")	
	if not bSuccess or objHostWnd == nil or objTree == nil then
		tFunHelper.TipLog("[YBYL.IPC:Init] create WebBrowserWnd failed ")
		AsynCall(YBYL.Exit)
		return false
	end
	
	self.HostWnd = objHostWnd 
	self.WebBrowserObj = objTree:GetUIObject("WebBrowser")		
	
	if self.WebBrowserObj == nil then		
		AsynCall(YBYL.Exit)
		return false
	end	
	
	self:AttachBrowserEvent()
	-- self:InitWebBrowser()
	-- self.WebBrowserObj:CreateWebBrowser()
	-- self.WebBrowserObj:Show(true)
	-- self.WebBrowserObj:SetNavigateTimer()	
	return true
end



function YBYL.IPC:RegisterMethod()
	tFunHelper.TipLog("RegisterMethod")
	self.Session:RegisterInterface("defaultInterface")
	-- 一个接口就够了，第一个参数表示方法名
	self.Session:RegisterMethod("defaultInterface", "IPCCall", function(...) return self:OnIPCCall(...) end)
end

function YBYL.IPC:OnAsynConnectServer(session, res)
	tFunHelper.TipLog("OnAsynConnectServer, res=", res, ", session=", session)
	if res == 0 and session then
		self.Session = session
		self:RegisterMethod()
		self.Session:SetCloseCallback(function()
			tFunHelper.TipLog("OnSessionCloseCallback, session=", self.Session)
			self.Session = nil
			AsynCall(YBYL.Exit)
		end)
	elseif res == XLIPC_RESULT_WAITTHREAD_NONE then
		if self.nTryTimes > XLIPC_CONNECT_TRY_TIMES then
			tFunHelper.TipLog("OnAsynConnectServer res == XLIPC_RESULT_WAITTHREAD_NONE, try times : ", self.nTryTimes, ", exit...")
			AsynCall(YBYL.Exit)
			return
		end
		-- 这里，有可能是主线程的等待还没起来，1s后再连一次
		SetOnceTimer(function()
			self.nTryTimes = self.nTryTimes + 1
			local res = self:AsynConnectServer()
			if 0 ~= res then
				tFunHelper.TipLog("AsynConnectServer res ~= 0, exit res : ", res)
				AsynCall(YBYL.Exit)
			end
		end, XLIPC_CONNECT_FAILED_INTERVAL)
	else
		-- 连接失败，直接退出
		AsynCall(YBYL.Exit)
	end
end

function YBYL.IPC:OnExit()
	if self.WebBrowserObj and self.ObjectTree and not self.IsRemoving then
		self.IsRemoving = true
		self.ExternalObj:RemoveIEWindowResizeRect()
		self.WebBrowserObj:GetFather():RemoveChild(self.WebBrowserObj)
		self.WebBrowserObj = nil
		self.IsRemoving = false
	end
	if self.Session then
		self.Session:Close()
		self.Session = nil
	end
end


function YBYL:Exit()
	tipUtil:Exit()
end


function YBYL.IPC:AsynConnectServer()
	local ipcfactory = XLGetObject("Xunlei.UIEngine.IPC.Factory")
	if not ipcfactory then
		return -1
	end
	
	local res = ipcfactory:AsynConnectServer(self.ID, 0, function(session, res) self:OnAsynConnectServer(session, res) end)
	tFunHelper.TipLog("AsynConnectServer, res=", res," ID=",self.ID)
	return res
end

function YBYL.IPC:Run()
	local bRet, strServerID = tFunHelper.GetCommandStrValue("/connect")
	if not bRet or not IsRealString(strServerID) then
		return false
	end	

	-- ID 是作为客户端，服务器的id
	self.ID = strServerID
	self.nTryTimes = 1
	-- 连接 YBYL.exe服务器
	local res = self:AsynConnectServer()
	-- if 0 ~= res then
		-- tFunHelper.TipLog("AsynConnectServer res ~= 0, abort res : ", res)
		-- return false
	-- end
	self.ShortcutTable = 
	{
		BitOr(string.byte("O", 1) * 0x10000, 0x2), -- openfile
		BitOr(string.byte("W", 1) * 0x10000, 0x2), -- exit
		BitOr(string.byte("H", 1) * 0x10000, 0x2), -- browserhistory
		BitOr(string.byte("T", 1) * 0x10000, 0x2), -- addnewtab
		BitOr(string.byte("K", 1) * 0x10000, 0x2), -- reopencurrenttab
		BitOr(string.byte("D", 1) * 0x10000, 0x1), -- topbarinputurl
		BitOr(9 * 0x10000, 0x2), 				   -- ctrl+tab
		BitOr(9 * 0x10000, 0x6), 				   -- ctrl+shift+tab
		BitOr(112* 0x10000, 0), -- 快捷键说明 F1
		BitOr(113* 0x10000, 0), -- sysconfig F2    
		BitOr(114* 0x10000, 0), -- about F2    
	}
	-- YBYL.YBYLPre.self:AttachListener("OnExit", self.OnExit, self)
	SetOnceTimer(function()
		-- 10s连不上，那就退出
		if self.Session == nil then
			tFunHelper.TipLog("AsynConnectServer timeout, 10s, exit.")
			YBYL.Exit()
		end
	end, 10*1000)
	return true
end
	
local bRun = YBYL.IPC:Run()

if not bRun then
	-- 服务器启动失败，直接退出
	YBYL.Exit()
end


