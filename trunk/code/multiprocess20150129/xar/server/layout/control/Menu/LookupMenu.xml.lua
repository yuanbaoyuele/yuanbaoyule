local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

-------事件---
function OnSelect_Stop(self)
	tIEMenuHelper:ExecuteCMD("StopDownLoad")
end

function OnSelect_Refresh(self)
	tIEMenuHelper:ExecuteCMD("Refresh")
end


function OnSelect_Zoom50(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 50)
end


function OnSelect_Zoom75(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 75)
end


function OnSelect_Zoom100(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 100)
end


function OnSelect_Zoom125(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 125)
end


function OnSelect_Zoom150(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 150)
end

function OnSelect_Zoom200(self)
	tIEMenuHelper:ExecuteCMD("Zoom", 200)
end

function OnSelect_SourceCode(self)
	tIEMenuHelper:ExecuteCMD("ViewSource")
end


function OnSelect_FullScreen(self)
	tFunHelper.SetBrowserFullScrn()
end


