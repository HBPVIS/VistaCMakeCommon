include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VMESCHACH_FOUND )
	vista_find_package_root( Meschach FILES include/zmatrix2.h include/matrix2.h include/meminfo.h )	

	if( MESCHACH_ROOT_DIR )		
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

endif( NOT VMESCHACH_FOUND )

find_package_handle_standard_args( VMeschach "Meschach could not be found" MESCHACH_ROOT_DIR MESCHACH_LIBRARIES )

