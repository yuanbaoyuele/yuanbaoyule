local tipUtil = XLGetObject("API.Util")
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

local g_bHasMenu = false
-------------窗口
function OnCreate( self )
	local objCollectWnd = self
	SetWindowFullSize(objCollectWnd)
	SetCollectWndTrackSize(objCollectWnd, MainWndW, MainWndH)
	
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	objMainHostWnd:AddSyncWnd(objCollectWnd:GetWndHandle(), {"position", "enable"})
	
	objMainHostWnd:AttachListener("OnSize", false, 
		function(objMainWnd, MainWndW, MainWndH)
			SetCollectWndTrackSize(objCollectWnd, MainWndW, MainWndH)
			
			local objRootCtrl = GetRootCtrlByWndObj(objCollectWnd)
			local attr = objRootCtrl:GetAttribute()
			if attr.bFix then
				SetWindowFullSize(objCollectWnd)
			end
		end		
	)
end


function SetCollectWndTrackSize(objCollectWnd, MainWndW, MainWndH)
	local objHeadWindow = tFunHelper.GetWndInstByName("TipHeadFullScrnWnd.Instance")
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	local objCollectBtn = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectBtn")
	local BtnL, BtnT, BtnR, BtnB = objCollectBtn:GetAbsPos()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainHostWnd:GetWindowRect()
	local nHeadWndL, nHeadWndT, nHeadWndR, nHeadWndB = objHeadWindow:GetWindowRect()
	
	local nWndTop = nHeadWndT+BtnB
	local nSizeH = nMainWndB-nWndTop-4
	
	objCollectWnd:SetMaxTrackSize(450, nSizeH)
end


function OnShowWindow(self, bShow)
	self:SetFocus(true)
	
	local objRootCtrl = GetRootCtrlByWndObj(self)
	local attr = objRootCtrl:GetAttribute()
	if not attr.bFix then
		SetWindowPos(self)
	end
	
	SetFixStyle(objRootCtrl, attr.bFix)
end


function OnFocusChange(self, bFocus)
	local objRootCtrl = GetRootCtrlByWndObj(self)
	local attr = objRootCtrl:GetAttribute()
		
	if not bFocus and not attr.bFix then
		-- local nCursorX, nCursorY = tipUtil:GetCursorPos() 	
		-- local l, t, r, b = objRootCtrl:GetAbsPos()
		-- local objWnd = self

		-- local left,top,right,bottom = objWnd:HostWndRectToScreenRect(l, t, r, b)
		-- if nCursorX > left and nCursorX < right and nCursorY>top and nCursorY<bottom then
			-- return
		-- end
		
		if g_bHasMenu then
			return
		end
		
		self:Show(0)
	end	
end


function OnSize(self, _type, width, height)	
	local objTree = self:GetBindUIObjectTree()
	local objRootLayout = objTree:GetUIObject("root.layout")
	local objRootCtrl = objRootLayout:GetObject("CollectWndCtrl")
	
	if not objRootCtrl then
		return
	end
	
	objRootCtrl:SetObjPos(0, 0, width, height)
	AdjustMainPanelSize(objRootCtrl, width)
end


function SetWindowFullSize(objWnd)
	local objHeadWindow = tFunHelper.GetWndInstByName("TipHeadFullScrnWnd.Instance")
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	local objCollectBtn = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectBtn")
	local HeadL, HeadT, HeadR, HeadB = objHeadCtrl:GetAbsPos()
	local BtnL, BtnT, BtnR, BtnB = objCollectBtn:GetAbsPos()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainHostWnd:GetWindowRect()
	local nHeadWndL, nHeadWndT, nHeadWndR, nHeadWndB = objHeadWindow:GetWindowRect()
	
	local WithoutShadow = tFunHelper.GetMainCtrlChildObj("WithoutShadow")
	local nNoShadowL, nNoShadowT, nNoShadowR, nNoShadowB = WithoutShadow:GetAbsPos()
	
	local nWndTop = nHeadWndT+BtnB
	local nWndLeft = nMainWndL+nNoShadowL+4
	local nWndHeight = nMainWndB-nWndTop-nNoShadowT-10
	
	local selfleft, selftop, selfright, selfbottom = objWnd:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	if tFunHelper.IsBrowserFullScrn() then
		local nWidth, nHeight = tipUtil:GetScreenSize()
		nWndHeight = nHeight
		objWnd:Move(0, 0, wndwidth, nHeight)
	else
		objWnd:Move(nWndLeft, nWndTop, wndwidth, nWndHeight)
	end	
	
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootLayout = objtree:GetUIObject("root.layout")
	local objRootCtrl = objRootLayout:GetObject("CollectWndCtrl")
	objRootCtrl:SetObjPos(0, 0, wndwidth, nWndHeight)
end


function SetWindowPos(objWnd)
	local objHeadWindow = tFunHelper.GetWndInstByName("TipHeadFullScrnWnd.Instance")
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	local objCollectBtn = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectBtn")
	local HeadL, HeadT, HeadR, HeadB = objHeadCtrl:GetAbsPos()
	local BtnL, BtnT, BtnR, BtnB = objCollectBtn:GetAbsPos()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainHostWnd:GetWindowRect()
	local nHeadWndL, nHeadWndT, nHeadWndR, nHeadWndB = objHeadWindow:GetWindowRect()
	
	local WithoutShadow = tFunHelper.GetMainCtrlChildObj("WithoutShadow")
	local nNoShadowL, nNoShadowT, nNoShadowR, nNoShadowB = WithoutShadow:GetAbsPos()
	
	local nWndTop = nHeadWndT+BtnB
	local nWndLeft = nMainWndL+nNoShadowL+4
	
	local selfleft, selftop, selfright, selfbottom = objWnd:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	if wndheight < 660 then
		wndheight = 660
	end
	
	if wndheight > nMainWndB-nWndTop-nNoShadowT-15 then
		wndheight = nMainWndB-nWndTop-nNoShadowT-15
	end
	
	objWnd:Move(nWndLeft, nWndTop, wndwidth, wndheight)
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	objRootCtrl:SetObjPos(0, 0, wndwidth, wndheight)
end


function GetRootCtrlByWndObj(objWnd)
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootLayout = objtree:GetUIObject("root.layout")
	local objRootCtrl = objRootLayout:GetObject("CollectWndCtrl")
	
	return objRootCtrl
end


----------方法---
function ShowTab(self, nIndex)
	local objRootCtrl = self
	local objTabCollect = objRootCtrl:GetControlObject("TipCollectWnd.Tab.Collect")
	local objTabSource = objRootCtrl:GetControlObject("TipCollectWnd.Tab.Source")
	local objTabHistory = objRootCtrl:GetControlObject("TipCollectWnd.Tab.History")
	
	local tTabList = {objTabCollect, objTabSource, objTabHistory}
	
	for key, objTab in ipairs(tTabList) do
		if key == nIndex then
			SetTabActiveStyle(objTab, true)
		else
			SetTabActiveStyle(objTab, false)
		end		
	end
	
	local objContainer = objRootCtrl:GetControlObject("Container")
	objContainer:Show(nIndex)
end


function CloseCollectWnd(self)
	local objRootCtrl = self
	SetFixStyle(objRootCtrl, false)
	-- EnableSyncWindow(objRootCtrl, false)
	
	local objTree= objRootCtrl:GetOwner()
	local objWnd = objTree:GetBindHostWnd()
	objWnd:Show(0)
end


function SetFixStyle(objRootCtrl, bFix)
	local objFixBtn = objRootCtrl:GetControlObject("TipCollectWnd.FixBtn")
	local objCloseBtn = objRootCtrl:GetControlObject("TipCollectWnd.CloseBtn")
	
	objFixBtn:SetVisible(not bFix)
	objFixBtn:SetChildrenVisible(not bFix)
	objCloseBtn:SetVisible(bFix)
	objCloseBtn:SetChildrenVisible(bFix)
	
	EnableResizeFrame(objRootCtrl, bFix)
	
	local attr = objRootCtrl:GetAttribute()
	attr.bFix = bFix
	
	local l, t, r, b = objRootCtrl:GetObjPos()
	local WndWidth = r - l
	
	AdjustMainPanelSize(objRootCtrl, WndWidth)
end


function EnableResizeFrame(objRootCtrl, bFix)
	local objResizeFrame = objRootCtrl:GetControlObject("ResizeFrame")
	local objBottom = objResizeFrame:GetControlObject("mainwnd.resize.bottom")
	local objBottomRight = objResizeFrame:GetControlObject("mainwnd.resize.bottomright")
	
	local bEnable = not bFix
	objBottom:SetEnable(bEnable)
	objBottomRight:SetEnable(bEnable)
end


local g_bHasAddSync = false
function EnableSyncWindow(objRootCtrl, bEnable)
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objTree= objRootCtrl:GetOwner()
	local objWnd = objTree:GetBindHostWnd()
	if bEnable and not g_bHasAddSync then
		objMainHostWnd:AddSyncWnd(objWnd:GetWndHandle(), {"position" ,"visible", "enable"})
		g_bHasAddSync = true
		return
	end
	if not bEnable and g_bHasAddSync then
		objMainHostWnd:RemoveSyncWnd(objWnd:GetWndHandle())
		g_bHasAddSync = false
	end
end

-----------事件
function OnInitControl(self)
	SetFixStyle(self, false)
end


function OnClickAddToBar(self)
	InitMenuHelper()
	tIEMenuHelper:ExecuteCMD("AddFav")
end


function OnClickAddArrow(self)
	g_bHasMenu = true

	local objAddtoBtn = self:GetOwnerControl()
	InitMenuHelper()
	tFunHelper.TryDestroyOldMenu(objAddtoBtn, "CollectWndMenu")
	tFunHelper.CreateAndShowMenu(objAddtoBtn,  "CollectWndMenu", 20)
	
	g_bHasMenu = false
end


function OnClickWebSite(self)
	tFunHelper.OpenURLInNewTab("https://ieonline.microsoft.com/")
end


local g_bDownFixBtn = false
function OnDownFixBtn(self)
	g_bDownFixBtn = true
	SetBtnDownStyle(self, true)
end

function OnUpFixBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	if g_bDownFixBtn then
		SetBtnDownStyle(self, false)
		g_bDownFixBtn = false
	end
	
	SetFixStyle(objRootCtrl, true)
	-- EnableSyncWindow(objRootCtrl, true)
	
	local objTree= self:GetOwner()
	local objWnd = objTree:GetBindHostWnd()
	SetWindowFullSize(objWnd)
end

function OnMsLeaveFixBtn(self)
	if g_bDownFixBtn then
		SetBtnDownStyle(self, false)
		g_bDownFixBtn = false
	end
end


function OnDownCloseBtn(self)
	SetBtnDownStyle(self, true)
end


function OnUpCloseBtn(self)
	SetBtnDownStyle(self, false)
	
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:CloseCollectWnd()
end


--tab
function OnClickTabCollect(self)
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:ShowTab(1)
end

function OnClickTabSource(self)
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:ShowTab(2)
end

function OnClickTabHistory(self)
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:ShowTab(3)
end


-----------
function SetBtnDownStyle(objBtn, bDownStyle)
	local l, t, r, b = objBtn:GetObjPos()
	local w = r - l
	local h = b - t
	
	if bDownStyle then
		l = l + 1
		t = 11
	else
		l = l - 1
		t = 10
	end
	
	local objRootCtrl = objBtn:GetParent()
	local fl, ft, fr, fb = objRootCtrl:GetObjPos()
	local fw = fr - fl
	local fh = fb - ft
	
	objBtn:SetObjPos2("father.width-"..tostring(fw-l), t, w, h)	
end


function SetTabActiveStyle(objTab, bActive)
	local l, t, r, b = objTab:GetObjPos()
	
	if bActive then
		objTab:SetObjPos(l, 0, r, "father.height")
		objTab:SetTextureID("Collect.Tab.Bkg.Hover")	
	else
		objTab:SetObjPos(l, 0, r, "father.height")
		objTab:SetTextureID("Collect.Tab.Bkg.Normal")
	end
end


function AdjustMainPanelSize(objRootCtrl, width)
	local attr = objRootCtrl:GetAttribute()
	local webbrowser = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	local l, t, r, b = webbrowser:GetObjPos()
	if attr.bFix then
		webbrowser:SetObjPos2(width, t, "father.width-2-"..tostring(width), "father.height-23-120")
	else
		webbrowser:SetObjPos2(1, t, "father.width-2", "father.height-23-120")
	end
	
	local objResizeLayout = tFunHelper.GetHeadCtrlChildObj("MainPanel.ResizeLayout")
	local l, t, r, b = objResizeLayout:GetObjPos()
	if attr.bFix then
		objResizeLayout:SetObjPos2(width, t, "father.width-2-"..tostring(width), "father.height")
	else
		objResizeLayout:SetObjPos2(1, t, "father.width-2", "father.height")
	end
	
	local objStateBar = tFunHelper.GetMainCtrlChildObj("StateBar")
	local l, t, r, b = objStateBar:GetObjPos()
	if attr.bFix then
		objStateBar:SetObjPos2(width, "father.height-23", "father.width-2-"..tostring(width), 23)
	else
		objStateBar:SetObjPos2(1, "father.height-23", "father.width-2", 23)
	end
end


function InitMenuHelper()
	local objActiveTab = tFunHelper.GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		return
	end
	
	local objBrowserCtrl = objActiveTab:GetBindBrowserCtrl()
	if objBrowserCtrl then
		local objUEBrowser = objBrowserCtrl:GetControlObject("browser")
		tIEMenuHelper:Init(objUEBrowser)
	end
end

function RouteToFather(self)
	self:RouteToFather()
end



