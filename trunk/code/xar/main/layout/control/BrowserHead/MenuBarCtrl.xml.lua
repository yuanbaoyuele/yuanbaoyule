local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-----方法----


-----事件----
function OnClickHideBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	local nBtnL, nBtnT, nBtnR, nBtnB = self:GetObjPos()
	local nRootL, nRootT, nRootR, nRootB = objRootCtrl:GetObjPos()
	
	local nBtnW = nBtnR-nBtnL+10
	local nRootW = nRootR-nRootL
	local nNewLeft = nRootW-nBtnW
	
	objRootLayout:SetObjPos(nNewLeft, 0, "father.width", "father.height")
	SetHideBtnStyle(objRootCtrl, false)
end


function OnClickShowBtn(self)
	local objRootCtrl = self:GetOwnerControl()
	local objRootLayout = objRootCtrl:GetControlObject("root.layout")
	objRootLayout:SetObjPos(0, 0, "father.width", "father.height")
	
	SetHideBtnStyle(objRootCtrl, true)
end


function OnClickFile(self)
	InitMenuHelper()
	TryDestroyOldMenu(self, "FileMenu")
	CreateAndShowMenu(self, "FileMenu")
end


function OnClickLookup(self)
	InitMenuHelper()
	TryDestroyOldMenu(self, "LookupMenu")
	CreateAndShowMenu(self, "LookupMenu")
end


function OnClickCollect(self)
	InitMenuHelper()
	TryDestroyOldMenu(self, "CollectMenu")
	CreateAndShowMenu(self, "CollectMenu")
end


function OnClickTool(self)
	InitMenuHelper()
	TryDestroyOldMenu(self, "ToolMenu")
	CreateAndShowMenu(self, "ToolMenu")
end


function OnClickHelp(self)
	InitMenuHelper()
	TryDestroyOldMenu(self, "HelpMenu")
	CreateAndShowMenu(self, "HelpMenu")
end

----

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


function TryDestroyOldMenu(objMenuText, strMenuKey)
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")
	local strHostWndName = strMenuKey..".HostWnd.Instance" 
	local strObjTreeName = strMenuKey..".Tree.Instance"

	if uHostWndMgr:GetHostWnd(strHostWndName) then
		uHostWndMgr:RemoveHostWnd(strHostWndName)
	end
	
	if uObjTreeMgr:GetUIObjectTree(strObjTreeName) then
		uObjTreeMgr:DestroyTree(strObjTreeName)
	end
end


function CreateAndShowMenu(objMenuText, strMenuKey)
	local uTempltMgr = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")

	if uTempltMgr and uHostWndMgr and uObjTreeMgr then
		local uHostWnd = nil
		local strHostWndName = strMenuKey..".HostWnd.Instance"
		local strHostWndTempltName = "MenuHostWnd"
		local strHostWndTempltClass = "HostWndTemplate"
		local uHostWndTemplt = uTempltMgr:GetTemplate(strHostWndTempltName, strHostWndTempltClass)
		if uHostWndTemplt then
			uHostWnd = uHostWndTemplt:CreateInstance(strHostWndName)
		end

		local uObjTree = nil
		local strObjTreeTempltName = strMenuKey.."Tree"
		local strObjTreeTempltClass = "ObjectTreeTemplate"
		local strObjTreeName = strMenuKey..".Tree.Instance"
		local uObjTreeTemplt = uTempltMgr:GetTemplate(strObjTreeTempltName, strObjTreeTempltClass)
		if uObjTreeTemplt then
			uObjTree = uObjTreeTemplt:CreateInstance(strObjTreeName)
		end

		if uHostWnd and uObjTree then
			--函数会阻塞
			local bSucc = ShowMenuHostWnd(objMenuText, uHostWnd, uObjTree)
			
			if bSucc and uHostWnd:GetMenuMode() == "manual" then
				uObjTreeMgr:DestroyTree(strObjTreeName)
				uHostWndMgr:RemoveHostWnd(strHostWndName)
			end
		end
	end
end


function ShowMenuHostWnd(objMenuText, uHostWnd, uObjTree)
	uHostWnd:BindUIObjectTree(uObjTree)
					
	local objMainLayout = uObjTree:GetUIObject("Menu.MainLayout")
	if not objMainLayout then
	    return false
	end	
	local nL, nT, nR, nB = objMainLayout:GetObjPos()				
	local nMenuContainerWidth = nR - nL
	local nMenuContainerHeight = nB - nT
	local nMenuLeft, nMenuTop = GetScreenAbsPos(objMenuText)
	
	uHostWnd:SetFocus(false) --先失去焦点，否则存在菜单不会消失的bug
	
	--函数会阻塞
	local bOk = uHostWnd:TrackPopupMenu(objHostWnd, nMenuLeft, nMenuTop, nMenuContainerWidth, nMenuContainerHeight)
	return bOk
end

function GetScreenAbsPos(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	local nL, nT, nR, nB = objUIElem:GetAbsPos()
	return objHostWnd:HostWndPtToScreenPt(nL, nT)
end


function SetHideBtnStyle(objRootCtrl, bHideBtnVsbl)
	local objHideBtn = objRootCtrl:GetControlObject("MenuBarCtrl.HideBtn")
	local objShowBtn = objRootCtrl:GetControlObject("MenuBarCtrl.ShowBtn")
	local bShowBtnVsbl = not bHideBtnVsbl
	
	objHideBtn:SetVisible(bHideBtnVsbl)
	objHideBtn:SetChildrenVisible(bHideBtnVsbl)
	objShowBtn:SetVisible(bShowBtnVsbl)
	objShowBtn:SetChildrenVisible(bShowBtnVsbl)
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end