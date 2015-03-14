local tipUtil = XLGetObject("API.Util")
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")


-------------窗口
function OnCreate( self )
	local objCollectWnd = self
	SetWindowFullSize(objCollectWnd)
	
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	-- objMainHostWnd:AddSyncWnd(objCollectWnd:GetWndHandle(), {"position" ,"visible", "enable"})
	
	objMainHostWnd:AttachListener("OnSize", false, 
		function(objMainWnd)
			local objRootCtrl = GetRootCtrlByWndObj(objCollectWnd)
			local attr = objRootCtrl:GetAttribute()
			if attr.bFix then
				SetWindowFullSize(objCollectWnd)
			end
		end		
	)
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
	
	if not bFocus then
		if not attr.bFix then
			self:Show(0)
		end
	end	
end


function SetWindowFullSize(objWnd)
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	local objCollectBtn = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectBtn")
	local HeadL, HeadT, HeadR, HeadB = objHeadCtrl:GetAbsPos()
	local BtnL, BtnT, BtnR, BtnB = objCollectBtn:GetAbsPos()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainHostWnd:GetWindowRect()
	
	local nWndTop = nMainWndT+BtnB
	local nWndLeft = nMainWndL+HeadL
	local nWndHeight = nMainWndB-nWndTop-4
		
	local selfleft, selftop, selfright, selfbottom = objWnd:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	objWnd:Move(nWndLeft, nWndTop, wndwidth, nWndHeight)
	
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	objRootCtrl:SetObjPos(0, 0, wndwidth, nWndHeight)
end


function SetWindowPos(objWnd)
	local objMainHostWnd = tFunHelper.GetMainWndInst()
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	local objCollectBtn = objHeadCtrl:GetControlObject("BrowserHeadCtrl.CollectBtn")
	local HeadL, HeadT, HeadR, HeadB = objHeadCtrl:GetAbsPos()
	local BtnL, BtnT, BtnR, BtnB = objCollectBtn:GetAbsPos()
	local nMainWndL, nMainWndT, nMainWndR, nMainWndB = objMainHostWnd:GetWindowRect()
	
	local nWndTop = nMainWndT+BtnB
	local nWndLeft = nMainWndL+HeadL
	
	local selfleft, selftop, selfright, selfbottom = objWnd:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	if wndheight < 660 then
		wndheight = 660
	end
	
	if wndheight > nMainWndB-nWndTop-4 then
		wndheight = nMainWndB-nWndTop-4
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


end


function CloseCollectWnd(self)
	local objRootCtrl = self
	SetFixStyle(objRootCtrl, false)
	EnableSyncWindow(objRootCtrl, false)
	
	local objTree= objRootCtrl:GetOwner()
	local objWnd = objTree:GetBindHostWnd()
	objWnd:Show(0)
end




-----------事件
function OnInitControl(self)
	SetFixStyle(self, false)
end


function OnClickAddToBar(self)

end


function OnClickAddArrow(self)

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
	EnableSyncWindow(objRootCtrl, true)
	
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


-----------
function SetFixStyle(objRootCtrl, bFix)
	local objFixBtn = objRootCtrl:GetControlObject("TipCollectWnd.FixBtn")
	local objCloseBtn = objRootCtrl:GetControlObject("TipCollectWnd.CloseBtn")
	
	objFixBtn:SetVisible(not bFix)
	objFixBtn:SetChildrenVisible(not bFix)
	objCloseBtn:SetVisible(bFix)
	objCloseBtn:SetChildrenVisible(bFix)
	
	local attr = objRootCtrl:GetAttribute()
	attr.bFix = bFix
	
	local l, t, r, b = objRootCtrl:GetObjPos()
	local WndWidth = r - l

	local webbrowser = tFunHelper.GetMainCtrlChildObj("MainPanel.Center")
	local l, t, r, b = webbrowser:GetObjPos()
	if bFix then
		webbrowser:SetObjPos(WndWidth, t, "father.width", "father.height")
	else
		webbrowser:SetObjPos(0, t, "father.width", "father.height")
	end
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


function SetBtnDownStyle(objBtn, bDownStyle)
	local l, t, r, b = objBtn:GetObjPos()
	local w = r - l
	local h = b - t
	
	if bDownStyle then
		l = l + 2
		t = t + 2
	else
		l = l - 2
		t = t - 2
	end
	
	objBtn:SetObjPos(l, t, l+w, t+h)	
end


function RouteToFather(self)
	self:RouteToFather()
end



