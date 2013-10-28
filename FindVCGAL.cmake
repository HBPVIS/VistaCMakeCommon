# $Id: FindVCGAL.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VCGAL_FOUND )
	
	vista_find_package_root( CGAL "include/CGAL/AABB_tree.h" )	

	vista_find_original_package( CGAL )
	if( CGAL_FOUND )
		file( TO_CMAKE_PATH "${CGAL_LIBRARIES_DIR}" _BIN_PATH )
		set( CGAL_LIBRARY_DIRS ${CGAL_LIBRARY_DIRS} "${CGAL_LIBRARIES_DIR}/../bin" )
	endif()
	
endif( NOT VCGAL_FOUND )

find_package_handle_standard_args( VCGAL "CGAL could not be found" CGAL_USE_FILE )



