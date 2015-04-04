local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_ClearHistory(self)
	local strFileKey = "tUrlHistory"
	tFunHelper.ClearFileInfo(strFileKey)
end

function OnSelect_ClearCollect(self)
	local strFileKey = "tUserCollect"
	tFunHelper.ClearFileInfo(strFileKey)
	tFunHelper.UpdateCollectList()
	
	local objHeadCtrl = tFunHelper.GetMainCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	objAddressBar:SetCollectBtnStyle("normal")
end


function OnSelect_Profile(self)
	tFunHelper.ShowPopupWndByName("TipConfigWnd.Instance", true)
end

function OnSelect_InternetPro(self)
	tIEMenuHelper:ExecuteCMD("Options")
end



