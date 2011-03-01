include( FindPackageHandleStandardArgs )

if( NOT VOPENSG_FOUND )

	find_path( OPENSG_DIR include/OpenSG/OSGAction.h PATHS $ENV{OPENSG_ROOT}/${VISTA_HWARCH} $ENV{OPENSG_ROOT} CACHE PATH "OpenSG package directory" )

	if( OPENSG_DIR )
		set( OpenSG_FOUND "YES" )
		message( STATUS "Found OpenSG in ${OPENSG_DIR}" )

		if( UNIX )
			set( OPENSG_LIB_DIR ${OPENSG_DIR}/lib/opt )
		elseif( WIN32 )
			set( OPENSG_LIB_DIR ${OPENSG_DIR}/lib )
		endif( UNIX )
		set( OPENSG_INC_DIR ${OPENSG_DIR}/include )
		set( OPENSG_LIBRARIES
			optimized OSGWindowGLUT
			optimized OSGSystem
			optimized OSGBase
			debug OSGWindowGLUTD
			debug OSGSystemD
			debug OSGBaseD
		)
		set( OPENSG_DEFINTIONS -DOSG_WITH_GLUT -DOSG_WITH_GIF -DOSG_WITH_TIF -DOSG_WITH_JPG -DOSG_BUILD_DLL -D_OSG_HAVE_CONFIGURED_H_ )
	endif( OPENSG_DIR )
	
	macro( vista_use_OpenSG )
		include_directories( ${OPENSG_INC_DIR} )
		link_directories( ${OPENSG_LIB_DIR} )
		list( APPEND LIBRARIES ${OPENSG_LIBRARIES} )
		add_definitions( ${OPENSG_DEFINTIONS} )			
	endmacro( vista_use_OpenSG )
	
	find_package_handle_standard_args( VOpenSG "OpenSG could not be found" OPENSG_INC_DIR OPENSG_LIBRARIES )

endif( NOT VOPENSG_FOUND )



