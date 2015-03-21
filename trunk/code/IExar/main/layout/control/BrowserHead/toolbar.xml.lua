local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
function OnMainPageLeftButtonMouseEnter(self, x, y)
	local right = self:GetObject("Layout.MainPage.Right")
	if not right then
		right = self:GetObject("Layout.Printer.Right")
	end
	right:SetState(2)
end

function OnMainPageLeftButtonMouseLeave(self, x, y)
	local right = self:GetObject("Layout.MainPage.Right")
	if not right then
		right = self:GetObject("Layout.Printer.Right")
	end
	right:SetState(0)
end

function OnMainPageRightButtonMouseEnter(self,  x, y)
	local left = self:GetParent()
	left:SetState(2)
end

function OnMainPageRightButtonMouseLeave(self, x, y)
	local left = self:GetParent()
	left:SetState(0)
end

function OnMainPageRightButtonClick(self, x, y)
	local left = self:GetParent()
	local parentattr = left:GetAttribute()
	parentattr.NormalBkgID = parentattr.DownBkgID
	parentattr.HoverBkgID = parentattr.DownBkgID
	left:Updata()
	local selfattr = self:GetAttribute()
	selfattr.NormalBkgID = selfattr.DownBkgID
	selfattr.HoverBkgID = selfattr.DownBkgID
	self:Updata()
	if self:GetID() == "Layout.MainPage.Right" then
		tFunHelper.CreateAndShowMenu(self, "MainPageMenu", 26, false, true)
	else
	end
end

function OnMainPageRightButtonFocusChange(self, isfocus)
	if true then return end
	if not isfocus then
		local left = self:GetParent()
		local parentattr = left:GetAttribute()
		parentattr.NormalBkgID = ""
		parentattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		left:Updata()
		local selfattr = self:GetAttribute()
		selfattr.NormalBkgID = ""
		selfattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		self:Updata()
	end
end

function OnMainPageLeftButtonClick(self, x, y)
	local left = self:GetObject("Layout.MainPage.Right")
	if not left then
		left = self:GetObject("Layout.Printer.Right")
	end
	local parentattr = left:GetAttribute()
	parentattr.NormalBkgID = parentattr.DownBkgID
	parentattr.HoverBkgID = parentattr.DownBkgID
	left:Updata()
	local selfattr = self:GetAttribute()
	selfattr.NormalBkgID = selfattr.DownBkgID
	selfattr.HoverBkgID = selfattr.DownBkgID
	self:Updata()
	if self:GetID() == "Layout.MainPage.Left" then
		--´ò¿ªÖ÷Ò³
		--tFunHelper.CreateAndShowMenu(self, "MainPageMenu", 0, true)
	else
	end
end

function OnMainPageLeftButtonFocusChange(self, isfocus)
	if not isfocus then
		local left = self:GetObject("Layout.MainPage.Right")
		if not left then
			left = self:GetObject("Layout.Printer.Right")
		end
		local parentattr = left:GetAttribute()
		parentattr.NormalBkgID = ""
		parentattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		left:Updata()
		local selfattr = self:GetAttribute()
		selfattr.NormalBkgID = ""
		selfattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		self:Updata()
	end
end