local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local SearchEngineMap = {}
local SearchEngineDisplay = {}
local SearchEngineIcon = {}

function OnClick(self)
	local control = self:GetOwnerControl()
	local edit = control:GetControlObject("edit")
	
	local txt = edit:GetText()
	if string.len(txt) > 0 then
		-- 存
		--XLMessageBox("push key word")
		--local explorerHistory = XLGetGlobal("BoltFox.History")
		--explorerHistory:PushFrontRecentSearchKeyword(txt)
	
		control:FireExtEvent("OnSearch", txt)
	end
end

function OnInitControl(self)
	local tUserConfig = tFunHelper.ReadConfigFromMemByKey("tUserConfig") or {}
	SearchEngineMap = tUserConfig["SearchEngine"] or {
		{ displayName = "百度一下 (默认)", name = "baidu", url="http://www.baidu.com/s?wd={searchword}"},
		{ displayName = "Google", name = "google", url="http://www.google.com/q={searchword}"},
		{ displayName = "Live Search", name = "bing",url="http://cn.bing.com/search?q={searchword}"},
		--{ displayName = "百度", name = "baidu2", icon = "bitmap.search.baidu",url="http://cn.bing.com/search?q=xxx"},
	}
	
	for i, v in ipairs(SearchEngineMap) do
		SearchEngineDisplay[i] = v.displayName
		SearchEngineIcon[i] = tFunHelper.GetIcoBitmapObj(tFunHelper.GetSearchEngineIcoName(v.url))
	end
	SearchEngineDisplay[#SearchEngineDisplay+1] = "在此页上查找..."
	SearchEngineDisplay[#SearchEngineDisplay+1] = "查找更多提供程序..."
	SearchEngineDisplay[#SearchEngineDisplay+1] = "管理搜索提供程序"
	local attr = self:GetAttribute()
	attr.SearchEngine = SearchEngineMap[1]
end


function OnClick2(self)
	local control = self:GetOwnerControl()
	local left, top, right, bottom = self:GetAbsPos()
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	local x, y = hostwnd:ClientPtToScreenPt(left, top)
	
	--local explorerHistory = XLGetGlobal("BoltFox.History")
	--local array = explorerHistory:GetRecentSearchKeywords()
	
	--XLPrint("-----------------")
	--for k,v in ipairs(array) do
	--	XLPrint(v)
	--end
	--XLPrint("-----------------         ----------")
		
	local data = { 
		textArray = SearchEngineDisplay, 
		edit = self, 
		iconArray = SearchEngineIcon
	}

	
	ShowPopupWnd(control, x-190, y + (bottom-top) , 190+16, 200, data)
end

function OnLButtonDbClick(self)
	
end

function ShowPopupWnd(control, left, top, width, bottom, data)
	local hostwndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local hostwnd = hostwndMgr:GetHostWnd("BoltFox.SearchPopupWnd")
	if hostwnd then
		hostwnd:SetVisible(true)
		return 
	end

	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local frameHostWndTemplate = templateMananger:GetTemplate("SearchPopupWnd","HostWndTemplate")
	if frameHostWndTemplate then  
		local frameHostWnd = frameHostWndTemplate:CreateInstance("BoltFox.SearchPopupWnd")
		if frameHostWnd then
			local objectTreeTemplate = templateMananger:GetTemplate("SearchPopupTree","ObjectTreeTemplate")
			if objectTreeTemplate then
				local uiObjectTree = objectTreeTemplate:CreateInstance("BoltFox.SearchPopupTree")
				if uiObjectTree then
					frameHostWnd:BindUIObjectTree(uiObjectTree)
					frameHostWnd:SetUserData(data)
					frameHostWnd:Create()
					
					frameHostWnd:Move(left, top, width, #data.textArray*22+6+10)
					
					frameHostWnd:AttachListener("OnDestroy", false, 
						function ()
							--XLPrint("OnHostwndClose")
							if data.closeByClick then
								if data.isSetSearchEngine then
									SetSearchEngine(control, data.text)
								else
									--local edit = control:GetControlObject("edit")
									--edit:SetText(data.text)
									SetSearchEngine(control, data.text)
								end
							end
						end
					)
				end
			end
		end
	end
end

function OnControlFocusChange(self, focus)
	if not focus then
		AsynCall(function ()
				local hostwndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
				local hostwnd = hostwndMgr:GetHostWnd("BoltFox.SearchPopupWnd")
				if hostwnd and not hostwnd:GetFocus() then
					hostwnd:Destroy()
				
					local hostwndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
					hostwndMgr:RemoveHostWnd("BoltFox.SearchPopupWnd")
					
					local treeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")
					treeMgr:DestroyTree("BoltFox.SearchPopupTree")
				end
			end
		)
		local editextctrl = self:GetControlObject("editextctrl_layout") 
		if editextctrl then
			self:RemoveChild(editextctrl)
		end
	else
		local txtobj = self:GetControlObject("edit")
		local strText  = txtobj:GetText()
		if strText == "" or strText == nil then
			local editextctrl = self:GetControlObject("editextctrl_layout") 
			if not editextctrl then
				local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
				editextctrl = objFactory:CreateUIObject("editextctrl_layout", "TextureObject")
				local parentbkg =  self:GetControlObject("border")
				local l, t, r, b =  parentbkg:GetObjPos()
				editextctrl:SetObjPos(l, b+1, r, b+33)
				-- editextctrl:SetSrcColor("#ffffff")
				-- editextctrl:SetDestColor("#ffffff")
				-- editextctrl:SetDestPt(r-l, 32)
				-- editextctrl:SetSrcPt(0, 0)
				-- editextctrl:SetBlendType("Source")
				-- editextctrl:SetFillType("Monochrome")
				editextctrl:SetTextureID("search.drap.bkg")
				editextctrl:SetZorder(999999999)
				for i=1, #SearchEngineMap do
					local btn = self:GetControlObject("minibtn"..i)
					if not btn then
						btn = objFactory:CreateUIObject("minibtn"..i, "TipAddin.Button")
						editextctrl:AddChild(btn)
						btn:SetObjPos2(6+(i-1)*24, 4, 22, 22)
						btn:AttachListener("OnClick", false, function(_self)
							--XLMessageBox()
							SetSearchEngine(self, SearchEngineMap[i]["displayName"])
						end)
					end
					local attr = btn:GetAttribute()
					local imgobj = self:GetControlObject("miniimgobj"..i)
					if not imgobj then
						imgobj = objFactory:CreateUIObject("miniimgobj"..i, "ImageObject")
						if SearchEngineIcon[i] then
							imgobj:SetBitmap(SearchEngineIcon[i])
						else
							local strDefResID = tFunHelper.GetDefaultIcoImgID()
							imgobj:SetResID(strDefResID)
						end
						imgobj:SetDrawMode(1)
						imgobj:SetDrawMode(2)
						btn:AddChild(imgobj)
						imgobj:SetObjPos2(3, 3, 16, 16)
						imgobj:SetZorder(999999)
					end
					attr.NormalBkgID = ""
					attr.HoverBkgID = "searchselect.hover"
					attr.DownBkgID = "searchselect.down"
					if i>=5 then
						break
					end
				end
				local lineobj = self:GetControlObject("searchctrlline")
				if not lineobj then
					lineobj = objFactory:CreateUIObject("searchctrlline", "TextureObject")
					editextctrl:AddChild(lineobj)
					lineobj:SetObjPos2(r-l-62, 5, 1, "father.height-10")
					lineobj:SetTextureID("YBYL.Menu.Splitter.Vertical")
				end
				local lasttext = self:GetControlObject("searchctrltext")
				if not lasttext then
					lasttext = objFactory:CreateUIObject("searchctrltext", "TipAddin.Button")
					editextctrl:AddChild(lasttext)
					lasttext:SetObjPos2(r-l-53, 5, 50, 23)
					lasttext:SetText("  查找...")
					lasttext:SetTextFont("font.text12")
					local attr = lasttext:GetAttribute()
					--attr.LeftTextPos = 30
					attr.TopTextPos = 2
					attr.NormalBkgID = ""
					attr.HoverBkgID = "about.button.bkg.hover"
					attr.DownBkgID = "about.button.bkg.down"
				end
				parentbkg:AddChild(editextctrl)
			end
		end
	end
end

function Edit_OnKeyDown(self, char)
	if char and char == 13 then
		local control = self:GetOwnerControl()
		local edit = control:GetControlObject("edit")
		
		local txt = edit:GetText()
		if string.len(txt) > 0 then
			--local explorerHistory = XLGetGlobal("BoltFox.History")
			--explorerHistory:PushFrontRecentSearchKeyword(txt)
			--control:FireExtEvent("OnSearch", txt)
		end
	end
end


function icon_OnLButtonUp(self)
	local control = self:GetOwnerControl()
	local left, top, right, bottom = control:GetAbsPos()
	local tree = self:GetOwner()
	local hostwnd = tree:GetBindHostWnd()
	local x, y = hostwnd:ClientPtToScreenPt(left, top)

	local data = { 
		textArray = SearchEngineDisplay, 
		edit = self, 
		iconArray = SearchEngineIcon,
		isSetSearchEngine = true,
	}

	
	--ShowPopupWnd(control, x, y + (bottom-top) - 4, right-left, 200, data)
end

function SetSearchEngine(control, engine)
	local icon = control:GetControlObject("icon")
	local attr = control:GetAttribute()
	for i=1, #SearchEngineMap do
		if SearchEngineMap[i].displayName == engine then
			if SearchEngineIcon[i] then
				icon:SetBitmap(SearchEngineIcon[i])
			else
				local strDefResID = tFunHelper.GetDefaultIcoImgID()
				icon:SetResID(strDefResID)
			end
			attr.SearchEngine = SearchEngineMap[i]
			break
		end
	end
	for i, v in ipairs(SearchEngineDisplay) do
		if v == engine then
			--XLMessageBox(v)
			break
		end
	end
end


function OnMouseEnterArrow(self)
	tFunHelper.ShowToolTip(true, "搜索选项")
end


function OnMouseEnterSearch(self)
	tFunHelper.ShowToolTip(true, "搜索(按 Alt+Enter 在新选项卡中搜索)")
end


function OnMouseEnterImage(self)
	tFunHelper.ShowToolTip(true, "")
end


function OnMouseEnterEdit(self)
	tFunHelper.ShowToolTip(true, "键入以搜索网站(Ctrl+E)")
end


function HideToolTip(self)
	tFunHelper.ShowToolTip(false)
end



