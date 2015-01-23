/********************************************************************
*
* =-----------------------------------------------------------------=
* =                                                                 =
* =             Copyright (c) Xunlei, Ltd. 2004-2013              =
* =                                                                 =
* =-----------------------------------------------------------------=
* 
*   FileName    :   ExtObjRegisterHelper
*   Author      :   ������
*   Create      :   2013-5-23 2:33
*   LastChange  :   2013-5-23 2:33
*   History     :	
*
*   Description :   ��չԪ�����ע�Ḩ����
*
********************************************************************/ 
#ifndef __EXTOBJREGISTERHELPER_H__
#define __EXTOBJREGISTERHELPER_H__

namespace Xunlei
{
namespace Bolt
{

struct NullClass
{
	int dummy[2];
};

// ÿ����չ��𶼶�Ӧһ��ʵ���ĸ������ע�Ḩ����
template<typename CStruct, typename SingletonClass>
struct SingletonStructFiller
{
	SingletonStructFiller()
	{
		::memset(&m_instance, 0, sizeof(m_instance));

		// ����new�����Ķ��󲻿�ɾ����ÿ����չ����һ��ע�ᣬ���������������ڶ���Ҫ
		SingletonClass* lpInstance = new SingletonClass();
		lpInstance->FillCStruct<SingletonClass>(&m_instance);
	}

	operator CStruct* ()
	{
		return &m_instance;
	}

private:

	CStruct m_instance;
};

template<typename CStruct>
struct SingletonStructFiller<CStruct, NullClass>
{
	operator CStruct* ()
	{
		return NULL;
	}
};

// ÿ����չ���󶼶�Ӧһ��ʵ���ĸ������ע�Ḩ����
template<typename CStruct, typename ObjectClass>
struct ObjectStructFiller
{
	ObjectStructFiller()
	{
		::memset(&m_instance, 0, sizeof(m_instance));

		ObjectClass::FillCStruct<ObjectClass>(&m_instance);
	}

	operator CStruct* ()
	{
		return &m_instance;
	}

private:

	CStruct m_instance;
};

template<typename CStruct>
struct ObjectStructFiller<CStruct, NullClass>
{
	operator CStruct* ()
	{
		return NULL;
	}
};

template<ExtObjType type>
struct ExtObjMethodsSelector;

#define EXTOBJMETHODS_SELECTOR(type, method) \
	template<> \
	struct ExtObjMethodsSelector<type> \
	{ \
		typedef method result; \
	};

EXTOBJMETHODS_SELECTOR(ExtObjType_layoutObj, ExtLayoutObjMethods);
EXTOBJMETHODS_SELECTOR(ExtObjType_renderableObj, ExtLayoutObjMethods);
EXTOBJMETHODS_SELECTOR(ExtObjType_imageObj, ExtImageObjMethods);
EXTOBJMETHODS_SELECTOR(ExtObjType_realObj, ExtRealObjMethods);

template<typename ObjectClass, ExtObjType type>
struct MethodsStructFiller
{
	typedef typename ExtObjMethodsSelector<type>::result method_type;

	MethodsStructFiller()
	{
		::memset(&methods, 0, sizeof(methods));

		ObjectClass::FillCStruct<ObjectClass>(&methods);
	}

	operator method_type* ()
	{
		return &methods;
	}

private:

	method_type methods;
};

template<ExtObjType type>
struct MethodsStructFiller<NullClass, type>
{
	typedef typename ExtObjMethodsSelector<type>::result method_type;

	operator method_type* ()
	{
		return NULL;
	}
};

// ��ȫʹ��BOLT��չ��ܸ����������ʹ�õ���չԪ����ע�Ḩ���࣬���ĳ����û��ʵ�֣���NullClass����
template<ExtObjType type, typename ObjectClass, typename CreatorClass, 
typename ParserClass = NullClass, typename LuaHostClass = NullClass,
typename EventClass = NullClass>
struct ExtObjRegisterHelper
{
	static bool Register(const char* className, unsigned long attribute)
	{
		assert(className);

		ExtObjRegisterInfo registerInfo = { sizeof(registerInfo) };
		registerInfo.type = type;
		registerInfo.className = className;
		registerInfo.attribute = attribute;

		MethodsStructFiller<ObjectClass, type> methods;
		registerInfo.lpExtObjMethods = methods;

		SingletonStructFiller<ExtObjCreator, CreatorClass> creator;
		registerInfo.lpExtObjCreator = creator;

		SingletonStructFiller<ExtObjParser, ParserClass> parser;
		registerInfo.lpExtObjParser = parser;	

		SingletonStructFiller<ExtObjLuaHost, LuaHostClass> luaHost;
		registerInfo.lpExtObjLuaHost = luaHost;	

		ObjectStructFiller<ExtObjEvent, EventClass> event;
		registerInfo.lpExtObjEvent = event;

		return !!XLUE_RegisterExtObj(&registerInfo);
	}
};

} // Bolt
} // Xunlei

#endif // __EXTOBJREGISTERHELPER_H__