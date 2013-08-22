# $Id: FindVEigen.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VCATSXFEMSOLVER_FOUND )
	vista_find_package_root( CatsXFEMSolver CatsXFEMSolver/XFEM.h )	

	if( CATSXFEMSOLVER_ROOT_DIR )
		set( CATSXFEMSOLVER_INCLUDE_DIRS ${CATSXFEMSOLVER_ROOT_DIR})	
		set( CATSXFEMSOLVER_LIBRARY_DIRS ${CATSXFEMSOLVER_ROOT_DIR}/CatsXFEMSolver)
		if ( CATSXFEMSOLVER_VERSION_STRING VERSION_LESS 1.2)
			set( CATSXFEMSOLVER_LIBRARIES libgoto2_nehalemp-r1.13 umfpack libamd libg2c libgcc libshared libSources)
		else ()
			set( CATSXFEMSOLVER_LIBRARIES 
				optimized umfpack
				optimized libamd 				
				optimized Propagation
				debug umfpack
				debug libamd 
				debug PropagationD)
		endif()
	else( CATSXFEMSOLVER_ROOT_DIR )
		message( WARNING "vista_find_package_root - File named CatsXFEMSolver/XFEM.h not found" )	
	endif( CATSXFEMSOLVER_ROOT_DIR )
endif( NOT VCATSXFEMSOLVER_FOUND )

find_package_handle_standard_args( VCATSXFEMSOLVER "CatsXFEMSolver could not be found" CATSXFEMSOLVER_ROOT_DIR )

