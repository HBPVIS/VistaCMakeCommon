# $Id: FindVOpenSG.cmake 22870 2011-08-08 07:10:04Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

#if( NOT VOPENSCENEGRAPH_FOUND )
	vista_find_package_root( OpenSceneGraph "include/osg/camera" )
	
	set( ENV{OSG_ROOT} "${OPENSCENEGRAPH_ROOT_DIR}" )

	#set( OpenSceneGraph_DEBUG TRUE )
	
	vista_find_original_package( VOpenSceneGraph OpenSceneGraph )
	
	
	set( OPENSCENEGRAPH_INCLUDE_DIRS "${OSG_INCLUDE_DIR}" )
	set( OPENSCENEGRAPH_LIBRARIES "${OPENSCENEGRAPH_LIBRARIES}" )
	set( OPENSCENEGRAPH_LIBRARY_DIRS )
	foreach( _LIB ${OPENSCENEGRAPH_LIBRARIES} )
		get_filename_component( _PATH "${_LIB}" PATH )
		get_filename_component( _UP_PATH "${_PATH}" PATH )
		if( EXISTS "${_UP_PATH}" )
			list( APPEND OPENSCENEGRAPH_LIBRARY_DIRS ${_PATH} )
			list( APPEND OPENSCENEGRAPH_LIBRARY_DIRS "${_UP_PATH}/bin" )
		endif()
	endforeach()
	if( OPENSCENEGRAPH_LIBRARY_DIRS )
		list( REMOVE_DUPLICATES OPENSCENEGRAPH_LIBRARY_DIRS )
	endif()
	message( "OPENSCENEGRAPH_LIBRARY_DIRS = ${OPENSCENEGRAPH_LIBRARY_DIRS}" )

#endif( NOT VOPENSCENEGRAPH_FOUND )

find_package_handle_standard_args( VOpenSceneGraph "OpenSceneGraph could not be found" OPENSG_FOUND )
