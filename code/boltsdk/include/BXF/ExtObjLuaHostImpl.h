/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   ExtObjLuaHostImpl
*   Author      :   ������
*   Create      :   2013-5-21 23:08
*   LastChange  :   2013-5-21 23:08
*   History     :	
*
*   Description :   BOLT��չ�����lua��װ������
*
********************************************************************/ 
#ifndef __EXTOBJLUAHOSTIMPL_H__
#define __EXTOBJLUAHOSTIMPL_H__

#include "./ExtLayoutObjMethodsImpl.h"

namespace Xunlei
{
namespace Bolt
{

// TΪ��չ����ObjectClass��lua��װ�࣬����MagicObject��lua��װ��LuaMagicObject
// ����T��Ҫʵ��GetLuaFunction�������淵����Ҫע���API
template<typename T, typename ObjectClass>
class ExtObjLuaHostImpl
{
public:

	typedef ExtObjLuaHostImpl this_class;
	typedef T derived_class;
	typedef ObjectClass obj_class;

public:

	// ��ʵ�������Ϊȫ��̬�࣬���Ǹ�ÿ����չ���lua��װ�ṩһ��ʵ�����ܻ����ã��������벻����������Ľ��
	ExtObjLuaHostImpl()
	{

	}

	virtual ~ExtObjLuaHostImpl()
	{

	}

	template<typename FinalClass>
	void FillCStruct(ExtObjLuaHost* lpExtLuaHost)
	{
		typedef FinalClass final_class;

		assert(lpExtLuaHost);

		lpExtLuaHost->size = sizeof(ExtObjLuaHost);
		lpExtLuaHost->userData = this;

		lpExtLuaHost->lpfnGetLuaFunctions = GetLuaFunctionsCallBack;
		AssignIfOverride(this_class, final_class, RegisterAuxClass, lpExtLuaHost);
	}

public:

	// �������ö���luaջ�ʹ�lua��ȡ����ĸ�������

	// ��luaջ��ȡԪ������
	static XLUE_LAYOUTOBJ_HANDLE CheckObject(lua_State* luaState, int index)
	{
		assert(luaState);
		return XLUE_CheckObject(luaState, index);
	}

	// ֱ�Ӵ�luaջ��ָ��λ�û�ȡ��չ�����࣬����MagicObject
	static obj_class* CheckExtObject(lua_State* luaState, int index)
	{
		XLUE_LAYOUTOBJ_HANDLE hObj = CheckObject(luaState, index);
		if (hObj == NULL)
		{
			return NULL;
		}

		void* lpExtObjHandle = XLUE_GetExtHandle(hObj);
		assert(lpExtObjHandle);
		if (lpExtObjHandle == NULL)
		{
			return NULL;
		}

		return ExtLayoutObjMethodsImpl::ObjectFromExtHandle<obj_class>(lpExtObjHandle);
	}

	template<typename TargetClass>
	static TargetClass* CheckExtObjectEx(lua_State* luaState, int index)
	{
		XLUE_LAYOUTOBJ_HANDLE hObj = CheckObject(luaState, index);
		if (hObj == NULL)
		{
			return NULL;
		}

		void* lpExtObjHandle = XLUE_GetExtHandle(hObj);
		assert(lpExtObjHandle);
		if (lpExtObjHandle == NULL)
		{
			return NULL;
		}

		return ExtLayoutObjMethodsImpl::ObjectFromExtHandle<TargetClass>(lpExtObjHandle);
	}

	// Push����MagicObject*�Ķ���ջ����ʧ�ܵĻ������һ��nil��ջ��
	static bool PushExtObject(lua_State* luaState, obj_class* lpExtObject)
	{
		assert(luaState);
		if (lpExtObject == NULL)
		{
			lua_pushnil(luaState);
			return false;
		}

		XLUE_LAYOUTOBJ_HANDLE hObj = lpExtObject->GetObjectHandle();
		assert(hObj);
		if (lpExtObject == NULL)
		{
			lua_pushnil(luaState);
			return false;
		}

		return !!XLUE_PushObject(luaState, hObj);
	}

	template<typename TargetClass>
	static bool PushExtObjectEx(lua_State* luaState, TargetClass* lpExtObject)
	{
		assert(luaState);
		if (lpExtObject == NULL)
		{
			lua_pushnil(luaState);
			return false;
		}

		XLUE_LAYOUTOBJ_HANDLE hObj = lpExtObject->GetObjectHandle();
		assert(hObj);
		if (lpExtObject == NULL)
		{
			lua_pushnil(luaState);
			return false;
		}

		return !!XLUE_PushObject(luaState, hObj);
	}

public:

	// ��ȡ����չԪ�������е�lua��չapi	
	virtual bool GetLuaFunction(const char* className, const XLLRTGlobalAPI** lplpLuaFunctions, size_t* lpFuncCount) = 0;

	// ע�����ĸ���lua�����ȫ�ֶ���
	virtual bool RegisterAuxClass(const char* /*className*/, XL_LRT_ENV_HANDLE /*hEnv*/)
	{
		return true;
	}

private:

	static this_class* ThisFromUserData(void* userData)
	{
		assert(userData);
		return (this_class*)userData;
	}

private:

	static BOOL XLUE_STDCALL GetLuaFunctionsCallBack(void* userData, const char* className, const XLLRTGlobalAPI** lplpLuaFunctions, size_t* lpFuncCount)
	{
		return ThisFromUserData(userData)->GetLuaFunction(className, lplpLuaFunctions, lpFuncCount)? TRUE : FALSE;
	}

	static BOOL XLUE_STDCALL RegisterAuxClassCallBack(void* userData, const char* className, XL_LRT_ENV_HANDLE hEnv)
	{
		return ThisFromUserData(userData)->RegisterAuxClass(className, hEnv)? TRUE : FALSE;
	}
};

// ExtObjLuaHostImpl����չʵ�֣�����ֱ�Ӵ������ȡAPI����
// ����T��Ҫ����static XLLRTGlobalAPI s_szLuaMemberFuncs[]���������������Ӧ��lua����
template<typename T, typename ObjectClass>
class ExtObjLuaHostImplEx
	: public ExtObjLuaHostImpl<T, ObjectClass>
{
public:
	ExtObjLuaHostImplEx()
	{

	}

	virtual ~ExtObjLuaHostImplEx()
	{

	}

public:

	// ExtObjLuaHostImpl
	virtual bool GetLuaFunction(const char* className, const XLLRTGlobalAPI** lplpLuaFunctions, size_t* lpFuncCount)
	{
		return DefaultGetLuaFunction(className, lplpLuaFunctions, lpFuncCount);
	}

private:

	bool DefaultGetLuaFunction(const char* /*className*/, const XLLRTGlobalAPI** lplpLuaFunctions, size_t* lpFuncCount)
	{
		assert(lplpLuaFunctions);
		assert(lpFuncCount);

		const XLLRTGlobalAPI* lpLuaFuncs = T::s_szLuaMemberFuncs;
		*lplpLuaFunctions = lpLuaFuncs;

		size_t count = 0;
		while(lpLuaFuncs->func != NULL && lpLuaFuncs->name != NULL)
		{
			++lpLuaFuncs;
			++count;
		}

		*lpFuncCount = count;

		return true;
	}
};

} // Bolt
} // Xunlei

#endif // __EXTOBJLUAHOSTIMPL_H__