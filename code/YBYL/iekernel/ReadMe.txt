========================================================================
    ACTIVE TEMPLATE LIBRARY : iekernel Project Overview
========================================================================

AppWizard has created this iekernel project for you to use as the starting point for
writing your Dynamic Link Library (DLL).

This file contains a summary of what you will find in each of the files that
make up your project.

iekernel.vcproj
    This is the main project file for VC++ projects generated using an Application Wizard.
    It contains information about the version of Visual C++ that generated the file, and
    information about the platforms, configurations, and project features selected with the
    Application Wizard.

iekernel.idl
    This file contains the IDL definitions of the type library, the interfaces
    and co-classes defined in your project.
    This file will be processed by the MIDL compiler to generate:
        C++ interface definitions and GUID declarations (iekernel.h)
        GUID definitions                                (iekernel_i.c)
        A type library                                  (iekernel.tlb)
        Marshaling code                                 (iekernel_p.c and dlldata.c)

iekernel.h
    This file contains the C++ interface definitions and GUID declarations of the
    items defined in iekernel.idl. It will be regenerated by MIDL during compilation.

iekernel.cpp
    This file contains the object map and the implementation of your DLL's exports.

iekernel.rc
    This is a listing of all of the Microsoft Windows resources that the
    program uses.

iekernel.def
    This module-definition file provides the linker with information about the exports
    required by your DLL. It contains exports for:
        DllGetClassObject
        DllCanUnloadNow
        DllRegisterServer
        DllUnregisterServer

/////////////////////////////////////////////////////////////////////////////
Other standard files:

StdAfx.h, StdAfx.cpp
    These files are used to build a precompiled header (PCH) file
    named iekernel.pch and a precompiled types file named StdAfx.obj.

Resource.h
    This is the standard header file that defines resource IDs.


/////////////////////////////////////////////////////////////////////////////
