local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

local g_nActiveTabID = 0
local g_nCurMaxTabID = 0
local g_tTabShowList = {}

-----方法----
function OpenURL(self, strURL, bInNewTab)
	if not IsRealString(strURL) then
		return
	end
	
	if bInNewTab then
		nNewTabID = OpenURLInNewTab(self, strURL)
	else
		nNewTabID = OpenURLInCurTab(self, strURL)
	end

	PushShowTab(self, nNewTabID)
	SetActiveTab(self, nNewTabID)
	-- AdjustTabSize(self)
	tFunHelper.SaveUrlToHistory(strURL)
	SendURLReport(strURL)
end


function GetActiveTabCtrl(self)
	local nCurActiveTabID = GetActiveTabID(self)
	local objTabCtrl = GetTabCtrlByID(self, nCurActiveTabID)
	return objTabCtrl
end


function CloseCurrentTab(self)
	local objRootCtrl = self
	local nTabID = GetActiveTabID(objRootCtrl)
	CloseTabByID(objRootCtrl, nTabID)
	TerminateWhenNoTab(objRootCtrl)
end


function GetTotalShowTabNum(self)
	local tTabShowList = GetTabShowList(self)
	return #tTabShowList
end

function GetTotalShowTabList(self)
	local tTabShowList = GetTabShowList(self)
	return tTabShowList
end


function SetActiveTab(objRootCtrl, nNewActiveID)
	tFunHelper.TipLog("[SetActiveTab] nNewActiveID:" .. tostring(nNewActiveID))

	local objNewActiveTab = GetTabCtrlByID(objRootCtrl, nNewActiveID)
	if nNewActiveID == 0 then
		objRootCtrl:FireExtEvent("OnActiveTabChange", 0)
		return
	else
		objRootCtrl:FireExtEvent("OnActiveTabChange", objNewActiveTab)
	end
	
	if not objNewActiveTab then
		return
	end
	
	local nCurActiveID = GetActiveTabID(objRootCtrl)
	
	ShowTabAndBrowser(objRootCtrl, nCurActiveID, false)
	ShowTabAndBrowser(objRootCtrl, nNewActiveID, true)
	
	SetCurActiveTabID(objRootCtrl, nNewActiveID)
	AdjustTabSize(objRootCtrl)
end


function AdjustTabSize(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	local tTabShowList = GetTabShowList(objRootCtrl)
	
	local nTotalNum = #tTabShowList
	if nTotalNum < 1 then
		return
	end

	TryShowThumbBtn(objRootCtrl, nTotalNum)
	
	local objContLayout = objRootCtrl:GetControlObject("TabContainerCtrl.Container.Layout") 
	local nFatherL, nFatherT, nFatherR, nFatherB = objContLayout:GetObjPos()
	if nFatherR < 210 then
		nFatherR = 210
	end
	local nFatherW = nFatherR - nFatherL
	
	local objAddBtn = objRootCtrl:GetControlObject("TabContainerCtrl.AddNewTab")
	local nAddBtnL, nAddBtnT, nAddBtnR, nAddBtnB = objAddBtn:GetObjPos()
	local nAddBtnW = nAddBtnR - nAddBtnL
	local nBtnSpan = 0
	
	local nMaxTabWidth = attr.nMaxTabWidth
	local nTabWidth = nMaxTabWidth

	if nTotalNum*nMaxTabWidth>nFatherW-(nAddBtnW+nBtnSpan) then
		nTabWidth = nFatherW/nTotalNum
	end
	
	--处理激活态的tab
	-- local nActiveTabID = GetActiveTabID(objRootCtrl)
	g_nActiveTabID = GetActiveTabID(objRootCtrl)
	-- local nActiveShowIndex = GetTabShowIndexByID(objRootCtrl, nActiveTabID)
	local nActiveShowIndex = GetTabShowIndexByID(objRootCtrl, g_nActiveTabID)
	local nActiveSpan = 3
	local nFinalRight = nTotalNum*nTabWidth+nBtnSpan - nActiveSpan*2 - nTotalNum
	local objFather = objRootCtrl:GetControlObject("TabContainerCtrl.Container")
	
	for nIndex, objTabCtrl in ipairs(tTabShowList) do
		objTabCtrl:SetZorder(10)	
		local nLeft = (nIndex-1)*nTabWidth
		
		if nIndex > 1 then
			nLeft = nLeft - nIndex + 1
		end
		
		if nIndex == nActiveShowIndex then
			nLeft = nLeft - nActiveSpan
			objTabCtrl:SetZorder(100)
		end
		
		if nIndex > nActiveShowIndex then
			nLeft = nLeft - nActiveSpan*2
		end 
		
		objTabCtrl:SetObjPos(nLeft, 0, nLeft+nTabWidth, "father.height")
		if nTotalNum == 1 then
			local nRight = nLeft+300
			if nRight > nFatherR then
				nRight = nFatherR-(nAddBtnW+nBtnSpan)
			end
		
			objTabCtrl:SetObjPos(nLeft, 0, nRight, "father.height")
			objTabCtrl:SetCloseBtnVisible(false)
			nFinalRight = nRight-4
		end		
	end
	
	objAddBtn:SetObjPos(nFinalRight, nAddBtnT, nFinalRight+nAddBtnW, nAddBtnB)
end


-----事件----
function OnInitControl(self)
	-- SetCurMaxTabID(self, 0)
	-- SetCurActiveTabID(self, 0)
	-- InitTabShowList(self)
end


function OnClickAddNewTab(self)
	tFunHelper.OpenNewTabDefault()
end

function OnMsEnterAddNewTab(self)
	local objImage = self:GetObject("TabContainerCtrl.AddNewTab.Image")
	objImage:SetVisible(true)
		
	tFunHelper.ShowToolTip(true, "新选项卡(Ctrl+T)")
end

function OnMsLeaveAddNewTab(self)
	local objImage = self:GetObject("TabContainerCtrl.AddNewTab.Image")
	objImage:SetVisible(false)
	
	HideToolTip()
end


function OnMouseEnterThumb(self)
	tFunHelper.ShowToolTip(true, "快速导航选项卡(Ctrl+Q)")
end


function OnClickThumbBtn(self)
	local webbrowser = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	local thunmbobj = tFunHelper.GetMainCtrlChildObj("MainPanel.thunmblayout")
	
	local bThumbVisible = thunmbobj:GetVisible()
	if bThumbVisible then
		webbrowser:SetVisible(true)
		webbrowser:SetChildrenVisible(true)
		thunmbobj:SetVisible(false)
		thunmbobj:SetChildrenVisible(false)
	else
		webbrowser:SetVisible(false)
		webbrowser:SetChildrenVisible(false)
		thunmbobj:SetVisible(true)
		thunmbobj:SetChildrenVisible(true)
	
		thunmbobj:Show()
	end
	
end


function OnClickThumbArrow(self)
	local nTopSpan = 30
	tFunHelper.TryDestroyOldMenu(self, "WebTabListMenu")
	tFunHelper.CreateAndShowMenu(self, "WebTabListMenu", nTopSpan)
end


function OnMouseEnterArrow(self)
	tFunHelper.ShowToolTip(true, "选项卡列表")
end


function HideToolTip()
	tFunHelper.ShowToolTip(false)
end


function OnClickCloseCurTab(self)
	local objRootCtrl = self:GetOwnerControl()
	objRootCtrl:CloseCurrentTab()	
end


function OnContainerPosChange(self)
	AdjustTabSize(self)
	AdjustFullScrnStyle(self)	
end


--webtabctrl传来的点击事件
function OnClickTabItem(self, strFunName, nTabID)
	local objFather = self:GetFather()
	local objRootCtrl = objFather:GetOwnerControl()
	SetActiveTab(objRootCtrl, nTabID)
end


function OnCloseTabItem(self, strFunName, nTabID)
	tFunHelper.TipLog("[OnCloseTabItem] nTabID: "..tostring(nTabID))
	local objFather = self:GetFather()
	local objRootCtrl = objFather:GetOwnerControl()

	CloseTabByID(objRootCtrl, nTabID)
	
	TerminateWhenNoTab(objRootCtrl)
end


function TerminateWhenNoTab(objRootCtrl)
	local nTotalNum = GetTotalShowTabNum(objRootCtrl)
	if nTotalNum <=0 then
		tFunHelper.ReportAndExit()
	end	
end


function OnDragTabItem(self, strFunName, strDragState, nPosX, nPosY)
	local objTabItemCtrl = self
	local objFather = self:GetFather()
	local objRootCtrl = objFather:GetOwnerControl()
	local attr = objRootCtrl:GetAttribute()
	if attr == nil then
		return
	end
	
	local objAddBtn = objRootCtrl:GetControlObject("TabContainerCtrl.AddNewTab")
	local nTabID = objTabItemCtrl:GetSelfID()
	local nShowIndex = GetTabShowIndexByID(objRootCtrl, nTabID)
	if nShowIndex == 0 then
		return
	end
	
	local nFatherLeft, top, nFatherRight, bottom = objFather:GetObjPos()
	local nSelfL, nSelfT, nSelfR, nSelfB = objTabItemCtrl:GetObjPos()
	
	if strDragState == "start" then
		attr.DragData = {}
		attr.DragTabZorder = objTabItemCtrl:GetZorder()
		attr.DragData["x"] = nSelfL + nPosX
		objTabItemCtrl:SetZorder(attr.DragTabZorder + 9999)	
		
	elseif strDragState == "draging" then
		local strDirect = ""
		
		if tonumber(attr.DragData["x"]) == nil then
			return
		end
	
		objAddBtn:SetVisible(false)
		objAddBtn:SetChildrenVisible(false)
		local diffx = nSelfL + nPosX - attr.DragData["x"]
		if diffx == 0 then 
			
		elseif diffx < 0 then
			strDirect = "left"		
			if nSelfL + diffx <= nFatherLeft then
				diffx = 0
			end
		else		
			strDirect = "right"
			if nSelfR + diffx >= nFatherRight then
				diffx = 0
			end				
		end
		
		objTabItemCtrl:SetObjPos(nSelfL + diffx, nSelfT, nSelfR + diffx, nSelfB)
		attr.DragData["x"] = nSelfL + nPosX
		TryChangeDragPos(objRootCtrl, objTabItemCtrl, nShowIndex, strDirect)
		
	elseif strDragState == "cancel" then
		objAddBtn:SetVisible(true)
		objAddBtn:SetChildrenVisible(true)
		attr.DragData = {}
		AdjustTabSize(objRootCtrl)
		local Zorder = attr.DragTabZorder or 0
		objTabItemCtrl:SetZorder(Zorder)
	end
end


----内部实现---
function OpenURLInNewTab(objRootCtrl, strURL)
	local nNewTabID = GetCurMaxTabID(objRootCtrl) + 1
	local objNewTab = CreateNewTab(objRootCtrl, nNewTabID)
	local objWebBrower = CreateNewBrowser(objRootCtrl, nNewTabID)
	
	SetCurMaxTabID(objRootCtrl, nNewTabID)
	
	if not objNewTab or not objWebBrower then
		tFunHelper.TipLog("[OpenURLInNewTab] create new tab failed")
		return
	end
	
	objWebBrower:Navigate(strURL)
	objNewTab:SaveUserInputURL(strURL)
	objNewTab:BindBrowserCtrl(objWebBrower)
	objNewTab:SetNewURLState(true)
	objNewTab:ShowGif()
	return nNewTabID
end


function OpenURLInCurTab(objRootCtrl, strURL)
	local objActiveTab = objRootCtrl:GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		objRootCtrl:OpenURL(strURL,true)
		return
	end
	
	local objBrowser = objActiveTab:GetBindBrowserCtrl()
	if not objBrowser then
		objRootCtrl:OpenURL(strURL,true)
		return
	end

	local objWebBrowCtrl = objBrowser:GetControlObject( "browser" )
	if not objWebBrowCtrl then
		objRootCtrl:OpenURL(strURL,true)
		return
	end
	
	objActiveTab:SetNewURLState(true)
	objWebBrowCtrl:Navigate(strURL)
	objActiveTab:ShowGif()
end


function CreateNewTab(objRootCtrl, nNewID)
	local objFather = objRootCtrl:GetControlObject("TabContainerCtrl.Container")
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local strTabKey = GetTabCtrlKey(nNewID)
	
	local objTab = objFactory:CreateUIObject(strTabKey, "WebTabCtrl")
	if not objTab then
		tFunHelper.TipLog("[CreateNewTab] create new WebTabCtrl failed")
		return false
	end
	
	objFather:AddChild(objTab)
	objTab:SetSelfID(nNewID)
	objTab:AttachListener("OnClickTabItem", false, OnClickTabItem)
	objTab:AttachListener("OnCloseTabItem", false, OnCloseTabItem)
	objTab:AttachListener("OnDrag", false, OnDragTabItem)
	
	return objTab
end


function CreateNewBrowser(objRootCtrl, nNewID)
	local objFather = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	if not objFather then
		tFunHelper.TipLog("[CreateNewBrowser] GetMainCtrlChildObj failed")
		return nil
	end
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	
	local strTabKey = GetWebBrowserCtrlKey(nNewID)
	
	local objWeb = objFactory:CreateUIObject(strTabKey, "WebBrowser")
	if not objWeb then
		tFunHelper.TipLog("[CreateNewBrowser] create new WebBrowser failed")
		return false
	end
	
	objFather:AddChild(objWeb)
	objWeb:SetObjPos(0, 0, "father.width", "father.height")
	objWeb:SetZorder(-1)
	
	return objWeb
end


function TryShowThumbBtn(objRootCtrl, nTabNumber)
	local objThumbLayout = objRootCtrl:GetControlObject("TabContainerCtrl.ThumbLayout") 
	local objContLayout = objRootCtrl:GetControlObject("TabContainerCtrl.Container.Layout") 
	local l, t, r, b = objRootCtrl:GetObjPos()
	
	if nTabNumber > 1 then
		objThumbLayout:SetVisible(true)
		objThumbLayout:SetChildrenVisible(true)
		objContLayout:SetObjPos(35,0,"father.width-35","father.height")
	else
		objThumbLayout:SetVisible(false)
		objThumbLayout:SetChildrenVisible(false)
		objContLayout:SetObjPos(0,0,"father.width","father.height")
	end
end


function ShowTabAndBrowser(objRootCtrl, nCtrlID, bShow)
	tFunHelper.TipLog("[ShowTabAndBrowser] nCtrlID:" .. tostring(nCtrlID) .. " bShow:"..tostring(bShow))

	local objTab = GetTabCtrlByID(objRootCtrl, nCtrlID)
	if not objTab then
		return
	end
	
	objTab:SetActiveStyle(bShow)
	local objBrowser = objTab:GetBindBrowserCtrl()
	if objBrowser then
		objBrowser:SetVisible(bShow)
		objBrowser:SetChildrenVisible(bShow)
		
		if bShow then
			local timerManager = XLGetObject("Xunlei.UIEngine.TimerManager")
			local timerID = timerManager:SetTimer( function ( item, id )
					item:KillTimer(id)
					objTab:SetWindowBitmap()	
				end, 100)
				
		end
	end
end


function GetActiveTabID(objRootCtrl)
	-- local attr = objRootCtrl:GetAttribute()
	-- return attr.nActiveTabID
	return g_nActiveTabID
end

function SetCurActiveTabID(objRootCtrl, nTabID)
	-- local attr = objRootCtrl:GetAttribute()
	-- attr.nActiveTabID = tonumber(nTabID)
	g_nActiveTabID = tonumber(nTabID)
end


--TabShowList指在界面上顺序显示的tab序列
function GetTabShowList(objRootCtrl)
	-- local attr = objRootCtrl:GetAttribute()
	-- return attr.tTabShowList
	
	return g_tTabShowList
end

function InitTabShowList(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	attr.tTabShowList = {}
end


function PushShowTab(objRootCtrl, nNewTabID)
	-- local attr = objRootCtrl:GetAttribute()
	-- local tTabShowList = attr.tTabShowList
	local objTabCtrl = GetTabCtrlByID(objRootCtrl, nNewTabID)
	
	-- tTabShowList[#tTabShowList+1] = objTabCtrl
	g_tTabShowList[#g_tTabShowList+1] = objTabCtrl
	
end


function RemoveShowTab(objRootCtrl, nIndex)
	-- local attr = objRootCtrl:GetAttribute()
	-- local tTabShowList = attr.tTabShowList
	-- table.remove(tTabShowList, nIndex)
	table.remove(g_tTabShowList, nIndex)
end


--ID是tabctrl的唯一标志，ShowIndex是tabctrl在界面展示的序号
function GetTabShowIndexByID(objRootCtrl, nTabID)
	local tTabShowList = GetTabShowList(objRootCtrl)
	
	for nIndex, objTabCtrl in ipairs(tTabShowList) do
		local nCurTabID = objTabCtrl:GetSelfID()
		if nTabID == nCurTabID then
			return nIndex
		end
	end

	return 0
end


function GetTabIDByShowIndex(objRootCtrl, nShowIndex)
	local tTabShowList = GetTabShowList(objRootCtrl)
	local objTabCtrl = tTabShowList[nShowIndex]
	if objTabCtrl then
		return objTabCtrl:GetSelfID()
	end
	
	return 0
end


function CloseTabByID(objRootCtrl, nTabID)
	local nTabShowIndex = GetTabShowIndexByID(objRootCtrl, nTabID)
	if nTabShowIndex == 0 then
		return
	end
	
	RemoveShowTab(objRootCtrl, nTabShowIndex)
	
	--处理激活态的tab
	local nCurActiveTabID = GetActiveTabID(objRootCtrl)
	if nCurActiveTabID == nTabID then
		local nTotalNum = GetTotalShowTabNum(objRootCtrl)
		local nNewActiveIndex = nTabShowIndex
		if nNewActiveIndex > nTotalNum then
			nNewActiveIndex = nTotalNum
		end
		
		local nNewActiveTabID = GetTabIDByShowIndex(objRootCtrl, nNewActiveIndex)
		SetActiveTab(objRootCtrl, nNewActiveTabID)
	end
	
	AdjustTabSize(objRootCtrl)
	DestroyTabAndBrowByID(objRootCtrl, nTabID)
end


function DestroyTabAndBrowByID(objRootCtrl, nID)
	local objTabCtrl = GetTabCtrlByID(objRootCtrl, nID)	
	local objBrowserCtrl = objTabCtrl:GetBindBrowserCtrl()
	local rawWebBrowser = objBrowserCtrl:GetRawWebBrowser()
	if rawWebBrowser ~= nil then
		tipUtil:DetachBrowserEvent(rawWebBrowser)
	end
	local objBrowserFather = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	if objBrowserCtrl and objBrowserFather then
		objBrowserFather:RemoveChild(objBrowserCtrl)
	end
	
	local objTabFather = objRootCtrl:GetControlObject("TabContainerCtrl.Container")
	if objTabCtrl and objTabFather then	
		objTabFather:RemoveChild(objTabCtrl)
	end
end


function TryChangeDragPos(objRootCtrl, objTabItemCtrl, nShowIndex, strDirect)
	local tTabShowList = GetTabShowList(objRootCtrl)
	local nSelfL, _, nSelfR = objTabItemCtrl:GetObjPos()
	
	if tostring(strDirect) == "left" then
		local objPreWebCtrl = tTabShowList[nShowIndex-1]
		if not objPreWebCtrl then
			return
		end
		
		local nMiddlePos = GetTabMiddlePos(objPreWebCtrl)
		if nSelfL < nMiddlePos then
			ChangeTabPos(objRootCtrl, nShowIndex, nShowIndex-1, strDirect)
		end
	
	elseif tostring(strDirect) == "right" then
		local objRightWebCtrl = tTabShowList[nShowIndex+1]
		if not objRightWebCtrl then
			return
		end
		
		local nMiddlePos = GetTabMiddlePos(objRightWebCtrl)
		if nSelfR > nMiddlePos then
			ChangeTabPos(objRootCtrl, nShowIndex, nShowIndex+1, strDirect)
		end
	end	
end


function GetTabMiddlePos(objWebCtrl)
	local nSelfL, _, nSelfR = objWebCtrl:GetObjPos() 
	local nWidth = nSelfR - nSelfL
	return nSelfL+nWidth/2
end


function ChangeTabPos(objRootCtrl, nActiveIndex, nToMoveIndex, strActiveDrct)
	local tTabShowList = GetTabShowList(objRootCtrl)
	local objActiveTab = tTabShowList[nActiveIndex]
	local objToMoveTab = tTabShowList[nToMoveIndex]

	local nMoveL, nMoveT, nMoveR, nMoveB = objToMoveTab:GetObjPos()  
	local nWidth = nMoveR - nMoveL
	
	if strActiveDrct == "left" then
		objToMoveTab:SetObjPos(nMoveL+nWidth, nMoveT, nMoveR+nWidth, nMoveB)
	elseif strActiveDrct == "right" then
		objToMoveTab:SetObjPos(nMoveL-nWidth, nMoveT, nMoveR-nWidth, nMoveB)
	end
	
	tTabShowList[nActiveIndex] = objToMoveTab
	tTabShowList[nToMoveIndex] = objActiveTab
end


function GetTabCtrlByID(objRootCtrl, nTabID)
	local strTabKey = GetTabCtrlKey(nTabID)
	local objContainer = objRootCtrl:GetControlObject("TabContainerCtrl.Container")
	return objContainer:GetObject(strTabKey)
end


function GetTabCtrlKey(nID)
	return "WebTabCtrl_"..tostring(nID)
end

function GetWebBrowserCtrlKey(nID)
	return "WebBrowser_"..tostring(nID)
end


function GetCurMaxTabID(objRootCtrl)
	-- local attr = objRootCtrl:GetAttribute()
	-- return attr.nCurMaxTabID
	return g_nCurMaxTabID
end

function SetCurMaxTabID(objRootCtrl, nCurMaxTabID)
	-- local attr = objRootCtrl:GetAttribute()
	-- attr.nCurMaxTabID = nCurMaxTabID
	g_nCurMaxTabID = nCurMaxTabID
end


--全屏按钮
function ShowFullScreenBtn(objRootCtrl, bShowFullScrn)
	local objFullScreen = objRootCtrl:GetControlObject("TabContainerCtrl.FullScrn")
	local objRestore = objRootCtrl:GetControlObject("TabContainerCtrl.RestoreBtn")
	local bShowRestore = not bShowFullScrn
	
	if objFullScreen and objRestore then
		objFullScreen:SetVisible(bShowFullScrn)
		objRestore:SetVisible(bShowRestore)
		objFullScreen:SetChildrenVisible(bShowFullScrn)
		objRestore:SetChildrenVisible(bShowRestore)
	end	
end


function AdjustFullScrnStyle(objRootCtrl)
	local bIsFullScreen = tFunHelper.IsBrowserFullScrn()
	local bShowFullScrn = not bIsFullScreen
	
	ShowFullScreenBtn(objRootCtrl, bShowFullScrn)
end


function SendURLReport(strURL)
	local tStatInfo = {}

	tStatInfo.strEC = "openurl"
	tStatInfo.strEA = strURL  
	tStatInfo.strEL = tFunHelper.GetMinorVerFormat() or ""
	tStatInfo.strEV = 1

	tFunHelper.DelayTipConvStatistic(tStatInfo)
end



------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


