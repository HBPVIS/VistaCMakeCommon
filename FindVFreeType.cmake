# $Id: FindVGLEW.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VFREETYPE_FOUND )

	vista_find_package_root( FREETYPE include/freetype/freetype.h )

	if( FREETYPE_ROOT_DIR )
		find_library( FREETYPE_LIBRARIES NAMES freetype
					PATHS ${FREETYPE_ROOT_DIR}/lib
					CACHE "FREETYPE library" )
		mark_as_advanced( FREETYPE_LIBRARIES )

		set( FREETYPE_INCLUDE_DIRS ${FREETYPE_ROOT_DIR}/include )
		set( FREETYPE_LIBRARY_DIRS ${FREETYPE_ROOT_DIR}/lib )
		get_filename_component( FREETYPE_LIBRARY_DIRS ${FREETYPE_LIBRARIES} PATH )

	endif( FREETYPE_ROOT_DIR )

endif( NOT VFREETYPE_FOUND )

find_package_handle_standard_args( VFREETYPE "FFREETYPE could not be found" FREETYPE_ROOT_DIR )

