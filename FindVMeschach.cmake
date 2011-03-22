# Search for precompiled MESCHACH path

include( FindPackageHandleStandardArgs )

if( NOT VMESCHACH_FOUND )
	find_path( MESCHACH_ROOT_DIR include/zmatrix2.h include/zmatrix2.h include/matrix2.h include/meminfo.h include/machine.h include/sparse2.h 
				PATHS $ENV{MESCHACH_ROOT}/${VISTA_HWARCH} $ENV{MESCHACH_ROOT}
						$ENV{VRDEV}/Meschach/${VISTA_HWARCH} $ENV{VRDEV}/Meschach
				CACHE "Meschach package directory" )

	if( MESCHACH_ROOT_DIR )
		message( STATUS "Found Meschach in ${MESCHACH_ROOT_DIR}" )
		
		set( MESCHACH_INCLUDE_DIRS ${MESCHACH_ROOT_DIR}/include )
		set( MESCHACH_LIBRARY_DIRS ${MESCHACH_ROOT_DIR}/lib )
		set( MESCHACH_LIBRARIES
			optimized Meschach
			debug MeschachD
		)		
		
	else( MESCHACH_ROOT_DIR )		
		# todo
		#find_package( MESCHACH )
	
		#if( MESCHACH_FOUND )
		#	set( MESCHACH_INC_DIR ${MESCHACH_INCLUDE_DIRS} )
			#MESCHACH_LIBRARIES already set by find_package
		#endif( MESCHACH_FOUND )
		
	endif( MESCHACH_ROOT_DIR )	
	
	macro( vista_use_Meschach )
		include_directories( ${MESCHACH_INCLUDE_DIRS} )
		link_directories( ${MESCHACH_LIBRARY_DIRS} )
	endmacro( vista_use_Meschach )


endif( NOT VMESCHACH_FOUND )

find_package_handle_standard_args( VMeschach "Meschach could not be found" MESCHACH_INCLUDE_DIRS MESCHACH_LIBRARIES )  
