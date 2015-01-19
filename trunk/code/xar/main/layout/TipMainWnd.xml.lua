local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local gRootCtrl = nil


function OnClose( self )
	-- self:Show(0)
	return false, false
end


local gTipStartTime = nil
function GetTipStartTime()
	return gTipStartTime
end
XLSetGlobal("YBYL.GetTipStartTime", GetTipStartTime)

function OnShowWindow(self, bShow)
	if bShow then
		gTipStartTime = tipUtil:GetCurrentUTCTime()
	end
end


function OnSize(self, _type, width, height)	
	local objTree = self:GetBindUIObjectTree()
	local objRootCtrl = objTree:GetUIObject("root.layout:root.ctrl")
	objRootCtrl:SetObjPos(0, 0, width, height)
	local objBkg = objRootCtrl:GetControlObject("bkg")
end


function PopupInDeskCenter(self)
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	local nScreenW = workright - workleft
	local nScreenH = workbottom - worktop
	
	local selfleft, selftop, selfright, selfbottom = self:GetWindowRect()
	local wndwidth, wndheight = selfright - selfleft, selfbottom - selftop
	
	local objtree = self:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout:root.ctrl")
	local nRtCtrlL, nRtCtrlT, nRtCtrlR, nRtCtrlB = objRootCtrl:GetAbsPos()
	local nRtCtrlW, nRtCtrlH = nRtCtrlR - nRtCtrlL, nRtCtrlB - nRtCtrlT
	
	local wndleft = (nScreenW-nRtCtrlW)/2-nRtCtrlL
	local wndtop = (nScreenH-nRtCtrlH)/2-nRtCtrlT
	
	self:Move(wndleft, wndtop, wndwidth, wndheight)
end


function OnCreate( self )
	 PopupInDeskCenter(self)
end


function OnDestroy( self )
	local objtree = self:GetBindUIObjectTree()
	if objtree ~= nil then
		self:UnbindUIObjectTree()
		local objtreeManager = XLGetObject("Xunlei.UIEngine.TreeManager")
		objtreeManager:DestroyTree(objtree)
	end
	local wndId = self:GetID()
	if wndId ~= nil then
		local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
		local tempWnd = hostwndManager:GetHostWnd(wndId)
		if tempWnd then
			-- hostwndManager:RemoveHostWnd(wndId)
		end
	end
end


