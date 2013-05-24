# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENAL_FOUND )
	# try three options: once with include subdir AL, once without, and - if both fail - a general FindOpenAL file
	
	vista_find_package_root( OpenAL "include/AL/al.h" NAMES "OpenAL 1.1 SDK" )
	vista_find_package_root( OpenAL "include/al.h" NAMES "OpenAL 1.1 SDK" )

	if( OPENAL_ROOT_DIR )
		if( EXISTS "${OPENAL_ROOT_DIR}/include/AL/al.h" )
			set( OPENAL_INCLUDE_DIRS ${OPENAL_ROOT_DIR}/include/AL )
		elseif( EXISTS "${OPENAL_ROOT_DIR}/include/al.h" )
			set( OPENAL_INCLUDE_DIRS ${OPENAL_ROOT_DIR}/include )
		endif( EXISTS "${OPENAL_ROOT_DIR}/include/AL/al.h" )

		set( OPENAL_LIBRARIES ${OPENAL_LIBRARIES} CACHE INTERNAL "" FORCE )
		
		if( VISTA_64BIT )
			vista_find_library_uncached(
				NAMES OpenAL al openal OpenAL32
				PATH_SUFFIXES lib64 libs64 libs/Win64
				PATHS
				${OPENAL_ROOT_DIR}
			)
		else()
			vista_find_library_uncached(
				NAMES OpenAL al openal OpenAL32
				PATH_SUFFIXES lib libs libs/Win32
				PATHS
				${OPENAL_ROOT_DIR}
			)
		endif()
		if( VISTA_UNCACHED_LIBRARY )
			set( OPENAL_LIBRARIES ${VISTA_UNCACHED_LIBRARY} )
			get_filename_component( OPENAL_LIBRARY_DIRS ${VISTA_UNCACHED_LIBRARY} PATH )
		endif( VISTA_UNCACHED_LIBRARY )
	else( OPENAL_ROOT_DIR )
		# try using a general FindOpenAL.cmake
		find_package( OpenAL )
		if( OPENAL_FOUND )
			set( OPENAL_LIBRARIES ${OPENAL_LIBRARY} )
			set( OPENAL_LIBRARY ${OPENAL_LIBRARY} CACHE INTERNAL "" FORCE )
			set( OPENAL_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR} )
			get_filename_component( _DIR ${OPENAL_INCLUDE_DIRS} PATH  )
			set( OPENAL_ROOT_DIR ${_DIR} CACHE PATH "OpenAL package rot dir" )
		endif( OPENAL_FOUND )
	endif( OPENAL_ROOT_DIR )
endif( NOT VOPENAL_FOUND )

find_package_handle_standard_args( VOpenAL "OpenAL could not be found" OPENAL_ROOT_DIR OPENAL_LIBRARIES )
