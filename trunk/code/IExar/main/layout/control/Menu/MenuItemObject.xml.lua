-- 属性SubMenuID是NoramlMenu的一个模板ID，根据属性其创建子菜单（子菜单也是一个NormalMenu）
function CreateSubMenu( self )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	if attr.SubMenuID ~= nil then	
		local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local menuTemplate = templateMananger:GetTemplate(attr.SubMenuID,"ObjectTemplate")
		if menuTemplate == nil then
			return
		end
		local sub_menu = menuTemplate:CreateInstance( attr.SubMenuID.."instance" )
		if sub_menu == nil then
			return
		end
		local submenu_attr = sub_menu:GetAttribute()
		submenu_attr.ParentObj = self
		sub_menu:SetVisible( false )
		sub_menu:SetChildrenVisible(false)
		self:AddChild( sub_menu )
		sub_menu:OnInitControl()	
	end
end

function Show(self, show)
    local attr = self:GetAttribute()
	if attr == nil then
		return
	end
    attr.Visible = show
	self:SetVisible(show)
    self:SetChildrenVisible(show)
end

function IsVisible(self)
    local attr = self:GetAttribute()
	if attr == nil then
		return false
	end
    return attr.Visible
end

-- 
function SetShowType( self, type_ )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Type = type_
	
	if attr.Type == 0 then
		if attr.Text ~= nil then
			self:SetText(attr.Text, attr.RightText)
		end
		-- if attr.Icon ~= nil then
			-- self:SetIconID(attr.Icon)
		-- end
		
		if attr.SubMenuID ~= nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")			
			local arrow = uiFactory:CreateUIObject("menu_arrow", "ImageObject")
			if arrow ~= nil then
				arrow:SetResProvider(xarManager)
				arrow:SetResID( attr.NormalArrow )
				self:AddChild( arrow )
				arrow:SetObjPos( "father.width - 23", "(father.height-8)/2+1", "father.width - 9", "(father.height-8)/2 + 1 + 8" )
			end
		end
		
		if attr.Enable ~= nil then
			self:SetEnable(attr.Enable)
		end
		self:Show(attr.Visible)
	else
		self:SetEnable( 0 )
		local separator = self:GetControlObject( "separator" )
		if separator == nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			separator = uiFactory:CreateUIObject("separator", "ImageObject")
			if separator ~= nil then
				separator:SetResProvider(xarManager)
				separator:SetDrawMode(1)
				self:AddChild( separator )						
				separator:SetObjPos( "2", "(father.height - "..attr.SeparatorHeight..")/2", "father.width-1", "(father.height + "..attr.SeparatorHeight..")/2" )
			end
		end
		if attr.Icon ~= nil then
			separator:SetResID( attr.Icon )
		end
    end
end


function OnInitControl(self)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end	
	self:FireExtEvent( "OnInit" )
	attr.show_sub_menu = false
	SetShowType( self, attr.Type)		
	
	local bShow = attr.DeleteImgVisible
	self:ShowDeleteBtn(bShow)
end

function SetFontColorNormal(self,color)
	local attr = self:GetAttribute()
	attr.FontColorNormal = color
	local item = self:GetControlObject("text")
	item:SetTextColorResID(attr.FontColorNormal)
end

--设置描边
function SetFontBorder(self,color)
	local attr = self:GetAttribute()
	local item = self:GetControlObject("text")
	item:SetEffectType("border")
	item:SetEffectColorResID(color)
end

function SetFontShadow(self,color,x,y)
	local attr = self:GetAttribute()
	local item = self:GetControlObject("text") 
	item:SetEnableShadow(1)
	item:SetShadowOffset(x,y)
	item:SetShadowColorResID(color)
end

function SetFont(self,font)
	local attr = self:GetAttribute()
	if attr.Font == font then
		return
	end
	attr.Font = font
	local item = self:GetControlObject("text")
	if item then
		item:SetTextFontResID(attr.Font)
	end
end

function GetText(self)
	local item = self:GetControlObject("text")
	return item:GetText()
end


function GetExtraData(self)
	local attr = self:GetAttribute()
	return attr.ExtraData
end


function SetText(self, text_, strRightText)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Text = text_
	attr.RightText = strRightText
	
	if attr.Type == 0 then
		local item = self:GetControlObject("text")
		if item == nil then
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
			local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
			local text_template = templateManager:GetTemplate( "menu.text", "ObjectTemplate" )
			item = text_template:CreateInstance( "text" )
			self:AddChild( item )
			-- item:SetResProvider(xarManager)
			if IsRealString(strRightText) then
				item:SetObjPos( ""..attr.TextPos, "0", "father.width/2-20", "father.height" )
			else
				item:SetObjPos( ""..attr.TextPos, "0", "father.width-"..tostring(attr.TextRightSpan), "father.height" )
			end	
			
			if attr.Font ~= nil and attr.Font ~= "" then
				item:SetTextFontResID( attr.Font )
			end
			item:SetTextColorResID( attr.FontColorNormal )
		end
		
		item:SetText(text_)
		if attr.AccKey and attr.AccKey then
			item:SetShortCutKey(attr.AccKey)
			item:SetKeyFont(attr.KeyFont)
		end
		SetRightText(self, strRightText)
		
		-- self:SetEnable(attr.Enable)
	end
end

function SetRightText(objRootCtrl, strRightText)
	local attr = objRootCtrl:GetAttribute()
	local item = objRootCtrl:GetControlObject("righttext")
	if item == nil then
		local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
		local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")
		local text_template = templateManager:GetTemplate( "menu.text", "ObjectTemplate" )
		item = text_template:CreateInstance( "righttext" )
		objRootCtrl:AddChild( item )
		item:SetResProvider(xarManager)
		
		item:SetObjPos( "father.width/2+5", "0", "father.width-"..tostring(attr.RightTextPos), "father.height")
		
		if attr.RightTextFont ~= nil and attr.RightTextFont ~= "" then
			item:SetTextFontResID( attr.RightTextFont )
		end
		item:SetTextColorResID( attr.RightTextColor )
		item:SetText(strRightText)
		item:SetHAlign(attr.RightTextHAligh)
	end
end


function SetTipsText(self, text_)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.TipsText = text_
end


function SetIconBitmap(self, objBitmap )
	local icon = self:GetControlObject( "icon" )
	
	if icon ~= nil then
		icon:SetBitmap(objBitmap)
	end	
end

function SetIconVisible(self, bVisible )
	local icon = self:GetControlObject( "icon" )
	if icon ~= nil then
		icon:SetVisible(bVisible)
	end	
end



function SetIconID( self, iconID )
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	attr.Icon = iconID
	if attr.Type == 0 then
		if attr.Icon ~= nil then
			local icon = self:GetControlObject( "icon" )
			if icon == nil then
				local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
				local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
				icon = uiFactory:CreateUIObject("icon", "ImageObject")
				if icon ~= nil then
					icon:SetResProvider(xarManager)
					icon:SetDrawMode( 1 )
					icon:SetAntialias( 2 )
					self:AddChild( icon )
					icon:SetObjPos( ""..attr.IconPos, "(father.height-"..attr.IconHeight..")/2", ""..attr.IconPos.."+"..attr.IconWidth, "(father.height+"..attr.IconHeight..")/2" )
				end
			end
			icon:SetResID( iconID )
			icon:SetVisible( attr.IconVisible )
		else
			local icon = self:GetControlObject( "icon" )
			if icon ~= nil then
				self:RemoveChild( icon )
			end
		end
	else
		self:SetEnable( 0 )
		local separator = self:GetControlObject( "separator" )
		if separator ~= nil then
			separator:SetResID( attr.Icon )
		end
	end
end

function GetIconID(self)
	local attr = self:GetAttribute()
	return attr.Icon
end

function SetEnable(self, enable)
	local attr = self:GetAttribute()
	if attr == nil then
		return
	end
	if attr.Type == 0 then
		attr.Enable = enable
		local textitem = self:GetControlObject("text")
		local righttext = self:GetControlObject("righttext")
		local hotkeyitem = self:GetControlObject("text.hotkey")
		
		if enable == 0 or not enable then
			if textitem then
				textitem:SetTextColorResID(attr.FontColorDisable)
			end
			if righttext then
				righttext:SetTextColorResID(attr.FontColorDisable)
			end
			
			-- textitem:SetEnableShadow(1)
			-- textitem:SetShadowColorResID("color.gray.shadow")
			-- textitem:SetShadowOffset(1, 1)
			if hotkeyitem then
				hotkeyitem:SetTextColorResID(attr.FontColorDisable)
			end
		else
			if textitem then
				textitem:SetTextColorResID(attr.FontColorNormal)
				-- textitem:SetEnableShadow(0)
			end
			if righttext then
				righttext:SetTextColorResID(attr.FontColorNormal)
			end
			
			if hotkeyitem then
				hotkeyitem:SetTextColorResID(attr.FontColorNormal)
				-- hotkeyitem:SetEnableShadow(0)
			end
		end
	elseif attr.Type == 1 then
		attr.Enable = enable
	end
end


-- 得到菜单项的宽度（此方法给MenuObject调，遍历计算出最宽的值，用以调整整个菜单的宽度）
function GetMinWidth(self)
	local attr = self:GetAttribute()
	if attr.Type == 0 then
		local textObj = self:GetControlObject("text")
		local cx, cy = textObj:GetTextExtent()
		local hotkeyTextObj = self:GetControlObject("text.hotkey")
		if hotkeyTextObj then
			local hotkeyx, hotkeyy = hotkeyTextObj:GetTextExtent()
			cx , cy = cx + hotkeyx, cy + hotkeyy
		end
		if attr.TextRightWidth < 16 then 
			return attr.TextPos + cx + attr.TextRightWidth - 16
		else
			return attr.TextPos + cx + attr.TextRightWidth
		end
	end
end

-- 改变菜单字体颜色，弹出子菜单的箭头状态，state 1 hover 0 normal
function ChangeState(self,newState)		
	local attr = self:GetAttribute()
	if attr.State == newState then
		return
	end
	
	if not attr.Visible then
	    return
	end
	
	attr.State = newState
	
	if attr.Type == 0 then
		if attr.Enable == 0 or not attr.Enable then
			return
		end
		
		local arrow = self:GetControlObject( "menu_arrow" )
		if arrow ~= nil then
			if newState == 0 then
				arrow:SetResID( attr.NormalArrow )
			else
				arrow:SetResID( attr.HoverArrow )
			end
		end
		local item = self:GetControlObject("text")
		local righttext = self:GetControlObject("righttext")
		if item ~= nil then
			if newState == 0 then
				item:SetTextColorResID( attr.FontColorNormal )
				righttext:SetTextColorResID( attr.FontColorNormal )
			else
				item:SetTextColorResID( attr.FontColorHover )
				righttext:SetTextColorResID( attr.FontColorHover )
			end
		end
	end
end

-- 用户单击此菜单项调。（在NoramlMenu里面处理菜单快捷键或按enter时也会调此函数）
function SelectItem(self)
	local id = self:GetID()
	self:FireExtEvent("OnPreSelect", id)
	local sub_menu = self:GetSubMenu()
	if sub_menu == nil then
		local menuObj = self:GetFather()
		menuObj:EndMenu()
		
		self:FireExtEvent("OnSelect", id)
	else
		if not self:IsShowSubMenu() then
			self:ShowSubMenu(false)
		end
	end
end

function CancelItem(self)	
	local menuObj = self:GetFather()
	menuObj:EndMenu()
end

function OnLButtonUp(self, x, y)
	local attr = self:GetAttribute()
	if not attr.Visible then
	    return
	end
	if not self:IsEnable() then
		return
	end
	
	-- self:SetCaptureMouse(false)
	local left,top,right,bottom = self:GetObjPos()
	local width,height = right - left, bottom - top
		
	if (x >= 0) and (x < width) and (y >= 0) and (y < height) then
		self:SelectItem()
	else 
		self:CancelItem()
	end
	
	return 0, false
end

-- 通过SubMenuID属性，得到子菜单，没子菜单就创建，子菜单是挂在此菜单项的children下。
function GetSubMenu(self)
	local attr = self:GetAttribute()
	if attr == nil then return end
	if attr.SubMenuID ~= nil then
		local sub_menu = self:GetControlObject( attr.SubMenuID.."instance" )
		if sub_menu == nil then
			if attr.SubMenuID ~= nil then
				CreateSubMenu( self )
			end
			sub_menu = self:GetControlObject( attr.SubMenuID.."instance" )
		end
		return sub_menu
	end
end

function OnMouseHover(self)
	local submenu = self:GetSubMenu()
	if submenu == nil then
		return
	end
	
	--try show submenu
end

-- 通过父亲MenuObject接口SetHoverItem统一处理（选中此菜单项，弹出子菜单等）
function OnMouseMove(self)
	local attr = self:GetAttribute()
	if self:IsEnable() and attr.Type == 0 then
		if attr.State == 1 then
			return
		end
		if not attr.Visible then
			return
		end
		local menu = self:GetFather()	
		menu:SetHoverItem(self)
		self:SetFocus( true )
		if attr.TipsText then
	--		XMP.SetTips(attr.TipsText,0)
		end
	end
end

-- 通过父亲MenuObject接口SetHoverItem统一处理（取消当前选中）
function OnMouseLeave(self)
	local attr = self:GetAttribute()
	if self:IsEnable() and attr.Type == 0 then
		if attr.State == 0 then
			return
		end
		
		if not attr.Visible then
			return
		end
		local menu = self:GetFather()
		--local oldItem = menu:GetAttribute().HoverItem
		menu:SetHoverItem(nil)
		if attr.TipsText then
	--		XMP.SetTips()
		end
	end
end

function IsEnable(self)
	local attr = self:GetAttribute()
	if attr.Enable ~= nil then
		if attr.Enable == 0 or not attr.Enable then
			return false
		end
	end
	
	return true
end

function OnLButtonDown(self)
	local attr = self:GetAttribute()
	if not attr.Visible then
	    return
	end
	if self:IsEnable() then
		self:SetCaptureMouse(true)
	end
end

function OnRButtonUp(self)

end


-- 设置submenuid,MenuObject的templateid来设置
function SetSubMenu( self, menuid )
	local attr = self:GetAttribute()
	attr.SubMenuID = menuid
	local arrow = self:GetControlObject( "menu_arrow" )
	if attr.SubMenuID ~= nil then
		if arrow == nil then
			local uiFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
			local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")			
			local arrow = uiFactory:CreateUIObject("menu_arrow", "ImageObject")
			if arrow ~= nil then
				arrow:SetResProvider(xarManager)
				arrow:SetResID( attr.NormalArrow )
				self:AddChild( arrow )
				arrow:SetObjPos( "father.width - 13", "(father.height-8)/2", "father.width - 9", "(father.height-8)/2 + 8" )
			end
		end
	else
		self:RemoveChild( arrow )
	end
end

function EndSubMenu( self )
	local submenu = self:GetSubMenu()
	if submenu ~= nil then
		--submenu:SetChildrenVisible( false )
		self:RemoveChild( submenu )
		local attr = self:GetAttribute()
		attr.show_sub_menu = false		
	end
end

function ShowSubMenu( self, is_keyboard )
	local submenu = self:GetSubMenu()
	if submenu ~= nil then
	    self:FireExtEvent("OnShowSubMenu")
		if submenu:GetItemCount() == 0 then
			--return
		end
		local left, top, right, bottom = self:GetObjPos()
		local abs_left, abs_top, abs_right, abs_bottom = self:GetAbsPos()
		local sub_left, sub_top, sub_right, sub_bottom = submenu:GetObjPos()
		
		local father_menu = self:GetFather()
		local father_abs_left, father_abs_top, father_abs_right, father_abs_bottom = father_menu:GetAbsPos()
		
		-- 通过父亲菜单的位置调整子菜单的位置
		local menuTree = submenu:GetOwner()
		local menuHostWnd = menuTree:GetBindHostWnd()		
		abs_left, abs_top = menuHostWnd:ClientPtToScreenPt( abs_left, abs_top )
		abs_right, abs_bottom = menuHostWnd:ClientPtToScreenPt( abs_right, abs_bottom )
		father_abs_left, father_abs_top = menuHostWnd:ClientPtToScreenPt( father_abs_left, father_abs_top )
		father_abs_right, father_abs_bottom = menuHostWnd:ClientPtToScreenPt( father_abs_right, father_abs_bottom )
		local sleft, stop, sright, sbottom = menuHostWnd:GetMonitorRect(father_abs_left, father_abs_top)
		local widthDiff
		-- if XMP.Helper.IsNotTransparent() and XMP.PlayCtrl.IsPlaying() then
			-- widthDiff = 2   --没有阴影
		-- else
			 widthDiff = 6   --有阴影
		-- end
		
		if father_abs_right + sub_right - sub_left > sright and abs_top + sub_bottom - sub_top <= sbottom then--左下
			submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left + widthDiff, 0, father_abs_left - abs_left + widthDiff, sub_bottom - sub_top )
			submenu:SetPopStatus( 1, 2 )
		elseif father_abs_right + sub_right - sub_left > sright and abs_top + sub_bottom - sub_top > sbottom then--左上
			submenu:SetObjPos( sub_left - sub_right + father_abs_left - abs_left + widthDiff, sub_top - sub_bottom + bottom - top, father_abs_left - abs_left + widthDiff, bottom - top )
			submenu:SetPopStatus( 2, 2 )
		elseif father_abs_right + sub_right - sub_left <= sright and abs_top + sub_bottom - sub_top > sbottom then--右上
			submenu:SetObjPos( father_abs_right - abs_left - widthDiff, sub_top - sub_bottom + bottom - top, father_abs_right - abs_left + sub_right - sub_left - widthDiff, bottom - top )
			submenu:SetPopStatus( 2, 1 )
		elseif father_abs_right + sub_right - sub_left <= sright and abs_top + sub_bottom - sub_top <= sbottom then--右下
			submenu:SetObjPos( father_abs_right - abs_left - widthDiff, 0, father_abs_right - abs_left + sub_right - sub_left - widthDiff, sub_bottom - sub_top )
			submenu:SetPopStatus( 1, 1 )
		end
		if is_keyboard ~= nil and is_keyboard then
			submenu:MoveNextItem()
			submenu:SetFocus( true )
		end
		-- 动画显示
		submenu:AnimateShow()
		submenu:SetVisible( true )
		submenu:SetChildrenVisible(true)
		local attr = self:GetAttribute()
		attr.show_sub_menu = true	
		
		SetWindowSize(submenu)
	end
end


function SetWindowSize(submenu)
	local objTree = submenu:GetOwner()
	local objMenuWnd = objTree:GetBindHostWnd()
	local nWndL, nWndT, nWndR, nWndB = objMenuWnd:GetWindowRect()
	local nSubMenuL, nSubMenuT, nSubMenuR, nSubMenuB = submenu:GetObjPos()
	
	local nWndWidth = nWndR-nWndL
	local nWndHeight = nWndB-nWndT
	if nWndWidth < nSubMenuR then
		nWndWidth = nSubMenuR
	end
	
	if nWndHeight < nSubMenuB then
		nWndHeight = nSubMenuB
	end
	
	objMenuWnd:Move(nWndL, nWndT, nWndL+nWndWidth, nWndT+nWndHeight)
end


-- 返回菜单项大小，给上层的MenuObject调，调整菜单宽度
function GetItemSize( self )
	local left, top, right, bottom = self:GetObjPos()
	return right - left, bottom - top
end

-- 设置type 1 菜单项，0 分割条
function SetType( self, type_ )
	local attr = self:GetAttribute()
	if attr.Type ~= type_ then
		if attr.Type == 0 then
			local text = self:GetControlObject( "text" )
			self:RemoveChild( text )
			local icon = self:GetControlObject( "icon" )
			self:RemoveChild( icon )
			local arrow = self:GetControlObject( "menu_arrow" )
			self:RemoveChild( arrow )
		elseif attr.Type == 1 then
			local separator = self:GetControlObject( "separator" )
			self:RemoveChild( separator )
		end
	end
	SetShowType( self, type_)
end

function OnKeyDown( self, char )
	self:RouteToFather()
end

function HasSubMenu( self )
	local attr = self:GetAttribute()
	if attr.SubMenuID ~= nil then
		return true
	end
	return false
end

function SetAccKey( self, key )
	local attr = self:GetAttribute()
	attr.AccKey = key
	self:SetText(attr.Text)
end

function IsShowSubMenu( self )
	local attr = self:GetAttribute()
	return attr.show_sub_menu
end

function SetMargin( self, left, top, right, bottom)
	local attr = self:GetAttribute()
	
	attr.IconPos = attr.IconPos+left
	attr.TextPos = attr.TextPos+left
end

function GetParentItem(self)
	local menu = self:GetOwnerControl()
	return menu:GetParentItem()
end

function SetUserData(self, data)
	local attr = self:GetAttribute()
	attr.Data = data
end

function GetUserData(self)
	local attr = self:GetAttribute()
	return attr.Data
end


function ShowDeleteBtn(self, bShow)
	local objDelete = self:GetControlObject("MenuItem.Delete")
	if objDelete then
		objDelete:SetVisible(bShow)
		objDelete:SetChildrenVisible(bShow)
	end
end


function OnClickDelete(self)
	local objMenuItem = self:GetOwnerControl()
	local objMenu = objMenuItem:GetFather()
	
	if not objMenuItem or not objMenu then
		return
	end
	
	DeleteHistory(objMenu, objMenuItem)	
	
	local nIndex = objMenu:GetItemIndex(objMenuItem)
	if nIndex == 0 then
		return
	end
	
	local objNormalMenu = objMenu:GetOwnerControl()
	if objNormalMenu then
		objNormalMenu:RemoveItem(nIndex)
	end
end


function DeleteHistory(objMenu, objMenuItem)	
	local attr = objMenu:GetAttribute()
	local strMenuType = attr.MenuType
	
	if not IsRealString(strMenuType) then
		return
	end

	local tFunHelper = XLGetGlobal("YBYL.FunctionHelper") 
	if strMenuType == "urlhistory" then
		local strURL = objMenuItem:GetText()
		tFunHelper.RemoveHistoryURL(strURL)
		
	elseif strMenuType == "collect" then
		local strURL = objMenuItem:GetExtraData()
		tFunHelper.RemoveUserCollectURL(strURL)
		tFunHelper.UpdateCollectList()
	end
end



function RouteToFather(self)
	self:RouteToFather()
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end