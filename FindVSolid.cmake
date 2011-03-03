# Search for precompiled SOLID path

include( FindPackageHandleStandardArgs )

if( NOT VSOLID_FOUND )

	find_path( SOLID_DIR include/SOLID.h 
				PATHS $ENV{SOLID_ROOT}/${VISTA_HWARCH} $ENV{SOLID_ROOT}
						$ENV{VRDEV}/SOLID/${VISTA_HWARCH} $ENV{VRDEV}/SOLID
				CACHE "Solid package directory" )

	if( SOLID_DIR )
		message( STATUS "Found Solid in ${SOLID_DIR}" )
		
		set( SOLID_INC_DIR ${SOLID_DIR}/include )
		set( SOLID_LIB_DIR ${SOLID_DIR}/lib )
		set( SOLID_LIBRARIES
			optimized solid
			optimized qhull
			optimized broad
			optimized complex
			optimized convex
			debug solidD
			debug qhullD
			debug broadD
			debug complexD
			debug convexD
		)	
		
		
		
	else( SOLID_DIR )		
		# todo
		#find_package( SOLID )
		
		#if( SOLID_FOUND )
		#	set( SOLID_INC_DIR ${SOLID_INCLUDE_DIR} )
			#SOLID_LIBRARIES already set by find_package
		#endif( SOLID_FOUND )
		
	endif( SOLID_DIR )	
	
	macro( vista_use_bullet )
			include_directories( ${SOLID_INC_DIR} )
			link_directories( ${SOLID_LIB_DIR} )
			list( APPEND LIBRARIES ${SOLID_LIBRARIES} )
	endmacro( vista_use_bullet )


endif( NOT VSOLID_FOUND )

find_package_handle_standard_args( VSolid "Solid could not be found" SOLID_INC_DIR SOLID_LIBRARIES )  
