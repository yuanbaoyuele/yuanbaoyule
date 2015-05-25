local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
-------事件---

function OnSelect_Help(self)
	local strResDir = tFunHelper.GetResourceDir()
	if not IsRealString(strResDir) then
		return
	end
	local strIEHelp_chm = tipUtil:PathCombine(strResDir, "iexplore.chm")
	if not tipUtil:QueryFileExists(strIEHelp_chm) then
		return
	end
	tipUtil:ShellExecute(0, "open", strIEHelp_chm, "", 0, "SW_SHOW")
end

function OnSelect_NewFunction(self)
	local strNewFunUrl = "http://windows.microsoft.com/zh-cn/internet-explorer/ie-8-welcome#welcome=tab1"
	tFunHelper.OpenURLInCurTab(strNewFunUrl)
end

function OnSelect_Support(self)
	local strSupportUrl = "https://support.microsoft.com/zh-cn"
	tFunHelper.OpenURLInCurTab(strSupportUrl)
end

function OnSelect_ReportSet(self)
	tFunHelper.ShowModalDialog("TipFeedbackWnd", "TipFeedbackWndInstance", "TipFeedbackTree", "TipFeedbackTreeInstance")
end

function OnSelect_About(self)
	local objTree = self:GetOwner()
	local objMenuHostWnd = objTree:GetBindHostWnd()
	tFunHelper.ShowModalDialog("TipAboutWnd", "TipAboutWndInstance", "TipAboutTree", "TipAboutTreeInstance")
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


