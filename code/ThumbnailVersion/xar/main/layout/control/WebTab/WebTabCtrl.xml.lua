local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


-----方法----
function SetTabText(self, strText)
	local objText = self:GetControlObject("WebTabCtrl.Text")
	if objText then
		objText:SetText(tostring(strText))
	end
end

function GetTabText(self)
	local objText = self:GetControlObject("WebTabCtrl.Text")
	if objText then
		return objText:GetText()
	end
end


function GetIcoName(self)
	local attr = self:GetAttribute()
	return attr.strIcoName
end


function GetLocalURL(self)
	local objWebBrowser = self:GetBindBrowserCtrl()
	if objWebBrowser then
		local strURL = objWebBrowser:GetLocationURL()
		if IsRealString(strURL) then
			return strURL
		end
	end
	
	return self:GetUserInputURL()
end

--用户输入的url
function SaveUserInputURL(self, strURL)
	local attr = self:GetAttribute()
	attr.strInputURL = strURL
end

function GetUserInputURL(self)
	local attr = self:GetAttribute()
	return attr.strInputURL
end


function SetSelfID(self, nID)
	local attr = self:GetAttribute()
	attr.bTabID = tonumber(nID)
end

function GetSelfID(self)
	local attr = self:GetAttribute()
	return attr.bTabID
end


function SetActiveStyle(self, bActive)	
	if bActive then
		FocusOnBrowser(self)
		ShowActiveBkg(self, true)
		self:SetCloseBtnVisible(true)
	else
		ShowActiveBkg(self, false)
		self:SetCloseBtnVisible(false)
	end
		
	ShowMouseEnterBkg(self, false)
	SetActiveState(self, bActive)	
end


function BindBrowserCtrl(self, objWebBrowser)
	if not objWebBrowser then
		return
	end

	local attr = self:GetAttribute()
	attr.objBrowserCtrl = objWebBrowser
	
	attr.objBrowserCtrl:AttachListener("OnNavigateComplete2", false, 
		function (objBrowser, strEventName, strURL)
			SetAddressBarState(self)
			DownloadTabIco(self, strURL)
			
			local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
			local timerID = timerManager:SetTimer( function ( item, id )
					item:KillTimer(id)
					self:SetWindowBitmap()	
				end, 100)
		end)
	
	attr.objBrowserCtrl:AttachListener("OnTitleChange", false, 
		function (objBrowser, strEventName, strTitle)
			SetTabTitle(self, strTitle)
			SetBrowserTitle(strTitle)
		end)
		
	attr.objBrowserCtrl:AttachListener("OnNewWindow3", false, 
		function (objBrowser, strEventName, nFlags, strUrlContext, strUrl)
			if IsRealString(strUrl)	then
				tFunHelper.OpenURLInNewTab(strUrl)
				return true
			end
		end)	
	attr.objBrowserCtrl:AttachListener("OnDownload", false, 
		function (objBrowser, strEventName, URL, lpHeaders, lpRedir, pmk, pbc)
			if IsRealString(URL) then
				AsynCall(function()
					local bDownload = tipUtil:DownloadFileByIE(URL)
				end)
				self:CloseTab()
				return true
			end
		end)
end


function GetBindBrowserCtrl(self, objWebBrowser)
	local attr = self:GetAttribute()	
	return attr.objBrowserCtrl
end

function GetGoBackState(self)
	local attr = self:GetAttribute()
	return attr.bGoBackState	
end

function SetGoBackState(self, bGoBackState)
	local attr = self:GetAttribute()
	attr.bGoBackState = bGoBackState
end

function GetGoForwardState(self)
	local attr = self:GetAttribute()
	return attr.bGoForwardState	
end

function SetGoForwardState(self, bGoForwardState)
	local attr = self:GetAttribute()
	attr.bGoForwardState = bGoForwardState
end


function SetNewURLState(self, bIsOpening)
	local attr = self:GetAttribute()
	attr.bNewURLState = bIsOpening
end

function GetNewURLState(self)
	local attr = self:GetAttribute()
	return attr.bNewURLState
end

function AddCurURLIndex(self, nDiff)
	local attr = self:GetAttribute()
	attr.nCurURLIndex = attr.nCurURLIndex+nDiff
	
	if attr.nCurURLIndex < 1 then
		attr.nCurURLIndex = 1
		return
	end
	
	if attr.nCurURLIndex > #attr.tCurURLList then
		attr.nCurURLIndex = #attr.tCurURLList
		return
	end
end

function SetCloseBtnVisible(self, bVisible)
	local objCloseBtn = self:GetControlObject("WebTabCtrl.CloseBtn")
	objCloseBtn:SetVisible(bVisible)
	objCloseBtn:SetChildrenVisible(bVisible)
end


function GetWindowBitmap(self)
	local attr = self:GetAttribute()
	return attr.hWindowBitmap
end

function SetWindowBitmap(self)
	local attr = self:GetAttribute()
	local objCurrentBrowser = self:GetBindBrowserCtrl()
	if not objCurrentBrowser then
		return
	end
	
	local hWindowBitmap = objCurrentBrowser:GetWindowBitmap()
	attr.hWindowBitmap = hWindowBitmap
end


function CloseTab(objRootCtrl)
	local nTabID = objRootCtrl:GetSelfID()
	
	objRootCtrl:SetVisible(false)
	objRootCtrl:SetChildrenVisible(false)
	
	objRootCtrl:FireExtEvent("OnCloseTabItem", nTabID)
end


function ShowGif(self)
	local objCurrentBrowser = self:GetBindBrowserCtrl()
	if not objCurrentBrowser then
		return
	end
	
	if objCurrentBrowser:GetBusy() then
		SetHeadImageGif(self, true)
	end
	
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	timerManager:SetTimer(function(item, id)
			if objCurrentBrowser:GetBusy() then
				-- SetHeadImageGif(self, true)
			else
				SetHeadImageGif(self, false)
				item:KillTimer(id)	
			end
			
		end, 500)
end

-----事件----
function OnInitControl(self)
	self:SetSelfID(0)
	SetActiveState(self, false)
	self:SetGoBackState(false)
	self:SetGoForwardState(false)
end

function OnLButtonDown(self)
	self:SetCaptureMouse(true)
end

function OnClickTab(self, x, y)   --LButtonUp
	local nTabID = self:GetSelfID()
	self:FireExtEvent("OnClickTabItem", nTabID)
	
	local attr = self:GetAttribute()
	attr.strDragState = "cancel"
	self:FireExtEvent("OnDrag", attr.strDragState, x, y)
	self:SetCaptureMouse(false)
end


function OnMouseEnterTab(self)
	ShowMouseEnterBkg(self, true)
	
	local strTitle = self:GetTabText()
	local strURL = self:GetLocalURL()
	local strText = strTitle.."\r\n"..strURL
	tFunHelper.ShowToolTip(true, strText)
end


function OnMouseLeaveTab(self)
	ShowMouseEnterBkg(self, false)
	tFunHelper.ShowToolTip(false)
end


function OnMouseMoveTab(self, x, y, nFlag)
    local attr = self:GetAttribute()

	if nFlag == 0x0001 then --左键按下
		if attr.strDragState == nil or attr.strDragState == "cancel" then
			attr.strDragState = "start"
		elseif attr.strDragState == "start" then
			attr.strDragState = "draging"
		end
		self:FireExtEvent("OnDrag", attr.strDragState, x, y)
	end
end


function OnMButtonUp(self)
	local objCloseBtn = self:GetControlObject("WebTabCtrl.CloseBtn")
	local bCloseBtnVisible = objCloseBtn:GetVisible()
	
	if bCloseBtnVisible then
		CloseTab(self)
	end
end


function OnRButtonUpItem(self)
	local bRButtonPopup = true
	tFunHelper.TryDestroyOldMenu(self, "RBtnWebTabMenu")
	tFunHelper.CreateAndShowMenu(self, "RBtnWebTabMenu", 0, bRButtonPopup)
end


--只隐藏控件， 是否销毁交给父控件决定
function OnClickCloseTab(self)
	CloseTab(self:GetOwnerControl())
end


function OnMouseEnterClose(self)
	tFunHelper.ShowToolTip(true, "关闭选项卡(Ctrl+W)")
end

function HideToolTip(self)
	tFunHelper.ShowToolTip(false)
end

------


function SetHeadImageGif(objRootCtrl, bSetGif)
	local objGif = objRootCtrl:GetControlObject("WebTabCtrl.Loading")
	local objHeadImg = objRootCtrl:GetControlObject("WebTabCtrl.HeadImg")
	if not objGif then
		return
	end

	objGif:SetVisible(bSetGif)
	objHeadImg:SetVisible(not bSetGif)
	
	if bSetGif then
		objGif:Play()
	else
		objGif:Stop()
	end
end


function FocusOnBrowser(objRootCtrl)
	local objBrowser = objRootCtrl:GetBindBrowserCtrl()
	if objBrowser then
		objBrowser:SetRealFocus(true)
	end
end


function SetActiveState(objRootCtrl, bActive)
	local attr = objRootCtrl:GetAttribute()
	attr.bTabActive = bActive
end


function GetActiveState(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	return attr.bTabActive
end


function SaveTitleToHistory(objRootCtrl, strTitle)
	local strURL = objRootCtrl:GetLocalURL()
	if string.find(strTitle, strURL) then --简单过滤
		return
	end

	local strFileKey = "tUrlHistory"
	tFunHelper.SaveLctnNameToFile(strURL, strTitle, strFileKey)
end

function SaveIcoNameToHistory(objRootCtrl, strIcoName)
	local strURL = objRootCtrl:GetLocalURL()
	
	local strFileKey = "tUrlHistory"
	tFunHelper.SaveIcoNameToFile(strURL, strIcoName, strFileKey)
end


function PushTitleToList(objRootCtrl, strTitle)
	local attr = objRootCtrl:GetAttribute()
	local bNewURLState = objRootCtrl:GetNewURLState()
	if not bNewURLState then
		return
	end
	objRootCtrl:SetNewURLState(false)
	
	if type(attr.tCurURLList) ~= "table" then
		attr.tCurURLList = {}
	end
	local tCurURLList = {}
	tCurURLList["strURL"] = objRootCtrl:GetLocalURL()
	tCurURLList["strTitle"] = strTitle
	table.insert(attr.tCurURLList, 1, tCurURLList)
	
	local nIndex = #tCurURLList+1
	attr.nCurURLIndex = nIndex
end

local g_hTimer = nil
local g_strLastTitle = ""
function SetTabTitle(objRootCtrl, strTitle)
	if not IsRealString(strTitle) then
		return
	end
	
	objRootCtrl:SetTabText(strTitle)
	SaveTitleToHistory(objRootCtrl, strTitle)
	
	--记录本web的访问历史
	local nTimeSpanInMs = 1 * 1000
	local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	g_strLastTitle = strTitle
	
	if not g_hTimer then
		g_hTimer = timerManager:SetTimer(function(item, id)
		
			PushTitleToList(objRootCtrl, g_strLastTitle)
			
			timerManager:KillTimer(g_hTimer)
			g_hTimer = nil
		end, nTimeSpanInMs)
	end
end


function SetIcoName(objRootCtrl, strIcoName)
	local attr = objRootCtrl:GetAttribute()
	attr.strIcoName = strIcoName
end


function SetTabIco(objRootCtrl, strIcoPath, strIcoName)
	if not tipUtil:QueryFileExists(tostring(strIcoPath)) then
		return
	end
	
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local objBitmap = tFunHelper.GetIcoBitmapObj(strIcoName)
	
	local objImage = objRootCtrl:GetControlObject("WebTabCtrl.HeadImg")
	if objBitmap then
		objImage:SetBitmap(objBitmap)
	else
		local strDefResID = tFunHelper.GetDefaultWebTabImgID()
		objImage:SetResID(strDefResID)
	end
	
	SetIcoName(objRootCtrl, strIcoName)
	SaveIcoNameToHistory(objRootCtrl, strIcoName)
end


function SetAddressBarState(objRootCtrl)
	local bActive = GetActiveState(objRootCtrl)
	if not bActive then
		return
	end

	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	strLocalURL = objRootCtrl:GetLocalURL()
	if IsRealString(strLocalURL) then
		objAddressBar:SetText(strLocalURL)
		objAddressBar:AdjustCollectBtnStyle(strLocalURL)

		tFunHelper.SaveUrlToHistory(strLocalURL)
	end
end


function SetAddressBarImage(objRootCtrl, strIcoName)
	local bActive = GetActiveState(objRootCtrl)
	if not bActive then
		return
	end

	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	objAddressBar:SetIcoImage(strIcoName)
end


function DownloadTabIco(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return 
	end
	
	local strLocalURL = objRootCtrl:GetLocalURL()
	if strURL ~= strLocalURL then
		return
	end
	
	tFunHelper.DownLoadIco(strURL, 
		function(bRet, strIcoPath, strIcoName)
			if bRet == 0 then
				SetTabIco(objRootCtrl, strIcoPath, strIcoName)
				SetAddressBarImage(objRootCtrl, strIcoName)
			end
		end)			
end


function ShowMouseEnterBkg(objRootCtrl, bShow)
	local bActive = GetActiveState(objRootCtrl)
	if bActive then
		return
	end
	
	local objMsEnterBkg = objRootCtrl:GetControlObject("WebTabCtrl.MouseEnter.Bkg")
	if not objMsEnterBkg then
		return
	end
	
	objMsEnterBkg:SetVisible(bShow)
end


function SetBrowserTitle(strTitle)
	local objTitleCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Title")
	if not objTitleCtrl then
		return
	end

	objTitleCtrl:SetTitleText(strTitle)
end


function ShowActiveBkg(objRootCtrl, bActive)
	local objActvieBkg = objRootCtrl:GetControlObject("WebTabCtrl.Bkg")
	local objLayout = objRootCtrl:GetControlObject("WebTabCtrl.Layout")
	local l, t, r, b = objLayout:GetObjPos()
	
	if bActive then
		objActvieBkg:SetTextureID("YBYL.Tab.Active")
		objLayout:SetObjPos(0, 0, "father.width", "father.height")
	else
		objActvieBkg:SetTextureID("YBYL.Tab.Normal")
		objLayout:SetObjPos(0, 2, "father.width", "father.height-2")
	end
end


function RouteToFather(self)
	self:RouteToFather()
end
------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end