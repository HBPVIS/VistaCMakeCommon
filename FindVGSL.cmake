# $Id: FindVGLEW.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VGSL_FOUND )

	vista_find_package_root( GSL include/gsl/gsl_sys.h )

	if( GSL_ROOT_DIR )
		#find_library( GSL_LIBRARY NAMES gsl
		#			PATHS ${GSL_ROOT_DIR}/lib
		#			CACHE "GSL library" )
		#find_library( GSL_LIBRARY_CBLAS NAMES cblas
		#			PATHS ${GSL_ROOT_DIR}/lib
		#			CACHE "GSL cblas library" )
		#mark_as_advanced( GSL_LIBRARY )
		#mark_as_advanced( GSL_LIBRARY_CBLAS )
		#set( GSL_LIBRARIES "${GSL_LIBRARY}" "${GSL_LIBRARY_CBLAS}" )
		set( GSL_LIBRARIES gsl cblas )
		
		set( GSL_INCLUDE_DIRS "${GSL_ROOT_DIR}/include" )
		set( GSL_LIBRARY_DIRS "${GSL_ROOT_DIR}/lib" )
		

	endif( GSL_ROOT_DIR )

endif( NOT VGSL_FOUND )

find_package_handle_standard_args( VGSL "GSL could not be found" GSL_ROOT_DIR )

