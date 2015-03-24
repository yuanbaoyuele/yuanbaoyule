local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
function OnMainPageLeftButtonMouseEnter(self, x, y)
	local right = self:GetObject("Layout.MainPage.Right")
	if not right then
		right = self:GetObject("Layout.Printer.Right")
	end
	right:SetState(1)
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
	left:SetState(1)
end

function OnMainPageRightButtonMouseLeave(self, x, y)
	local left = self:GetParent()
	left:SetState(0)
end

function TryDistoryOldMenu(self)
	local tMenuNames = {"MainPageMenu", "PrintMenu", "PageMenu", "SafeMenu", "ToolBarMenu", "HelpMenu"}
	for i, v in ipairs(tMenuNames) do
		tFunHelper.TryDestroyOldMenu(self, v)
	end
end

function OnMainPageRightButtonClick(self, x, y)
	local left = self:GetParent()
	OnMainPageLeftButtonMouseEnter(left)
	--local parentattr = left:GetAttribute()
	--parentattr.NormalBkgID = parentattr.DownBkgID
	--parentattr.HoverBkgID = parentattr.DownBkgID
	--left:Updata()
	local selfattr = self:GetAttribute()
	selfattr.NormalBkgID = selfattr.DownBkgID
	selfattr.HoverBkgID = selfattr.DownBkgID
	self:Updata()
	TryDistoryOldMenu(self)
	if self:GetID() == "Layout.MainPage.Right" then
		tFunHelper.CreateAndShowMenu(self, "MainPageMenu", 26, false, true)
	else
		tFunHelper.CreateAndShowMenu(self, "PrintMenu", 26, false, true)
	end
end

function OnMainPageRightButtonFocusChange(self, isfocus)
	--if true then return end
	--local hostwndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	--local hostwnd = hostwndMgr:GetHostWnd("MainPageMenu.HostWnd.Instance")
	--if hostwnd then return end
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
	 local right = self:GetObject("Layout.MainPage.Right")
	 if not right then
		 right = self:GetObject("Layout.Printer.Right")
	 end
	right:SetState(0)
	-- local parentattr = left:GetAttribute()
	-- parentattr.NormalBkgID = parentattr.DownBkgID
	-- parentattr.HoverBkgID = parentattr.DownBkgID
	-- left:Updata()
	-- local selfattr = self:GetAttribute()
	-- selfattr.NormalBkgID = selfattr.DownBkgID
	-- selfattr.HoverBkgID = selfattr.DownBkgID
	-- self:Updata()
	if self:GetID() == "Layout.MainPage.Left" then
		--´ò¿ªÖ÷Ò³
		--tFunHelper.CreateAndShowMenu(self, "MainPageMenu", 0, true)
		local strHomePage = tFunHelper.GetHomePage()
		if strHomePage ~= "" and strHomePage ~= nil then
			tFunHelper.OpenURLInCurTab(strHomePage)	
		end
	else
	end
end

function OnMainPageLeftButtonFocusChange(self, isfocus)
	--if true then return end
	--local hostwndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	--local hostwnd = hostwndMgr:GetHostWnd("MainPageMenu.HostWnd.Instance")
	--if hostwnd then return end
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

function OnMainPageLeftLButtonDown(self)
	local right = self:GetObject("Layout.MainPage.Right")
	if not right then
		right = self:GetObject("Layout.Printer.Right")
	end
	right:SetState(2)
end

function OnPagePClick(self)
	--local selfattr = self:GetAttribute()
	--selfattr.NormalBkgID = selfattr.DownBkgID
	--selfattr.HoverBkgID = selfattr.DownBkgID
	--self:Updata()
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "PageMenu", 26, false, true)
end

function OnSafeClick(self)
	--local selfattr = self:GetAttribute()
	--selfattr.NormalBkgID = selfattr.DownBkgID
	--selfattr.HoverBkgID = selfattr.DownBkgID
	--self:Updata()
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "SafeMenu", 26, false, true)
end

function HideOutChild(self)
	local parent = self:GetControlObject("Layout.main")
	local nCount = parent:GetChildCount()
	local pl, pt, pr, pb = parent:GetObjPos()
	for i = 1, nCount do
		local objChild = parent:GetChildByIndex(i)
		if objChild then
			local l, t, r, b = objChild:GetObjPos()
			if pr-pl <= 50 and objChild:GetID() == "Layout.More.Btn"  then
				objChild:SetVisible(false)
				objChild:SetChildrenVisible(false)
			elseif r > pr-pl-13 and objChild:GetID() ~= "Layout.More.Btn"  then
				objChild:SetVisible(false)
				objChild:SetChildrenVisible(false)
			else
				objChild:SetVisible(true)
				objChild:SetChildrenVisible(true)
			end
		end
	end
end

function OnPosChange(self, oldl, oldt, oldr, oldb, newl, newr, newr, newb)
	local owner = self:GetOwnerControl()
	local l, t, r, b = owner:GetObjPos()
	local width = r-l
	if width <= 350 then
		self:SetObjPos2("father.width-"..(30), 87, 30, 25)
	elseif width < 738 then
		local newWidth = 411-738+width
		if newWidth<0 then
			newWidth = 0
		end
	
		self:SetObjPos2("father.width-"..(411-738+width), 87, newWidth, 25)
	else
		self:SetObjPos2("father.width-"..(411), 87, 411, 25)
	end
	HideOutChild(self)
end

function OnToolOClick(self)
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "ToolBarMenu", 26, false, true)
end

function OnHelpClick(self)
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "HelpMenu", 26, false, true)
end

function OnMoreClick(self)
	tFunHelper.TryDestroyOldMenu(self, "ToolBarMoreMenu")
	tFunHelper.CreateAndShowMenu(self, "ToolBarMoreMenu", 26, false, true)
end