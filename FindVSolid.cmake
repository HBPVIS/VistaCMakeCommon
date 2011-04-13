# Search for precompiled SOLID path

include( FindPackageHandleStandardArgs )

if( NOT VSOLID_FOUND )

	find_path( SOLID_ROOT_DIR include/SOLID.h 
				PATHS $ENV{SOLID_ROOT}/${VISTA_HWARCH} $ENV{SOLID_ROOT}
						$ENV{VRDEV}/SOLID/${VISTA_HWARCH} $ENV{VRDEV}/SOLID
				CACHE "Solid package directory" )

	if( SOLID_ROOT_DIR )
		message( STATUS "Found Solid in ${SOLID_ROOT_DIR}" )
		
		set( SOLID_INCLUDE_DIRS ${SOLID_ROOT_DIR}/include )
		set( SOLID_LIBRARY_DIRS ${SOLID_ROOT_DIR}/lib )
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
		
		
		
	else( SOLID_ROOT_DIR )		
		# todo
		#find_package( SOLID )
		
		#if( SOLID_FOUND )
		#	set( SOLID_INCLUDE_DIRS ${SOLID_INCLUDE_DIRS} )
			#SOLID_LIBRARIES already set by find_package
		#endif( SOLID_FOUND )
		
	endif( SOLID_ROOT_DIR )	
	
	macro( vista_use_Solid )
		if( NOT VISTA_USE_SOLID_CALLED )
			include_directories( ${SOLID_INCLUDE_DIRS} )
			link_directories(  ${SOLID_LIBRARY_DIRS} )		
			#set variables for Vista BuildSystem to track dependencies
			list( APPEND VISTA_TARGET_LINK_DIRS ${SOLID_LIBRARY_DIRS} )
			list( APPEND VISTA_TARGET_DEPENDENCIES "Solid" )
			set( VISTA_USE_SOLID_CALLED TRUE )
		endif( NOT VISTA_USE_SOLID_CALLED )
	endmacro( vista_use_Solid )


endif( NOT VSOLID_FOUND )

find_package_handle_standard_args( VSolid "Solid could not be found" SOLID_INCLUDE_DIRS SOLID_LIBRARIES )  
