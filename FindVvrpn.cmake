# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VVRPN_FOUND )
	vista_find_package_root( vrpn include/vrpn_Connection.h )

	if( VRPN_ROOT_DIR )
		set( VRPN_INCLUDE_DIRS "${VRPN_ROOT_DIR}/include" )
		set( VRPN_LIBRARY_DIRS "${VRPN_ROOT_DIR}/lib" )
		
		vista_check_library_exists( _VRPN_DLL_EXISTS vrpndll "${VRPN_LIBRARY_DIRS}" )
		vista_check_library_exists( _VRPN_STATIC_EXISTS vrpn "${VRPN_LIBRARY_DIRS}" )
		
		set( _VRPN_LIB_NAME )
		if( _VRPN_DLL_EXISTS AND( BUILD_SHARED_LIBS OR NOT _VRPN_STATIC_EXISTS ) )
			set( _VRPN_LIB_NAME vrpndll )
		elseif( _VRPN_STATIC_EXISTS )
			set( _VRPN_LIB_NAME vrpn )
		else()
			# no lib exists :(
		endif()
	endif()
	
	if( _VRPN_LIB_NAME )	
		vista_check_library_exists( _VRPN_DEB1_EXISTS ${_VRPN_LIB_NAME}d "${VRPN_LIBRARY_DIRS}" )
		vista_check_library_exists( _VRPN_DEB2_EXISTS ${_VRPN_LIB_NAME}D "${VRPN_LIBRARY_DIRS}" )		
		
		if( _VRPN_DEB1_EXISTS )
			set( VRPN_LIBRARIES optimized ${_VRPN_LIB_NAME} debug ${_VRPN_LIB_NAME}d )
		elseif( _VRPN_DEB2_EXISTS )
			set( VRPN_LIBRARIES optimized ${_VRPN_LIB_NAME} debug ${_VRPN_LIB_NAME}D )
		else()
			set( VRPN_LIBRARIES ${_VRPN_LIB_NAME} )
		endif()
	endif()

endif()

find_package_handle_standard_args( Vvrpn "vrpn could not be found" VRPN_ROOT_DIR _VRPN_LIB_NAME )
