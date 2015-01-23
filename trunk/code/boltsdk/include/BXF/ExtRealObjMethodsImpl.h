/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   ExtRealObjMethodsImpl
*   Author      :   ������
*   Create      :   2013-5-22 11:08
*   LastChange  :   2013-5-22 11:08
*   History     :	
*
*   Description :   ��չԪ�����RealObj���¼�������
*
********************************************************************/ 
#ifndef __EXTREALOBJMETHODSIMPL_H__
#define __EXTREALOBJMETHODSIMPL_H__

#include "./ExtLayoutObjMethodsImpl.h"

namespace Xunlei
{
namespace Bolt
{

class ExtRealObjMethodsImpl
	: public ExtLayoutObjMethodsImpl
{
public:
	typedef ExtRealObjMethodsImpl this_class;
	typedef ExtLayoutObjMethodsImpl base_class;

public:

	ExtRealObjMethodsImpl(XLUE_LAYOUTOBJ_HANDLE hObj)
		:ExtLayoutObjMethodsImpl(hObj)
	{
	}

	virtual ~ExtRealObjMethodsImpl()
	{
	}

	template<typename FinalClass>
	static void FillCStruct(ExtRealObjMethods* lpExtMethods)
	{
		assert(lpExtMethods);

		lpExtMethods->size = sizeof(ExtRealObjMethods);
		lpExtMethods->userData = NULL;

		base_class::FillCVector<FinalClass>(&lpExtMethods->layoutObjMethodVector);
		FillCVector<FinalClass>(&lpExtMethods->realObjMethodVector);
	}

	template<typename FinalClass>
	static void FillCVector(ExtRealObjMethodsVector* lpExtMethodsVector)
	{
		assert(lpExtMethodsVector);
		
		typedef FinalClass final_class;
		lpExtMethodsVector->size = sizeof(ExtRealObjMethodsVector);

		AssignIfOverride(this_class, final_class, OnCreateRealWindow, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnSetRealFocus, lpExtMethodsVector);
		AssignIfOverride(this_class, final_class, OnGetRenderWindow, lpExtMethodsVector);
	}

public:

	// Real����Ԫ������¼���ָʾ�������Ѿ�����/��Ҫ���٣��ⲿ��չ������Ҫ��������洴��/�����Լ���ϵͳ���ڣ�
	// ������XLUE_SetRealObjectWindow���õ�����RealObject�ϻ����Ƴ�
	virtual void OnCreateRealWindow(BOOL /*bCreate*/, OS_HOSTWND_HANDLE /*hWnd*/)
	{

	}

	// Real����Ԫ������¼���ָʾ���ý��㵽�Լ���ϵͳ������,�������Ƴ�����
	virtual void OnSetRealFocus(BOOL /*focus*/)
	{

	}

	// Real����Ԫ������¼�����ȡ��ǰ������ʾ���������ھ��
	virtual OS_HOSTWND_HANDLE OnGetRenderWindow()
	{
		assert(false);
		return NULL;
	}

protected:

	static this_class* ThisFromObjHandle(void* objHandle)
	{
		assert(objHandle);

		base_class* lpBase = base_class::ThisFromObjHandle(objHandle);

		return dynamic_cast<this_class*>(lpBase);
	}

private:

	static void XLUE_STDCALL OnCreateRealWindowCallBack(void* /*userData*/, void* objHandle, BOOL bCreate, OS_HOSTWND_HANDLE hWnd)
	{
		return ThisFromObjHandle(objHandle)->OnCreateRealWindow(bCreate, hWnd);
	}

	static void XLUE_STDCALL OnSetRealFocusCallBack(void* /*userData*/, void* objHandle, BOOL focus)
	{
		return ThisFromObjHandle(objHandle)->OnSetRealFocus(focus);
	}

	static OS_HOSTWND_HANDLE XLUE_STDCALL OnGetRenderWindowCallBack(void* /*userData*/, void* objHandle)
	{
		return ThisFromObjHandle(objHandle)->OnGetRenderWindow();
	}
};

} // Bolt
} // Xunlei

#endif // __EXTREALOBJMETHODSIMPL_H__