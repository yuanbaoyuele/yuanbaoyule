local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil	
	
function GetWeb(self)
	local browser = self:GetControlObject("browser")	
	return browser
end
function SetErrorUrl( self, url )
	local attr = self:GetAttribute()
	attr.ErrorUrl = url
end

function GetErrorUrl( self, url )
	local attr = self:GetAttribute()
	return attr.ErrorUrl
end

function SetExternal( self, webevent )
	local attr = self:GetAttribute()
	attr.External = webevent
	local browser = self:GetControlObject("browser")
	if browser then
		browser:SetExternal( attr.External )
	end
end

function GetBusy( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		return browser:GetBusy()
	end
	return false
end
function Stop( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:Stop()
	end
end

function Refresh( self  )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:Refresh()
	end
end



function Home( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:Refresh()
	end
end

function GoBack( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:GoBack()
	end
end

function GetWindow( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		return browser:GetWindow()
	end
end

function GoForward( self )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:GoForward()
	end
end

function EnableContextMenu( self, bEnable )
	local browser = self:GetControlObject( "browser" )
	local attr = self:GetAttribute()
	attr.ContextMenu = bEnable
	if browser ~= nil then
		browser:EnableContextMenu(bEnable)
	end
end

function RegisterAsDropTarget( self, bEnable )
	local browser = self:GetControlObject( "browser" )
	if browser ~= nil then
		browser:RegisterAsDropTarget(bEnable)
	end
end

function GetLocationURL(self)
	local browser = self:GetControlObject("browser")
	if browser ~= nil then
		return browser:GetLocationURL()
	end
	return nil
end

function GetRawWebBrowser(self)
	local browser = self:GetControlObject("browser")
	if browser ~= nil then
		return browser:GetRawWebBrowser()
	end
	return nil
end

function GetWindowBitmap(self)
	local browser = self:GetControlObject("browser")
	if browser ~= nil then
		return browser:GetWindowBitmap()
	end
	return nil
end


function EnableScriptError(self, enable)
	local browser = self:GetControlObject("browser")
	if browser ~= nil then
		enable = enable or false
		return browser:EnableScriptError(enable)
	end
	return nil
end

function OnInitControl(self)
	local errorbkg = self:GetControlObject("error.bkg")
	local loadingimg = self:GetControlObject("loading.img")
	
	errorbkg:SetVisible(false)
	errorbkg:SetChildrenVisible(false)
	loadingimg:SetVisible(true)
	loadingimg:SetChildrenVisible(true)
	
	local attr = self:GetAttribute()
	local pagename = "SmallErrorPage"
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local page = objFactory:CreateUIObject("error.page", pagename)
	page:SetObjPos("0", "0", "father.width", "father.height")
	errorbkg:AddChild(page)
	
	self:SetVisible(attr.Visible)
	self:SetChildrenVisible(attr.Visible)
	
	if attr.ErrorBkgColorResID then
		errorbkg:SetSrcColor(attr.ErrorBkgColorResID)
		errorbkg:SetDestColor(attr.ErrorBkgColorResID)
	end
	if attr.BkgColorResID then
		local webbkg = self:GetControlObject("web.bkg")
		webbkg:SetSrcColor(attr.BkgColorResID)
		webbkg:SetDestColor(attr.BkgColorResID)
	end
	-- 直接显示loading
	attr.firstNavigate = true
	-- ShowLoadingPage(self)
end

function InitWebBrowserObj(self)
	local attr = self:GetAttribute()
	
	local browser = self:GetControlObject( "browser" )
	browser:SetVisible( true )
	browser:SetChildrenVisible( true )
	
	browser:EnableScriptError(attr.ScriptError)
	--默认不支持右键菜单和拖拽对象
	browser:EnableContextMenu(attr.ContextMenu)
	browser:RegisterAsDropTarget(true)
	if attr.External ~= nil then
		browser:SetExternal( attr.External )
	end
	browser:SetObjPos( "0", "0", "father.width", "father.height" )
	local cookie, ret = browser:AttachListener( "OnNavigateError", false, function( self, URL )
												table.insert( attr.ErrorUrls, URL )
												for i = 1, #attr.CompleteUrls do
													if attr.CompleteUrls[ i ] == URL then
														table.remove( attr.CompleteUrls, i )
														break
													end
												end
												return true
											 end )
	browser:AttachListener( "OnNavigateComplete2", false, function( obj, URL)
													self:FireExtEvent( "OnNavigateComplete2", URL)
													local error_ = false
													for i = 1, #attr.ErrorUrls do
														if attr.ErrorUrls[ i ] == URL then
															error_ = true
															break
														end
													end
													if not error_ then
														table.insert( attr.CompleteUrls, URL )
													end
													return true
												 end )
	browser:AttachListener( "OnCommandStateChange", false, function( obj, command, enable )
																attr[command .. "state" ] = enable 
																self:FireExtEvent( "OnCommandStateChange", command, enable )
																return true
														   end )
	browser:AttachListener("OnTitleChange", false, function(obj, title)
		attr.Title = title 
		self:FireExtEvent("OnTitleChange", title)
		return true
	end)
	browser:AttachListener("OnNewWindow3", false, function(obj, flags, url_context, url)
		local bCancel = self:FireExtEvent("OnNewWindow3", flags, url_context, url)
		if bCancel == nil then bCancel = false end
		return 0, 0, bCancel, true
	end)	
	browser:AttachListener("OnDocumentComplete", false, function(obj, URL)
		self:FireExtEvent("OnDocumentComplete", URL)
	end)
	browser:AttachListener("OnBeforeNavigate2", false, function(obj, URL)		
		self:FireExtEvent("OnBeforeNavigate2", URL)
	end)	
	
	browser:AttachListener("OnDownload", false, function( obj, URL, lpHeaders, lpRedir, pmk, pbc )
		local bCancel = self:FireExtEvent("OnDownload", URL, lpHeaders, lpRedir, pmk, pbc)
		if bCancel == nil then bCancel = false end
		return 0, 0, bCancel, true
	end)

	local rawWebBrowser = browser:GetRawWebBrowser()
	if rawWebBrowser ~= nil then
		tipUtil:AttachBrowserEvent(rawWebBrowser)
	end	
end


function Navigate( self, url )
	local attr = self:GetAttribute()
	attr.ErrorUrls = {}
	attr.CompleteUrls = {}
	-- 第一次Navigate 不做动画，因为在OnInitControl 的时候已经做了
	if attr.firstNavigate then 
		attr.firstNavigate = false
	else
		-- ShowLoadingPage(self)	
	end
	--在初始化URL时，自动为这个URL加上 #gettime()
	--url = url .. "#" .. tostring(os.time())
	attr.url = url
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local browser = self:GetControlObject( "browser" )
	if browser == nil then
		browser = objFactory:CreateUIObject( "browser", "WebBrowseObject" )
		self:AddChild( browser )
		if browser then
			InitWebBrowserObj(self)
		end
	end

	browser:Navigate( url )
	SetErrorUrl(self, "")
	self:FireExtEvent("OnNavigate", url)
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if attr.timer then
		timerManager:KillTimer( attr.timer )
		attr.timer = nil
	end
	attr.timer = timerManager:SetTimer( function ( item, id )
								local killTimer = false
								for i = 1, #attr.ErrorUrls do
									for j = 1, #attr.CompleteUrls do
										if attr.ErrorUrls[ i ] == attr.CompleteUrls[ j ] then
											table.remove( attr.CompleteUrls, j )
											break
										end
									end
								end
								if #attr.CompleteUrls > 0 or not attr.CustomErrorPage then
									SetErrorUrl(self, "")
									browser:SetVisible( true )
									browser:SetChildrenVisible( true )
									HideBkgPage(self)
									killTimer = true
								elseif not browser:GetBusy() then
									self:FireExtEvent( "OnNavigateError", url )
									browser:SetVisible( true )
									browser:SetChildrenVisible( true )
									-- self:RemoveChild( browser )
									ShowErrorPage(self, url)
									-- attr.errorurl = url
									killTimer = true
								end
								if killTimer then
									timerManager:KillTimer( id )
									attr.timer = nil
								end
						   end, 500)
end

function OnDestroy( self )
	local attr = self:GetAttribute()
	if attr.timer ~= nil then
		local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
		timerManager:KillTimer( attr.timer )
	end
	return true
end


function OnBtnRefresh(self)
	local page = self:GetOwnerControl()
	local web = page:GetOwnerControl()
	local attr = web:GetAttribute()
	web:Navigate(attr.errorurl)
	return true
end
function OnBtnClose(self)
	local web = self:GetOwnerControl()
	web:FireExtEvent("OnErrorClose")
end
function OnBtnMin(self)
	local web = self:GetOwnerControl()	
	web:FireExtEvent("OnErrorMin")
end
-- function ShowErrorPage(self)
	-- local bkg = self:GetControlObject("web.bkg")
	-- local errorbkg = self:GetControlObject("error.bkg")
	-- local loadingimg = self:GetControlObject("loading.img")
	
	-- bkg:SetVisible(true)
	-- bkg:SetChildrenVisible(true)
	-- errorbkg:SetVisible(true)
	-- errorbkg:SetChildrenVisible(true)
	-- loadingimg:SetVisible(false)
	-- loadingimg:SetChildrenVisible(false)
	
	-- StopAni(self)
-- end

local g_ErrorURLTimer = nil
function ShowErrorPage(self, url)	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	if g_ErrorURLTimer then
		timerManager:KillTimer( g_ErrorURLTimer )
	end
	
	g_ErrorURLTimer = timerManager:SetTimer( function ( item, id )
		local browser = self:GetControlObject("browser")
		SetErrorUrl(self, url)
		browser:Navigate("res://ieframe.dll/http_303_webOC.htm")
		timerManager:KillTimer( g_ErrorURLTimer )
		g_ErrorURLTimer = nil
	end)
end


function ShowLoadingPage(self)
	StartAni(self)
	local bkg = self:GetControlObject("web.bkg")
	local errorbkg = self:GetControlObject("error.bkg")
	local loadingimg = self:GetControlObject("loading.img")
	
	bkg:SetVisible(true)
	bkg:SetChildrenVisible(true)
	errorbkg:SetVisible(false)
	errorbkg:SetChildrenVisible(false)
	loadingimg:SetVisible(true)
	loadingimg:SetChildrenVisible(true)
end

function HideBkgPage(self)
	local bkg = self:GetControlObject("web.bkg")
	bkg:SetVisible(false)
	bkg:SetChildrenVisible(false)
	
	StopAni(self)
end

function StartAni(self)
	StopAni(self)
	local loadingimg = self:GetControlObject("loading")
	local objectTree = self:GetOwner()
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")		
	local popAniT = templateMananger:GetTemplate("ball.animation","AnimationTemplate")
	if popAniT and objectTree then
		local popAni = popAniT:CreateInstance()
		popAni:BindImageObj(loadingimg)
		objectTree:AddAnimation(popAni)
		popAni:Resume()
		local attr = self:GetAttribute()
		attr.loadingani = popAni
	end
end

function StopAni(self)
	local attr = self:GetAttribute()
	if attr then
		if attr.loadingani then
			attr.loadingani:Stop()
		end
		attr.loadingani = nil
	end
end

function Show(self, visible)
	local attr = self:GetAttribute()
	if attr.Visible == visible then
		return
	end
	attr.Visible = visible
	self:SetVisible(visible)
	self:SetChildrenVisible(visible)
end
function AddSearchAssistant(self , relayer)
	local attr = self:GetAttribute()
	local browser = self:GetControlObject("browser")
	local rawWebBrowser = browser:GetRawWebBrowser()	
	local sniffer = relayer:AddSearchAssistant(rawWebBrowser)
	return sniffer
end
function SetRealFocus(self,focus)
	local browser = self:GetControlObject("browser")
	if browser then
		browser:SetRealFocus(focus)
	end
end