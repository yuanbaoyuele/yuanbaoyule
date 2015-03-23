local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


local SearchParam = {
	baidu = "http://www.baidu.com/s?wd=",
	google = "http://www.google.com/q=",
	soso = "http://www.soso.com/q?pid=s.idx&cid=s.idx.se&w=xxx",
	bing = "http://cn.bing.com/search?q=xxx",
}
function OnSearch(self, func, txt)
	local attr = self:GetAttribute()
	
	local searchurl = SearchParam[attr.SearchEngine]..txt
	tFunHelper.OpenURLInNewTab(searchurl)
end

---方法---
function ProcessTabChange(self, objTabCtrl)
	ProecssAddressBar(self, objTabCtrl)
	ProecssNavgateBtnList(self, objTabCtrl)
end


function SetHeadFullScrnStyle(self, bFullScrn)
	local objFullScrnBtn = self:GetControlObject("BrowserHeadCtrl.FullScrnBtnList")
	objFullScrnBtn:SetVisible(bFullScrn)
	objFullScrnBtn:SetChildrenVisible(bFullScrn)
	
	local objAddressBar = self:GetControlObject("BrowserHeadCtrl.AddressBar")
	local objRefreshBtnList = self:GetControlObject("BrowserHeadCtrl.RefreshBtnList")
	local objSearchCtrl = self:GetControlObject("BrowserHeadCtrl.SearchCtrl")
	
	if bFullScrn then
		objAddressBar:SetObjPos(85, 5, "father.width-472", 27)
		objRefreshBtnList:SetObjPos("father.width-467", 5, "father.width-377", 27)
		objSearchCtrl:SetObjPos("father.width-382", 5, "father.width-127", 27)
	else
		objAddressBar:SetObjPos(85, 5, "father.width-392", 27)
		objRefreshBtnList:SetObjPos("father.width-387", 5, "father.width-317", 27)
		objSearchCtrl:SetObjPos("father.width-302", 5, "father.width-47", 27)
	end
end



---------事件--
function OnInitControl(self)
	self:SetHeadFullScrnStyle(false)
end

--------
function ProecssAddressBar(objRootCtrl, objTabCtrl)
	local objAddressBar = objRootCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if objAddressBar then
		objAddressBar:ProcessTabChange(objTabCtrl)
	end
end

function ProecssNavgateBtnList(objRootCtrl, objTabCtrl)
	local objNavgateBtnList = objRootCtrl:GetControlObject("BrowserHeadCtrl.NavgateBtnList")
	local objRefreshBtnList = objRootCtrl:GetControlObject("BrowserHeadCtrl.RefreshBtnList")
	if objNavgateBtnList then
		objNavgateBtnList:SetCurrentWebTab(objTabCtrl)
	end
	
	if objRefreshBtnList then
		objRefreshBtnList:SetCurrentWebTab(objTabCtrl)
	end
end


function OnClickCollect(self)
	local bFix = false
	local nTabIndex = 1
	tFunHelper.ShowCollectWnd(nTabIndex, bFix)
end

------辅助函数---
function GetHostWndByUIElem(objUIElem)
	local objTree = objUIElem:GetOwner()
	if objTree then
		return objTree:GetBindHostWnd()
	end
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end

