local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


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
	AdjustTabSize(self)
end


-----事件----
function OnInitControl(self)
	SetCurMaxTabID(self, 0)
	SetCurActiveTabID(self, 0)
	InitTabShowList(self)
end


function OnClickAddNewTab(self)
	local objRootCtrl = self:GetOwnerControl()
	local strDefURL = "www.hao123.com"
	objRootCtrl:OpenURL(strDefURL, true)
end


function OnClickCloseCurTab(self)
	local objRootCtrl = self:GetOwnerControl()
	local nTabID = GetActiveTabID(objRootCtrl)
	CloseTabByID(objRootCtrl, nTabID)
end


function OnClickFullScrn(self)

end


function OnContainerPosChange(self)
	AdjustTabSize(self)
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
	objNewTab:BindBrowserCtrl(objWebBrower)
	
	return nNewTabID
end


function OpenURLInCurTab(objRootCtrl, strURL)


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
	
	return objWeb
end


function AdjustTabSize(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	local tTabShowList = GetTabShowList(objRootCtrl)
	
	local nTotalNum = #tTabShowList
	local objContLayout = objRootCtrl:GetControlObject("TabContainerCtrl.Container.Layout") 
	local nFatherL, nFatherT, nFatherR, nFatherB = objContLayout:GetObjPos()
	local nFatherW = nFatherR - nFatherL
	
	local objAddBtn = objRootCtrl:GetControlObject("TabContainerCtrl.AddNewTab")
	local nAddBtnL, nAddBtnT, nAddBtnR, nAddBtnB = objAddBtn:GetObjPos()
	local nAddBtnW = nAddBtnR - nAddBtnL
	local nBtnSpan = 10
	
	local nMaxTabWidth = attr.nMaxTabWidth
	local nTabWidth = nMaxTabWidth

	if nTotalNum*nMaxTabWidth>nFatherW-(nAddBtnW+nBtnSpan) then
		nTabWidth = nFatherW/nTotalNum
	end
	
	for nIndex, objTabCtrl in ipairs(tTabShowList) do
		local nLeft = (nIndex-1)*nTabWidth
		objTabCtrl:SetObjPos(nLeft, 0, nLeft+nTabWidth, "father.height")
	end
	
	local nFinalRight = nTotalNum*nTabWidth+nBtnSpan
	objAddBtn:SetObjPos(nFinalRight, nAddBtnT, nFinalRight+nAddBtnW, nAddBtnB)
end


function SetActiveTab(objRootCtrl, nNewActiveID)
	tFunHelper.TipLog("[SetActiveTab] nNewActiveID:" .. tostring(nNewActiveID))

	local objNewActiveTab = GetTabCtrlByID(objRootCtrl, nNewActiveID)
	if not objNewActiveTab then
		return
	end
	
	local nCurActiveID = GetActiveTabID(objRootCtrl)
	
	ShowTabAndBrowser(objRootCtrl, nCurActiveID, false)
	ShowTabAndBrowser(objRootCtrl, nNewActiveID, true)

	SetCurActiveTabID(objRootCtrl, nNewActiveID)
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
	end
end


function GetActiveTabID(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	return attr.nActiveTabID
end

function SetCurActiveTabID(objRootCtrl, nTabID)
	local attr = objRootCtrl:GetAttribute()
	attr.nActiveTabID = tonumber(nTabID)
end


--TabShowList指在界面上顺序显示的tab序列
function GetTabShowList(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	return attr.tTabShowList
end

function InitTabShowList(objRootCtrl)
	local attr = objRootCtrl:GetAttribute()
	attr.tTabShowList = {}
end

function GetTotalShowTabNum(objRootCtrl)
	local tTabShowList = GetTabShowList(objRootCtrl)
	return #tTabShowList
end

function PushShowTab(objRootCtrl, nNewTabID)
	local attr = objRootCtrl:GetAttribute()
	local tTabShowList = attr.tTabShowList
	local objTabCtrl = GetTabCtrlByID(objRootCtrl, nNewTabID)
	
	tTabShowList[#tTabShowList+1] = objTabCtrl
end


function RemoveShowTab(objRootCtrl, nIndex)
	local attr = objRootCtrl:GetAttribute()
	local tTabShowList = attr.tTabShowList
	table.remove(tTabShowList, nIndex)
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
	local objBrowserFather = tFunHelper.GetMainCtrlChildObj("MainPanel.WebContainer")
	if objBrowserCtrl and objBrowserFather then
		objBrowserFather:RemoveChild(objBrowserCtrl)
	end
	
	local objTabFather = objRootCtrl:GetControlObject("TabContainerCtrl.Container")
	if objTabCtrl and objTabFather then
		objTabFather:RemoveChild(objTabCtrl)
	end
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
	local attr = objRootCtrl:GetAttribute()
	return attr.nCurMaxTabID
end

function SetCurMaxTabID(objRootCtrl, nCurMaxTabID)
	local attr = objRootCtrl:GetAttribute()
	attr.nCurMaxTabID = nCurMaxTabID
end



------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


