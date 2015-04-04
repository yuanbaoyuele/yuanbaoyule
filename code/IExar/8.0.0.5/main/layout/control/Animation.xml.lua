local KKV = XLGetGlobal("KKV")
function HideDialog_BindObj(self,obj)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	local attr = self:GetAttribute()
	attr.left,attr.top,attr.right,attr.bottom =obj:GetObjPos()
	local newImageObject = KKV.Animation.Snapshot(obj)
	attr.bindObj = obj
	obj:SetChildrenVisible(false)
	obj:SetVisible(false)
	KKV.Helper.Assert(newImageObject)
	if nil == newImageObject then
		return
	end
	attr.imageObj = newImageObject
	obj:GetFather():AddChild(newImageObject)
end

function HideDialog_GetBindObj(self)
	local attr = self:GetAttribute()
	if attr then
		return attr.bindObj
	end
	
	return nil
end

function HideDialog_Action(self)

	local curve = self:GetCurve()
	local totalTime = self:GetTotalTime()
	local runningTime = self:GetRuningTime()
	local progress = curve:GetProgress(runningTime / totalTime)
	local bindObj = self:GetBindObj()
	
	local attr = self:GetAttribute()

	--放大
	local left,right,top,bottom
	if attr.ZoomOut then
		left = attr.left - attr.ChangeX * progress
		right = attr.right + attr.ChangeX * progress
		top = attr.top - attr.ChangeY * progress
		bottom = attr.bottom + attr.ChangeY* progress
	else
		left = attr.left + attr.ChangeX * progress
		right = attr.right - attr.ChangeX * progress
		top = attr.top + attr.ChangeY * progress
		bottom = attr.bottom - attr.ChangeY* progress
	end
	KKV.Helper.Assert(attr.imageObj)
	if nil == attr.imageObj then
		return
	end
	attr.imageObj:SetObjPos(left,top,right,bottom)
	--改变透明度
	local alpha = 255 - 255*(runningTime / totalTime)
	attr.imageObj:SetAlpha(alpha)
	return true
end


function PopDialog_BindObj(self,obj)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	local attr = self:GetAttribute()
	attr.left,attr.top,attr.right,attr.bottom =obj:GetObjPos()
	
	local newImageObject = KKV.Animation.Snapshot(obj)
	attr.bindObj = obj
	obj:SetChildrenVisible(false)
	obj:SetVisible(false)
	attr.imageObj = newImageObject
	obj:GetFather():AddChild(newImageObject)
	
	local function onAniFinish(self,old,new)
		if new == 4 then
			obj:GetFather():RemoveChild(newImageObject)
			obj:SetVisible(true)
			obj:SetChildrenVisible(true)
		end
		return true
	end
	self:AttachListener(true,onAniFinish)
end

function PopDialog_GetBindObj(self)
	local attr = self:GetAttribute()
	if attr then
		return attr.bindObj
	end
	
	return nil
end

function PopDialog_Action(self)
	local curve = self:GetCurve()
	local totalTime = self:GetTotalTime()
	local runningTime = self:GetRuningTime()
	local progress = curve:GetProgress(runningTime / totalTime)
	local bindObj = self:GetBindObj()
	
	local attr = self:GetAttribute()
	if nil==attr.imageObj then
		return true
	end
	
	local left,right,top,bottom
	if attr.ZoomOut then
		--放大
		left = (attr.left + attr.ChangeX) - attr.ChangeX * progress
		right = (attr.right - attr.ChangeX) + attr.ChangeX * progress
		top = (attr.top + attr.ChangeY) - attr.ChangeY * progress
		bottom = (attr.bottom - attr.ChangeY) + attr.ChangeY* progress
	else
		--缩小
		left = (attr.left - attr.ChangeX) + attr.ChangeX * progress
		right = (attr.right + attr.ChangeX) - attr.ChangeX * progress
		top = (attr.top - attr.ChangeY) + attr.ChangeY * progress
		bottom = (attr.bottom + attr.ChangeY) - attr.ChangeY* progress
	end
	attr.imageObj:SetObjPos(left,top,right,bottom)
	--改变透明度
	local alpha = 255*(runningTime / totalTime)
	attr.imageObj:SetAlpha(alpha)
	return true
end

function tipsWnd_BindObj(self,obj)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	local attr = self:GetAttribute()
	attr.left,attr.top,attr.right,attr.bottom =obj:GetObjPos()
	
	local newImageObject = KKV.Animation.Snapshot(obj)
	attr.bindObj = obj
end

function tipsWnd_GetBindObj(self)
	local attr = self:GetAttribute()
	if attr then
		return attr.bindObj
	end
	
	return nil
end
function tipsWnd_SetKeyFrameRect(self,startLeft,startTop,startRight,startBottom,endLeft,endTop,endRight,endBottom)
	local attr = self:GetAttribute()
	attr.srcleft = startLeft
	attr.srctop = startTop
	attr.srcright = startRight
	attr.srcbottom = startBottom
	attr.destleft = endLeft
	attr.desttop = endTop
	attr.destright = endRight
	attr.destbottom = endBottom
end

function tipsWnd_Action(self)
	local curve = self:GetCurve()
	local totalTime = self:GetTotalTime()
	local runningTime = self:GetRuningTime()
	local progress = curve:GetProgress(runningTime / totalTime)
	local bindObj = self:GetBindObj()
	
	local attr = self:GetAttribute()
	local wnd = attr.bindObj:GetOwner():GetBindHostWnd()
	
	local left,top,right,bottom	
		
	left = attr.srcleft + (attr.destleft - attr.srcleft) * progress
	top = attr.srctop + (attr.desttop - attr.srctop) * progress
	right = attr.srcright + (attr.destright - attr.srcright) * progress
	bottom = attr.srcbottom + (attr.destbottom - attr.srcbottom) * progress
	
	-- left = attr.srcleft 
	-- top = attr.srctop 
	-- right = attr.destright
	-- bottom = attr.destbottom
	
	wnd:Move(left,top,right-left,3000)
	-- wnd:Move(attr.srcleft,attr.srctop,attr.destright-attr.srcleft,attr.destbottom - attr.srctop)
	-- wnd:Move(234,95,280,394)
	return true
end


-- 如果动画需要回调函数的话，为避免obj的状态被混乱，一致要求进行两步操作
-- 第一步显示调用XMP.Animation.StopAni(obj)，然后才可以设置obj的状态；
-- 第二步才调用RunXXXAni

-- 因为回调函数可能会设置obj的状态，如果不先显示停止上次的动画，
-- 则可能在调用RunXXXAni中停止上次动画并回调，
-- 从而导致之前设置好的obj状态被回调函数中的代码覆盖

KKV.Animation = {}

function GetSettingAniTime(self, key)
	local totalTime = self:GetTotalTime()
	return totalTime
	-- local settingPerc = KKV.Setting:Get(key, 100)
	-- return totalTime * settingPerc / 100
end

function KKV.Animation.StopAni(obj)
	KKV.Helper.Assert(obj ~= nil)
	local ani = KKV.Animation[obj:GetHandle()]
	if ani then
		ani:ForceStop()
	end
end

function KKV.Animation.PauseAni(obj)
	KKV.Helper.Assert(obj ~= nil)
	local ani = KKV.Animation[obj:GetHandle()]
	if ani then
		KKV.Animation[obj:GetHandle()] = nil
		ani:Stop()
	end
end

function KKV.Animation.Snapshot(obj)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	local left, top, right, bottom = obj:GetObjPos()
	local xlgraphic = XLGetObject("Xunlei.XLGraphic.Factory.Object")
	local theBitmap = xlgraphic:CreateBitmap("ARGB32", right - left, bottom - top)
	if not theBitmap then
		return
	end
	local theRender = XLGetObject("Xunlei.UIEngine.RenderFactory")
	theRender:RenderObject(obj, theBitmap)
	
	local objFactory = XLGetObject("Xunlei.UIEngine.ObjectFactory")
	local newImageObject = objFactory:CreateUIObject("", "ImageObject")
	newImageObject:SetBitmap(theBitmap)
	newImageObject:SetDrawMode(1)
	newImageObject:SetObjPos(left, top, right, bottom)
	newImageObject:SetZorder(obj:GetZorder())
	return newImageObject
end

-- 图片类型的渐隐渐现动画，影响图片本身的alpha值
function RunAlphaAni(obj, src_alpha, dest_alpha, fun, total_time, key)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	KKV.Animation.StopAni(obj)
	total_time = total_time or 500
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local ani = aniFactory:CreateAnimation("AlphaChangeAnimation")
	ani:SetTotalTime(total_time)
	ani:SetTotalTime(GetSettingAniTime(ani, key))
	ani:SetKeyFrameAlpha(src_alpha, dest_alpha)
	
	local handle = obj:GetHandle()
	local function onAniFinish(self,old,new)
		if new == 4 then
			KKV.Animation[handle] = nil
			if fun then fun(obj) end
		end
	end
	
	ani:BindRenderObj(obj)
	local tree = obj:GetOwner()
	KKV.Helper.Assert(tree ~= nil)
	tree:AddAnimation(ani)
	ani:AttachListener(true,onAniFinish)
	KKV.Animation[handle] = ani
	ani:Resume()
end

-- layout类型的渐隐渐显动画，不影响layout本身的alpha值
-- obj在动画结束之后会根据最终alpha值来设置可见性，注意这点副作用
function RunAlphaAniEx(obj, src_alpha, dest_alpha, fun, total_time, key)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	KKV.Animation.StopAni(obj)
	-- 拍照用，拍完复原，也要设置相应的Zorder
	local zorder = obj:GetZorder()
	obj:SetVisible(true)
	obj:SetChildrenVisible(true)

	local left, top, right, bottom =obj:GetObjPos()
	KKV.Helper.Assert(right)
	local newImageObject = KKV.Animation.Snapshot(obj)
	
	-- 隐藏
	obj:SetVisible(false)
	obj:SetChildrenVisible(false)
	obj:GetFather():AddChild(newImageObject)
	
	total_time = total_time or 500
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local ani = aniFactory:CreateAnimation("AlphaChangeAnimation")
	ani:SetTotalTime(total_time)
	ani:SetTotalTime(GetSettingAniTime(ani, key))
	ani:SetKeyFrameAlpha(src_alpha, dest_alpha)
	
	local handle = obj:GetHandle()
	local function onAniFinish(self,old,new)
		if new == 4 then
			obj:GetFather():RemoveChild(newImageObject)
			obj:SetVisible(dest_alpha~=0)
			obj:SetChildrenVisible(dest_alpha~=0)
			KKV.Animation[handle] = nil
			if fun then fun(obj) end
		end
		return true
	end
	
	ani:BindRenderObj(newImageObject)
	local tree = obj:GetOwner()
	tree:AddAnimation(ani)
	ani:AttachListener(true,onAniFinish)
	KKV.Animation[handle] = ani
	ani:Resume()
end

-- 针对不是由xlue渲染的对象，会移动对象本身
function RunPosAni(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, key)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	KKV.Animation.StopAni(obj)
	total_time = total_time or 500
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local ani = aniFactory:CreateAnimation("PosChangeAnimation")
	ani:SetTotalTime(total_time)
	ani:SetTotalTime(GetSettingAniTime(ani, key))
	ani:SetKeyFrameRect(startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom)
	
	local handle = obj:GetHandle()
	local function onAniFinish(self,old,new)
		if new == 4 then
			KKV.Animation[handle] = nil
			if fun then fun(obj, 3, 4) end
		end
		return true
	end
	
	ani:BindObj(obj)
	local tree = obj:GetOwner()
	tree:AddAnimation(ani)
	ani:AttachListener(true,onAniFinish)
	KKV.Animation[handle] = ani
	ani:Resume()	
end

-- 移动坐标相对于父对象，不移动对象本身
-- 动画运行结束之后，会把obj置为可见，注意这点副作用
function RunPosAniEx(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, key)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	KKV.Animation.StopAni(obj)
	
	-- 拍照用，拍完复原，也要设置相应的Zorder
	local zorder = obj:GetZorder()
	obj:SetVisible(true)
	obj:SetChildrenVisible(true)

	local left, top, right, bottom =obj:GetObjPos()
	local newImageObject = KKV.Animation.Snapshot(obj)
	
	-- 先隐藏，动画完了之后再复原
	obj:SetVisible(false)
	obj:SetChildrenVisible(false)
	obj:GetFather():AddChild(newImageObject)
	
	total_time = total_time or 500
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local ani = aniFactory:CreateAnimation("PosChangeAnimation")
	ani:SetTotalTime(total_time)
	ani:SetTotalTime(GetSettingAniTime(ani, key))
	ani:SetKeyFrameRect(startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom)
	
	local handle = obj:GetHandle()
	local function onAniFinish(self,old,new)
		if new == 4 then
			obj:GetFather():RemoveChild(newImageObject)
			obj:SetVisible(true)
			obj:SetChildrenVisible(true)
			KKV.Animation[handle] = nil
			if fun then fun(obj) end
		end
		return true
	end
	
	ani:BindObj(newImageObject)
	local tree = obj:GetOwner()
	tree:AddAnimation(ani)
	ani:AttachListener(true,onAniFinish)
	KKV.Animation[handle] = ani
	ani:Resume()	
end

local function RunDlgAni(bkg, fun, bPopAni, total_time)
	KKV.Helper.Assert(bkg)
	if not bkg then
		return
	end
	KKV.Animation.StopAni(bkg)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")
	local aniName
	if bPopAni then
		aniName = "popdlg.animation"
	else
		aniName = "hidedlg.animation"
	end
	local popAniT = templateMananger:GetTemplate(aniName,"AnimationTemplate")
	if popAniT then
		local popAni = popAniT:CreateInstance()
		popAni:BindObj(bkg)
		if total_time ~= nil then
			popAni:SetTotalTime(total_time)
			popAni:SetTotalTime(GetSettingAniTime(popAni, "$ianimation_window"))
		end
		local tree = bkg:GetOwner()
		tree:AddAnimation(popAni)
		local handle = bkg:GetHandle()
		KKV.Animation[handle] = ani

		local function OnAniFinish(self,old,new)
			if new == 4 then
				if fun then fun(bkg) end
				KKV.Animation[handle] = nil
			end
			return true
		end
		popAni:AttachListener(true, OnAniFinish)
		popAni:Resume()
	end
end

function KKV.Animation.RunSeqFrameAni(obj, seqResID, fun, total_time, loop)
	KKV.Helper.Assert(obj)
	if not obj then
		return
	end
	if loop == nil then
		loop = true
	end
	if total_time == nil then
		total_time = 800
	end
	obj:SetVisible(true)
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local seqFramAni = aniFactory:CreateAnimation("SeqFrameAnimation")
	seqFramAni:SetLoop(loop)
	seqFramAni:SetResID(seqResID)
	seqFramAni:SetTotalTime(total_time)
	seqFramAni:BindImageObj(obj)
	local tree = obj:GetOwner()
	tree:AddAnimation(seqFramAni)
	local handle = obj:GetHandle()
	KKV.Animation[handle] = seqFramAni
	local function OnAniFinish(self, old, new)
		if new == 4 then
			if fun then fun(bkg) end
			--KKV.Animation[handle] = nil
		end
		return true
	end
	seqFramAni:AttachListener(true, OnAniFinish)
	seqFramAni:Resume()
end

function KKV.Animation.RunPopDlgAni(bkg, fun, total_time)
	RunDlgAni(bkg, fun, true, total_time)
end

function KKV.Animation.RunHideDlgAni(bkg, fun, total_time)
	RunDlgAni(bkg, fun, false, total_time)
end

function KKV.Animation.RunPosAni_Control(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time)
	RunPosAni(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, "$ianimation_control")
end

function KKV.Animation.RunPosAni_Tab(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time)
	RunPosAni(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, "$ianimation_tab")
end

function KKV.Animation.RunPosAni_Window(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time)
	RunPosAni(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, "$ianimation_window")
end
--自定义窗口动画
function KKV.Animation.RunPosAni_Custom_Window(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time)
	local templateMananger = XLGetObject("Xunlei.UIEngine.TemplateManager")	
	local tree = obj:GetOwner()
	local posVAniT = templateMananger:GetTemplate("kkv.tips.wndAni.V","AnimationTemplate")			
	local posVAni = posVAniT:CreateInstance()	
	posVAni:SetKeyFrameRect(startLeft,startTop,startRight,startBottom,endLeft,endTop, endRight, endBottom)						
	posVAni:BindObj(obj)
	posVAni:SetTotalTime(total_time or 500)
	posVAni:AttachListener(true,
		function(self,old,new)
			if new == 4 then
				fun()
			end
		end)
	tree:AddAnimation(posVAni)			
	posVAni:Resume()
end
--山寨窗口动画(用定时器)
local cookie = nil
function KKV.Animation.RunPosAni_Timer_Window(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time,frq,incx,incy)
	local TimerManager = XLGetObject("Xunlei.UIEngine.TimerManager")	
	local tree = obj:GetOwner()
	local wnd = tree:GetBindHostWnd()
	local hDistan = endLeft - startLeft
	local vDistan = endTop - startTop
	local ifrq = frq or 10      			-- 频率	
	local hnw = incx or 15      			-- 横向步宽	
	hnw = hDistan>0 and hnw or -hnw
	local hn = math.abs(hDistan/hnw) + 1 	-- 横向步数
	local vnw = incy or 20     				-- 纵向步宽
	vnw = vDistan>0 and vnw or -vnw	
	local vn = math.abs(vDistan/vnw) + 1 	-- 纵向步数	
	local count = 0
	local maxNW = hn > vn and hn or vn 
	
	-- XLMessageBox(tostring(hnw).." "..tostring(vnw).." "..tostring(vDistan))
	cookie = TimerManager:SetTimer(function()			
		count = count + 1
		if count > maxNW then 
			wnd:Move(endLeft,endTop,endRight,endBottom)		
			AsynCall(function()
				TimerManager:KillTimer(cookie)
				if fun then 
					fun()
				end
			end)
			
		else			
			local left,right,top,bottom 			
			left = startLeft
			right = startRight
			top = startTop
			bottom = startBottom 
			if count < hn then 
				-- x方向的变化
				-- left = startLeft + count*hnw
				--right = startRight + count*hnw
			end			
			if count < vn then 
				-- y方向的变化				
				top = startTop + count*vnw
				-- bottom = startBottom + count*vnw				
			end
			wnd:Move(left,top,right,bottom+1000)
		end
	end,ifrq)
	SetOnceTimer(function() 		
		AsynCall(function()
			--TimerManager:KillTimer(cookie)
		end)
	end,1000)
end
function KKV.Animation.RunPosAlphaAni(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, src_alpha, dest_alpha,fun, total_time,curve)
	local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")
	local owner = obj:GetOwner()	
	if src_alpha and dest_alpha then 		
		local alphaAni = aniFactory:CreateAnimation("AlphaChangeAnimation")
		alphaAni:SetTotalTime(total_time or 500)
		alphaAni:SetKeyFrameAlpha(src_alpha,dest_alpha)
		alphaAni:BindRenderObj(obj) 
		if curve then 
			alphaAni:BindCurveID(curve)
		end
		owner:AddAnimation(alphaAni)
		alphaAni:Resume()
	end

	local posAni = aniFactory:CreateAnimation("PosChangeAnimation")
	posAni:SetTotalTime(total_time or 500)
	posAni:SetKeyFrameRect(startLeft, startTop, startRight, startBottom,
	endLeft, endTop, endRight, endBottom)
	posAni:BindLayoutObj(obj)
	if curve then 
		posAni:BindCurveID(curve)
	end
	owner:AddAnimation(posAni)
	posAni:AttachListener(true,
		function(self,old,new)
			if new == 4 then 
				fun()
			end
		end)
	posAni:Resume()
end
function KKV.Animation.RunPosAniEx_Tab(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time)
	RunPosAniEx(obj, startLeft, startTop, startRight, startBottom, endLeft, endTop, endRight, endBottom, fun, total_time, "$ianimation_tab")
end

function KKV.Animation.RunAlphaAni_Control(obj, src_alpha, dest_alpha, fun, total_time)
	RunAlphaAni(obj, src_alpha, dest_alpha, fun, total_time, "$ianimation_control")
end

function KKV.Animation.RunAlphaAni_Tab(obj, src_alpha, dest_alpha, fun, total_time)
	RunAlphaAni(obj, src_alpha, dest_alpha, fun, total_time, "$ianimation_tab")
end

function KKV.Animation.RunAlphaAniEx_Control(obj, src_alpha, dest_alpha, fun, total_time)
	RunAlphaAniEx(obj, src_alpha, dest_alpha, fun, total_time, "$ianimation_control")
end

function KKV.Animation.RunAlphaAniEx_Tab(obj, src_alpha, dest_alpha, fun, total_time)
	RunAlphaAniEx(obj, src_alpha, dest_alpha, fun, total_time, "$ianimation_tab")
end

function KKV.Animation.RunAlphaAniEx_Window(obj, src_alpha, dest_alpha, fun, total_time)
	RunAlphaAniEx(obj, src_alpha, dest_alpha, fun, total_time, "$ianimation_window")
end