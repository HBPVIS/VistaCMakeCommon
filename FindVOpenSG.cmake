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
	endif( OPENSG_ROOT_DIR )

endif( NOT VOPENSG_FOUND )

find_package_handle_standard_args( VOpenSG "OpenSG could not be found" OPENSG_ROOT_DIR )



