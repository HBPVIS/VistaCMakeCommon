# Search for precompiled GLUT path

include( FindPackageHandleStandardArgs )

if( NOT VGLUT_FOUND )

	find_path( GLUT_ROOT_DIR include/GL/freeglut.h 
			PATHS 	${GLUT_ROOT_DIR}
					$ENV{FREEGLUT_ROOT}/${VISTA_HWARCH} $ENV{FREEGLUT_ROOT}
					$ENV{GLUT_ROOT} $ENV{GLUT_ROOT}/${VISTA_HWARCH} 
					$ENV{OPENSG_ROOT} $ENV{OPENSG_ROOT}/${VISTA_HWARCH} 
					$ENV{VRDEV}/freeglut/${VISTA_HWARCH}  $ENV{VRDEV}/freeglut 
					$ENV{VRDEV}/glut/${VISTA_HWARCH}  $ENV{VRDEV}/glut 
					$ENV{VRDEV}/OpenSG/${VISTA_HWARCH}  $ENV{VRDEV}/OpenSG 
			CACHE "Glut/Freeglut package directory" )
	mark_as_advanced( GLUT_ROOT_DIR )
	
	find_library( GLUT_LIBRARIES NAMES freeglut freeglut-msvc90x86 glut glut32 
					PATHS ${GLUT_ROOT_DIR}/lib ${GLUT_ROOT_DIR}/lib/opt
					CACHE "Glut/freeglut library" )

	if( GLUT_ROOT_DIR AND GLUT_LIBRARIES )
		
		set( GLUT_INCLUDE_DIRS ${GLUT_ROOT_DIR}/include )
		set( GLUT_DEFINITIONS "" )
		
	else( GLUT_ROOT_DIR AND GLUT_LIBRARIES )
			
		find_path( GLUT_ROOT_DIR include/GL/glut.h 
				PATHS	${GLUT_ROOT_DIR}
						$ENV{GLUT_ROOT}/${VISTA_HWARCH} $ENV{GLUT_ROOT}
						$ENV{VRDEV}/glut/${VISTA_HWARCH} $ENV{VRDEV}/glut
				CACHE "Glut/Freeglut package directory" )
		find_library( GLUT_LIBRARIES NAMES glut glut32 PATHS ${GLUT_ROOT_DIR}/lib ${GLUT_ROOT_DIR}/lib/opt )
		
		if( GLUT_ROOT_DIR AND GLUT_LIBRARIES )
			
			set( GLUT_INCLUDE_DIRS ${GLUT_ROOT_DIR}/include )
			set( GLUT_DEFINITIONS "-DUSE_NATIVE_GLUT" )
		
		else( GLUT_ROOT_DIR AND GLUT_LIBRARIES )
			find_package( GLUT )
			
			if( GLUT_FOUND )
			
				set( GLUT_INCLUDE_DIRS ${GLUT_INCLUDE_DIR} )
				set( GLUT_LIBRARIES ${GLUT_glut_LIBRARY} )
				set( GLUT_DEFINITIONS "-DUSE_NATIVE_GLUT" )
				
			endif( GLUT_FOUND )
			
		endif( GLUT_ROOT_DIR AND GLUT_LIBRARIES )

	endif( GLUT_ROOT_DIR AND GLUT_LIBRARIES )
	
	macro( vista_use_GLUT )
		if( NOT VISTA_USE_GLUT_CALLED )
			include_directories( ${GLUT_INCLUDE_DIRS} )
			add_definitions( ${GLUT_DEFINITIONS} )
			link_directories(  ${GLUT_LIBRARY_DIRS} )		
			#set variables for Vista BuildSystem to track dependencies
			list( APPEND VISTA_TARGET_LINK_DIRS ${GLUT_LIBRARY_DIRS} )
			list( APPEND VISTA_TARGET_DEPENDENCIES "GLUT" )
			set( VISTA_USE_GLUT_CALLED TRUE )
		endif( NOT VISTA_USE_GLUT_CALLED )
	endmacro( vista_use_GLUT )

endif( NOT VGLUT_FOUND )

find_package_handle_standard_args( VGLUT "glut/Freeglut could not be found" GLUT_INCLUDE_DIRS GLUT_LIBRARIES ) 
set( GLUT_FOUND ${VGLUT_FOUND} )

