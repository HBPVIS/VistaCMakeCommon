# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VVRPN_FOUND )
	vista_find_package_root( vrpn include/vrpn_Connection.h )

	if( VRPN_ROOT_DIR )
		set( VRPN_INCLUDE_DIRS ${VRPN_ROOT_DIR}/include )
		set( VRPN_LIBRARY_DIRS ${VRPN_ROOT_DIR}/lib )
		if( WIN32 )
			set( VRPN_LIBRARIES optimized vrpndll debug vrpndllD )
		else( WIN32 )
			set( VRPN_LIBRARIES vrpn  )
		endif( WIN32 )
	endif( VRPN_ROOT_DIR )	
	
endif( NOT VVRPN_FOUND )

find_package_handle_standard_args( Vvrpn "vrpn could not be found" VRPN_ROOT_DIR )



