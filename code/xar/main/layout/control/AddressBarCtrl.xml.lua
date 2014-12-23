local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


---方法---
function SetText(self, strURL)
	local objUrlEdit = self:GetControlObject("AddressBarCtrl.UrlEdit")
	if objUrlEdit then
		objUrlEdit:SetText(strURL)
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
function OnMouseEnterCllct(self)
	self:SetTextureID("YBYL.AddressBar.Collect.Hover")
	RouteToFather(self)
end

function OnMouseLeaveCllct(self)
	self:SetTextureID("YBYL.AddressBar.Collect.Normal")
end

function OnLButtonUpCllct(self)
	
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


function RouteToFather(self)
	self:RouteToFather()
end


------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end