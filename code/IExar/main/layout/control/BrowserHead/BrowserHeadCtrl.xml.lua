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

-- function OnClickCollect(self)
	-- local owner = self:GetOwner():GetUIObject("root.layout:root.ctrl")
	-- if not owner then return end
	
	-- local webbrowser = tFunHelper.GetMainCtrlChildObj("MainPanel.Center")
	-- local l, t, r, b = webbrowser:GetObjPos()
	-- local collectpanel = tFunHelper.GetMainCtrlChildObj("MainPanel.collectpanel")
	-- if not collectpanel then
		-- local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
		-- collectpanel = objFactory:CreateUIObject("MainPanel.collectpanel", "ie.collect")
		-- owner:AddChild(collectpanel)
		-- collectpanel:SetObjPos(4, 115, 215+16, b+25)
		-- collectpanel:SetVisible(false)
		-- collectpanel:SetZorder(9999999)
	-- end
	-- if collectpanel:GetVisible() then
		-- collectpanel:SetVisible(false)
		-- webbrowser:SetObjPos(l-265, t, r, b)
	-- else
		-- collectpanel:Show(1)
		-- webbrowser:SetObjPos(l+265, t, r, b)
		-- collectpanel:SetVisible(true)
	-- end
-- end

local g_HasCreate = false
function OnClickCollect(self)
	if not g_HasCreate then
		local bSuccess = tFunHelper.CreateSubWndByName("TipCollectWnd", "TipCollectTree", ".Instance")
		if bSuccess then
			 g_HasCreate = true
		else
			return
		end
	end
	
	local objWnd = tFunHelper.GetWndInstByName("TipCollectWnd.Instance")
	local objtree = objWnd:GetBindUIObjectTree()
	local objRootLayout = objtree:GetUIObject("root.layout")
	local objRootCtrl = objRootLayout:GetObject("CollectWndCtrl")
	if objWnd:GetVisible() then
		objRootCtrl:CloseCollectWnd()
		return
	end	
	
	tFunHelper.ShowPopupWndByName("TipCollectWnd.Instance", false)
	objRootCtrl:ShowTab(1)
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


