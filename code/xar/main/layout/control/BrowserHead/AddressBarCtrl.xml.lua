local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil


---方法---
function SetText(self, strURL)
	local objUrlEdit = self:GetControlObject("AddressBarCtrl.UrlEdit")
	if objUrlEdit then
		objUrlEdit:SetText(strURL)
	end
end

function GetText(self)
	local objUrlEdit = self:GetControlObject("AddressBarCtrl.UrlEdit")
	if objUrlEdit then
		return objUrlEdit:GetText()
	end
end

function AdjustCollectBtnStyle(self, strURL)
	local objCollectBtn = self:GetControlObject("AddressBarCtrl.Collect")
	local bHasCollected = CheckHasCollect(strURL)
	if bHasCollected then
		SetCollectBtnStyle(self, "hover")
	else
		SetCollectBtnStyle(self, "normal")
	end	 
end



function ProcessTabChange(self, objTabCtrl)
	if tonumber(objTabCtrl) ~= nil and objTabCtrl == 0 then
		self:SetText("")
		
	elseif objTabCtrl then
		local strURL = objTabCtrl:GetLocalURL()
		if IsRealString(strURL) then
			self:SetText(strURL)
		end
		self:AdjustCollectBtnStyle(strURL)
	end
end

-----事件----
--背景框
function OnMouseEnterBkg(self)
	self:SetTextureID("YBYL.AddressBar.UrlSearch.Bkg.Hover")
end

function OnMouseLeaveBkg(self)
	self:SetTextureID("YBYL.AddressBar.UrlSearch.Bkg.Normal")
end


--收藏--
function OnLButtonUpCllct(self)
	local objRootCtrl = self:GetOwnerControl()
	local strURL = objRootCtrl:GetText()
	if not IsRealString(strURL) then
		return
	end
	
	local bHasCollected = CheckHasCollect(strURL)
	if bHasCollected then
		RemoveCollect(objRootCtrl, strURL)
		SetCollectBtnStyle(objRootCtrl, "normal")
	else
		AddCollect(objRootCtrl, strURL)
		SetCollectBtnStyle(objRootCtrl, "hover")
	end	
end


--下拉箭头
function OnClickDropArrow(self)
	local tUrlHistory = tFunHelper.ReadConfigFromMemByKey("tUrlHistory") or {}
	if #tUrlHistory < 1 then
		return
	end

	local objRootCtrl = self:GetOwnerControl()
	local objEditBkg = objRootCtrl:GetControlObject("AddressBarCtrl.Bkg")

	TryDestroyOldMenu(objEditBkg, "UrlHistoryMenu")
	CreateAndShowMenu(objEditBkg, "UrlHistoryMenu")
end


function OnUrlEditKeyDown(self, nKeyCode)
	if nKeyCode ~= 13 then --只处理回车
		return
	end

	local strURL = self:GetText()
	if IsRealString(strURL) then
		tFunHelper.OpenURL(strURL)
	end
	
	tFunHelper.SaveUrlToHistory(strURL)
end



----------------
function SetCollectBtnStyle(objRootCtrl, strState)
	local objCollectBtn = objRootCtrl:GetControlObject("AddressBarCtrl.Collect")

	if strState == "hover" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Hover")
	elseif strState == "normal" then
		objCollectBtn:SetTextureID("YBYL.AddressBar.Collect.Normal")
	end
end


function CheckHasCollect(strURL)
	if not IsRealString(strURL) then
		return false
	end
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return false
	end

	for nIndex, tCollectInfo in pairs(tUserCollect) do
		if type(tCollectInfo) == "table" and tCollectInfo["strURL"] == strURL then
			return true
		end
	end
	
	return false
end


function RemoveCollect(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return
	end

	for nIndex, tCollectInfo in pairs(tUserCollect) do
		if type(tCollectInfo) == "table" and tCollectInfo["strURL"] == strURL then
			table.remove(tUserCollect, nIndex)
			tFunHelper.SaveConfigToFileByKey("tUserCollect")
			break
		end
	end
end


function AddCollect(objRootCtrl, strURL)
	if not IsRealString(strURL) then
		return
	end
	
	local tUserCollect = tFunHelper.ReadConfigFromMemByKey("tUserCollect")
	if type(tUserCollect) ~= "table" then
		tUserCollect= {}
		return
	end

	local tCollectInfo = {}
	tCollectInfo.strURL = strURL
	
	table.insert(tUserCollect, tCollectInfo)
	tFunHelper.SaveConfigToFileByKey("tUserCollect")
end


--下拉菜单
function TryDestroyOldMenu(objMenuBtn, strMenuKey)
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")
	local strHostWndName = strMenuKey..".HostWnd.Instance" 
	local strObjTreeName = strMenuKey..".Tree.Instance"

	if uHostWndMgr:GetHostWnd(strHostWndName) then
		uHostWndMgr:RemoveHostWnd(strHostWndName)
	end
	
	if uObjTreeMgr:GetUIObjectTree(strObjTreeName) then
		uObjTreeMgr:DestroyTree(strObjTreeName)
	end
end


function CreateAndShowMenu(objMenuBtn, strMenuKey)
	local uTempltMgr = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local uHostWndMgr = XLGetObject("Xunlei.UIEngine.HostWndManager")
	local uObjTreeMgr = XLGetObject("Xunlei.UIEngine.TreeManager")

	if uTempltMgr and uHostWndMgr and uObjTreeMgr then
		local uHostWnd = nil
		local strHostWndName = strMenuKey..".HostWnd.Instance"
		local strHostWndTempltName = "MenuHostWnd"
		local strHostWndTempltClass = "HostWndTemplate"
		local uHostWndTemplt = uTempltMgr:GetTemplate(strHostWndTempltName, strHostWndTempltClass)
		if uHostWndTemplt then
			uHostWnd = uHostWndTemplt:CreateInstance(strHostWndName)
		end

		local uObjTree = nil
		local strObjTreeTempltName = strMenuKey.."Tree"
		local strObjTreeTempltClass = "ObjectTreeTemplate"
		local strObjTreeName = strMenuKey..".Tree.Instance"
		local uObjTreeTemplt = uTempltMgr:GetTemplate(strObjTreeTempltName, strObjTreeTempltClass)
		if uObjTreeTemplt then
			uObjTree = uObjTreeTemplt:CreateInstance(strObjTreeName)
		end

		if uHostWnd and uObjTree then
			--函数会阻塞
			local bSucc = ShowMenuHostWnd(objMenuBtn, uHostWnd, uObjTree)
			
			if bSucc and uHostWnd:GetMenuMode() == "manual" then
				uObjTreeMgr:DestroyTree(strObjTreeName)
				uHostWndMgr:RemoveHostWnd(strHostWndName)
			end
		end
	end
end


function ShowMenuHostWnd(objMenuBtn, uHostWnd, uObjTree)
	uHostWnd:BindUIObjectTree(uObjTree)
					
	local objMainLayout = uObjTree:GetUIObject("Menu.MainLayout")
	if not objMainLayout then
	    return false
	end	
	local nL, nT, nR, nB = objMainLayout:GetObjPos()				
	local nMenuContainerWidth = nR - nL
	local nMenuContainerHeight = nB - nT
	local nMenuLeft, nMenuTop = GetScreenAbsPos(objMenuBtn)
	
	uHostWnd:SetFocus(false) --先失去焦点，否则存在菜单不会消失的bug
	
	--函数会阻塞
	local bOk = uHostWnd:TrackPopupMenu(objHostWnd, nMenuLeft, nMenuTop, nMenuContainerWidth, nMenuContainerHeight)
	return bOk
end

function GetScreenAbsPos(objUIElem)
	local objTree = objUIElem:GetOwner()
	local objHostWnd = objTree:GetBindHostWnd()
	local nL, nT, nR, nB = objUIElem:GetAbsPos()
	return objHostWnd:HostWndPtToScreenPt(nL, nT)
end


function RouteToFather(self)
	self:RouteToFather()
end

------辅助函数---
function IsRealString(str)
	return type(str) == "string" and str ~= ""
end