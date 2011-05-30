# $Id: FindVopenni.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENNI_FOUND )
	vista_find_package_root( openni include/XnOpenNI.h )

	if( OPENNI_ROOT_DIR )
		set( OPENNI_INCLUDE_DIRS ${OPENNI_ROOT_DIR}/include/ni )
		set( OPENNI_LIBRARY_DIRS ${OPENNI_ROOT_DIR}/lib )
		set( OPENNI_LIBRARIES OpenNI )
	endif( OPENNI_ROOT_DIR )

endif( NOT VOPENNI_FOUND )

find_package_handle_standard_args( Vopenni "openni could not be found" OPENNI_ROOT_DIR )



