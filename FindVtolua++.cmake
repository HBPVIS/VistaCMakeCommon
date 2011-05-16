include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VTOLUA++_FOUND )
	vista_find_package_root( tolua++ include/tolua++.h )

	if( TOLUA++_ROOT_DIR )		
		set( TOLUA++_INCLUDE_DIRS ${TOLUA++_ROOT_DIR}/include )
		set( TOLUA++_LIBRARY_DIRS ${TOLUA++_ROOT_DIR}/lib )
		if( WIN32 )
			set( TOLUA++_LIBRARIES
				optimized tolua++
				debug tolua++D
			)
		else()
			set( TOLUA++_LIBRARIES tolua++ )
		endif( WIN32 )
		
		set( TOLUA++_DEPENDENCIES package LUA REQUIRED )
		
	endif( TOLUA++_ROOT_DIR )

endif( NOT VTOLUA++_FOUND )

find_package_handle_standard_args( Vtolua++ "tolua++ could not be found" TOLUA++_ROOT_DIR ) 

