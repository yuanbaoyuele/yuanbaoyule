local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


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
		SetCollectBtnStyle(self, "hover")
	else
		SetCollectBtnStyle(self, "normal")
	end	 
end



function ProcessTabChange(self, objTabCtrl)
	if tonumber(objTabCtrl) ~= nil and objTabCtrl == 0 then
		self:SetText("")
		
	elseif objTabCtrl then
		local strURL = objTabCtrl:GetLocalURL()
		if IsRealString(strURL) then
			self:SetText(strURL)
		end
		self:AdjustCollectBtnStyle(strURL)
	end
end

-----事件----
--背景框
function OnMouseEnterBkg(self)
	self:SetTextureID("YBYL.AddressBar.UrlSearch.Bkg.Hover")
end

function OnMouseLeaveBkg(self)
	self:SetTextureID("YBYL.AddressBar.UrlSearch.Bkg.Normal")
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
		SetCollectBtnStyle(objRootCtrl, "normal")
	else
		AddCollect(objRootCtrl, strURL)
		SetCollectBtnStyle(objRootCtrl, "hover")
	end	
end


--下拉箭头
function OnClickDropArrow(self)
	
end


function OnUrlEditKeyDown(self, nKeyCode)
	if nKeyCode ~= 13 then --只处理回车
		return
	end

	local strURL = self:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURL(strURL)
	end
end



----------------
function SetCollectBtnStyle(objRootCtrl, strState)
	local objCollectBtn = objRootCtrl:GetControlObject("AddressBarCtrl.Collect")

	if strState == "hover" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Hover")
	elseif strState == "normal" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Normal")
	end
end


function CheckHasCollect(strURL)
	if not IsRealString(strURL) then
		return false
	end
	
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
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return
	end

	for nIndex, tCollectInfo in pairs(tUserCollect) do
		if type(tCollectInfo) == "table" and tCollectInfo["strURL"] == strURL then
			table.remove(tUserCollect, nIndex)
			tFunHelper.SaveConfigToFileByKey("tUserCollect")
			break
		end
	end
end


function AddCollect(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return
	end

	local tCollectInfo = {}
	tCollectInfo.strURL = strURL
	
	table.insert(tUserCollect, tCollectInfo)
	tFunHelper.SaveConfigToFileByKey("tUserCollect")
end



function RouteToFather(self)
	self:RouteToFather()
end

------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end