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
	return objText
end


function GetLocalURL(self)
	local objWebBrowser = self:GetBindBrowserCtrl()
	if objWebBrowser then
		local strURL = objWebBrowser:GetLocationURL()
		if IsRealString(strURL) then
			return strURL
		end
	end
	
	local attr = self:GetAttribute()
	return attr.strInputURL   
end

--用户输入的url
function SaveInputURL(self, strURL)
	local attr = self:GetAttribute()
	attr.strInputURL = strURL
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
	local objActvieBkg = self:GetControlObject("WebTabCtrl.Active.Bkg")
	
	if bActive then
		FocusOnBrowser(self)
		objActvieBkg:SetTextureID("YBYL.Tab.Active")
		self:SetCursorID("IDC_ARROW")
	else
		objActvieBkg:SetTextureID("")
		self:SetCursorID("IDC_HAND")
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
	
	attr.objBrowserCtrl:AttachListener("Fire_OnNavigateComplete2", false, 
		function (objBrowser, strEventName, strURL)
			SetAddressBarState(self, strURL)
			DownloadTabIco(self, strURL)
		end)
	
	attr.objBrowserCtrl:AttachListener("Fire_OnTitleChange", false, 
		function (objBrowser, strEventName, strTitle)
			SetTabTitle(self, strTitle)
		end)
		
	attr.objBrowserCtrl:AttachListener("Fire_OnNewWindow3", false, 
		function (objBrowser, strEventName, nFlags, strUrlContext, strUrl)
			if IsRealString(strUrl)	then
				tFunHelper.OpenURL(strUrl)
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
end

function OnMouseLeaveTab(self)
	ShowMouseEnterBkg(self, false)
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



--只隐藏控件， 是否销毁交给父控件决定
function OnClickCloseTab(self)
	local objRootCtrl = self:GetOwnerControl()
	local nTabID = objRootCtrl:GetSelfID()
	
	objRootCtrl:SetVisible(false)
	objRootCtrl:SetChildrenVisible(false)
	
	objRootCtrl:FireExtEvent("OnCloseTabItem", nTabID)
end

------
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


function SetTabTitle(objRootCtrl, strTitle)
	if not IsRealString(strTitle) then
		return
	end

	local objText = objRootCtrl:GetControlObject("WebTabCtrl.Text")
	objText:SetText(strTitle)
end


function SetTabIco(objRootCtrl, strIcoPath)
	if not tipUtil:QueryFileExists(tostring(strIcoPath)) then
		return
	end
	
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local objBitmap = xlgraphic:CreateBitmap(strIcoPath,"ARGB32")
	
	local objImage = objRootCtrl:GetControlObject("WebTabCtrl.HeadImg")
	if objImage then
		objImage:SetBitmap(objBitmap)
	end		
end


function SetAddressBarState(objRootCtrl, strURL)
	local bActive = GetActiveState(objRootCtrl)
	if not bActive then
		return
	end

	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
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
	end
end


function DownloadTabIco(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return 
	end
	
	local strLocalURL = objRootCtrl:GetLocalURL()
	if strURL ~= strLocalURL then
		return
	end
	
	local strDomain = string.match(strURL, "(http://[^/]+)")		
	if not IsRealString(strDomain) then	
		return
	end
	
	local strIconURL = strDomain .. "/favicon.ico"	
	local strTempDir = tFunHelper.GetProgramTempDir("webbrowser\\ico")
	local strIcoID = tipUtil:GetStringMD5(strIconURL)
	local strIcoSuffix = tostring(strIcoID)..".ico" 
	local strSavePath = tipUtil:PathCombine(strTempDir, strIcoSuffix)
	
	if tipUtil:QueryFileExists(strSavePath) then
		SetTabIco(objRootCtrl, strSavePath)
	else
		tFunHelper.NewAsynGetHttpFile(strIconURL, strSavePath, false, 
		function(bRet, strIcoPath)
			tFunHelper.TipLog("[DownloadTabIco] strURL=" .. strIconURL .. " saveIcoPath=",strSavePath)
			if bRet == 0 then
				SetTabIco(objRootCtrl, strIcoPath)
			end
		
		end, 60*1000)
	end			
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
	
	if bShow then
		objMsEnterBkg:SetTextureID("YBYL.Tab.MouseEnter")
	else
		objMsEnterBkg:SetTextureID("")
	end
end



function RouteToFather(self)
	self:RouteToFather()
end
------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end