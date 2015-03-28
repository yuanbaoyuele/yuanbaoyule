local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local gStatMenuPop = false
local gLastSelectObj
local gLastMenuName

function PopMenu(self, name)
	if not gStatMenuPop or not gLastSelectObj or not gLastMenuName or gLastMenuName == name  then return end
	gLastSelectObj = self
	gLastMenuName = name
	
	-- local left1 = gLastSelectObj:GetParent()
	-- if left1 and left1.GetAttribute then
		-- local parentattr = left1:GetAttribute()
		-- parentattr.NormalBkgID = ""
		-- if left1.Updata then
			-- left1:Updata()
		-- end
	-- end
	-- local attr1 = gLastSelectObj:GetAttribute()
	-- attr1.NormalBkgID = ""
	-- gLastSelectObj:Updata()
	
	-- local left = self:GetParent()
	-- if left and left.GetAttribute then
		-- local parentattr = left:GetAttribute()
		-- parentattr.NormalBkgID = parentattr.HoverBkgID
		-- if left.Updata then
			-- left:Updata()
		-- end
	-- end
	-- local attr = self:GetAttribute()
	-- attr.NormalBkgID = attr.HoverBkgID
	-- self:Updata()
	tFunHelper.TryDestroyOldMenu(gLastSelectObj, gLastMenuName)
	tFunHelper.CreateAndShowMenu(self, name, 26, false, true)
	gStatMenuPop = false
end
function OnMainPageLeftButtonMouseEnter(self, x, y)
	local right = self:GetObject("Layout.MainPage.Right")
	if not right then
		right = self:GetObject("Layout.Printer.Right")
		self:SetState(1)
		right:SetState(1)
		PopMenu(right, "PrintMenu")
	else
		self:SetState(1)
		right:SetState(1)
		PopMenu(right, "MainPageMenu")
	end
end

function InitMenuHelper()
	local objActiveTab = tFunHelper.GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		return
	end
	
	local objBrowserCtrl = objActiveTab:GetBindBrowserCtrl()
	if objBrowserCtrl then
		local objUEBrowser = objBrowserCtrl:GetControlObject("browser")
		tIEMenuHelper:Init(objUEBrowser)
	end
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
	InitMenuHelper()
	local tMenuNames = {"MainPageMenu", "PrintMenu", "PageMenu", "SafeMenu", "ToolBarMenu", "HelpMenu"}
	for i, v in ipairs(tMenuNames) do
		tFunHelper.TryDestroyOldMenu(self, v)
	end
end

function OnMouseEnterPage(self)
	self:SetState(1)
	PopMenu(self, "PageMenu")
end

function OnMouseEnterSafe(self)
	self:SetState(1)
	PopMenu(self, "SafeMenu")
end

function OnMouseEnterTool(self)
	self:SetState(1)
	PopMenu(self, "ToolBarMenu")
end

function OnMainPageRightButtonClick(self, x, y)
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "MainPageMenu"
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
		gLastMenuName = "PrintMenu"
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
		--打开主页
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
		-- local left = self:GetObject("Layout.MainPage.Right")
		-- if not left then
			-- left = self:GetObject("Layout.Printer.Right")
		-- end
		-- local parentattr = left:GetAttribute()
		-- parentattr.NormalBkgID = ""
		-- parentattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		-- left:Updata()
		-- local selfattr = self:GetAttribute()
		-- selfattr.NormalBkgID = ""
		-- selfattr.HoverBkgID = "Collect.Button.Bkg.Hover"
		-- self:Updata()
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
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "PageMenu"
	--local selfattr = self:GetAttribute()
	--selfattr.NormalBkgID = selfattr.DownBkgID
	--selfattr.HoverBkgID = selfattr.DownBkgID
	--self:Updata()
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "PageMenu", 26, false, true)
end

function OnSafeClick(self)
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "SafeMenu"
	--local selfattr = self:GetAttribute()
	--selfattr.NormalBkgID = selfattr.DownBkgID
	--selfattr.HoverBkgID = selfattr.DownBkgID
	--self:Updata()
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "SafeMenu", 26, false, true)
end

local ballshow = true
function HideOutChild(self)
	local parent = self:GetControlObject("Layout.main")
	local nCount = parent:GetChildCount()
	local pl, pt, pr, pb = parent:GetObjPos()
	ballshow = true
	for i = 1, nCount do
		local objChild = parent:GetChildByIndex(i)
		if objChild then
			local l, t, r, b = objChild:GetObjPos()
			if pr-pl <= 50 and objChild:GetID() == "Layout.More.Btn"  then
				objChild:SetVisible(false)
				objChild:SetChildrenVisible(false)
				ballshow = true
			elseif r > pr-pl-13 and objChild:GetID() ~= "Layout.More.Btn" then
				objChild:SetVisible(false)
				objChild:SetChildrenVisible(false)
				ballshow = false
			elseif objChild:GetID() ~= "Layout.More.Btn"  then
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
	--隐藏更多按钮
	if ballshow then
		local objmore = self:GetControlObject("Layout.More.Btn")
		if objmore then
			objmore:Show(false)
			objmore:SetChildrenVisible(false)
		end
	else
		local objmore = self:GetControlObject("Layout.More.Btn")
		if objmore then
			objmore:Show(true)
			objmore:SetChildrenVisible(true)
		end
	end
end

function OnToolOClick(self)
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "ToolBarMenu"
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "ToolBarMenu", 26, false, true)
end

function OnHelpClick(self)
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "HelpMenu"
	TryDistoryOldMenu(self)
	tFunHelper.CreateAndShowMenu(self, "HelpMenu", 26, false, true)
end

function OnMoreClick(self)
	gStatMenuPop = true
	gLastSelectObj = self
	gLastMenuName = "ToolBarMoreMenu"
	tFunHelper.TryDestroyOldMenu(self, "ToolBarMoreMenu")
	tFunHelper.CreateAndShowMenu(self, "ToolBarMoreMenu", 26, false, true)
end


function OnMouseEnterMail(self)
	tFunHelper.ShowToolTip(true, "阅读邮件")
end


function OnMouseEnterPrint(self)
	tFunHelper.ShowToolTip(true, "打印(Atl+R)")
end


function OnMouseEnterMainPage(self)
	tFunHelper.ShowToolTip(true, "主页(Atl+M)")
end

function OnMouseEnterHelp(self)
	self:SetState(1)
	PopMenu(self, "HelpMenu")
	tFunHelper.ShowToolTip(true, "帮助 (Atl+L)")
end


function HideToolTip()
	tFunHelper.ShowToolTip(false)
end

function OnMouseEnterMore(self)
	self:SetState(1)
	PopMenu(self, "ToolBarMoreMenu")
end

























