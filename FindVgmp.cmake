# $Id: FindVGMP.cmake 35232 2013-05-27 13:16:20Z cn276793 $


include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VGMP_FOUND )

	vista_find_package_root( gmp "include/gmp.h"  )
	
	if( GMP_ROOT_DIR)
		set( GMP_INCLUDE_DIRS "${GMP_ROOT_DIR}/include" )
		set( GMP_LIBRARY_DIRS "${GMP_ROOT_DIR}/lib" )
		if( WIN32 )
			set( GMP_LIBRARIES "libgmp-10" )
		else()
			set( GMP_LIBRARIES "gmp" )
		endif()
	endif()

endif( NOT VGMP_FOUND )

find_package_handle_standard_args( Vgmp "gmp could not be found" GMP_ROOT_DIR )

