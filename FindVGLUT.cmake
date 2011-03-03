# Search for precompiled GLUT path

include( FindPackageHandleStandardArgs )

if( NOT VGLUT_FOUND )

	find_path( GLUT_DIR include/GL/freeglut.h 
			PATHS 	$ENV{FREEGLUT_ROOT}/${VISTA_HWARCH} $ENV{FREEGLUT_ROOT}
					$ENV{GLUT_ROOT} $ENV{GLUT_ROOT}/${VISTA_HWARCH} 
					${VRDEV}/freeglut/${VISTA_HWARCH}  ${VRDEV}/freeglut 
					${VRDEV}/glut/${VISTA_HWARCH}  ${VRDEV}/glut 
			CACHE "Glut/Freeglut package directory" )			
	find_library( GLUT_LIBRARIES NAMES freeglut freeglut-msvc90x86 glut glut32 PATHS ${GLUT_DIR}/lib ${GLUT_DIR}/lib/opt )

	if( GLUT_DIR AND GLUT_LIBRARIES )
		message( STATUS "Found Freeglut in ${GLUT_DIR}" )
		
		set( GLUT_INC_DIR ${GLUT_DIR}/include )		
		
	else( GLUT_DIR AND GLUT_LIBRARIES )
		message( STATUS "FREEGLUT not found - searching for native GLUT" )
		
		find_path( GLUT_DIR include/GL/glut.h 
				PATHS	$ENV{FREEGLUT_ROOT}/${VISTA_HWARCH} $ENV{FREEGLUT_ROOT}
						${VRDEV}/glut/${VISTA_HWARCH}  ${VRDEV}/glut
				CACHE "Glut/Freeglut package directory" )
		find_library( GLUT_LIBRARIES NAMES glut glut32 PATHS ${GLUT_DIR}/lib ${GLUT_DIR}/lib/opt )
		
		if( GLUT_DIR AND GLUT_LIBRARIES )
			message( STATUS "Found GLUT in ${GLUT_DIR}" )
			
			set( GLUT_INC_DIR ${GLUT_DIR}/include )			
		
		else( GLUT_DIR AND GLUT_LIBRARIES )
			find_package( GLUT )
			
			if( GLUT_FOUND )
				set( GLUT_LIB_DIR "" )
				set( GLUT_INC_DIR ${GLUT_INCLUDE_DIR} )
				set( GLUT_LIBRARIES ${GLUT_glut_LIBRARY} )
				set( GLUT_DEFINITIONS "USE_NATIVE_GLUT" )
				
				message( STATUS "Found GLUT in ${GLUT_DIR}" )				
					
				macro( vista_use_GLUT )
					include_directories( ${GLUT_INC_DIR} )
					list( APPEND LIBRARIES ${GLUT_LIBRARIES} )
					add_definitions( ${GLUT_DEFINITIONS} )
				endmacro( vista_use_GLUT )
			endif( GLUT_FOUND )
			
		endif( GLUT_DIR AND GLUT_LIBRARIES )

	endif( GLUT_DIR AND GLUT_LIBRARIES )	
	
	macro( vista_use_GLUT )
		include_directories( ${GLUT_INC_DIR} )
		link_directories( ${GLUT_LIB_DIR} )
		add_definitions( ${GLUT_DEFINITIONS} )
		list( APPEND LIBRARIES ${GLUT_LIBRARIES} )
	endmacro( vista_use_GLUT )

endif( NOT VGLUT_FOUND )

find_package_handle_standard_args( VGLUT "glut/Freeglut could not be found" GLUT_INC_DIR GLUT_LIBRARIES )  

