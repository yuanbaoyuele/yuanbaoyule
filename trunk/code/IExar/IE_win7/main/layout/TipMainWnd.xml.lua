local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local gRootCtrl = nil


local gTipStartTime = nil
function GetTipStartTime()
	return gTipStartTime
end
XLSetGlobal("YBYL.GetTipStartTime", GetTipStartTime)

function OnShowWindow(self, bShow)
	if bShow then
		gTipStartTime = tipUtil:GetCurrentUTCTime()
		tFunHelper.ShowHeadWindow()
	end
end


function OnSize(self, _type, width, height)	
	local objTree = self:GetBindUIObjectTree()
	local objRootCtrl = objTree:GetUIObject("root.layout:root.ctrl")
	objRootCtrl:SetObjPos(0, 0, width, height)
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
	 local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
	 local dwCurrentPID = tipUtil:GetCurrentProcessId()
	 local timerID = timerManager:SetTimer( function ( item, id )
						local hForegroundWnd = tipUtil:GetForegroundProcessInfo()
						if hForegroundWnd ~= nil then
							local dwPID = tipUtil:GetWndProcessThreadId(hForegroundWnd)
							if dwPID == dwCurrentPID then
								tFunHelper.SetMainWndFocusStyle(true)
							else
								tFunHelper.SetMainWndFocusStyle(false)
							end
						end
						   end, 100)
end


function OnDestroy( self )
	tFunHelper.ReportAndExit()
	
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


function OnFocusChange(self, bFocus)
	--tFunHelper.SetMainWndFocusStyle(bFocus)
end



