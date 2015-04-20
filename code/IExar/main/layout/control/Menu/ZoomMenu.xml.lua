local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")


-----缩放子菜单
function OnSelect_Enlage(self)
	local nFactor = tFunHelper.GetZoomFactor()
	local nNewFactor = nFactor+25
	if nNewFactor > 1000 then
		nNewFactor = 1000
	end
	
	tIEMenuHelper:ExecuteCMD("Zoom", nNewFactor)
	tFunHelper.SetZoomFactor(nNewFactor)
end

function OnSelect_Narrow(self)
	local nFactor = tFunHelper.GetZoomFactor()
	local nNewFactor = nFactor-25
	if nNewFactor < 25 then
		nNewFactor = 25
	end
	
	tIEMenuHelper:ExecuteCMD("Zoom", nNewFactor)
	tFunHelper.SetZoomFactor(nNewFactor)
end

function OnSelect_Zoom50(self)
	local nFactor = 50
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom75(self)
	local nFactor = 75
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom100(self)
	local nFactor = 100
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom125(self)
	local nFactor = 125
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnSelect_Zoom150(self)
	local nFactor = 150
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end

function OnSelect_Zoom200(self)
	local nFactor = 200
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end

function OnSelect_Zoom400(self)
	local nFactor = 400
	tIEMenuHelper:ExecuteCMD("Zoom", nFactor)
	tFunHelper.SetZoomFactor(nFactor)
end


function OnInit_Zoom(self)
	local strText = self:GetID()
	local _, _, strZoom = string.find(strText, "[^%d]*(%d*)")
	if not IsRealString(strZoom) then
		return
	end

	local nFactor = tFunHelper.GetZoomFactor() or -1
	if tostring(nFactor) ~= strZoom then
		return
	end
	
	local attr = self:GetAttribute()
	attr.IconPos = 5
	attr.IconWidth = 6
	attr.IconHeight = 6
	attr.IconVisible = true
	attr.Icon = "Black.Flag"
	attr.IconHover = "White.Flag"
end


function OnSelect_Custom(self)
	
end

------------
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end



