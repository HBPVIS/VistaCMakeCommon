# $Id: FindVEigen.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VEIGEN_FOUND )
	vista_find_package_root( Eigen Dense )	

	if( EIGEN_ROOT_DIR )
		set( EIGEN_INCLUDE_DIRS ${EIGEN_ROOT_DIR})		
	else( EIGEN_ROOT_DIR )
		message( WARNING "vista_find_package_root - File named Dense not found" )	
	endif( EIGEN_ROOT_DIR )
endif( NOT VEIGEN_FOUND )

find_package_handle_standard_args( VEigen "Eigen could not be found" EIGEN_ROOT_DIR )

