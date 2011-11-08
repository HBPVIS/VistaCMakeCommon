# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VVRPN_FOUND )
	vista_find_package_root( vrpn include/vrpn_Connection.h )

	if( VRPN_ROOT_DIR )
		set( VRPN_INCLUDE_DIRS ${VRPN_ROOT_DIR}/include )
		set( VRPN_LIBRARY_DIRS ${VRPN_ROOT_DIR}/lib )
		if( WIN32 )
			if( BUILD_SHARED_LIBS )
				vista_check_library_exists( vrpndll _DLL_EXISTS )
				if( _DLL_EXISTS )
					set( VRPN_LIBRARIES optimized vrpndll debug vrpndllD )
				else()
					set( VRPN_LIBRARIES optimized vrpn debug vrpnD )
				endif()
			else()
				set( VRPN_LIBRARIES optimized vrpn debug vrpnD )
			endif()
		else( WIN32 )
			set( VRPN_LIBRARIES vrpn )
		endif( WIN32 )
	endif( VRPN_ROOT_DIR )

endif( NOT VVRPN_FOUND )

find_package_handle_standard_args( Vvrpn "vrpn could not be found" VRPN_ROOT_DIR )
