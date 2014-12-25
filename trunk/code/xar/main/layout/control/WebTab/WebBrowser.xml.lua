local FunctionObj = XLGetGlobal("YBYL.FunctionHelper")

function SetExternal( self, webevent )
	local attr = self:GetAttribute()
	attr.External = webevent
end

local gCurRetryTimes = 0	--��ǰ�����Դ���
local gTotalRetryTimes = 1 --�����ʧ�ܣ�����һ��
function Navigate( self, url )
	local attr = self:GetAttribute()
	attr.ErrorUrls = {}
	attr.CompleteUrls = {}
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local browser = self:GetControlObject( "browser" )
	if browser == nil then
		browser = objFactory:CreateUIObject( "browser", "WebBrowseObject" )
		self:AddChild( browser )
	end
	browser:EnableContextMenu(true)
	browser:SetVisible( false )
	browser:SetChildrenVisible( false )
	if attr.External ~= nil then
		browser:SetExternal( attr.External )
	end
	browser:SetObjPos( "0", "0", "father.width", "father.height" )
	local cookie, ret = browser:AttachListener("OnNavigateError", false, function( self, URL )
												table.insert( attr.ErrorUrls, URL )
												for i = 1, #attr.CompleteUrls do
													if attr.CompleteUrls[ i ] == URL then
														table.remove( attr.CompleteUrls, i )
														break
													end
												end
												return true
											 end)
	browser:AttachListener( "OnNavigateComplete2", false, function( obj, URL )
													FunctionObj.TipLog("WebBrowserctrl: OnNavigateComplete2 " .. URL)
													self:FireExtEvent( "Fire_OnNavigateComplete2", URL)
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
																self:FireExtEvent( "Fire_OnCommandStateChange", command, enable )
																return true
														   end )
	browser:Navigate( url )
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	attr.timer = timerManager:SetTimer( function ( item, id )
								if not browser:GetBusy() then
									timerManager:KillTimer( id )
									attr.timer = nil
									for i = 1, #attr.ErrorUrls do
										for j = 1, #attr.CompleteUrls do
											if attr.ErrorUrls[ i ] == attr.CompleteUrls[ j ] then
												table.remove( attr.CompleteUrls, j )
												break
											end
										end
									end
									
									if #attr.CompleteUrls > 0 then
										browser:SetVisible( true )
										browser:SetChildrenVisible( true )
										if type(FunctionObj.ShowTipWnd) == "function" then
											FunctionObj.ShowTipWnd()
										else
											-- FunctionObj:FailExitTipWnd(9)
										end
									else
										browser:SetVisible( false )
										browser:SetChildrenVisible( false )
										self:RemoveChild( browser )
										attr.errorurl = url
										if gCurRetryTimes < gTotalRetryTimes then
											gCurRetryTimes = gCurRetryTimes + 1
											ReloadPage(self)
										else
											-- FunctionObj:FailExitTipWnd(10)
										end
									end
								end
						   end, 500 )  
						   
	browser:AttachListener( "OnTitleChange", false, 
		function(obj, title)
			FunctionObj.TipLog("WebBrowserctrl: OnTitleChange " .. title)
			attr.Title = title 
			self:FireExtEvent("Fire_OnTitleChange", title)
			return true
		end)	

	browser:AttachListener( "OnNewWindow3", false, 
		function(obj, flags, urlContext, url)
			self:FireExtEvent("Fire_OnNewWindow3", flags, urlContext, url)
			return 0, nil, true, true
		end)
end


function GetLocationURL(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:GetLocationURL()
	end
	
	return ""
end

function GoBack(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:GoBack()
	end
end

function GoForward(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:GoForward()
	end
end

function Refresh(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:Refresh()
	end
end

function Stop(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:Stop()
	end
end

function GetBusy(self)
	local browser = self:GetControlObject( "browser" )
	if browser then
		return browser:GetBusy()
	end
end


function SetRealFocus(self, bFocus)
	local browser = self:GetControlObject( "browser" )
	if browser then
		browser:SetRealFocus(bFocus)
	end
end


function OnDestroy( self )
	local attr = self:GetAttribute()
	if attr.timer ~= nil then
		local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
		timerManager:KillTimer( attr.timer )
	end
	return true
end

function ReloadPage(self)
	local attr = self:GetAttribute()
	self:Navigate(attr.errorurl)
	return true
end