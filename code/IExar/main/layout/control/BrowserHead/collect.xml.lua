local tipUtil = XLGetObject("API.Util") 
local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
local treeNodeIndex = 0
local uiOwner
local treeNodeAttr={}
local tfilelistcache = nil
local frameHostWnd
local tFilePathMap = nil
local strFavoritesPath = tFunHelper.GetUserCollectDir()
local strSysTemp = tipUtil:GetSystemTempPath()
local strPathCachePath = tipUtil:PathCombine(strSysTemp, "iefilepathmap.dat")
local tUrlHistory = nil
function Show(self, index)
	uiOwner = self
	if index == 1 then --收藏夹
		RemoveAll()
		tFilePathMap = tFunHelper.LoadTableFromFile(strPathCachePath) or {}
		Dir2TreeList(strFavoritesPath, 10)
		--AdjustBkgPos()
	elseif index == 2 then --源
		RemoveAll()
	elseif index == 3 then--历史记录
		RemoveAll()
		CreateHistoryListUI()
	end
end

--右键菜单
function PopMenu(self, v)
	tFunHelper.CreateAndShowMenu(self, "CollectTreeMenu", 0, true)
end

function IsRealString(str) return type(str) == "string" and str ~= "" end

function GetHostName(URL) --获取域名
	if string.find(URL, "://") then
		URL = string.match(URL, "^.*://(.*)$" ) or ""
	end
	URL = string.match(URL, "^([^/]*).*$" )  or ""
	if string.find(URL, "@") then
		URL = string.match(URL, "^[^@]*@(.*)$" )  or ""
	end
	URL = string.match(URL, "^([^:]*).*$" )  or ""
	local captures = {}
	for w in string.gmatch(URL, "[^%.]+") do
		table.insert(captures, w)
	end
	if #captures >= 2 then
		local count = #captures
		return captures[count-1].."."..captures[count]
	end
	return "about:blank"
end

local nIEListIndex = 0
local lastselectlistname = ""
local tListAttr = {}
function CreateHistoryListUI()
	tUrlHistory = tUrlHistory or tipUtil:GetIEHistoryInfo()
	local nCurYear, nCurMon, nCurDay = tipUtil:FormatCrtTime(tipUtil:GetCurrentUTCTime())
	local nTodayFirstUTC = tipUtil:DateTime2Seconds(nCurYear, nCurMon, nCurDay, 0, 0, 0)
	local tDefineRecent = tDefineRecent or {}
	for i = 1, 7 do
		tDefineRecent[i] = tDefineRecent[i] or {}
		tDefineRecent[i]["minutc"] = nTodayFirstUTC-(i-1)*86400
		tDefineRecent[i]["maxutc"] = nTodayFirstUTC-(i-1)*86400+86400
	end
	local function Add2Recent(nVistUtc, strWeek, tUrl)
		for i, v in ipairs(tDefineRecent) do
			if nVistUtc >= v["minutc"] and nVistUtc < v["maxutc"] then
				v["info"] = v["info"] or {}
				v["weekday"] = strWeek
				if i == 1 then
					v["weekday"] = "今天"
				end
				--按域名分类
				local strHost = GetHostName(tUrl["pwcsUrl"])
				local t = v["info"][strHost] or {}
				t[#t+1] = tUrl
				v["info"][strHost] = t
			end
		end
	end
	for i, v in ipairs(tUrlHistory) do
		local nVistUtc, strWeek = tFunHelper.FileTime2LocalTime(v["ftLastVisited"])
		Add2Recent(nVistUtc, strWeek, v)
	end
	nIEListIndex = 0
	for i, v in ipairs(tDefineRecent) do
		if type(v["info"]) == "table" then
			CreateIEHistoryNode(v, 10, 1)--第一级
			tListAttr[v["weekday"]] = tListAttr[v["weekday"]] or  {}
			if tListAttr[v["weekday"]]["ext"] then
				for hostname, vv in pairs(v["info"]) do--第二级
					CreateIEHistoryNode({v, hostname, vv}, 30, 2)
					tListAttr[v["weekday"]..hostname] = tListAttr[v["weekday"]..hostname] or {}
					if tListAttr[v["weekday"]..hostname]["ext"] and type(vv) == "table" then
						for _, vvv in ipairs(vv) do
							CreateIEHistoryNode({v, hostname, vvv}, 50, 3)
						end
					end
				end
			end
		end
	end
end


function CreateIEHistoryNode(v, left, listrank)--创建ie历史节点
	local key = nil
	if listrank == 1 then
		key = v["weekday"]
	elseif listrank == 2 then
		key = v[1]["weekday"]..v[2]
	else
		key = v[1]["weekday"]..tostring(v[2])..tostring(v[3]["pwcsUrl"])
	end
	--背景layout
	local nodebkg = objFactory:CreateUIObject("bkg_listnode"..nIEListIndex, "LayoutObject")
	--图标
	local imgobj = objFactory:CreateUIObject("img_listnode"..nIEListIndex, "ImageObject")
	if listrank == 1 then
		imgobj:SetResID("img.week")
	elseif listrank == 2 then
		imgobj:SetResID("img.weekday")
	else
		imgobj:SetResID("collect.file.defaluticon")
	end
	
	local objpre = uiOwner:GetControlObject("bkg_listnode"..(nIEListIndex-1))
	local top = 0
	if objpre then
		local _, _, _, b = objpre:GetObjPos()
		top = b+2
	end
	nodebkg:SetObjPos2(left, top, 140, 16)
	nodebkg:AddChild(imgobj)
	if listrank == 1 then
		imgobj:SetObjPos2(0, 0, 15, 14)
	elseif listrank == 2 then
		imgobj:SetObjPos2(0, 0, 13, 19)
	else
		imgobj:SetObjPos2(0, 0, 16, 16)
	end
	
	--文本
	local txtobj = objFactory:CreateUIObject("txt_listnode"..nIEListIndex, "TextObject")
	txtobj:SetTextFontResID("font.menuitem")
	txtobj:SetTextColorResID("color.tab.normal")
	nodebkg:AddChild(txtobj)
	nodebkg:SetZorder(100)
	if listrank == 1 then
		txtobj:SetText(v["weekday"])
	elseif listrank == 2 then
		txtobj:SetText(v[2])
	else
		txtobj:SetText(v[3]["pwcsTitle"] or v[3]["pwcsUrl"])
	end
	txtobj:SetObjPos2(20, 0, 120, 16)
	--转发文本框事件，让父控件处理
	txtobj:AttachListener("OnLButtonDown", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseLeave", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseEnter", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseMove", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnRButtonDown", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnRButtonUp", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnLButtonUp", false, function(self, x, y)
		self:RouteToFather()
	end)
	
	local objparent = uiOwner:GetControlObject("Layout.Container")
	objparent:AddChild(nodebkg)
	if lastselectlistname == key then--恢复选中状态
		local _select = objparent:GetObject("nodebkg4select")
		if not _select then
			_select = objFactory:CreateUIObject("nodebkg4select", "TextureObject")
			objparent:AddChild(_select)
			_select:SetTextureID("YBYL.Menu.Select.Bkg")
			_select:SetZorder(101)
		end
		local l, t, r, b = objparent:GetObjPos()
		_select:SetObjPos2(0, top, r-l, 16)
		_select:SetVisible(true)
	end
	--处理事件
	local lbtndown = false
	nodebkg:AttachListener("OnLButtonDown", false, function(self, x, y)
		lbtndown = true
		lastselectlistname = key
		--选中状态
		local _select = objparent:GetObject("nodebkg4select")
		if not _select then
			_select = objFactory:CreateUIObject("nodebkg4select", "TextureObject")
			objparent:AddChild(_select)
			_select:SetTextureID("YBYL.Menu.Select.Bkg")
		end
		_select:SetZorder(101)
		local l, t, r, b = objparent:GetObjPos()
		_select:SetObjPos2(0, top, r-l, 16)
		_select:SetVisible(true)
	end)
	nodebkg:AttachListener("OnMouseLeave", false, function(self, x, y)
		txtobj:SetTextFontResID("font.menuitem")
		txtobj:SetTextColorResID("color.tab.normal")
	end)
	--鼠标划过状态变化
	nodebkg:AttachListener("OnMouseEnter", false, function(self, x, y)
		txtobj:SetTextFontResID("font.menuitemkey")
		txtobj:SetTextColorResID("system.blue")
		
	end)
	nodebkg:AttachListener("OnMouseMove", false, function(self, x, y)
		self:RouteToFather()
	end)
	nodebkg:AttachListener("OnLButtonUp", false, function(self, x, y)
		if lbtndown then
			if listrank ~= 3 then
				tListAttr[key] = tListAttr[key] or {}
				tListAttr[key]["ext"] = not tListAttr[key]["ext"]
				RemoveAll()
				CreateHistoryListUI()
			else
				local strUrl = v[3]["pwcsUrl"]
				if IsRealString(strUrl) then
					tFunHelper.OpenURLInNewTab(strUrl)
				end
			end
		end
		self:RouteToFather()
	end)
	nIEListIndex = nIEListIndex + 1
end

function Dir2TreeList(dir, left)
	local dirlist = tipUtil:FindDirList(dir)
	local filelist = tipUtil:FindFileList(dir, "*.*")
	local dirkey = string.gsub(dir, "[\\/]", "")
	if type(tFilePathMap[dirkey]) == "table" then
		local bRet, tTemp = false, {}
		for _, v1 in ipairs(filelist) do
			bRet = false
			for _, v2 in ipairs(tFilePathMap[dirkey]) do
				if v1 == v2 then
					bRet = true
					break
				end
			end
			if not bRet then
				tTemp[#tTemp] = v1
			end
		end
		for _, v1 in ipairs(dirlist) do
			bRet = false
			for _, v2 in ipairs(tFilePathMap[dirkey]) do
				if v1 == v2 then
					bRet = true
					break
				end
			end
			if not bRet then
				tTemp[#tTemp] = v1
			end
		end
		for _, v in ipairs(tTemp) do
			table.insert(tFilePathMap[dirkey], v)
		end
	else
		tFilePathMap[dirkey] = dirlist
		for _, v in ipairs(filelist) do
			table.insert(tFilePathMap[dirkey], v)
		end
	end
	for i, v in ipairs(tFilePathMap[dirkey]) do
		if string.match(v, "[\\/]([^\\/%.]*)$") == nil then
			CreateNode(v, "collect.file.defaluticon", left, false)
		else
			CreateNode(v, "collect.dir.defaluticon", left, true)
			if treeNodeAttr[v].ext then
				Dir2TreeList(v, left+20)
			end
		end
	end
end

function ReBuild()
	RemoveAll()
	Dir2TreeList(strFavoritesPath, 10)
	--AdjustBkgPos()
end

local isattchbkgmoveevent = false
local movemovecanstart = false
local lastclickname = ""
local lastclickicon = ""
function CreateNode(v, icon, left, isdir)
	local name = string.match(v, "^.*[/\\]([^/\\]*)$")
	local nodebkg = objFactory:CreateUIObject("bkg_treenode"..treeNodeIndex, "LayoutObject")
	local imgobj = objFactory:CreateUIObject("img_treenode"..treeNodeIndex, "ImageObject")
	
	imgobj:SetResID(icon)
	local objpre = uiOwner:GetControlObject("bkg_treenode"..(treeNodeIndex-1))
	local top = 0
	if objpre then
		local _, _, _, b = objpre:GetObjPos()
		top = b+2
	end
	nodebkg:SetObjPos2(left, top, 140, 16)
	nodebkg:AddChild(imgobj)
	imgobj:SetObjPos2(0, 0, 16, 16)
	local txtobj = objFactory:CreateUIObject("txt_treenode"..treeNodeIndex, "TextObject")
	txtobj:SetTextFontResID("font.menuitem")
	txtobj:SetTextColorResID("color.tab.normal")
	nodebkg:AddChild(txtobj)
	nodebkg:SetZorder(100)
	txtobj:SetText(name)
	txtobj:SetObjPos2(20, 0, 120, 16)
	
	txtobj:AttachListener("OnLButtonDown", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseLeave", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseEnter", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseMove", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnRButtonDown", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnRButtonUp", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnLButtonUp", false, function(self, x, y)
		self:RouteToFather()
	end)
	
	local objparent = uiOwner:GetControlObject("Layout.Container")
	objparent:AddChild(nodebkg)
	if lastclickname == v then--恢复选中状态
		local _select = objparent:GetObject("nodebkg4select")
		if not _select then
			_select = objFactory:CreateUIObject("nodebkg4select", "TextureObject")
			objparent:AddChild(_select)
			_select:SetTextureID("YBYL.Menu.Select.Bkg")
			_select:SetZorder(101)
		end
		local l, t, r, b = objparent:GetObjPos()
		_select:SetObjPos2(0, top, r-l, 16)
		_select:SetVisible(true)
	end
	treeNodeAttr[v] = treeNodeAttr[v] or {}
	if isdir then
		treeNodeAttr[v].ext = treeNodeAttr[v].ext or false
	end
	
	nodebkg:AttachListener("OnLButtonDown", false, function(self, x, y)
		treeNodeAttr[v].lbtndown = true
		movemovecanstart = true
		lastclickname = v
		lastclickicon = icon
		--选中状态
		local _select = objparent:GetObject("nodebkg4select")
		if not _select then
			_select = objFactory:CreateUIObject("nodebkg4select", "TextureObject")
			objparent:AddChild(_select)
			_select:SetTextureID("YBYL.Menu.Select.Bkg")
		end
		_select:SetZorder(101)
		local l, t, r, b = objparent:GetObjPos()
		_select:SetObjPos2(0, top, r-l, 16)
		_select:SetVisible(true)
	end)
	nodebkg:AttachListener("OnMouseLeave", false, function(self, x, y)
		treeNodeAttr[v].lbtndown = false
		treeNodeAttr[v].rbtndown = false
		txtobj:SetTextFontResID("font.menuitem")
		txtobj:SetTextColorResID("color.tab.normal")
	end)
	--鼠标划过状态变化
	nodebkg:AttachListener("OnMouseEnter", false, function(self, x, y)
		txtobj:SetTextFontResID("font.menuitemkey")
		txtobj:SetTextColorResID("system.blue")
		
	end)
	nodebkg:AttachListener("OnMouseMove", false, function(self, x, y)
		self:RouteToFather()
	end)
	
	if not isattchbkgmoveevent then
		isattchbkgmoveevent = true
		objparent:AttachListener("OnMouseMove", false, function(self, x, y)
			if movemovecanstart then
				local _nodebkg = objparent:GetObject("nodebkg4drag")
				local _name = string.match(lastclickname, "^.*[/\\]([^/\\]*)$")
				if not _nodebkg then
					--XLMessageBox(type(_nodebkg))
					_nodebkg = objFactory:CreateUIObject("nodebkg4drag", "LayoutObject")
					_nodebkg:SetObjPos2(x, y, 140, 16)
					local _imgobj = objFactory:CreateUIObject("img_nodebkg4drag", "ImageObject")
					_nodebkg:AddChild(_imgobj)
					_imgobj:SetObjPos2(0, 0, 16, 16)
					local _txtobj = objFactory:CreateUIObject("txt_nodebkg4drag", "TextObject")
					_nodebkg:AddChild(_txtobj)
					_imgobj:SetResID(lastclickicon)
					_txtobj:SetText(_name)
					_txtobj:SetObjPos2(20, 0, 100, 16)
					objparent:AddChild(_nodebkg)
				end
				local _img, _txt = _nodebkg:GetObject("img_nodebkg4drag"), _nodebkg:GetObject("txt_nodebkg4drag")
				_img:SetResID(lastclickicon)
				_txt:SetText(_name)
				_nodebkg:SetObjPos2(x, y, 120, 16)
				
				_nodebkg:SetAlpha(200, true)
				_nodebkg:SetVisible(true)
				_nodebkg:SetChildrenVisible(true)
			end
		end)
	end
	local function _onlbuttonup(self, x, y)
		local dir1 = string.match(v, "^(.*)[/\\][^/\\]*$")
		local dir2 = string.match(lastclickname, "^(.*)[/\\][^/\\]*$")
		if movemovecanstart then 
			local dirkey = string.gsub(dir1, "[\\/]", "")
			if lastclickname ~= v and dir1 == dir2 and type(tFilePathMap[dirkey]) == "table" then --只保存同一级的文件顺序
				local idx1, idx2 = nil, nil
				for i, v0 in ipairs(tFilePathMap[dirkey]) do
					if v0 == lastclickname then
						idx1 = i
					elseif v0 == v then
						idx2 = i
					end
				end
				if idx1 ~= nil and idx2 ~= nil then
					local temp = tFilePathMap[dirkey][idx1]
					tFilePathMap[dirkey][idx1] = tFilePathMap[dirkey][idx2]
					tFilePathMap[dirkey][idx2] = temp
					tFunHelper.SaveTableToFile(tFilePathMap, strPathCachePath)
					ReBuild()
				end
			elseif string.find(v, lastclickname, 1, true) == nil then--否则更换文件位置， 目标不能包含在源里,例如：C:\\TEST不能与C:\\TEST\\TEST.DAT交换，但反过来可以
				--移动文件或文件夹
			end
		end
		movemovecanstart = false
		local _nodebkg = objparent:GetObject("nodebkg4drag")
		if _nodebkg then
			_nodebkg:SetVisible(false)
			_nodebkg:SetChildrenVisible(false)
		end
	end
	nodebkg:AttachListener("OnLButtonUp", false, function(self, x, y)
		_onlbuttonup(self, x, y)
		if treeNodeAttr[v].lbtndown then
			if isdir then
				treeNodeAttr[v].ext = not treeNodeAttr[v].ext 
				ReBuild()
			else
				local strUrl = tipUtil:ReadINI(v, "InternetShortcut", "URL")
				if IsRealString(strUrl) then
					tFunHelper.OpenURLInNewTab(strUrl)
				end
			end
		end
		self:RouteToFather()
	end)
	nodebkg:AttachListener("OnRButtonDown", false, function(self, x, y)
		treeNodeAttr[v].rbtndown = true
		movemovecanstart = true
		lastclickname = v
		lastclickicon = icon
	end)
	nodebkg:AttachListener("OnRButtonUp", false, function(self, x, y)
		_onlbuttonup(self, x, y)
		if treeNodeAttr[v].rbtndown then
			--CreateAndShowMenu(self, "RBtnFavoritMenu", 0, true)
			PopMenu(self, v)
			--RenamePathName(nodebkg, v)
		end
		self:RouteToFather()
	end)
	treeNodeIndex = treeNodeIndex + 1
end

function RenamePathName(nodebkg, strPath)--重命名
	local count = nodebkg:GetChildCount()
	local txt, idx, edit
	for i=0,count-1 do
         local obj = nodebkg:GetChildByIndex(i)
		 if string.find(obj:GetID(), "txt_treenode", 1, true) ~= nil then
			txt = obj
			idx = string.match(obj:GetID(), "txt_treenode(%d*)")
		 elseif string.find(obj:GetID(), "edit_treenode", 1, true) ~= nil then
			edit = obj
		 end
	end
	if not txt then return end
	if not edit then
		edit = objFactory:CreateUIObject("edit_treenode"..idx, "EditObject")
		nodebkg:AddChild(edit)
		edit:SetTextColor("#000000")
		edit:SetFontID("default.font")
		edit:AttachListener("OnFocusChange", false, function(self, isFocus, lastFocusObj)
			if not isFocus then
				local strText = self:GetText()
				txt:SetText(strText)
				self:SetVisible(false)
				txt:SetVisible(true)
				txt:SetEnable(true)
				local dir = string.match(strPath, "^(.*)[\\/][^\\//]*$")
				local dirkey = string.gsub(dir, "[\\/]", "")
				if type(tFilePathMap[dirkey]) == "table" then
					for i, v in ipairs(tFilePathMap[dirkey]) do
						if v == strPath then
							tFilePathMap[dirkey][i] = dir.."\\"..strText
							--真正的重命名操作
							ReBuild()
							break
						end
					end
				end
			end
		end)
	end
	local l, t, r, b = txt:GetObjPos()
	edit:SetObjPos(l, t, r, b)
	local strText = txt:GetText()
	if string.len(strText) > 18 then
		edit:SetObjPos(l, t, r*2-l, b)
	end
	txt:SetVisible(false)
	txt:SetEnable(true)
	edit:SetFocus(true)
	edit:SetSelAll()
	edit:SetText(strText)
	edit:SetVisible(true)
end

function DeletePathName(nodebkg, strPath)--删除
	local dir = string.match(strPath, "^(.*)[\\/][^\\//]*$")
	local dirkey = string.gsub(dir, "[\\/]", "")
	if type(tFilePathMap[dirkey]) == "table" then
		for i, v in ipairs(tFilePathMap[dirkey]) do
			if v == strPath then
				--tFilePathMap[dirkey][i] = dir.."\\"..strText
				table.remove(tFilePathMap[dirkey], i)
				--真正的删除操作
				ReBuild()
				break
			end
		end
	end
end


function AdjustBkgPos()
	local objlast = uiOwner:GetControlObject("bkg_treenode"..(treeNodeIndex-1))
	if objlast then
		local _, _, _, b = objlast:GetObjPos()
		local objparent = uiOwner:GetControlObject("Layout.Container")
		local l, t, r, b2 = objparent:GetObjPos()
		objparent:SetObjPos(l, t, r, b+10)
	end
end

function RemoveAll()
	local objparent = uiOwner:GetControlObject("Layout.Container")
	local ret = objparent:RemoveAllChild()
	treeNodeIndex = 0
end


-----------事件
function OnClickAddToBar(self)

end


function OnClickAddArrow(self)

end

function OnDownFixBtn(self)

end

function OnUpFixBtn(self)

end

-----------
function RouteToFather(self)
	self:RouteToFather()
end




