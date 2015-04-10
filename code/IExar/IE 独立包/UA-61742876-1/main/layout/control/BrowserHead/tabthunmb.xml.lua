local tipUtil = XLGetObject("API.Util")
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

function OnInitControl(self)
	
end

function Show(self)
	local attr = self:GetAttribute()
	local bmp = self:GetControlObject("Layout.Forground")
	bmp:SetBitmap(attr.BitmapHandle)
	bmp:SetDrawMode(1)
	local closebtn = self:GetControlObject("Layout.CloseBtn")
	closebtn:Updata()
end

function OnControlMouseEnter(self, x, y)
	local bkg = self:GetControlObject("Layout.main")
	bkg:SetSrcColor("RGBA(255,255,100,100)")
	bkg:SetDestColor("RGBA(255,255,100,100)")
end

function OnControlMouseLeave(self, x, y)
	local bkg = self:GetControlObject("Layout.main")
	bkg:SetSrcColor("RGBA(255,255,100,0)")
	bkg:SetDestColor("RGBA(255,255,100,0)")
end

function OnLButtonDown(self, x, y)
end

function OnLButtonUp(self, x, y)
end

function OnClickClose(self)
end




