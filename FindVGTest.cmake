# $Id: FindVGTEST.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VGTEST_FOUND )
	vista_find_package_root( GTest include/gtest/gtest.h NAMES gtest GTEST )
	set( GTEST_ROOT ${GTEST_ROOT_DIR} )

	vista_find_original_package( VGTest )
	
endif( NOT VGTEST_FOUND )

find_package_handle_standard_args( VGTest "GTest could not be found" GTEST_ROOT_DIR )
