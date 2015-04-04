local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil

function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

function OnSearch(self, func, txt)
	local attr = self:GetAttribute()
	txt = encodeURI(txt)
	if txt ~= "" and txt ~= nil then
		local searchurl = string.gsub(string.lower(attr.SearchEngine["url"]), "{searchword}", txt)
		tFunHelper.OpenURLInNewTab(searchurl)
		local tStatInfo = {}

		tStatInfo.strEC = "onsearch"
		tStatInfo.strEA = attr.SearchEngine["url"]  
		tStatInfo.strEL = tFunHelper.GetMinorVer() or ""
		tStatInfo.strEV = 1

		tFunHelper.DelayTipConvStatistic(tStatInfo)
	end
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


function OnPosChange(self)
	if tFunHelper.IsBrowserFullScrn() then
		return
	end

	SetAddressBarPos(self)
	SetRefreshBtnPos(self)
	SetSearchCtrlPos(self)
end

--------
function SetAddressBarPos(objRootCtrl)
	local fl, ft, fr, fb = objRootCtrl:GetObjPos()
	local fw = fr - fl
	
	local AddBarW = fw-477
	if AddBarW < 130 then
		AddBarW = 130
	end
	
	local objAddressBar = objRootCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")	
	objAddressBar:SetObjPos2(85, 5, AddBarW, 22)

end

function SetRefreshBtnPos(objRootCtrl)
	local fl, ft, fr, fb = objRootCtrl:GetObjPos()
	local fw = fr - fl
	
	local BtnL = fw-387
	if BtnL < 220 then
		BtnL = 220
	end
	
	local objBtn = objRootCtrl:GetControlObject("BrowserHeadCtrl.RefreshBtnList")	
	objBtn:SetObjPos2(BtnL, 5, 70, 22)
end


function SetSearchCtrlPos(objRootCtrl)
	local fl, ft, fr, fb = objRootCtrl:GetObjPos()
	local fw = fr - fl
	
	local SearchL = fw-302
	if SearchL < 300 then
		SearchL = 300
	end
	
	local objSearchCtrl = objRootCtrl:GetControlObject("BrowserHeadCtrl.SearchCtrl")	
	objSearchCtrl:SetObjPos2(SearchL, 5, 255, 22)
end


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


