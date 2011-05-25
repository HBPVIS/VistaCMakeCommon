# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VWIIUSE_FOUND )
	vista_find_package_root( wiiuse include/wiiuse.h )

	if( WIIUSE_ROOT_DIR )
		set( WIIUSE_INCLUDE_DIRS ${WIIUSE_ROOT_DIR}/include )
		set( WIIUSE_LIBRARY_DIRS ${WIIUSE_ROOT_DIR}/lib )
		set( WIIUSE_LIBRARIES wiiuse )
	endif( WIIUSE_ROOT_DIR )

endif( NOT VWIIUSE_FOUND )

find_package_handle_standard_args( Vwiiuse "wiiuse could not be found" WIIUSE_ROOT_DIR )



