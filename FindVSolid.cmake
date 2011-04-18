include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSOLID_FOUND )
	vista_find_package_root( Solid include/SOLID.h )	

	if( SOLID_ROOT_DIR )
		
		set( SOLID_INCLUDE_DIRS ${SOLID_ROOT_DIR}/include )
		set( SOLID_LIBRARY_DIRS ${SOLID_ROOT_DIR}/lib )

		if( WIN32 )
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
		else()
			set( SOLID_LIBRARIES solid )
		endif( WIN32 )	
		
		
		
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

find_package_handle_standard_args( VSolid "Solid could not be found" SOLID_ROOT_DIR )  
