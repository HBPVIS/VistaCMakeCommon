# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENSG_FOUND )
	vista_find_package_root( OpenSG include/OpenSG/OSGAction.h )

	if( OPENSG_ROOT_DIR )
		if( UNIX )
			set( OPENSG_LIBRARY_DIRS ${OPENSG_ROOT_DIR}/lib/opt )
			set( OPENSG_LIBRARIES
				OSGWindowGLUT
				OSGSystem
				OSGBase
			)
		elseif( WIN32 )
			set( OPENSG_LIBRARY_DIRS ${OPENSG_ROOT_DIR}/lib )
			set( OPENSG_LIBRARIES
				optimized OSGWindowGLUT
				optimized OSGSystem
				optimized OSGBase
				debug OSGWindowGLUTD
				debug OSGSystemD
				debug OSGBaseD
			)
		endif( UNIX )
		set( OPENSG_INCLUDE_DIRS ${OPENSG_ROOT_DIR}/include )
		set( OPENSG_DEFINITIONS -DOSG_WITH_GLUT -DOSG_WITH_GIF -DOSG_WITH_TIF -DOSG_WITH_JPG -DOSG_BUILD_DLL -D_OSG_HAVE_CONFIGURED_H_ )
		set( OPENSG_DEPENDENCIES package GLUT REQUIRED )
		
		if( UNIX )
		  string( REGEX MATCH ".*icpc" _IS_ICPC_COMPILER ${CMAKE_CXX_COMPILER} )
		  if( _IS_ICPC_COMPILER )
			set( OPENSG_DEFINITIONS ${OPENSG_DEFINITIONS} -DOSG_ICC_GNU_COMPAT )
		  endif( _IS_ICPC_COMPILER )
		endif( UNIX )		
		
		if( CMAKE_CXX_COMPILER )
			execute_process( COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE CXX_VERSION )
			if( CXX_VERSION VERSION_GREATER 4.4 )
				set( OPENSG_DISABLE_GCC_WARNINGS TRUE CACHE BOOL "If enabled, projects that use OpenSG will disable write-string and deprecated warnings globally, to suppress OpenSG's warning barrage" )
				if( OPENSG_DISABLE_GCC_WARNINGS )
					set( OPENSG_DEFINITIONS ${OPENSG_DEFINITIONS} -Wno-write-strings -Wno-deprecated )
				endif( OPENSG_DISABLE_GCC_WARNINGS )
			endif( CXX_VERSION VERSION_GREATER 4.4 )
		endif( CMAKE_CXX_COMPILER )
	endif( OPENSG_ROOT_DIR )

endif( NOT VOPENSG_FOUND )

find_package_handle_standard_args( VOpenSG "OpenSG could not be found" OPENSG_ROOT_DIR )
