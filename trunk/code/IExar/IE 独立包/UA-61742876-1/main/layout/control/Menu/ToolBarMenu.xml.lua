

function OnSelect_MenuBar(self)

end

function OnSelect_CollectBar(self)
	
end

function OnSelect_CommandBar(self)
	
end

function OnSelect_StateBar(self)
	
end

function OnSelect_LockBar(self)
	
end


function OnInitControl(self)
	local objMenuContainer = self:GetControlObject( "context_menu" )
	if not objMenuContainer then
		return
	end
		
	SetMenuItemIco(objMenuContainer)
end


function SetMenuItemIco(objMenuContainer)
	local nMenuItemCount = objMenuContainer:GetItemCount()
	
	for i=1, nMenuItemCount do
		local objMenuItem = objMenuContainer:GetItem(i)
		if objMenuItem then
			local strIcoResID = objMenuItem:GetIconID() or ""
			objMenuItem:SetIconID(strIcoResID)
			objMenuItem:SetIconVisible(true)
		end	
	end
end




