# $Id: FindVCGAL.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VCGAL_FOUND )
	
	vista_find_package_root( CGAL "include/CGAL/AABB_tree.h" DEBUG_OUTPUT )	
	
	#if( CGAL_ROOT_DIR )
	#	set( CGAL_DIR "${CGAL_ROOT_DIR}/lib/CGAL" )
	#endif()
	#vista_find_original_package( VCGAL )
	#if( CGAL_FOUND )
	#	file( TO_CMAKE_PATH "${CGAL_LIBRARIES_DIR}" _BIN_PATH )
	#	set( CGAL_LIBRARY_DIRS ${CGAL_LIBRARY_DIRS} "${CGAL_LIBRARIES_DIR}/../bin" )
	#endif()
	
	if( CGAL_ROOT_DIR )
		# @TODO: boost_all_dyn_link not nice here...
		set( CGAL_DEFINITIONS -DCGAL_USE_MPFR -DCGAL_USE_GMP -DBOOST_ALL_DYN_LINK )
		set( CGAL_INCLUDE_DIRS "${CGAL_ROOT_DIR}/include" )
		set( CGAL_LIBRARY_DIRS "${CGAL_ROOT_DIR}/lib" "${CGAL_ROOT_DIR}/bin" )
	endif()
	
	vista_add_package_dependency( CGAL Boost REQUIRED system thread )
	vista_add_package_dependency( CGAL gmp REQUIRED )
	vista_add_package_dependency( CGAL mpfr REQUIRED )
	
endif( NOT VCGAL_FOUND )

find_package_handle_standard_args( VCGAL "CGAL could not be found" CGAL_LIBRARY_DIRS )



