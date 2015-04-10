
function GetTextExtent(self)
    local text = self:GetControlObject("button.text")
    return text:GetTextExtent()
end

function GetText(self)
    local text = self:GetControlObject("button.text")
    return text:GetText()
end

local function UpdateBkg(self, attr, noAni )	
	local bkg = self:GetControlObject("button.bkg")
	local oldbkg = self:GetControlObject("button.oldbkg")
	local ownerTree = self:GetOwner()
	local obj = self:GetControlObject("button.icon")

	local status = attr.Status
	local texture_id = ""
	if status == 1 then
	    if attr.IsDefaultButton then
		    texture_id = attr.DefaultBkgNormal
		else
		    texture_id = attr.BkgTextureID_Normal
		end
		if attr.IconBitmapID ~= nil then
			obj:SetResID( attr.IconBitmapID )
		end
	elseif status == 2 then
		texture_id = attr.BkgTextureID_Hover
		if attr.IconBitmapID_Hover ~= nil then
			obj:SetResID( attr.IconBitmapID_Hover )
		end
	elseif status == 3 then
		texture_id = attr.BkgTextureID_Down
		if attr.IconBitmapID_Down ~= nil then
			obj:SetResID( attr.IconBitmapID_Down )
		end
	elseif status == 4 then
		texture_id = attr.BkgTextureID_Disable
		if attr.IconBitmapID_Disable ~= nil then
			obj:SetResID( attr.IconBitmapID_Disable )
		end
	end
	local old_texture_id = bkg:GetTextureID()
	bkg:SetTextureID(texture_id)
	if noAni == nil or not noAni then
		oldbkg:SetTextureID(old_texture_id)
		oldbkg:SetAlpha(255)
		local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
		local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
		aniAlpha:BindRenderObj(oldbkg)
		aniAlpha:SetTotalTime(200)
		aniAlpha:SetKeyFrameAlpha(255,0)
		ownerTree:AddAnimation(aniAlpha)
		aniAlpha:Resume()
	end

end


local function UpdateText(self, attr)
	local textObj = self:GetControlObject("button.text")
	if attr.SpliceTextInfoID then
		--自动拼接ID
		local suf = {".normal", ".hover", ".down", ".disable"}


		local status = attr.Status
		local font_id = attr.TextFontID
		if font_id ~= "" then
			font_id = font_id .. suf[status]
			textObj:SetTextFontResID(font_id)
		end
		
		if attr.Status == 4 then
			textObj:SetTextColorResID(attr.DisableTextColor)
		else
			local color_id = attr.TextColorID
			if color_id ~= "" then
				color_id = color_id
				textObj:SetTextColorResID(color_id)
			end
		end
	else
		--不拼接ID
		textObj:SetTextFontResID(attr.TextFontID)
		if attr.Status == 4 then
			textObj:SetTextColorResID(attr.DisableTextColor)
		else
			textObj:SetTextColorResID(attr.TextColorID)
		end
	end
end

function SetTextFontID(self, id)
	local attr = self:GetAttribute()
	attr.TextFontID = id
	UpdateText(self, attr)
end


function SetTextColorID(self, id)
	local attr = self:GetAttribute()
	attr.TextColorID = id
	UpdateText(self, attr)
end

local function SetStatus(self, status)
	local attr = self:GetAttribute()
	if attr.Status == status then
		return
	end
	attr.Status = status
	UpdateBkg(self, attr)
	UpdateText(self, attr)
end

local function InitPosition(self)
	local attr = self:GetAttribute()
	local left, top, right, bottom = self:GetObjPos()
	local self_width = right - left
	local self_height = bottom - top

	local obj = self:GetControlObject("button.icon")
	left = attr.IconLeftPos
	right = left.."+"..attr.IconWidth
	top = attr.IconTopPos
	bottom = top.."+"..attr.IconHeight
	obj:SetObjPos(left, top, right, bottom)

	obj = self:GetControlObject("button.text")
	left = attr.TextLeftPos
	right = self_width
	top = attr.TextTopPos
	bottom = self_height
	obj:SetObjPos(left, top, right, bottom)
end

function SetEnable(self, enable)
	local attr = self:GetAttribute()
	if not attr then
		return
	end
	
	if enable then
		attr.Status = 1
	else
		attr.Status = 4
	end
	attr.Enable = enable
	UpdateBkg(self, attr, true)
	UpdateText(self, attr )
end


function GetEnable(self)
	local attr = self:GetAttribute()
	if attr.Status ~= 4 then
		return true
	else
		return false
	end
end

function SetObjPos(obj, left, top, right, bottom)
	local pre_left, pre_top, pre_right, pre_bottom = obj:GetObjPos()
	if left == nil then
		left = pre_left
	end
	if top == nil then
		top = pre_top
	end
	if right == nil then
		right = pre_right
	end
	if bottom == nil then
		bottom = pre_bottom
	end
	obj:SetObjPos(left, top, right, bottom)
end

function SetIconPos(self, left, top, right, bottom)
	local obj = self:GetControlObject("button.icon")
	SetObjPos(obj, left, top, right, bottom)
end

function SetTextPos(self, left, top, right, bottom)
	local obj = self:GetControlObject("button.text")
	SetObjPos(obj, left, top, right, bottom)
end

function SetValign(self, align)
	local obj = self:GetControlObject("button.text")
	obj:SetVAlign(align)
end

function SetText(self, text)
	local attr = self:GetAttribute()
	if attr.Text == text then
		return 0
	end

	attr.Text = text
	local obj = self:GetControlObject("button.text")
	local oldWidth, oldHeight = obj:GetTextExtent()
	obj:SetText(text)
	local newWidth, newHeight = obj:GetTextExtent()
	return newWidth - oldWidth
end

function SetBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Normal = texture_id .. ".normal"
	attr.BkgTextureID_Hover = texture_id .. ".hover"
	attr.BkgTextureID_Down = texture_id .. ".down"
	attr.BkgTextureID_Disable = texture_id .. ".disable"

	UpdateBkg(self, attr, true)
end

function SetNormalBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Normal = texture_id

	UpdateBkg(self, attr, true)
end

function SetHoverBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Hover = texture_id

	UpdateBkg(self, attr, true)
end

function SetDownBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Down = texture_id

	UpdateBkg(self, attr, true)
end

function SetDisableBkgTexture(self, texture_id)
	local attr = self:GetAttribute()
	attr.BkgTextureID_Disable = texture_id

	UpdateBkg(self, attr, true)
end


function SetIconImage(self, image_id, hover, down, disable)
	local attr = self:GetAttribute()
	attr.IconBitmapID = image_id
	attr.IconBitmapID_Hover = hover
	if hover == nil then
		attr.IconBitmapID_Hover = image_id
	end
	attr.IconBitmapID_Down = down
	if down == nil then
		attr.IconBitmapID_Down = image_id
	end
	attr.IconBitmapID_Disable = disable
	if disable == nil then
		attr.IconBitmapID_Disable = image_id
	end
	local obj = self:GetControlObject("button.icon")
	obj:SetResID(image_id)
end


function OnBind(self)
	local attr = self:GetAttribute()
	if attr.IconBitmapID_Hover == nil or attr.IconBitmapID_Hover == "" then
		attr.IconBitmapID_Hover = attr.IconBitmapID
	end
	if attr.IconBitmapID_Down == nil or attr.IconBitmapID_Down == "" then
		attr.IconBitmapID_Down = attr.IconBitmapID
	end
	if attr.IconBitmapID_Disable == nil or attr.IconBitmapID_Disable == "" then
		attr.IconBitmapID_Disable = attr.IconBitmapID
	end
	UpdateBkg(self, attr)
	UpdateText(self, attr)
	
	InitPosition(self)
	
	local icon = self:GetControlObject("button.icon")
	if attr.IconBitmapID ~= nil then
		icon:SetResID(attr.IconBitmapID)
	else
		icon:SetResID("")
	end
	
	local textObj = self:GetControlObject("button.text")
	textObj:SetText(attr.Text)
	textObj:SetVAlign(attr.VAlign)
	textObj:SetHAlign(attr.HAlign)
end


function OnPosChange(self, focus)
	InitPosition(self)
	return true
end



function OnLButtonDown(self)
	local attr = self:GetAttribute()
	local status = attr.Status
	if status ~= 4 and status ~= 3 then
		self:SetCaptureMouse(true)
		attr.Capture = true
		SetStatus(self, 3)
	end
	return 0, false
end

function OnLButtonUp(self, x, y, flags)
	local attr = self:GetAttribute()
	local status = attr.Status
	
	if attr.Capture then
		self:SetCaptureMouse(false)
		attr.Capture = false
		if status ~= 4 then
			local left, top, right, bottom = self:GetObjPos()
			if x >= 0 and x <= right - left and y >= 0 and y <= bottom - top then
				if attr.Status ~= 2 then
					SetStatus(self, 2)
				end
				self:FireExtEvent("OnButtonClick")
			else
				if attr.Status ~= 1 then
					SetStatus( self, 1 )
				end
			end
		end
	end
end



function OnMouseMove(self, x, y )
	local attr = self:GetAttribute()
	local status = attr.Status
	if status ~= 4 then
		local left, top, right, bottom = self:GetObjPos()
		if x >= 0 and x <= right - left and y >= 0 and y <= bottom - top then
			if attr.Capture then
				SetStatus(self, 3)
			else
				SetStatus(self, 2)
			end
		else
			SetStatus(self, 1)
		end
	end
	return 0
end

function OnMouseLeave( self )
	local attr = self:GetAttribute()
	if attr.Status ~= 4 then
		SetStatus( self, 1 )
	end
	return 0
end

function OnMouseHover( self, x, y )
	return 0
end

function OnInitControl( self )
	local attr = self:GetAttribute()
	if attr.EffectColorResID ~= nil then
		
		local textObj = self:GetControlObject("button.text")
		textObj:SetEffectType("bright")
		textObj:SetEffectColorResID( attr.EffectColorResID )
		if attr.BkgTextureID_Normal == "siamese.button.left.normal" or attr.BkgTextureID_Normal == "siamese.button.right.normal" then
		    local left, top, right, bottom = textObj:GetObjPos()
		    textobj:SetObjPos(left, top, right, bottom-4)
		end
	end
	
	self:SetEnable(attr.Enable)
	return true
end

function Show(self, visible)
    local attr = self:GetAttribute()
    attr.Visible = visible
    self:SetVisible(visible)
    self:SetChildrenVisible(visible)
end
