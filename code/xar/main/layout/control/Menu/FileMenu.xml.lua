local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_AddNewTab(self)
	local strHomePage = tFunHelper.GetOpenTabURL()
	tFunHelper.OpenURLInNewTab(strHomePage)
end

function OnSelect_AddNewWindow(self)
	tFunHelper.OpenURLInNewWindow()
end

function OnSelect_Open(self)
	local strURL = tIEMenuHelper:ExecuteCMD("Open")
	tFunHelper.OpenURLInNewTab(strURL)
end

function OnSelect_SaveAs(self)
	tIEMenuHelper:ExecuteCMD("SaveAS")
end

function OnSelect_PageSetup(self)
	tIEMenuHelper:ExecuteCMD("PageSetup")
end

function OnSelect_Print(self)
	tIEMenuHelper:ExecuteCMD("Print")
end

function OnSelect_PrintReview(self)
	tIEMenuHelper:ExecuteCMD("PrintReview")
end

function OnSelect_ShortCut(self)
	tIEMenuHelper:ExecuteCMD("CreateShortCut")
end

function OnSelect_Properties(self)
	tIEMenuHelper:ExecuteCMD("Properties")
end

function OnSelect_Exit(self)
	tFunHelper.ReportAndExit()
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


