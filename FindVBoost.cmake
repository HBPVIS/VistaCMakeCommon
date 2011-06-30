# $Id: FindVBOOST.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VBOOST_FOUND )
	if( NOT BOOST_ROOT )
		vista_find_package_root( BOOST boost/any.hpp NAMES Boost boost NO_CACHE )
		
		if( BOOST_ROOT_DIR )
			set( BOOST_ROOT ${BOOST_ROOT_DIR} )
		endif( BOOST_ROOT_DIR )
	endif( NOT BOOST_ROOT )
	
	find_package( Boost ${Boost_FIND_VERSION} COMPONENTS ${Boost_FIND_COMPONENTS} )
	
	set( BOOST_INCLUDE_DIRS ${Boost_INCLUDE_DIRS} )
	set( BOOST_LIBRARY_DIRS ${Boost_LIBRARY_DIRS} )
	set( BOOST_LIBRARIES ${Boost_LIBRARIES} )

endif( NOT VBOOST_FOUND )

find_package_handle_standard_args( VBOOST "BOOST could not be found" BOOST_ROOT_DIR )




