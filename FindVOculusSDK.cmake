# $Id: FindVOculusSDK.cmake 31553 2012-08-13 13:21:14Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOCULUSSDK_FOUND )
	vista_find_package_root( OculusSDK LibOVR/include/OVR.h )

	if( OCULUSSDK_ROOT_DIR )
		set( OCULUSSDK_INCLUDE_DIRS "${OCULUSSDK_ROOT_DIR}/LibOVR/Include" )
		if( WIN32 )
			if( VISTA_64BIT )
				set( OCULUSSDK_LIBRARY_DIRS "${OCULUSSDK_ROOT_DIR}/LibOVR/Lib/x64" )
				set( OCULUSSDK_LIBRARIES optimized libovr64 debug libovr64d )
			else()
				set( OCULUSSDK_LIBRARY_DIRS "${OCULUSSDK_ROOT_DIR}/LibOVR/Lib/Win32" )
				set( OCULUSSDK_LIBRARIES optimized libovr debug libovrd )
			endif()
		else()
			if( VISTA_64BIT )
				set( OCULUSSDK_LIBRARY_DIRS "${OCULUSSDK_ROOT_DIR}/LibOVR/Lib/Linux/Release/x86_64" )
			else()
				set( OCULUSSDK_LIBRARY_DIRS "${OCULUSSDK_ROOT_DIR}/LibOVR/Lib/Linux/Release/i386" )
			endif()
			set( OCULUSSDK_LIBRARIES ovr )
		endif()
	endif()
endif()

find_package_handle_standard_args( VOculusSDK "OculusSDK could not be found" OCULUSSDK_ROOT_DIR OCULUSSDK_LIBRARIES )

