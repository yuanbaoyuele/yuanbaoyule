local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")

-------事件---
function OnInitControl(self)
	ShowUserCollect(self)
end

--

function ShowUserCollect(self)
	local tCollectInfo = GetCollectInfo(self)
	local objMenuContainer = CreateMenuContainer(self)
	if not objMenuContainer then
		return false
	end
		
	local nTotalCount = 0
	for nIndex=1, #tCollectInfo do
		local tSubInfo = tCollectInfo[nIndex]
		if type(tSubInfo) == "table" then
			local objMenuItem = CreateMenuItem(tSubInfo, nIndex)	
			if objMenuItem then
				objMenuContainer:AddChild(objMenuItem)
				nTotalCount = nTotalCount+1
			end			
		end	
	end
	
	if nTotalCount < 1 then
		self:SetVisible(false)
		self:SetChildrenVisible(false)
	else
		BindMenuContainer(self, objMenuContainer, 9, nTotalCount)
	end
end


function CreateMenuContainer(objNormalMenuCtrl)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local menuTemplate = templateMananger:GetTemplate("toolbarmoremenu.context", "ObjectTemplate")
	if menuTemplate == nil then
		return nil
	end
	local objMenu = menuTemplate:CreateInstance( "context_menu" )
	return objMenu
end


function CreateMenuItem(tCollectInfo, nIndex)	
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local objMenuItemTempl = templateMananger:GetTemplate("menu.context.item", "ObjectTemplate")
	if objMenuItemTempl == nil then
		return nil
	end
	
	local objMenuItem = objMenuItemTempl:CreateInstance( "ToolBarMore_"..tostring(nIndex) )
	if not objMenuItem then
		return nil
	end

	local attr = objMenuItem:GetAttribute()
	attr.Text = tCollectInfo["strName"]
	if tCollectInfo["strTarget"] ~= "" then
		attr.SubMenuID = tCollectInfo["strTarget"]
	else
		attr.Enable = 0
	end
	attr.FontColorNormal = "404040"
	attr.TextPos = 27
	attr.DeleteImgVisible = false
	
	SetIcoImage(objMenuItem, tCollectInfo)
	objMenuItem:AttachListener("OnSelect", false, OnRButtonUpMenuItem)
	--objMenuItem:AttachListener("OnRButtonUp", false, OnRButtonUpMenuItem)
	return objMenuItem
end


function SetIcoImage(objMenuItem, tCollectInfo)
	local attr = objMenuItem:GetAttribute() 
	attr.IconPos = 3
	attr.IconWidth = 17
	attr.IconHeight = 17
	attr.IconVisible = true
	attr.Icon = tCollectInfo["objBitmap"]
	--local objBitmap = tCollectInfo["objBitmap"]
	--local strDefaultImgID = tFunHelper.GetDefaultIcoImgID()
	--objMenuItem:SetIconID(strDefaultImgID)
		
	--local objImage = objMenuItem:GetControlObject("icon")
	--if objBitmap and objImage then
		-- local objClone = objBitmap:Clone()
		--objMenuItem:SetIconID(objBitmap)
	--end
end


function OpenURL(objMenuItem)
	local strURL = objMenuItem:GetExtraData()
	tFunHelper.OpenURLInNewTab(strURL)
end


function OnRButtonUpMenuItem(objMenuItem)
	 --local attr = objMenuItem:GetAttribute()
	 --tFunHelper.TryDestroyOldMenu(objMenuItem, attr.MenuName)
	 --tFunHelper.CreateAndShowMenu(objMenuItem, attr.MenuName, 0, false, true)
end


--从CollectList控件获取数据
function GetCollectInfo(objContext)
	local objMenuBarCtrl = GetMenuBarCtrl(objContext)
	if not objMenuBarCtrl then
		return {}
	end
	local tMenuMap = {
		["Layout.Help.Btn"] = {["icon"] = "bmphelpico", ["text"] = "帮助", ["target"]="helpmenu.context.submenu"},
		["Layout.ToolO.Left"] = {["text"] = "工具", ["target"]="toolbar.context.submenu"},
		["Layout.SafeS.Left"] = {["text"] = "安全", ["target"]="safe.context.submenu"},
		["Layout.PageP.Left"] = {["text"] = "页面", ["target"]="page.context.submenu"},
		["Layout.Printer.Left"] = {["icon"]="bmpprint", ["text"] = "打印机", ["target"]="print.context.submenu"},
		["Layout.SlotMail.Left"] = {["icon"]="bmpslotmail", ["text"] = "邮件", ["target"]=""},
		["Layout.Source.Left"] = {["icon"]="bmpsourcedisable", ["text"] = "源", ["target"]=""},
	}
	local parent = objMenuBarCtrl:GetControlObject("Layout.main")
	local nCount = parent:GetChildCount()
	local tCollectInfo = {}
	for i = 1, nCount do
		local objChild = parent:GetChildByIndex(i)
		if objChild and not objChild:GetVisible() and not objChild:GetChildrenVisible() then
			local strID = objChild:GetID()
			if type(tMenuMap[strID]) == "table" then
				local nIndex = #tCollectInfo+1
				tCollectInfo[nIndex] = {}
				tCollectInfo[nIndex]["strName"] = tMenuMap[strID]["text"]
				tCollectInfo[nIndex]["objBitmap"] = tMenuMap[strID]["icon"]
				tCollectInfo[nIndex]["strTarget"] = tMenuMap[strID]["target"]
			end
		end
	end
	
	return tCollectInfo
end


function BindMenuContainer(self, objMenuContainer, nMaxShowHistory, nTotalCount)
	local attr = self:GetAttribute()
	attr.nLinePerPage = nMaxShowHistory
	attr.nTotalLineCount = nTotalCount

	self:OnInitControl(objMenuContainer)
end


function GetMenuBarCtrl(objMenuItem)
	local objHeadCtrl = tFunHelper.GetHeadCtrlChildObj("head.toolbar.instance")
	return objHeadCtrl
end


-----
function IsRealString(str)
	return type(str) == "string" and str~=nil
end


