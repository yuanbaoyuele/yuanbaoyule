local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")


---方法---
function SetText(self, strURL)
	local objUrlEdit = self:GetControlObject("AddressBarCtrl.UrlEdit")
	if objUrlEdit then
		objUrlEdit:SetText(strURL)
	end
end

function GetText(self)
	local objUrlEdit = self:GetControlObject("AddressBarCtrl.UrlEdit")
	if objUrlEdit then
		return objUrlEdit:GetText()
	end
end

function AdjustCollectBtnStyle(self, strURL)
	local objCollectBtn = self:GetControlObject("AddressBarCtrl.Collect")
	local bHasCollected = CheckHasCollect(strURL)
	if bHasCollected then
		self:SetCollectBtnStyle("hover")
	else
		self:SetCollectBtnStyle("normal")
	end	 
end

function SetIcoImage(self, strIcoName)
	local objImage = self:GetControlObject("AddressBarCtrl.Image")	
	if not objImage then
		return
	end
	
	if not IsRealString(strIcoName) then
		objImage:SetResID("")
		return
	end
	
	local objBitmap = tFunHelper.GetIcoBitmapObj(strIcoName)

	if objBitmap then
		objImage:SetBitmap(objBitmap)
	else
		local strDefResID = tFunHelper.GetDefaultIcoImgID()
		objImage:SetResID(strDefResID)
	end
end

function SetCollectBtnStyle(self, strState)
	local objCollectBtn = self:GetControlObject("AddressBarCtrl.Collect")
	if not objCollectBtn then
		return
	end
	
	if strState == "hover" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Hover")
	elseif strState == "normal" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Normal")
	end
end

function ProcessTabChange(self, objTabCtrl)
	if tonumber(objTabCtrl) ~= nil and objTabCtrl == 0 then
		self:SetText("")
		self:SetIcoImage("")
		
	elseif objTabCtrl then
		local strURL = objTabCtrl:GetLocalURL()
		local strIcoName = objTabCtrl:GetIcoName()
		if IsRealString(strURL) then
			self:SetText(strURL)
		end

		self:SetIcoImage(strIcoName)
		self:AdjustCollectBtnStyle(strURL)
	end
end


-----事件----
function OnMouseEnterArrow(self)
	tFunHelper.ShowToolTip(true, "显示地址栏自动完成")
end

function HideToolTip(self)
	tFunHelper.ShowToolTip(false)
end



--收藏--
function OnLButtonUpCllct(self)
	local objRootCtrl = self:GetOwnerControl()
	local strURL = objRootCtrl:GetText()
	if not IsRealString(strURL) then
		return
	end
	
	local bHasCollected = CheckHasCollect(strURL)
	if bHasCollected then
		RemoveCollect(objRootCtrl, strURL)
		tFunHelper.UpdateCollectList()
		objRootCtrl:SetCollectBtnStyle("normal")
	else
		AddCollect(objRootCtrl, strURL)
		tFunHelper.UpdateCollectList()
		objRootCtrl:SetCollectBtnStyle("hover")
	end	
end


--下拉箭头
function OnClickDropArrow(self)
	local tUrlHistory = tFunHelper.ReadConfigFromMemByKey("tUrlHistory") or {}
	if #tUrlHistory < 1 then
		return
	end

	local objRootCtrl = self:GetOwnerControl()
	local objEditBkg = objRootCtrl:GetControlObject("AddressBarCtrl.Bkg")

	local nTopSpan = 21
	tFunHelper.TryDestroyOldMenu(objEditBkg, "UrlHistoryMenu")
	tFunHelper.CreateAndShowMenu(objEditBkg, "UrlHistoryMenu", nTopSpan)
end


function OnUrlEditKeyDown(self, nKeyCode)
	if nKeyCode ~= 13 then --只处理回车
		return
	end

	local strURL = self:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURLInCurTab(strURL)
	end
	
	local bInAddressBar = true
	tFunHelper.SaveUrlToHistory(strURL, bInAddressBar)
end


function OnUrlEditRButtonUp(self)
	local nBegin, nEnd = self:GetSel()
	self:SetSel(nBegin, nEnd)
	tFunHelper.TryDestroyOldMenu(self, "RBtnEditMenu")
	tFunHelper.CreateAndShowMenu(self, "RBtnEditMenu", 0, true)
end


local g_bSelectAllFlag = false
function OnUrlEditFocus(self, bFocus)
	g_bSelectAllFlag = false
end


function OnUrlEditLButtonUp(self)
	if not g_bSelectAllFlag then
		self:SetSelAll()
		g_bSelectAllFlag = true
	end
end

----------------
function CheckHasCollect(strInputURL)
	if not IsRealString(strInputURL) then
		return false
	end
	
	local strURL = tFunHelper.FormatURL(strInputURL)
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return false
	end

	for nIndex, tCollectInfo in pairs(tUserCollect) do
		if type(tCollectInfo) == "table" and tCollectInfo["strURL"] == strURL then
			return true
		end
	end
	
	return false
end


function RemoveCollect(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return
	end
	
	tFunHelper.RemoveUserCollectURL(strURL)
end


function AddCollect(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return
	end
	
	tFunHelper.SaveUserCollectURL(strURL)
end


function RouteToFather(self)
	self:RouteToFather()
end

------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end