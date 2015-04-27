local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

function OnCreate( self )
	local objSelfWnd = self
	local objMainWnd = tFunHelper.GetMainWndInst()
	local mainleft, maintop, mainright, mainbottom = objMainWnd:GetWindowRect()

	local objMainPanelHead = tFunHelper.GetMainCtrlChildObj("MainPanel.HeadWnd")
	local HeadL, HeadT, HeadR, HeadB = objMainPanelHead:GetAbsPos()
	
	local nSelfL = mainleft+HeadL
	local nSelfT = maintop+HeadT
	local nSelfR = mainleft+HeadR
	local nSelfB = maintop+HeadB
	
	objSelfWnd:Move( nSelfL, nSelfT, nSelfR, nSelfB)
	
	local objtree = objSelfWnd:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	objRootCtrl:SetObjPos(0, 0, nSelfR-nSelfL, nSelfB-nSelfT)
	
	objMainWnd:AttachListener("OnSize", true, function( self, _type, width, height)	
	
		local mainleft, maintop, mainright, mainbottom = objMainWnd:GetWindowRect()
		objSelfWnd:SetTopMost(false)
		objSelfWnd:SetMaxTrackSize(width-8, 120)
		objSelfWnd:Move( mainleft+HeadL, maintop+40, mainright, 120)
		local objtree = objSelfWnd:GetBindUIObjectTree()
		local objRootCtrl = objtree:GetUIObject("root.layout")
		objRootCtrl:SetObjPos(0, 0, width-20*2, 120)
	end)	
end


function OnShowWindow(self, bShow)

end


-----------
--headctrl事件
function OnMouseEnterHead(self)
	-- SetCollectWndTopMost(self, false)
	local objTree = self:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	
	-- objHostWnd:BringWindowToTop()
	
	if not tFunHelper.IsBrowserFullScrn() then
		return
	end
	
	local nCursorX, nCursorY = tipUtil:GetCursorPos() 	
	if nCursorY > 2 then
		return
	end
	
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	
	local width = workright-workleft
	objHostWnd:Move(workleft, 0, workright, 118)
end


function OnMouseLeaveHead(self)
	-- SetCollectWndTopMost(self, false)

	if not tFunHelper.IsBrowserFullScrn() then
		return
	end
	
	local nCursorX, nCursorY = tipUtil:GetCursorPos() 	
	local workleft, worktop, workright, workbottom = tipUtil:GetWorkArea()
	
	if nCursorX>workleft and nCursorX<workright
		and nCursorY>worktop and nCursorY<110 then
		return
	end

	local objTree = self:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	objHostWnd:Move(workleft, -119, workright, 120)
	objHostWnd:SetTopMost(false)
end


--tabcontainer事件
function OnActiveTabChange(self, strEvntName,objActiveTab)
	if not objActiveTab then
		return
	end
	
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		tFunHelper.TipLog("[OnActiveTabChange] get objHeadCtrl failed")
		return
	end
	objHeadCtrl:ProcessTabChange(objActiveTab)
	
	local objTitleCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Title")
	if not objTitleCtrl then
		tFunHelper.TipLog("[OnActiveTabChange] get objTitleCtrl failed")
		return
	end
	objTitleCtrl:ProcessTabChange(objActiveTab)
end


---------
function HideWindow(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	objHostWnd:Show(0)
end


function GetCtrlByWnd(objWnd, strCtrlName)
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootCtrl = objtree:GetUIObject("root.layout")
	local objCtrl = objRootCtrl:GetObject(strCtrlName)

	return objCtrl
end


function SetCollectWndTopMost(objUIElem, bTopMost)
	local objCollectWnd = tFunHelper.GetWndInstByName("TipCollectWnd.Instance")
	if objCollectWnd then
		objCollectWnd:SetTopMost(bTopMost)
	end
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end



