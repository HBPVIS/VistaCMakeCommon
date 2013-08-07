# $Id: FindVLeapSDK.cmake 31553 2012-08-13 13:21:14Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VLeapSDK_FOUND )
	vista_find_package_root( LeapSDK include/Leap.h )

	if( LEAPSDK_ROOT_DIR )
		set( LEAPSDK_INCLUDE_DIRS "${LEAPSDK_ROOT_DIR}/include" )
		if( VISTA_64BIT )
			set( LEAPSDK_LIBRARY_DIRS "${LEAPSDK_ROOT_DIR}/lib/x64" )
		else()
			set( LEAPSDK_LIBRARY_DIRS "${LEAPSDK_ROOT_DIR}/lib/x86" )
		endif()
		if( WIN32 )			
			set( LEAPSDK_LIBRARIES optimized Leap debug Leapd )
		else()
			set( LEAPSDK_LIBRARIES Leap )
		endif()
	endif()
endif()

find_package_handle_standard_args( VLeapSDK "LeapSDK could not be found" LEAPSDK_ROOT_DIR LEAPSDK_LIBRARIES )

