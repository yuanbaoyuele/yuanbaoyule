local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


function RouteToFather__OnChar(self, char)
    if char == 9 then
        self:RouteToFather()
    end
end

function ComboBox__OnKeyUp( self, char )
	local attr = self:GetAttribute()
	attr.OnTab = true
    if char == 9 then
        self:RouteToFather()
    end
end

function ComboBox__OnKeyDown( self, char )
	if char == 13 then
		local edit = self:GetControlObject( "combo.edit" )
		self:FireExtEvent( "OnEnterContent", edit:GetText() )
	end
end

function CB__GetListHeight(self)
    local attr = self:GetAttribute()
    return attr.ListHeight
end

function CB__SetHostWndID(self, id)
    local attr = self:GetAttribute()
    attr.HostWndID = id
end

function CLB__OnScrollBarMouseWheel(self, name, x, y, distance)
    local owner = self:GetOwnerControl()
    owner:MouseWheel(distance / 10)
end

function CB__Edit__OnMouseWheel(self, x, y, distance)
    local owner = self:GetOwnerControl()
    local listbox = owner:GetControlObject("listbox")
    if listbox ~= nil then
        listbox:MouseWheel(distance / 10)
    end
end

function CB__SetFocus(self, focus)
    local edit = self:GetControlObject("combo.edit")
    edit:SetFocus(true)
end

function CB_OnFocusChange( self, focus )
	if focus then
		CB__SetFocus( self, focus )
	end
end

function CB__Undo(self)
    local edit = self:GetControlObject("combo.edit")
    edit:Undo()
end

function CB__SetState(self, state)
    local attr = self:GetAttribute()
    if attr.NowState ~= state then
        local bkg = self:GetControlObject("combo.bkg")
		local edit = self:GetControlObject("combo.edit")
        attr.NowState = state
        if attr.NowState == 0 then
            bkg:SetTextureID(attr.NormalBkgID)
			edit:SetTextColorID(attr.NormalTextColor)
        elseif attr.NowState == 1 then
            bkg:SetTextureID(attr.HoverBkgID)
			edit:SetTextColorID(attr.HoverTextColor)
        elseif attr.NowState == 2 then
            bkg:SetTextureID(attr.DisableBkgID)
			edit:SetTextColorID(attr.DisableTextColor)
        end
    end
end

function CB__GetText(self)
    local edit = self:GetControlObject("combo.edit")
    return edit:GetText()
end

function CB__SetText(self, text)
    local attr = self:GetAttribute()
    attr.editbysystem = true
    local edit = self:GetControlObject("combo.edit")
    edit:SetText(text)
    attr.editbysystem = false
end

function CB__AddItem(self, IconResID, IconWidth, LeftMargin, TopMargin, Text, Custom, Func)
    local listbox = self:GetControlObject("listbox")
    local num = listbox:GetItemCount()
    if num == nil then
        num = 0
    end
    num = num + 1
    local attr = self:GetAttribute()
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    local comboitem = objFactory:CreateUIObject("item"..num,"TipAddin.ComboItem")
    local itemattr = comboitem:GetAttribute()
    itemattr.NormalBkgID = attr.ItemNormalBkgID
    itemattr.HoverBkgID = attr.ItemHoverBkgID
    itemattr.LeftMargin = LeftMargin
    itemattr.TopMargin = TopMargin
    itemattr.IconResID = IconResID
    itemattr.IconWidth = IconWidth
    itemattr.ItemText = Text
    itemattr.ItemID = num
    itemattr.Custom = Custom
    itemattr.Func = Func
    listbox:AddItem(comboitem)
end

function CB__InsertItem(self, nindex, IconResID, IconWidth, LeftMargin, TopMargin, Text)
    local listbox = self:GetControlObject("listbox")
    local num = listbox:GetItemCount()
    if num == nil then
        num = 0
    end
    num = num + 1
    local attr = self:GetAttribute()
    local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
    local comboitem = objFactory:CreateUIObject("item"..num,"TipAddin.ComboItem")
    local itemattr = comboitem:GetAttribute()
    itemattr.NormalBkgID = attr.ItemNormalBkgID
    itemattr.HoverBkgID = attr.ItemHoverBkgID
    itemattr.LeftMargin = LeftMargin
    itemattr.TopMargin = TopMargin
    itemattr.IconResID = IconResID
    itemattr.IconWidth = IconWidth
    itemattr.ItemText = Text
    itemattr.ItemID = num
    listbox:InsertItem(comboitem, nindex)
end

function CB__RemoveItem(self, nindex)
    local listbox = self:GetControlObject("listbox")
    listbox:DeleteItem(nindex)
end

function CB__SetEnable(self, enable)
    local attr = self:GetAttribute()
    attr.Enable = enable
    local edit = self:GetControlObject("combo.edit")
    if attr.EnableEdit then
        edit:SetReadOnly(not attr.Enable)
        edit:SetNoCaret(not attr.Enable)
    end
    local btn = self:GetControlObject("combo.btn")
    btn:SetEnable(enable)
    local bkg = self:GetControlObject("combo.bkg")
    if attr.Enable then
        self:SetState(0)
    else
        self:SetState(2)
    end
end

function CB__GetEnable(self)
    local attr = self:GetAttribute()
    return attr.Enable
end

function CB__OnInitControl(self)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    local bkg = self:GetControlObject("combo.bkg")
    bkg:SetTextureID(attr.NormalBkgID)
    local icon = self:GetControlObject("combo.icon")
    local text = self:GetControlObject("combo.text")
    local edit = self:GetControlObject("combo.edit")
    local btn = self:GetControlObject("combo.btn")
    edit:SetReadOnly(not attr.EnableEdit)
    edit:SetNoCaret(not attr.EnableEdit)
	if not attr.EnableEdit then
		-- edit:SetCursorID("IDC_HAND")
	end
    edit:SetMultiline(attr.Multiline)
    local nowLeft = attr.LeftMargin
    if attr.IconVisible then
        icon:SetResID(attr.IconResID)
        icon:SetVisible(true)
        icon:SetObjPos(nowLeft, attr.TopMargin, nowLeft + attr.IconWidth, height - 2)
        nowLeft = nowLeft + attr.IconWidth
    end
    if attr.DesVisible then
        text:SetText(attr.DesText)
        text:SetObjPos(nowLeft + 2, 2, nowLeft + attr.DesWidth, height - 2)
        nowLeft = nowLeft + attr.DesWidth + 2
    end
	local right = "father.width-14-"..attr.EditRightMargin
    edit:SetObjPos( ""..nowLeft.."-3", "5", right, "father.height" )
--    btn:SetObjPos(width - 2 - 22, 0, width - 2, height)
    local lblayout = self:GetControlObject("listbox.layout")
    lblayout:SetVisible(false, true)
    self:SetEnable(attr.Enable)
end


function CB__Edit__OnChange(self)
    local control = self:GetOwnerControl()
    local text = self:GetText()
    local attr = control:GetAttribute()
    if attr.OnlyNumber then
        if not tonumber(text) and text ~= "" then
            self:Undo()
            return
        end
    end
    if attr.MaxLength then
        if text:len() > attr.MaxLength then
            self:Undo()
            return
        end
    end
    if not attr.editbyuser then
        if not attr.editbysystem then
            attr.editbyuser = true
        end
    end
    control:FireExtEvent("OnEditChange", text)
	return true
end

function CB__Edit__OnFocusChange(self, focus, dest)
    local control = self:GetOwnerControl()
    if not focus then
		if dest then 
			local dest_control = dest:GetOwnerControl()
			if not control:IsChild(dest) and not control:IsChild(dest_control) then
				CB__OnFocusChange(control, focus, dest)
			end
		else
			CB__OnFocusChange(control, focus, dest)
		end
    end	
	
    control:FireExtEvent("OnEditFocusChange", focus)
end

function RouteToFather__OnKeyDown( self, char )
	if char == 13 then
		self:RouteToFather()
	end
end

function CB__Edit__OnChar(self, char)
    local owner = self:GetOwnerControl()
    local ownerattr = owner:GetAttribute()
    ownerattr.editbyuser = true
    local listbox = owner:GetControlObject("listbox")
    if char == 9 then
        self:RouteToFather()
    elseif char == 40 then
        if not listbox then
            owner:ExpandList()
        end
        listbox = owner:GetControlObject("listbox")
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex == nil then
                listboxattr.AvalibleItemIndex = 0
            end
            local count = listbox:GetItemCount()
            if listboxattr.AvalibleItemIndex >= count then
                return
            end
            local olditem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listboxattr.AvalibleItemIndex = listboxattr.AvalibleItemIndex + 1
            local newitem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listbox:CancelAllSelect()
            if newitem then
                newitem:SetState(3)
            end
            listbox:AdjustAvalibleItemPos(1)
        end
    elseif char == 38 then
        if not listbox then
            owner:ExpandList()
        end
        listbox = owner:GetControlObject("listbox")
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex == nil then
                listboxattr.AvalibleItemIndex = 0
            end
            local count = listbox:GetItemCount()
            if listboxattr.AvalibleItemIndex <= 1 then
                return
            end
            local olditem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            listboxattr.AvalibleItemIndex = listboxattr.AvalibleItemIndex - 1
            local newitem = listbox:GetItem(listboxattr.AvalibleItemIndex)
            if olditem then
                olditem:SetState(0)
            end
            if newitem then
                newitem:SetState(3)
            end
            listbox:AdjustAvalibleItemPos(-1)
        end
    elseif char == 13 then
        if listbox then
            local listboxattr = listbox:GetAttribute()
            if listboxattr.AvalibleItemIndex then
                if listboxattr.AvalibleItemIndex ~= 0 then
                    listbox:FireExtEvent("OnSelect", listboxattr.AvalibleItemIndex)
                end
            end
        else
            owner:ExpandList()
        end
    end
end

function CB__BtnOnFocusChange(self, focus, dest)	
	local control = self:GetOwnerControl()
	if dest then
		local dest_control = dest:GetOwnerControl()
		
		local test1 = control:IsChild(dest)
		local test2 = control:IsChild(dest_control)
		if not test1 and not test2 then
			CB__OnFocusChange(self:GetOwnerControl(), focus, dest)
		end
	else
		CB__OnFocusChange(self:GetOwnerControl(), focus, dest)
	end
end

function CB__OnFocusChange( combo, focus, dest )
	local attr = combo:GetAttribute()
	local control = combo
			
	if focus then		
        return
    end
			
    if attr.OnListItem then				
        return
    end
    
    if not attr.Enable then				
        return
    end
    
    if not attr.ShowList then				
        return
    end
    if not attr.OnTab then
        local left, top, right, bottom = control:GetAbsPos()
        local x, y = tipUtil:GetCursorPos()
        
        local hostwndManager = XLGetObject("Xunlei.UIEngine.HostWndManager")
        local newtaskdlg = hostwndManager:GetHostWnd(attr.HostWndID)
		if newtaskdlg then
			local nleft, ntop, nright, nbottom = newtaskdlg:GetWindowRect()
			local absleft, abstop, absright, absbottom = left + nleft, top + ntop, right + nleft, bottom + ntop + attr.cur_list_height 
			if (x > absleft) and (x < absright) and (y > abstop) and (y < absbottom-4) then			
				return
			end
		end
    end
    attr.OnTab = false
	attr.ShowList = false
	local btnlayout = control:GetControlObject("combo.btn")
	btnlayout:SetZorder( 0 )
    local lblayout = control:GetControlObject("listbox.layout")
    local listbox = control:GetControlObject("listbox")
    lblayout:RemoveChild(listbox)
    lblayout.SetVisible(false, true)
    local left, top, right, bottom = control:GetObjPos()
    control:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)	
end

function CB__SetEditSel(self, spos, epos)	
    local attr = self:GetAttribute()	
	
	local edit = self:GetControlObject("combo.edit")
	if edit then
		edit:SetSel(spos, epos)
	end	
end

function CB__GetSelectItemName(self)
    local attr = self:GetAttribute()
    return attr.data[attr.select].Text
end

function CB__SelectItemByText(self, text)
    if text == nil then
        return false
    end
    local attr = self:GetAttribute()
    local i = 0
    for i = 1, #attr.data do
        if attr.data[i].Text == text then
            self:SelectItem(nil, i)
            return true
        end
    end
    return false
end

function CLB_SelectItem( self, name, id )
    local class = self:GetClass()
    local parent, listbox
	parent = self:GetOwnerControl()
	listbox = self
    local attr = parent:GetAttribute()
    attr.select = id
    local edit = parent:GetControlObject("combo.edit")
    local item = attr.data[id]
    if not item.Custom then
        edit:SetText(attr.data[id].Text)
        parent:FireExtEvent("OnSelectItemChanged", id)
		parent:FireExtEvent("OnEnterContent",attr.data[id].Text)
		edit:SetFocus(true)
    end
    local left, top, right, bottom = parent:GetObjPos()
    local lblayout = parent:GetControlObject("listbox.layout")
    attr.ShowList = false
	local btnlayout = parent:GetControlObject("combo.btn")
	btnlayout:SetZorder( 0 )
    lblayout:RemoveChild(listbox)
    if listbox then
        parent:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end
end

function CB__SelectItem(self, name, id)
    local class = self:GetClass()
    local parent, listbox
	parent = self
	listbox = parent:GetControlObject("listbox")
    local attr = parent:GetAttribute()
    attr.select = id
    local edit = parent:GetControlObject("combo.edit")
    local item = attr.data[id]
    if not item.Custom then
        edit:SetText(attr.data[id].Text)
        parent:FireExtEvent("OnSelectItemChanged", id)
		parent:FireExtEvent("OnEnterContent",attr.data[id].Text)
		edit:SetFocus(true)
    end
    local left, top, right, bottom = parent:GetObjPos()
    local lblayout = parent:GetControlObject("listbox.layout")
    attr.ShowList = false
	local btnlayout = parent:GetControlObject("combo.btn")
	btnlayout:SetZorder( 0 )
    lblayout:RemoveChild(listbox)
    if listbox then
        parent:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end
end

function HighlightFocus(self, boolean)
	local comboedit = self:GetControlObject("combo.edit")
	local content = comboedit:GetText()
	local attr = self:GetAttribute()
	
	if boolean then
		local index = 1
		for i = 1, #attr.data do
			if content == attr.data[i].Text or (content .. '\\') == attr.data[i].Text then
				index = i
				break
			end
		end
	
		local item = listbox:GetItem(index)
		local listboxattr = listbox:GetAttribute()
		if item then
			item:SetState(3)
			listboxattr.AvalibleItemIndex = index
		end
	end
end

local bRet, nWidth, nHeight = false
function GetDeskWndWH()
	if bRet then
		return bRet, nWidth, nHeight
	end
	
	local dtHandle = tipUtil:GetDesktopWndHandle() or ""
	local tag, sleft, stop, sright, sbottom = tipUtil:GetWndRect(dtHandle)
	bRet, nWidth, nHeight = false, nil, nil
	if tag then
		bRet = true
		nWidth = sright - sleft
		nHeight = sbottom - stop
	end
	return bRet, nWidth, nHeight
end

function IsOutOfDeskWnd(b)
	local bRet , nWidth, nHeight = GetDeskWndWH()
	if bRet and b > nHeight then
		return true
	end
	return false
end

function IsNearDeskBottom(obj)
	local wnd = obj:GetOwner():GetBindHostWnd()
	if wnd then
		local l, t, r, b = wnd:GetWindowRect()
		return IsOutOfDeskWnd(b)
	end
	return false
end

function ExpandList( self )
    local control = self
    local attr = control:GetAttribute()
    if not attr.Enable then
        return
    end
    local left, top, right, bottom = control:GetObjPos()
    local width, height = right - left, bottom - top
    local lblayout = control:GetControlObject("listbox.layout")
	local btnlayout = control:GetControlObject("combo.btn")
    local bNearBottom = IsNearDeskBottom(self)
    if not attr.ShowList then
        control:FireExtEvent("BeforeExpand")
        if attr.data == nil or #attr.data == 0 then			
            return
        end
        local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
        listbox = objFactory:CreateUIObject("listbox","TipAddin.ComboListBox")
    
        local listattr = listbox:GetAttribute()
        listattr.parent = control
        if attr.EnableHScroll ~= nil then
            listattr.EnableHScroll = attr.EnableHScroll
        end
        if attr.EnableVScroll ~= nil then
            listattr.EnableVScroll = attr.EnableVScroll
        end
        if attr.NoScroll then
            listattr.NoScroll = attr.NoScroll
        end
             
        listbox:AttachListener("OnSelect", true, CLB_SelectItem)
        local lbleft, lbtop, lbright, lbbottom = lblayout:GetObjPos()

       -- lblayout:SetObjPos(-2, height+5, width, attr.ListHeight)

        lblayout:AddChild(listbox)
		attr.ShowList = true
        listbox:SetZorder(1000)
		btnlayout:SetZorder( 2000 )
        for i=1, #attr.data do
            control:AddItem(attr.data[i].IconResID, attr.data[i].IconWidth, attr.data[i].LeftMargin, attr.data[i].TopMargin, attr.data[i].Text, attr.data[i].Custom, attr.data[i].Func)
        end
		local list_width, list_height = listbox:GetSize()
		local offset = 0
		if list_width > width then
			if list_height < attr.ListHeight - 12 then
				offset = 12
			end
		elseif list_width < width and list_width > width - 12 then
			if list_height > attr.ListHeight - 12 then
				offset = 12
			else
				offset = 0
			end
		elseif list_width < width - 12 then
			offset = 0
		end
		if list_height < attr.ListHeight - offset then
		--	listbox:SetObjPos(0, -4, width-2, list_height+4+offset)
			attr.cur_list_height = list_height
			control:FireExtEvent("OnListExpandChange", true, right - left, bottom - top + list_height - 1 + offset )
		else
		--	listbox:SetObjPos(0, -4, width-2, attr.ListHeight+4)
			attr.cur_list_height = attr.ListHeight
			control:FireExtEvent("OnListExpandChange", true, right - left, bottom - top + attr.ListHeight - 1 )
		end
		
		if attr.HighlightSelected then
			HighlightFocus(self, true)
		end
		
        local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
        local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
        posAni:SetTotalTime(200)
        posAni:BindLayoutObj(listbox)
		if bNearBottom then
			if list_height < attr.ListHeight then
				listattr.EnableVScroll = false
				--posAni:SetKeyFrameRect(2, -4, width-2, 0, 2, -4, width-2, list_height+4+offset)
				posAni:SetKeyFrameRect(2, -4-height, width-2, -height, 0, -4-height-list_height-4-offset+4, width, -4-height+4)
			else
				posAni:SetKeyFrameRect(2, -4-height, width-2, -height, 0, -4-height-attr.ListHeight-4+4, width, -4-height+4)
			end
		else
			if list_height < attr.ListHeight then
				listattr.EnableVScroll = false
				--posAni:SetKeyFrameRect(2, -4, width-2, 0, 2, -4, width-2, list_height+4+offset)
				posAni:SetKeyFrameRect(2, -4, width-2, 0, 0, 1, width, list_height+4+offset)
			else
				posAni:SetKeyFrameRect(2, -4, width-2, 0, 0, 1, width, attr.ListHeight+4)
			end
		end
        local owner = control:GetOwner()
        owner:AddAnimation(posAni)
        posAni:Resume()
    else
        local listbox = control:GetControlObject("listbox")
        if not listbox then
            return
        end
        function onAniFinish(self, old, new)
            if new == 4 then
                lblayout:RemoveChild(listbox)
				attr.ShowList = false
                lblayout:SetVisible(false, true)
            end
        end		
		btnlayout:SetZorder( 0 )
        local lbleft, lbtop, lbright, lbbottom = listbox:GetObjPos()
        local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
        local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
        posAni:SetTotalTime(200)
        posAni:BindLayoutObj(listbox)
		if bNearBottom then
			posAni:SetKeyFrameRect(lbleft, lbtop, lbright, lbbottom, 2, -24, width-2, -20)
		else
			posAni:SetKeyFrameRect(lbleft, lbtop, lbright, lbbottom, 2, -4, width-2, 0)
		end
        posAni:AttachListener(true,onAniFinish)
        local owner = control:GetOwner()
        owner:AddAnimation(posAni)
        posAni:Resume()
        control:FireExtEvent("OnListExpandChange", false, right - left, bottom - top)
    end
	
    control:FireExtEvent("OnEditFocusChange", true)
end

function CB__Btn__OnClick(self)
	ExpandList( self:GetOwnerControl() )
end

function CB__Btn__Down(self)
	local control = self:GetOwnerControl()
	local attr = control:GetAttribute()
    if attr.CanExpand then
        ExpandList( self:GetOwnerControl() )
    end
end

function CLB__Bkg__OnFocusChange(self, focus, dest)
    if focus then
		local combobox = self:GetOwnerControl()
        local edit = combobox:GetControlObject("combo.edit")
        edit:SetFocus(true) 
    end	
end

function CLB__ScrollBar__OnFocusChange(self, name, focus)
    if focus then
        return
    end
    local list = self:GetOwnerControl()
    local combobox = list:GetOwnerControl()
    combobox:CBOnFocusChange(focus)
end

function CLB__MouseWheel(self, distance)
    local vsb = self:GetControlObject("listbox.vscroll")
    if vsb:IsShow() then
        local ThumbPos = vsb:GetThumbPos()
        vsb:SetThumbPos(ThumbPos - distance)
    end
end

function CLB__UpdateItemPos(self)
    local attr = self:GetAttribute()    
    local allheight = 4
	
    for i=1,#attr.s_itemtable do
        local itemwidth, itemheight = attr.s_itemtable[i]:GetSize()
		
		attr.s_itemtable[i]:SetObjPos( 0, allheight, attr.s_maxwidth, allheight + itemheight-2 )
		attr.s_itemtable[i]:SetVisible(true)
			
        allheight = allheight + itemheight
    end
    local bkg=self:GetControlObject("item.layout")
	local bkg_left, bkg_top, bkg_right, bkg_bottom = bkg:GetObjPos()
--	bkg:SetObjPos( bkg_left, bkg_top, bkg_left + attr.s_maxwidth, bkg_bottom + attr.s_maxheight )
	
    self:AdjustItemPos()
end

function CLB__InsertItem(self, obj, index)
    local left, top, right, bottom = self:GetObjPos()
	local width, height = right - left, bottom - top
	
	local objLayout = self:GetFather()
	if objLayout ~= nil then
		local nFatherL, nFatherT, nFatherR, nFatherB = objLayout:GetObjPos()
		width, height = nFatherR - nFatherL, nFatherB - nFatherT
    end

    obj:SetParentObj(self)
    local attr = self:GetAttribute()
    local itemwidth, itemheight = obj:GetSize()

    if attr.s_itemtable == nil then
        attr.s_itemtable = {}
        attr.s_itempos = {}
    end
    
    if #attr.s_itemtable == 0 then
        attr.s_id = 0
        attr.s_maxwidth = width
        attr.s_maxheight = 0
        attr.s_top = 0
        attr.s_left = 0
		attr.item_maxwidth = 0
    end
    
    obj:SetID(attr.s_id+1)
    attr.s_id = attr.s_id + 1
    
    if index==-1 then
        table.insert(attr.s_itemtable, obj)
        if #attr.s_itempos==0 then
            table.insert(attr.s_itempos, 0)
        else
            local itemcount = #attr.s_itempos
            local item = attr.s_itemtable[itemcount]
            local tmpwidth, tmpheight = item:GetSize()
            table.insert(attr.s_itempos, tmpheight+attr.s_itempos[itemcount])
        end
    else
        table.insert(attr.s_itemtable, index+1, obj)
        if index+1==1 then
            table.insert(attr.s_itempos, index+1, 0)						
        else
            table.insert(attr.s_itempos, index+1, attr.s_itempos[index]+itemheight)
        end

        for i=index+2, #attr.s_itempos do
            attr.s_itempos[i] = attr.s_itempos[i] + itemheight
        end
    end
    
    attr.s_maxheight = attr.s_maxheight + itemheight
	
    if itemwidth > attr.s_maxwidth then
        attr.s_maxwidth = itemwidth
    end
    if itemwidth > attr.item_maxwidth then
		attr.item_maxwidth = itemwidth
	end
  
    obj:SetVisible(false)
    local bkg=self:GetControlObject("item.layout")
    bkg:AddChild(obj)
    
    if attr.NoScroll then
        local ctrl = self:GetOwnerControl()
        local cattr = ctrl:GetAttribute()
        cattr.ListHeight = attr.s_maxheight
     --   self:SetObjPos(left, top, right, attr.s_maxheight)
    end
    
    obj:AttachListener("OnLButtonUp", true, CLB__OnClickItem)
   
    if attr.s_itempos~=nil then
        self:UpdateItemPos()
    end	
end

function CLB_GetSize( self )
	local attr = self:GetAttribute()
	return attr.item_maxwidth, attr.s_maxheight
end

function CLB__AddItem(self, obj)
    self:InsertItem(obj, -1)
end

function CLB__DeleteItem(self, index)
    local attr = self:GetAttribute()
    local obj = attr.s_itemtable[index+1]
    
    if index+1==#attr.s_itemtable then
        table.remove(attr.s_itemtable, #attr.s_itemtable)
        table.remove(attr.s_itempos, #attr.s_itempos)
        
        local objwidth, objheight = obj:GetSize()
        attr.s_maxheight = attr.s_maxheight - objheight
    else
        local height = attr.s_itempos[index+2] - attr.s_itempos[index+1]
        table.remove(attr.s_itemtable, index+1)
        table.remove(attr.s_itempos, index+1)
        
        for i=index+1,#attr.s_itempos do
            attr.s_itempos[i] = attr.s_itempos[i] - height
        end
        
        attr.s_maxheight = attr.s_maxheight - height
    end
    
    attr.s_maxwidth = 0
    for i=1,#attr.s_itemtable do
        local objwidth, objheight = obj:GetSize()
        if objwidth > attr.s_maxwidth then
            attr.s_maxwidth = objwidth
        end
    end
        
    local bkg=self:GetControlObject("item.layout")
    bkg:RemoveChild(obj)
            
    if attr.NoScroll then
        local ctrl = self:GetOwnerControl()
        local cattr = ctrl:GetAttribute()
        cattr.ListHeight = attr.s_maxheight
     --   self:SetObjPos(left, top, right, attr.s_maxheight)
    end
    
    self:UpdateItemPos()
end

function CLB__DeleteAllItem(self)
    for i=1, self:GetItemCount() do
        self:DeleteItem(0)
    end
end

function CLB__GetItemCount(self)
    local attr = self:GetAttribute()
    return #attr.s_itemtable
end

function CLB__GetItem(self, index)
    local attr = self:GetAttribute()
    return attr.s_itemtable[index]
end

function CLB__GetItemIndexByObj(self, obj)
    local attr = self:GetAttribute()
    local id = obj:GetID()
    
    for i=1,#attr.s_itemtable do
        if attr.s_itemtable[i]:GetID()==id then
            return i-1
        end
    end
    
    return -1
end

function CLB__AdjustItemPos(self)
    local left, top, right, bottom = self:GetObjPos()
    local attr=self:GetAttribute()
    local width = right - left
    local height = bottom - top

    local hscroll = self:GetControlObject("listbox.hscroll")
    local vscroll = self:GetControlObject("listbox.vscroll")

    local listleft = left
    local listtop = top
    local listright = right
    local listbottom = bottom
    local bkg=self:GetControlObject("item.layout")
	local item_list = self:GetControlObject("item.list")
	local list_width = width
	local list_height = height
	local hsl_offset = 0
	local bkg_left, bkg_top, bkg_right, bkg_bottom = self:GetObjPos()
    if attr.EnableVScroll and (attr.s_maxheight > height) and (height ~= 0) then
        listright = listright
        vscroll:Show(true)
        vscroll:SetObjPos(width-12, 3, width, listbottom - listtop - 3)	
		list_width = width - 12
		hsl_offset = 12
    else
        vscroll:Show(false)
    end

    if attr.EnableHScroll and (attr.s_maxwidth > width) and (height ~= 0) then
        listbottom = listbottom
        hscroll:Show(true)
        hscroll:SetObjPos(0, height - 12, listright - listleft - hsl_offset, height)
		list_height = height - 12
    else
        hscroll:Show(false)
    end
	
	if attr.EnableVScroll and attr.s_maxheight > list_height and list_height ~= 0 then
		vscroll:SetScrollRange( 0, attr.s_maxheight - list_height )
		vscroll:SetPageSize(list_height, true)		
	end

	if attr.EnableHScroll and attr.item_maxwidth > list_width and list_width ~= 0 then
		hscroll:SetScrollRange( 0, attr.item_maxwidth - list_width )
		hscroll:SetPageSize(list_width, true)
	end
	--item_list:SetObjPos( 0, 0, width, list_height )
	
    local bkg=self:GetControlObject("listbox.bkg")
 --   bkg:SetObjPos(0, 0, width, height)
end

function CLB__GetItemIndexByPoint(self, point) 
    local attr = self:GetAttribute()  
    if #attr.s_itempos==0 then
        return 0
    elseif attr.s_itempos[#attr.s_itempos]>attr.s_maxheight then
        return 0
    elseif attr.s_itempos[#attr.s_itempos]<=point and point<attr.s_maxheight then
        return #attr.s_itempos
    end
    
    for i=1,#attr.s_itempos-1 do
        if attr.s_itempos[i]<=point and point<attr.s_itempos[i+1] then
            return i
        end
    end
    
    return 0
end

function CLB__OnClickItem(self, x, y)
    local listbox = self:GetOwnerControl()
    local attr = listbox:GetAttribute()
    local left,top,right,bottom = self:GetObjPos()
    local index=listbox:GetItemIndexByPoint(y + attr.s_top + top)

    if index==0 then
        return 
    end
    local item = attr.s_itemtable[index]
    local id = item:GetID()
    local iattr = item:GetAttribute()
    local parent = attr.parent
    if iattr.Custom then
        iattr.Func()
    end
    listbox:FireExtEvent("OnSelect", id)
end

function CLB_OnInitControl(self)
    local attr=self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()

    attr.s_id = 0
    attr.s_maxwidth = right - left
    attr.s_maxheight = 0
    attr.s_top = 0
    attr.s_left = 0
    attr.item_maxwidth = 0
	
    if attr.s_itemtable==nil then
        attr.s_itemtable = {}
        attr.s_itempos = {}
    end
    
    self:AdjustItemPos()
    if #attr.s_itemtable~=0 then
        self:UpdateItemPos(true)
    end
end

function CLB__OnPosChange(self)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
	local attr = self:GetAttribute()
	if attr.s_maxwidth < width then
		attr.s_maxwidth = width
	end
    self:UpdateItemPos()
end

function CLB__AdjustAvalibleItemPos(self, offset)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    local attr = self:GetAttribute()
    local item = self:GetItem(attr.AvalibleItemIndex)
    if not item:GetVisible() then
        if offset == 1 then
            attr.s_top = attr.s_itempos[self:GetItemIndexByPoint(attr.s_itempos[attr.AvalibleItemIndex] - height) + 1]
        elseif offset == -1 then
            attr.s_top = attr.s_itempos[self:GetItemIndexByPoint(attr.s_itempos[attr.AvalibleItemIndex])]
        end
        local vsb = self:GetControlObject("listbox.vscroll")
        vsb:SetScrollPos(attr.s_top, true)
        self:UpdateItemPos()
        item:SetState(3)
    end
end

function CLB__OnVScroll(self, fun, type_, pos)
    local listbox = self:GetOwnerControl()
    local lattr = listbox:GetAttribute()
    local bkg=listbox:GetControlObject("item.layout")
    local left,top,right,bottom=bkg:GetObjPos()

	local pos = self:GetScrollPos()
    
    if type_==1 then
        self:SetScrollPos( pos - 15, true )
    elseif type_==2 then
		self:SetScrollPos( pos + 15, true )
    end
    
	local newpos = self:GetScrollPos()
--	bkg:SetObjPos( left, -newpos, right, bottom - top - newpos )
	return true
end

function CLB__OnHScroll(self, fun, type_, pos)
    local listbox = self:GetOwnerControl()
    local lattr = listbox:GetAttribute()
    local bkg=listbox:GetControlObject("item.layout")
    local left,top,right,bottom=bkg:GetObjPos()

	local pos = self:GetScrollPos()
    
    if type_==1 then
        self:SetScrollPos( pos - 15, true )
    elseif type_==2 then
		self:SetScrollPos( pos + 15, true )
    end
    
	local newpos = self:GetScrollPos()
--	bkg:SetObjPos( -newpos, top, right - left - newpos, bottom )
	return true
end

function CLB__CancelAllSelect(self)
    local attr = self:GetAttribute()
    for i=1,#attr.s_itemtable do
        attr.s_itemtable[i]:SetState(0)
    end
end

function CI__SetState(self, newState)
    local attr = self:GetAttribute()
    if newState ~= attr.NowState then
        local ownerTree = self:GetOwner()
        local bkg = self:GetControlObject("comboitem.bkg")
        local text = self:GetControlObject("comboitem.text")
        if newState == 0 then
            bkg:SetTextureID(attr.NormalBkgID)
            text:SetTextColorResID("system.black")
        elseif newState == 3 then
            bkg:SetTextureID(attr.HoverBkgID)
            text:SetTextColorResID("system.white")
        end
        attr.NowState = newState
    end
end

function CI__GetSize(self)
    local attr = self:GetAttribute()
    if attr.RealWidth == nil then
        local text = self:GetControlObject("comboitem.text")
        text:SetText(attr.ItemText)
        local cx, cy = text:GetTextExtent()
        attr.RealWidth = attr.LeftMargin + attr.IconWidth + cx
        attr.RealHeight = 22
    end
    return attr.RealWidth, attr.RealHeight
end

function CI__SetParentObj(self, obj)
    local attr = self:GetAttribute()
    attr.parent = obj
end

function CI__SetVisible(self, visible)
    local attr = self:GetAttribute()
    attr.visible = visible
    local bkg = self:GetControlObject("comboitem.bkg")
    bkg:SetVisible(visible)
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")
    icon:SetVisible(visible)
    text:SetVisible(visible)
end

function CI__GetVisible(self)
    local attr = self:GetAttribute()
    return attr.visible
end

function CI__GetID(self)
    local attr = self:GetAttribute()
    return attr.ItemID
end

function CI__SetID(self, id)
    local attr = self:GetAttribute()
    attr.ItemID = id
end

function CI__GetText(self)
    local attr = self:GetAttribute()
    return attr.ItemText
end

function CI__OnBind(self)
    local attr = self:GetAttribute()
    attr.NowState = 0
    local width, height = self:GetSize()
    local bkg = self:GetControlObject("comboitem.bkg")
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")	
    text:SetTextColorResID("system.black")
    bkg:SetTextureID(attr.NormalBkgID)
   -- bkg:SetObjPos(0, 0, width, height)	

    local nowleft = attr.LeftMargin    
    if attr.IconResID then
        icon:SetResID(attr.IconResID)
    --    icon:SetObjPos(nowleft, attr.TopMargin, nowleft + attr.IconWidth, height)
        nowleft = nowleft + attr.IconWidth
        icon:SetVisible(true)    
    end
	
	    
    --text:SetObjPos(nowleft, 0, width, height)
end

function CI__OnPosChange(self)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width = right - left
    local height = bottom - top
    local bkg = self:GetControlObject("comboitem.bkg")
    local icon = self:GetControlObject("comboitem.icon")
    local text = self:GetControlObject("comboitem.text")
    bkg:SetTextureID(attr.NormalBkgID)
    bkg:SetObjPos(1, 0, width-1, height)
    text:SetTextColorResID("system.black")
    local nowleft = attr.LeftMargin
    icon:SetResID(attr.IconResID)
 --   icon:SetObjPos(nowleft, attr.TopMargin, nowleft + attr.IconWidth, height)
    nowleft = nowleft + attr.IconWidth
    icon:SetVisible(true)
    
    text:SetObjPos(5, 0, width, height)
end

function CI__OnFocusChange(self, focus)
    if focus then
        self:SetState(3)
    else
        self:SetState(0)
    end
end

function CI__OnMouseMove(self)
    local owner = self:GetOwnerControl()
    local ownerattr = owner:GetAttribute()
    ownerattr.AvalibleItemIndex = self:GetID()
    local owner2 = owner:GetOwnerControl()
    local owner2attr = owner2:GetAttribute()
    owner2attr.OnListItem = true
    owner:CancelAllSelect()
    self:SetState(3)
end

function CI__OnMouseLeave(self)
    local owner = self:GetOwnerControl()
    local owner2 = owner:GetOwnerControl()
    local owner2attr = owner2:GetAttribute()
    owner2attr.OnListItem = false
    --self:SetState(0)
end

