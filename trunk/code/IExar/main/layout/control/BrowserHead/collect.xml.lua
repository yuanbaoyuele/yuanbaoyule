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

function CreateHistoryListUI()
	--local tUrlHistory = tipUtil:GetIEHistoryInfo()
	--local nMaxCount = (#tUrlHistory > 20 and 20 or #tUrlHistory)
	local strHistoryPath = "C:\\Users\\wangwei\\AppData\\Local\\Microsoft\\Windows\\Temporary Internet Files"
	local tUrlHistory = tipUtil:FindFileList(strHistoryPath, "*")
	for i, v in ipairs(tUrlHistory) do
		XLMessageBox(tostring(v))
	end
end

function CreateIEHistoryNode(i, v)--创建ie历史节点
	
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
	nodebkg:SetObjPos2(left, top, 120, 16)
	nodebkg:AddChild(imgobj)
	imgobj:SetObjPos2(0, 0, 16, 16)
	local txtobj = objFactory:CreateUIObject("txt_treenode"..treeNodeIndex, "TextObject")
	nodebkg:AddChild(txtobj)
	txtobj:SetText(name)
	txtobj:SetObjPos2(20, 0, 100, 16)
	
	txtobj:AttachListener("OnLButtonDown", false, function(self, x, y)
		self:RouteToFather()
	end)
	txtobj:AttachListener("OnMouseLeave", false, function(self, x, y)
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
	
	local objparent = uiOwner:GetControlObject("Layout.main")
	objparent:AddChild(nodebkg)
	treeNodeAttr[v] = treeNodeAttr[v] or {}
	if isdir then
		treeNodeAttr[v].ext = treeNodeAttr[v].ext or false
	end
	
	nodebkg:AttachListener("OnLButtonDown", false, function(self, x, y)
		treeNodeAttr[v].lbtndown = true
		movemovecanstart = true
		lastclickname = v
		lastclickicon = icon
	end)
	nodebkg:AttachListener("OnMouseLeave", false, function(self, x, y)
		treeNodeAttr[v].lbtndown = false
		treeNodeAttr[v].rbtndown = false
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
					_nodebkg:SetObjPos2(x, y, 120, 16)
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
				XLMessageBox(name)
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
		local objparent = uiOwner:GetControlObject("Layout.main")
		local l, t, r, b2 = objparent:GetObjPos()
		objparent:SetObjPos(l, t, r, b+10)
	end
end

function RemoveAll()
	local objparent = uiOwner:GetControlObject("Layout.main")
	local ret = objparent:RemoveAllChild()
	treeNodeIndex = 0
end





