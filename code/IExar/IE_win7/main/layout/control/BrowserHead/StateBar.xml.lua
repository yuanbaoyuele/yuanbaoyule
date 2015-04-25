local tFunHelper = XLGetGlobal("YBYL.FunctionHelper")
local tipUtil = tFunHelper.tipUtil
local tIEMenuHelper = XLGetGlobal("YBYL.IEMenuHelper")

function CreateStateListener(objStatusText)
	local objFactory = XLGetObject("APIListen.Factory")
	if not objFactory then
		tFunHelper.TipLog("[CreateFilterListener] not support APIListen.Factory")
		return
	end
	
	local objListen = objFactory:CreateInstance()	
	objListen:AttachListener(
		function(key,...)	

			--tFunHelper.TipLog("[CreateFilterListener] key: " .. tostring(key))
			
			local tParam = {...}	
			if tostring(key) == "OnStatusTextChange" then
				if tParam[1] ~= nil then
					objStatusText:SetText(tParam[1])
				end	
			end
		end
	)
end

-----方法----
function OnInitControl(self)
	local objStatusText = self:GetControlObject("StateBar.Text")
	if objStatusText ~= nil then
		CreateStateListener(objStatusText)
	end	
end

-----事件----

function OnClickZoomText(self)
	InitMenuHelper()
	local nFactor = tFunHelper.GetZoomFactor()
	if nFactor < 100 or nFactor >= 150 then
		tIEMenuHelper:ExecuteCMD("Zoom", 100)
		tFunHelper.SetZoomFactor(100)
		return
	end
	
	local nNewFactor = nFactor+25
	tIEMenuHelper:ExecuteCMD("Zoom", nNewFactor)
	tFunHelper.SetZoomFactor(nNewFactor)
end


function OnInitZoomBtn(self)
	local nFactor = tFunHelper.GetZoomFactor()
	self:SetText(tostring(nFactor))
end


function OnClickZoomArrow(self)
	InitMenuHelper()
	local bRButtonPopup = false
	local bRightAlign = true
	local bTopAlign = true
	tFunHelper.TryDestroyOldMenu(self, "ZoomMenu")
	tFunHelper.CreateAndShowMenu(self, "ZoomMenu", 9, bRButtonPopup, bRightAlign, bTopAlign)
end


function OnMouseEnterEarth(self)
	tFunHelper.ShowToolTip(true, "双击更改安全性设置")
end


function HideToolTip()
	tFunHelper.ShowToolTip(false)
end

----


------辅助函数---
function InitMenuHelper()
	local objActiveTab = tFunHelper.GetActiveTabCtrl()
	if objActiveTab == nil or objActiveTab == 0 then
		return
	end
	
	local objBrowserCtrl = objActiveTab:GetBindBrowserCtrl()
	if objBrowserCtrl then
		local objUEBrowser = objBrowserCtrl:GetControlObject("browser")
		tIEMenuHelper:Init(objUEBrowser)
	end
end


function RouteToFather(self)
	self:RouteToFather()
end

function IsRealString(str)
	return type(str) == "string" and str ~= ""
end