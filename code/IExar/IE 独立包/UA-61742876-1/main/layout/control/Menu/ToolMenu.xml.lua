local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_ClearHistory(self)
	--local strFileKey = "tUrlHistory"
	--tFunHelper.ClearFileInfo(strFileKey)
	tFunHelper.ShowModalDialog("TipDeleteExplorerHistroyWnd", "TipDeleteExplorerHistroyWndInstance", "TipDeleteExplorerHistroyWndTree", "TipDeleteExplorerHistroyWndTreeInstance")
end

function OnSelect_ClearCollect(self)
	local strFileKey = "tUserCollect"
	tFunHelper.ClearFileInfo(strFileKey)
	tFunHelper.UpdateCollectList()
	
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("MainPanel.Head")
	if not objHeadCtrl then
		return
	end
	
	local objAddressBar = objHeadCtrl:GetControlObject("BrowserHeadCtrl.AddressBar")
	if not objAddressBar then
		return
	end
	
	objAddressBar:SetCollectBtnStyle("normal")
end


function OnSelect_InPrivate(self)
	
end

function OnSelect_OpenLast(self)
	
end

function OnSelect_PrivateFilter(self)
	
end

function OnSelect_PrivateProfile(self)
	
end

function OnSelect_ManagePlugin(self)
	
end

function OnSelect_CompatibleView(self)
	
end

function OnSelect_CompatibleSet(self)
	
end

function OnSelect_Subscribe(self)
	
end

function OnSelect_FindSource(self)
	
end

function OnSelect_WindowsUpdate(self)
	local strUpdateUrl = "http://windowsupdate.microsoft.com/windowsupdate/v6/default.aspx?ln=zh-cn"
	tFunHelper.OpenURLInCurTab(strUpdateUrl)
end

function OnSelect_DevelopTool(self)
	
end

function OnSelect_Diagnose(self)
	
end



function OnSelect_Profile(self)
	tFunHelper.ShowPopupWndByName("TipConfigWnd.Instance", true)
end


function OnSelect_InternetPro(self)
	local strOldHomePage = tFunHelper.GetHomePageFromReg()
	
	tIEMenuHelper:ExecuteCMD("Options", function ()
			local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
			
			local strNowHomePage = tFunHelper.GetHomePageFromReg()
			if strOldHomePage~=strNowHomePage and not string.find(strNowHomePage, "%?") then  --用户改了主页
				tFunHelper.SetHomePage(strNowHomePage)
				tFunHelper.SetUserHPFlag(true)
				return
			end
			
			if string.find(strNowHomePage, "%?") then
				local strDefaultHomepage = tUserConfig["strDefaultHomePage"]
				if IsRealString(strDefaultHomepage) then
					tFunHelper.SetHomePage(strDefaultHomepage)
				end	
				tFunHelper.SetUserHPFlag(false)
			end
		end)
end


function IsRealString(str)
	return type(str) == "string" and str ~= ""
end


