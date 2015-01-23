local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnInitControl(self)
	local objMenuContext = self:GetControlObject("MenuContext")
	if not objMenuContext then
		return 
	end
	objMenuContext:OnInitControl()

	
	local objMenuContainer = objMenuContext:GetControlObject( "context_menu" )
	if not objMenuContainer then
		return
	end
		
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	local nAccelerateRate = tonumber(tUserConfig["nAccelerateRate"]) or 1
	local strMenuItemID = "Accelerate"..tostring(nAccelerateRate) 
	if nAccelerateRate < 1 then
		strMenuItemID = "Accelerate0_"..tostring(nAccelerateRate*10)  --减速
	end
	
	SetMenuItemIco(objMenuContainer)
	
	local objMenuItem = objMenuContainer:GetObject(strMenuItemID)
	if not objMenuItem then
		return
	end
	
	objMenuItem:SetIconVisible(true)
	
	local attr = self:GetAttribute()
	attr.objSelItem = objMenuItem
	
	UpdateAccBtnText(objMenuItem)
end


function BindRelateObject(self, objRelate)
	local objNormalMenu = self:GetControlObject("MenuContext")
	objNormalMenu:BindRelateObject(objRelate)
end


function GetRelateObject(self)
	local objNormalMenu = self:GetControlObject("MenuContext")
	return objNormalMenu:GetRelateObject(objRelate)
end


function OnSelect_Accelerate1(self)
	tFunHelper.AccelerateFlash(1)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate2(self)
	tFunHelper.AccelerateFlash(2)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate5(self)
	tFunHelper.AccelerateFlash(5)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate10(self)
	tFunHelper.AccelerateFlash(10)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate0_9(self)
	tFunHelper.AccelerateFlash(0.9)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate0_5(self)
	tFunHelper.AccelerateFlash(0.5)
	SaveRate(self)
	UpdateAccBtnText(self)
end

function OnSelect_Accelerate0_1(self)
	tFunHelper.AccelerateFlash(0.1)
	SaveRate(self)
	UpdateAccBtnText(self)
end


function SaveRate(objMenuItem)
	local attr = objMenuItem:GetAttribute()
	local nAccelerateRate = tonumber(attr.ExtraData)
	
	if nAccelerateRate == nil then
		return
	end
	
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	tUserConfig["nAccelerateRate"] = nAccelerateRate
	tFunHelper.SaveConfigToFileByKey("tUserConfig")
end


function UpdateAccBtnText(self)
	local strText = self:GetText()
	strText = string.gsub(strText, "（默认）", "")
	
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objFuncBtnList = objHeadCtrl:GetControlObject("BrowserHeadCtrl.FuncBtnList")
	if not objFuncBtnList then
		return
	end

	local objAccBtnText = objFuncBtnList:GetControlObject("FuncBtnList.Accelerate.Text")
	if not objAccBtnText then
		return
	end
	
	objAccBtnText:SetText(strText)
end


function SetMenuItemIco(objMenuContainer)
	local nMenuItemCount = objMenuContainer:GetItemCount()
	
	for i=1, nMenuItemCount do
		local objMenuItem = objMenuContainer:GetItem(i)
		if objMenuItem then
			local strIcoResID = objMenuItem:GetIconID() or ""
			objMenuItem:SetIconID(strIcoResID)
		end	
	end
end

-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


