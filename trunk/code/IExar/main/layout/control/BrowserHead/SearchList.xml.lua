function SetText(self, txt)
	local text = self:GetControlObject("text")
	text:SetText(txt)
end

function OnMouseEnter(self)
	local bkg = self:GetControlObject("bkg")
	bkg:SetTextureID("YBYL.Menu.Select.Bkg")
	local txt = self:GetControlObject("text")
	txt:SetTextColorResID("system.white")
end

function OnMouseLeave(self)
	local bkg = self:GetControlObject("bkg")
	-- bkg:SetTextureID("pluginitem.all.down")
	bkg:SetTextureID("")
	local txt = self:GetControlObject("text")
	txt:SetTextColorResID("system.black")
end

function OnLButtonUp(self)
	self:FireExtEvent("OnClick")
end

function GetText(self)
	local text = self:GetControlObject("text")
	return text:GetText()
end

function AddString(self, text, icon, update)
	local attr = self:GetAttribute()
	table.insert(attr.data, {text = text, icon = icon})
	
	if update then
		self:UpdateUI()
	end
end

function RemoveString(self, text, update)
	local attr = self:GetAttribute()
	for i=1, #attr.data do
		if attr.data[i].text == text then
			table.remove(attr.data, i)
			break
		end
	end
	
	if update then
		self:UpdateUI()
	end
end

function UpdateUI(self)
	local attr = self:GetAttribute()
	local container = self:GetControlObject("container")
	local control = self
	
	local function OnItemClick(self)
		--XLPrint("OnItemClick(self) "..self:GetText())
		control:FireExtEvent("OnSelectChange", self:GetText())
	end
	
	local xarManager = XLGetObject("Xunlei.UIEngine.XARManager")
	local xarFactory = xarManager:GetXARFactory()
		
	-- 仅创建需要的....多余的不管..
	if #attr.data > container:GetChildCount() then
		
		
		for i=1, #attr.data - container:GetChildCount() do
			local obj = xarFactory:CreateUIObject("item."..container:GetChildCount(), "BoltFox.SearchListItem.Ctrl")
			container:AddChild(obj)
			if i == 1 then
				local txt = obj:GetControlObject("text")
				txt:SetTextFontResID("font.text12.bold")
			end
			obj:AttachListener("OnClick", false, OnItemClick)
		end
	end
	
	local height = 22
	local nStratY = 0
	for i=1, #attr.data do
		local obj = container:GetChildByIndex(i-1)
		obj:SetText(attr.data[i].text)
		if i < #attr.data - 2 then
			obj:SetIcon(attr.data[i].icon)
		else
			local txt = obj:GetControlObject("text")
			txt:SetTextColorResID("system.gray")
			obj:SetEnable(false)
		end
		if i == 5 then
			obj:SetObjPos(0, nStratY, "father.width", nStratY + height+14)
			nStratY = nStratY + height + 14
			local bkg = obj:GetControlObject("bkg")
			bkg:SetObjPos(0, 7, "father.width", "father.height-7")
			local linetop = xarFactory:CreateUIObject("searchlinetop."..i, "TextureObject")
			linetop:SetTextureID("YBYL.Menu.Splitter")
			obj:AddChild(linetop)
			linetop:SetObjPos2(0, 3, "father.width", 1)
			local linebottom = xarFactory:CreateUIObject("searchlinebottom."..i, "TextureObject")
			linebottom:SetTextureID("YBYL.Menu.Splitter")
			obj:AddChild(linebottom)
			linebottom:SetObjPos2(0, 32, "father.width", 1)
		else
			obj:SetObjPos(0, nStratY, "father.width", nStratY + height)
			nStratY = nStratY + height
		end
		--[[if i >= 5 then
			local txt = obj:GetControlObject("text")
			txt:SetTextColorResID("system.gray")
			obj:SetEnable(false)
		end]]--
	end
	
	
end

function OnInitControl(self)
	local attr = self:GetAttribute()
	attr.data = {}
end

function SetIcon(self, ico)
	local icon = self:GetControlObject("icon")
	if ico then
		icon:SetBitmap(ico)
	else
		local strDefResID = tFunHelper.GetDefaultIcoImgID()
		icon:SetResID(strDefResID)
	end
	icon:SetVisible(true)
end

function GetIcon(self)
	local icon = self:GetControlObject("icon")
	return icon:GetBitmap()
end