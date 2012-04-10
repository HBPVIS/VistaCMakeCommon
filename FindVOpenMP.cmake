# $Id: FindVGLEW.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENMP_FOUND )

	vista_find_original_package( OpenMP )
	
	if( OPENMP_FOUND )
		set( OPENMP_USE_FILE "VOpenMPUseFile.cmake" )
	endif()

endif( NOT VOPENMP_FOUND )

find_package_handle_standard_args( VOPENMP_FOUND "OpenMP could not be found" OPENMP_FOUND )

