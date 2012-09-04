# $Id: FindVOpenMesh.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENMESH_FOUND )

	vista_find_package_root( OPENMESH include/OpenMesh/Core/Mesh/TriMeshT.hh )

	if( OPENMESH_ROOT_DIR )
		find_library( OPENMESH_LIBRARIES NAMES OpenMeshCore OpenMeshTools OPENMESH
					PATHS ${OPENMESH_ROOT_DIR}/lib
					CACHE "OpenMesh library" )
		mark_as_advanced( OPENMESH_LIBRARIES )

		set( OPENMESH_INCLUDE_DIRS ${OPENMESH_ROOT_DIR}/include )
		set( OPENMESH_LIBRARY_DIRS ${OPENMESH_ROOT_DIR}/lib )
		get_filename_component( OPENMESH_LIBRARY_DIRS ${OPENMESH_LIBRARIES} PATH )

	endif( OPENMESH_ROOT_DIR )

endif( NOT VOPENMESH_FOUND )

find_package_handle_standard_args( VOPENMESH "OpenMesh could not be found" OPENMESH_ROOT_DIR )

