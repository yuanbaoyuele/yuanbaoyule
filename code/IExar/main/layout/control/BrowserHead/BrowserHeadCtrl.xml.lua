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
	local owner = self:GetOwner():GetUIObject("root.layout:root.ctrl")
	if not owner then return end
	local webbrowser = owner:GetControlObject("MainPanel.Center")
	local l, t, r, b = webbrowser:GetObjPos()
	local collectpanel = owner:GetControlObject("MainPanel.collectpanel")
	if not collectpanel then
		local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		collectpanel = objFactory:CreateUIObject("MainPanel.collectpanel", "ie.collect")
		owner:AddChild(collectpanel)
		collectpanel:SetObjPos(0+16, t+60, 265+16, b+25)
		collectpanel:SetVisible(false)
		collectpanel:SetZorder(9999999)
	end
	if collectpanel:GetVisible() then
		collectpanel:SetVisible(false)
		webbrowser:SetObjPos(l-265, t, r, b)
	else
		collectpanel:Show(1)
		webbrowser:SetObjPos(l+265, t, r, b)
		collectpanel:SetVisible(true)
	end
end


function OnClickTabThunmb(self)
	local owner = self:GetOwner():GetUIObject("root.layout:root.ctrl")
	if not owner then return end
	local ret =	tFunHelper.GetCurBrowserBitmap()
	if not ret then return end
	local webbrowser = owner:GetControlObject("MainPanel.WebContainer")
	local thunmblayout = owner:GetControlObject("MainPanel.thunmblayout")
	if thunmblayout then
		owner:RemoveChild(thunmblayout)
		webbrowser:SetVisible(true)
		webbrowser:SetChildrenVisible(true)
		return
	end
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	thunmblayout = objFactory:CreateUIObject("MainPanel.thunmblayout", "LayoutObject")
	local parent = webbrowser:GetParent()
	parent:AddChild(thunmblayout)
	local l, t, r, b = webbrowser:GetObjPos()
	webbrowser:SetVisible(false)
	webbrowser:SetChildrenVisible(false)
	thunmblayout:SetObjPos(l, t, r, b)
	
	local thunmbobj = owner:GetControlObject("tabthunmbobj")
	if thunmbobj then
		owner:RemoveChild(thunmbobj)
	end
	thunmbobj = objFactory:CreateUIObject("tabthunmbobj", "ie.tabthunmb")
	local attr = thunmbobj:GetAttribute()
	attr.BitmapHandle = ret
	thunmblayout:AddChild(thunmbobj)
	thunmbobj:SetObjPos2(58, 46, 226, 175)
	thunmbobj:Show()
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


