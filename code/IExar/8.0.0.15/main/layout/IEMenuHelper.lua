local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")
local apiUtil = FunctionObj.tipUtil
local apiAsynUtil = XLGetObject("API.AsynUtil")

local gIEMenu={}
--[[
	WM_COMMAND 0x0111
	--文件
	IDM_PAGESETUP 			2004 页面设置
	IDM_PRINT     			27 打印
	IDM_PRINTPREVIEW      	2003 打印预览
	IDM_CREATESHORTCUT  	2266 桌面快捷方式
	IDM_PROPERTIES  		28  属性
	
	--查看
	
	IDM_REFRESH      2300 刷新
	IDM_STOPDOWNLOAD 2301 停止
	IDM_VIEWSOURCE   2139 查看源代码
	
	工具
	IDM_OPTIONS      2135 Internet选项 
	
	帮助
--]]

	  
function gIEMenu:Init(ctrlBrowser)
	if not ctrlBrowser then
		return
	end

	self.ctrlBrowser = ctrlBrowser
	self.lpWeb2 = ctrlBrowser:GetRawWebBrowser() 
	if self.lpWeb2 ~= nil then
		return true
	end
	--[[
	local hRealWnd = ctrlBrowser:GetWindow()
	if hRealWnd ~= nil then
		local hShellDoc = apiUtil:FindWindowEx(hRealWnd, nil, "Shell DocObject View", nil)
		if hShellDoc ~= nil then
			local hIEServer = apiUtil:FindWindowEx(hShellDoc, nil, "Internet Explorer_Server", nil)
			if hIEServer ~= nil then
				self.hShellDoc = hShellDoc
				self.WndIEServer = hIEServer
				self.ctrlBrowser = ctrlBrowser
				self.lpWeb2 = ctrlBrowser:GetRawWebBrowser() 
				return true
			end
		end	
	end
	--]]
	return false
end

function gIEMenu:OpenFile(strKey)
	local bOpenFileDialog = true 
	local strExtName  = nil
	local strDefName = nil
	local strFilter = "HTML Files (*.htm, *.html, *.mht)|*.htm, *.html, *.mht|Text Files (*.txt)|*.txt|GIF Files (*.gif)|*.gif|JPGE Files (*.jpg, *.jpge)|*.jpg, *.jpge|All Files (*.*)|*.*||"
	return apiUtil:FileDialog(bOpenFileDialog, strFilter, strExtName, strDefName)
end

local gMenuCMD = {
			--文件
			Open = gIEMenu.OpenFile,
			--SaveAS = apiUtil.IEMenu_SaveAs,
			PageSetup = {0x0111, 2004+1*65536,0},
			Print = {0x0111, 27+1*65536,0},
			PrintReview = {0x0111, 2003+1*65536,0},
			CreateShortCut = {0x0111, 2266+1*65536,0},
			Properties = {0x0111, 28+1*65536,0},
			
			--查看
			Refresh = {0x0111, 2300+1*65536,0},
			StopDownLoad = {0x0111, 2301+1*65536,0},
			ViewSource = {0x0111, 2139+1*65536,0},
			--Zoom = apiUtil.IEMenu_Zoom,
			--工具
			--Options = {0x0111, 2135+1*65536,0},	
			
			--收藏夹
			AddFav = {0x0111, 2261+1*65536,0},	
			--OrganizeFav = apiUtil.IEFavorite_Organize,
			
			--编辑
			SelectAll = {0x0111, 31+1*65536,0},
			Copy = {0x0111, 15+1*65536,0},
			Cut = {0x0111, 16+1*65536,0},
			Paste = {0x0111, 26+1*65536,0},
			
	  }

function gIEMenu:ExecuteCMD(strKey,...)
	if type(gMenuCMD[strKey]) == "table" then
		local hRealWnd = self.ctrlBrowser:GetWindow()
		
		if hRealWnd == nil then
			return
		end
		
		local hShellEmb = apiUtil:FindWindowEx(hRealWnd, nil, "Shell Embedding", nil)
		if hShellEmb == nil then
			hShellEmb = hRealWnd  --兼容xlue的版本
		end
		
		local hShellDoc = apiUtil:FindWindowEx(hShellEmb, nil, "Shell DocObject View", nil)
		if hShellDoc == nil then
			return
		end	
		
		local hIEServer = apiUtil:FindWindowEx(hShellDoc, nil, "Internet Explorer_Server", nil)
		if hIEServer ~= nil then
			apiUtil:PostWndMessageByHandle(hIEServer,gMenuCMD[strKey][1],gMenuCMD[strKey][2],0)
		end
		return
		
	elseif 	strKey == "SaveAS" then
		apiUtil:IEMenu_SaveAs(self.lpWeb2)
	elseif 	strKey == "Zoom" then
		apiUtil:IEMenu_Zoom(self.lpWeb2,...)
		--gMenuCMD[strKey](self.lpWeb2,...)
	elseif 	strKey == "OrganizeFav" then
		local hMainWnd = ...
		apiUtil:IEFavorite_Organize(hMainWnd)
	elseif strKey == "Options" then
		local funCallBack = ...
		local hMainWnd = 0
		local hUEMainWnd = FunctionObj:GetMainWndInst()
		if hUEMainWnd ~= nil then
			hMainWnd = hUEMainWnd:GetWndHandle() or 0
		end
		apiAsynUtil:AsynCreateProcess("", "rundll32.exe shell32.dll,Control_RunDLL inetcpl.cpl,,0", "",32, 1,
			function (nRet, tProcDetail)
				-- fCallback(nRet, tProcDetail) --tProcDetail.hProcess, tProcDetail.hThread, tProcDetail.dwProcessId, tProcDetail.dwThreadId
				
				if nRet == 0 and type(funCallBack) == "function" then
					if tProcDetail.hProcess ~= nil then
						apiAsynUtil:AsynWaitForSingleObject(tProcDetail.hProcess,nil,
							function(nRet)
								if nRet == 0 then
									funCallBack()
								end
							end)
					end
				end
			end)
		
		--apiUtil:ShellExecute(hMainWnd, "open", "rundll32.exe", "shell32.dll,Control_RunDLL inetcpl.cpl,,0", 0, "SW_SHOW")
	elseif 	type(gMenuCMD[strKey]) == "function" then
		return gMenuCMD[strKey](...)
	end	
end
	  
	  
XLSetGlobal("YBYL.IEMenuHelper", gIEMenu)


  