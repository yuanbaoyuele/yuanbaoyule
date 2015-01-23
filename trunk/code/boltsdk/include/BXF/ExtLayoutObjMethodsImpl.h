/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   ExtLayoutObjMethodsImpl
*   Author      :   ������
*   Create      :   2013-5-18 23:52
*   LastChange  :   2013-5-18 23:52
*   History     :	
*
*   Description :   ��չԪ�����LayoutObj���¼�������
*
********************************************************************/ 
#ifndef __EXTLAYOUTOBJMETHODSIMPL_H__
#define __EXTLAYOUTOBJMETHODSIMPL_H__

#include <XLUE.h>
#include <assert.h>
#include "./ExtObjDefine.h"
#include "./LayoutObjectWrapper.h"

namespace Xunlei
{
namespace Bolt
{

class ExtLayoutObjMethodsImpl
	: public LayoutObjectBaseWrapper
{
public:
	typedef ExtLayoutObjMethodsImpl this_class;
	typedef LayoutObjectBaseWrapper base_class;

public:

	ExtLayoutObjMethodsImpl(XLUE_LAYOUTOBJ_HANDLE hObj)
	{
		m_hObj = hObj;
		assert(m_hObj);
	}

	virtual ~ExtLayoutObjMethodsImpl()
	{
		assert(m_hObj);
		//assert(XLUE_IsObjValid(m_hObj));
		m_hObj = NULL;
	}

	// ��ȡ��ǰ��չ������ⲿhandle
	void* GetObjectExtHandle()
	{
		return this;
	}

	XLUE_LAYOUTOBJ_HANDLE GetObjectHandle() const
	{
		return m_hObj;
	}

	// �ӵ�ǰ�����exthandle��ȡ��Ӧ�Ķ����࣬����MagicObject
	template<typename TargetClass>
	static TargetClass* ObjectFromExtHandle(void* objHandle)
	{
		this_class* lpBase = (this_class*)objHandle;
		return dynamic_cast<TargetClass*>(lpBase);
	}

	template<typename FinalClass>
	static void FillCStruct(ExtLayoutObjMethods* lpExtMethods)
	{
		assert(lpExtMethods);

		lpExtMethods->size = sizeof(ExtLayoutObjMethods);
		lpExtMethods->userData = NULL;

		FillCVector<FinalClass>(&lpExtMethods->layoutObjMethods);
	}

	template<typename FinalClass>
	static void FillCVector(ExtLayoutObjMethodsVector* lpExtMethodsVector)
	{
		assert(lpExtMethodsVector);
		
		typedef FinalClass final_class;
		lpExtMethodsVector->size = sizeof(ExtLayoutObjMethodsVector);

		AssignIfOverride(this_class, final_class, IsRenderable, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnBind, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnInitControl, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnDestroy, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnHitTest, lpExtMethodsVector);

		AssignIfOverride(this_class, final_class, OnCtrlHitTest, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, GetCursorID, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, GetCaretLimitRect, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnGetWantKey, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnQueryFocus, lpExtMethodsVector);

		AssignIfOverride(this_class, final_class, OnSetFocus, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnSetControlFocus, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnControlMouseEnter, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnControlMouseLeave, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnControlMouseWheel, lpExtMethodsVector);
		
		AssignIfOverride(this_class, final_class, OnStyleUpdate, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnPaint, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnPaintEx, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnPosChanged, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnAbsPosChanged, lpExtMethodsVector);

		AssignIfOverride(this_class, final_class, OnFatherAbsPosChanged, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnVisibleChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnEnableChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnCaptureChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnZOrderChange, lpExtMethodsVector);

		AssignIfOverride(this_class, final_class, OnAlphaChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnCursorIDChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnResProviderChange, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnBindLayerChange, lpExtMethodsVector);

		bool ret = false;
		IsFunctionOverride(this_class, final_class, OnDragQuery, ret);
		IsFunctionOverride(this_class, final_class, OnDragEnter, ret);
		IsFunctionOverride(this_class, final_class, OnDragOver, ret);
		IsFunctionOverride(this_class, final_class, OnDragLeave, ret);
		IsFunctionOverride(this_class, final_class, OnDrop, ret);
		if (ret)
		{
			lpExtMethodsVector->lpfnOnDragEvent = OnDragEventCallBack;
		}

		AssignIfOverride(this_class, final_class, CanHandleInput, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, PreInputFilter, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, PostInputFilter, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnBindHostWnd, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnCreateHostWnd, lpExtMethodsVector);
	}

public:

	// Ԫ�����Ƿ����Ⱦ
	virtual bool IsRenderable()
	{
		return false;
	}

	// Ԫ����󶨵��������ϵ��¼������Ƽ�ʹ��
	virtual void OnBind()
	{

	}

	// Ԫ�����ʼ���¼���������д��һЩ��ʼ������
	virtual void OnInitControl()
	{

	}

	// Ԫ���������¼���������д��һЩ������
	virtual void OnDestroy()
	{

	}

	// Ԫ��������в����¼�������ȷ��һ�����Ƿ����ڶ���������
	// Ĭ��ʵ��ֻ����visible��alpha��pos��limitrect�ĸ����أ���д�˷������Ը��ǵ�Ĭ��ʵ��
	virtual bool OnHitTest(short x, short y)
	{
		return !!XLUE_ObjHitTest(m_hObj, x, y);
	}

	// Ԫ�����control���в��ԣ�һ��ֻ�п��ƶ�����Ҫ��Ӧ�÷���
	virtual bool OnCtrlHitTest(short /*x*/, short /*y*/, CtrlTestType& /*type*/)
	{
		return false;
	}


	virtual const char* GetCursorID(long /*x*/, long /*y*/, unsigned long /*wParam*/, unsigned long /*lParam*/)
	{
		return NULL;
	}

	// ��ȡ��ǰ����Թ����������򣬻��ڶ���������ϵ�������������²���Ҫ��д�ú���
	virtual void GetCaretLimitRect(RECT* lpLimitRect)
	{
		XLUE_GetObjCaretLimitRect(m_hObj, lpLimitRect);
	}

	// �ж϶���������Ҫ������Щ��������Ҫ������������tab��
	virtual int OnGetWantKey()
	{
		return ObjWantKey_None;
	}

	// �ж϶����Ƿ���Ҫ���ñ�������,����0��ʾ����Ҫ����0��ʾ����Ҫ
	virtual int OnQueryFocus()
	{
		return XLUE_QueryObjFocus(m_hObj);
	}

	// ����Ľ���״�������ı�
	virtual void OnSetFocus(BOOL /*bFocus*/, XLUE_LAYOUTOBJ_HANDLE /*hOppositeObj*/, FocusReason /*reason*/)
	{

	}

	// ����Ŀؼ�����״̬�����ı�
	virtual void OnSetControlFocus(BOOL /*bFocus*/,XLUE_LAYOUTOBJ_HANDLE /*hOppositeObj*/, FocusReason /*reason*/)
	{

	}

	// ����Ŀؼ�����¼�������enter/leave/wheel��
	virtual void OnControlMouseEnter(short /*x*/, short /*y*/, unsigned long /*flags*/)
	{

	}

	virtual void OnControlMouseLeave(short /*x*/, short /*y*/, unsigned long /*flags*/)
	{

	}

	virtual void OnControlMouseWheel(short /*x*/, short /*y*/, unsigned long /*flags*/)
	{

	}

	// �����style�����仯��ֻ��control��Ч
	virtual void OnStyleUpdate()
	{

	}

	// �������������Ļ��ƺ�����OnPaint���Բ�����mask�Ļ��ƣ�OnPaintEx�ǹ���mask�Ļ��ƣ�ʹ������������Щ
	// �ڶ�����OnPaintEx������£�����ʹ�øú���

	// ���ƶ����lpSrcClipRect����Ŀ��λͼ��Ŀ��λͼ�Ĵ�С��lpSrcClipRect��Сһ��
	// lpSrcClipRect�ǻ���Ԫ��������ϵ�ģ�Ҳ������ڸö�������Ͻ�λ��
	// hBitmapDest�п���Clip��������λͼ�������ڴ治һ���������ģ���ȡĳһ�е�buffer����ʹ��XL_GetBitmapBuffer
	virtual void OnPaint(XL_BITMAP_HANDLE /*hBitmapDest*/, const RECT* /*lpDestClipRect*/, const RECT* /*lpSrcClipRect*/, unsigned char /*alpha*/)
	{

	}

	virtual void OnPaintEx(XL_BITMAP_HANDLE /*hBitmapDest*/, const RECT* /*lpDestClipRect*/, const RECT* /*lpSrcClipRect*/, unsigned char /*alpha*/, XLGraphicHint* /*lpHint*/)
	{

	}

	// �����λ�øı��¼������ڶ�����������ϵ
	virtual void OnPosChanged(const RECT* /*lpOldPos*/, const RECT* /*lpNewPos*/)
	{

	}

	// ����ľ���λ�øı��¼������ڶ���������ϵ��ֻ�б��󶨵�UIObjectTree����¼��Żᱻ����
	virtual void OnAbsPosChanged(const RECT* /*lpOldAbsPos*/, const RECT* /*lpNewAbsPos*/)
	{

	}

	// �����ֱ�ӻ��߼�Ӹ�����ľ���λ�÷����ı䣬 ����Ӷ��������������limitrect�������ô��Ҫ��Ӧ���¼�������
	virtual void OnFatherAbsPosChanged()
	{

	}

	// ����Ŀɼ�״̬�����ı�
	virtual void OnVisibleChange(BOOL /*bVisible*/)
	{

	}

	// �����enable״̬�����ı�
	virtual void OnEnableChange(BOOL /*bEnable*/)
	{

	}

	// �����capture״̬�����ı�
	virtual void OnCaptureChange(BOOL /*bCapture*/)
	{

	}

	// �����zorder�����ı�
	virtual void OnZOrderChange()
	{

	}

	// �����alpha�����ı�
	virtual void OnAlphaChange(unsigned char /*newAlpha*/, unsigned char /*oldAlpha*/)
	{

	}

	// �����cursor�����ı�
	virtual void OnCursorIDChange()
	{

	}

	// �����resprovider�����ı�
	virtual void OnResProviderChange(XLUE_RESPROVIDER_HANDLE /*hResProvider*/)
	{

	}
	
	// ����󶨵�layer�����ı�
	virtual void OnBindLayerChange(XLUE_LAYOUTOBJ_HANDLE /*hNewLayerObject*/, XLUE_LAYOUTOBJ_HANDLE /*hOldLayerObj*/)
	{

	}

	// Ԫ�����drop����¼�
	virtual bool OnDragQuery(void* /*pDataObj*/, DWORD /*grfKeyState*/, POINT /*pt*/, unsigned long* /*lpEffect*/)
	{
		return false;
	}

	virtual bool OnDragEnter(void* /*pDataObj*/, DWORD /*grfKeyState*/, POINT /*pt*/, unsigned long* /*lpEffect*/)
	{
		return false;
	}

	virtual bool OnDragOver(void* /*pDataObj*/, DWORD /*grfKeyState*/, POINT /*pt*/, unsigned long* /*lpEffect*/)
	{
		return false;
	}

	virtual bool OnDragLeave()
	{
		return false;
	}

	virtual bool OnDrop(void* /*pDataObj*/, DWORD /*grfKeyState*/, POINT /*pt*/, unsigned long* /*lpEffect*/)
	{
		return false;
	}

	// �����Ƿ���Ҫ���ͼ��������¼���Ĭ��ֻҪ��д��PreInputFilter��PostInputFilter������������Ҫ
	// ���������д�˸÷������м��ٵ��û����CanHandleInput����
	virtual bool CanHandleInput()
	{
		assert(false);
		return false;
	}

	// ǰ���¼������������Դ������ͼ����¼������¼�·�ɵ��ʼ���ã�handled=true�������¼�·�ɵĺ�������
	virtual long PreInputFilter(unsigned long /*actionType*/, unsigned long /*wParam*/, unsigned long /*lParam*/, BOOL* lpHandled)
	{
		assert(lpHandled);
		*lpHandled = FALSE;

		return 0;
	}

	// �����¼������������¼�·�ɵ����ʵ�ʵ���
	virtual long PostInputFilter(unsigned long /*actionType*/, unsigned long /*wParam*/, unsigned long /*lParam*/, BOOL* lpHandled)
	{
		assert(lpHandled);
		*lpHandled = FALSE;

		return 0;
	}

	// Ԫ�������ڵĶ������󶨵�hostwnd�ʹ�hostwnd�����¼�
	virtual void OnBindHostWnd(XLUE_OBJTREE_HANDLE /*hTree*/, XLUE_HOSTWND_HANDLE /*hHostWnd*/, BOOL /*bBind*/)
	{

	}

	// Ԫ�������ڵĶ�������hostwnd�Ĵ����������¼�
	virtual void OnCreateHostWnd(XLUE_OBJTREE_HANDLE /*hTree*/, XLUE_HOSTWND_HANDLE /*hHostWnd*/, BOOL /*bCreate*/)
	{

	}

protected:

	static this_class* ThisFromObjHandle(void* objHandle)
	{
		assert(objHandle);

		return (this_class*)objHandle;
	}

private:

	// �ڴ˷�װ��ϵ�£�ʹ��ʵ����ص�objHandle������userData
	static BOOL XLUE_STDCALL IsRenderableCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->IsRenderable()? TRUE : FALSE;
	}

	static void XLUE_STDCALL OnBindCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnBind();
	}

	static void XLUE_STDCALL OnInitControlCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnInitControl();
	}

	static void XLUE_STDCALL OnDestroyCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnDestroy();
	}

	static BOOL XLUE_STDCALL OnHitTestCallBack(void* /*userData*/, void* objHandle, short x, short y)
	{
		return ThisFromObjHandle(objHandle)->OnHitTest(x, y)? TRUE : FALSE;
	}

	static BOOL XLUE_STDCALL OnCtrlHitTestCallBack(void* /*userData*/, void* objHandle, short x, short y, CtrlTestType& type)
	{
		return ThisFromObjHandle(objHandle)->OnCtrlHitTest(x, y, type)? TRUE : FALSE;
	}

	static const char* XLUE_STDCALL GetCursorIDCallBack(void* /*userData*/, void* objHandle, long x, long y, unsigned long wParam, unsigned long lParam)
	{
		return ThisFromObjHandle(objHandle)->GetCursorID(x, y, wParam, lParam);
	}

	static void XLUE_STDCALL GetCaretLimitRectCallBack(void* /*userData*/, void* objHandle, RECT* lpLimitRect)
	{
		return ThisFromObjHandle(objHandle)->GetCaretLimitRect(lpLimitRect);
	}

	static int XLUE_STDCALL OnGetWantKeyCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnGetWantKey();
	}

	static int XLUE_STDCALL OnQueryFocusCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnQueryFocus();
	}

	static void XLUE_STDCALL OnSetFocusCallBack(void* /*userData*/, void* objHandle, BOOL bFocus, XLUE_LAYOUTOBJ_HANDLE hOppositeObj, FocusReason reason)
	{
		return ThisFromObjHandle(objHandle)->OnSetFocus(bFocus, hOppositeObj, reason);
	}

	static void XLUE_STDCALL OnSetControlFocusCallBack(void* /*userData*/, void* objHandle, BOOL bFocus,XLUE_LAYOUTOBJ_HANDLE hOppositeObj, FocusReason reason)
	{
		return ThisFromObjHandle(objHandle)->OnSetControlFocus(bFocus, hOppositeObj, reason);
	}

	static void XLUE_STDCALL OnControlMouseEnterCallBack(void* /*userData*/, void* objHandle, short x, short y, unsigned long flags)
	{
		return ThisFromObjHandle(objHandle)->OnControlMouseEnter(x, y, flags);
	}

	static void XLUE_STDCALL OnControlMouseLeaveCallBack(void* /*userData*/, void* objHandle, short x, short y, unsigned long flags)
	{
		return ThisFromObjHandle(objHandle)->OnControlMouseLeave(x, y, flags);
	}

	static void XLUE_STDCALL OnControlMouseWheelCallBack(void* /*userData*/, void* objHandle, short x, short y, unsigned long flags)
	{
		return ThisFromObjHandle(objHandle)->OnControlMouseWheel(x, y, flags);
	}

	// �����style�����仯��ֻ��control��Ч
	static void XLUE_STDCALL OnStyleUpdateCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnStyleUpdate();
	}

	static void XLUE_STDCALL OnPaintCallBack(void* /*userData*/, void* objHandle, XL_BITMAP_HANDLE hBitmapDest, const RECT* lpDestClipRect, const RECT* lpSrcClipRect, unsigned char alpha)
	{
		return ThisFromObjHandle(objHandle)->OnPaint(hBitmapDest, lpDestClipRect, lpSrcClipRect, alpha);
	}

	static void XLUE_STDCALL OnPaintExCallBack(void* /*userData*/, void* objHandle, XL_BITMAP_HANDLE hBitmapDest, const RECT* lpDestClipRect, const RECT* lpSrcClipRect, unsigned char alpha, XLGraphicHint* lpHint)
	{
		return ThisFromObjHandle(objHandle)->OnPaintEx(hBitmapDest, lpDestClipRect, lpSrcClipRect, alpha, lpHint);
	}

	static void XLUE_STDCALL OnPosChangedCallBack(void* /*userData*/, void* objHandle, const RECT* lpOldPos, const RECT* lpNewPos)
	{
		return ThisFromObjHandle(objHandle)->OnPosChanged(lpOldPos, lpNewPos);
	}

	static void XLUE_STDCALL OnAbsPosChangedCallBack(void* /*userData*/, void* objHandle, const RECT* lpOldAbsPos, const RECT* lpNewAbsPos)
	{
		return ThisFromObjHandle(objHandle)->OnAbsPosChanged(lpOldAbsPos, lpNewAbsPos);
	}

	static void XLUE_STDCALL OnFatherAbsPosChangedCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnFatherAbsPosChanged();
	}

	static void XLUE_STDCALL OnVisibleChangeCallBack(void* /*userData*/, void* objHandle, BOOL bVisible)
	{
		return ThisFromObjHandle(objHandle)->OnVisibleChange(bVisible);
	}

	static void XLUE_STDCALL OnEnableChangeCallBack(void* /*userData*/, void* objHandle, BOOL bEnable)
	{
		return ThisFromObjHandle(objHandle)->OnEnableChange(bEnable);
	}

	static void XLUE_STDCALL OnCaptureChangeCallBack(void* /*userData*/, void* objHandle, BOOL bCapture)
	{
		return ThisFromObjHandle(objHandle)->OnCaptureChange(bCapture);
	}	

	static void XLUE_STDCALL OnZOrderChangeCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnZOrderChange();
	}

	static void XLUE_STDCALL OnAlphaChangeCallBack(void* /*userData*/, void* objHandle, unsigned char newAlpha, unsigned char oldAlpha)
	{
		return ThisFromObjHandle(objHandle)->OnAlphaChange(newAlpha, oldAlpha);
	}

	static void XLUE_STDCALL OnCursorIDChangeCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnCursorIDChange();
	}

	static void XLUE_STDCALL OnResProviderChangeCallBack(void* /*userData*/, void* objHandle, XLUE_RESPROVIDER_HANDLE hResProvider)
	{
		return ThisFromObjHandle(objHandle)->OnResProviderChange(hResProvider);
	}

	static void XLUE_STDCALL OnBindLayerChangeCallBack(void* /*userData*/, void* objHandle, XLUE_LAYOUTOBJ_HANDLE hNewLayerObject, XLUE_LAYOUTOBJ_HANDLE hOldLayerObject)
	{
		return ThisFromObjHandle(objHandle)->OnBindLayerChange(hNewLayerObject, hOldLayerObject);
	}

	static BOOL XLUE_STDCALL OnDragEventCallBack(void* /*userData*/, void* objHandle, DragEventType type, void* lpDragDataObj, unsigned long grfKeyState, POINT pt, unsigned long* lpEffect)
	{
		this_class* lpThis = ThisFromObjHandle(objHandle);
		bool ret = false;

		if (type == DragEventType_query)
		{
			ret = lpThis->OnDragQuery(lpDragDataObj, grfKeyState, pt, lpEffect);
		}
		else if (type == DragEventType_enter)
		{
			ret = lpThis->OnDragEnter(lpDragDataObj, grfKeyState, pt, lpEffect);
		}
		else if (type == DragEventType_over)
		{
			ret = lpThis->OnDragOver(lpDragDataObj, grfKeyState, pt, lpEffect);
		}
		else if (type == DragEventType_leave)
		{
			ret = lpThis->OnDragLeave();
		}
		else if (type == DragEventType_drop)
		{
			ret = lpThis->OnDrop(lpDragDataObj, grfKeyState, pt, lpEffect);
		}
		else
		{
			assert(false);
		}

		return (ret? TRUE : FALSE);
	}

	static BOOL XLUE_STDCALL CanHandleInputCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->CanHandleInput()? TRUE : FALSE;
	}

	static long XLUE_STDCALL PreInputFilterCallBack(void* /*userData*/, void* objHandle, unsigned long actionType, unsigned long wParam, unsigned long lParam, BOOL* lpHandled)
	{
		return ThisFromObjHandle(objHandle)->PreInputFilter(actionType, wParam, lParam, lpHandled);
	}

	static long XLUE_STDCALL PostInputFilterCallBack(void* /*userData*/, void* objHandle, unsigned long actionType, unsigned long wParam, unsigned long lParam, BOOL* lpHandled)
	{
		return ThisFromObjHandle(objHandle)->PostInputFilter(actionType, wParam, lParam, lpHandled);
	}

	
	static void XLUE_STDCALL OnBindHostWndCallBack(void* /*userData*/, void* objHandle, XLUE_OBJTREE_HANDLE hTree, XLUE_HOSTWND_HANDLE hHostWnd, BOOL bBind)
	{
		return ThisFromObjHandle(objHandle)->OnBindHostWnd(hTree, hHostWnd, bBind);
	}

	static void XLUE_STDCALL OnCreateHostWndCallBack(void* /*userData*/, void* objHandle, XLUE_OBJTREE_HANDLE hTree, XLUE_HOSTWND_HANDLE hHostWnd, BOOL bCreate)
	{
		return ThisFromObjHandle(objHandle)->OnCreateHostWnd(hTree, hHostWnd, bCreate);
	}
};

} // Bolt
} // Xunlei

#endif // __EXTLAYOUTOBJMETHODSIMPL_H__