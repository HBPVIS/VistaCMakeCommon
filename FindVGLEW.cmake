# Search for precompiled GLEW path
include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VGLEW_FOUND )

	vista_find_package_root( GLEW include/GL/glew.h )
	find_library( GLEW_LIBRARIES NAMES glew glew32 glew64 GLEW
					PATHS ${GLEW_ROOT_DIR}/lib
					CACHE "GLEW library" )
	
	if( GLEW_ROOT_DIR AND GLEW_LIBRARIES )
		
		set( GLEW_INCLUDE_DIRS ${GLEW_ROOT_DIR}/include )
		set( GLEW_LIBRARY_DIRS ${GLEW_ROOT_DIR}/lib )
		set( GLEW_DEFINITIONS "" )

	endif( GLEW_ROOT_DIR AND GLEW_LIBRARIES )

	mark_as_advanced( GLEW_LIBRARIES )

endif( NOT VGLEW_FOUND )

find_package_handle_standard_args( VGLEW "GLEW could not be found" GLEW_LIBRARIES GLEW_INCLUDE_DIRS ) 

