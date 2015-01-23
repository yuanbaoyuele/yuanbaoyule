/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   ExtObjCreatorImpl
*   Author      :   ������
*   Create      :   2013-5-20 0:04
*   LastChange  :   2013-5-20 0:04
*   History     :	
*
*   Description :   �ⲿ��չ����Ĵ��������������࣬ÿ����չ���Ӧ�ö�Ӧһ��
*
********************************************************************/ 
#ifndef __EXTOBJCREATORIMPL_H__
#define __EXTOBJCREATORIMPL_H__

#include <XLUE.h>
#include <assert.h>
#include "./ExtObjDefine.h"

namespace Xunlei
{
namespace Bolt
{

template<typename ObjectClass>
class ExtObjCreatorImpl
{
public:

	typedef ExtObjCreatorImpl this_class;
	typedef ObjectClass obj_class;

public:
	ExtObjCreatorImpl()
	{

	}

	virtual ~ExtObjCreatorImpl()
	{

	}

	template<typename FinalClass>
	void FillCStruct(ExtObjCreator* lpExtCreator)
	{
		assert(lpExtCreator);

		lpExtCreator->size = sizeof(ExtObjCreator);
		lpExtCreator->userData = this;

		lpExtCreator->lpfnCreateObj = CreateObjCallBack;
		lpExtCreator->lpfnDestroyObj = DestroyObjCallBack;
	}

public:

	// ������չԪ������ⲿʵ��������ɹ��򷵻�һ��handle����Ψһ��ʶ
	virtual obj_class* CreateObj(const char* lpObjClass, XLUE_LAYOUTOBJ_HANDLE hObj) = 0;

	// ������չԪ������ⲿʵ����lpObjHandleΪ����ʱ�򷵻ص�handle
	virtual void DestroyObj(obj_class* lpObj) = 0;

private:

	static this_class* ThisFromUserData(void* userData)
	{
		assert(userData);
		return (this_class*)userData;
	}

private:
	
	static void* XLUE_STDCALL CreateObjCallBack(void* userData, const char* lpObjClass, XLUE_LAYOUTOBJ_HANDLE hObj)
	{
		obj_class* lpObj = ThisFromUserData(userData)->CreateObj(lpObjClass, hObj);

		return lpObj->GetObjectExtHandle();
	}

	
	static void XLUE_STDCALL DestroyObjCallBack(void* userData, void* objHandle)
	{
		obj_class* lpObj = ExtLayoutObjMethodsImpl::ObjectFromExtHandle<obj_class>(objHandle);
		assert(lpObj);

		return ThisFromUserData(userData)->DestroyObj(lpObj);
	}
};

} // Bolt
} // Xunlei

#endif // __EXTOBJCREATORIMPL_H__