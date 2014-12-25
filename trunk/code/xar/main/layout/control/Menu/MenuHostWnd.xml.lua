function OnPopupMenu(self)
	
end

function OnEndMenu(self)

end

function OnBindObjectTree(self, menuTree)
	local objMainLayout = menuTree:GetUIObject("Menu.MainLayout")
	local context = objMainLayout:GetObject("Menu.Context")
	context:OnInitControl()	
end

------------------
