include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENAL_FOUND )
	vista_find_package_root( OpenAL include/al.h )

	if( OPENAL_ROOT_DIR )
		find_library( OPENAL_LIBRARIES
			NAMES OpenAL al openal OpenAL32
			PATH_SUFFIXES lib64 lib libs64 libs libs/Win32 libs/Win64
			PATHS
			${OPENAL_ROOT_DIR}
		)
		set( OPENAL_INCLUDE_DIRS ${OPENAL_ROOT_DIR}/include )
		set( OPENAL_LIBRARIES ${OPENAL_LIBRARIES} CACHE INTERNAL "" FORCE )

		if( OPENAL_LIBRARIES )
			set( OPENAL_ROOT_DIR ${OPENAL_ROOT_DIR}/include )
		endif( OPENAL_LIBRARIES )
	endif( OPENAL_ROOT_DIR )
		
	if( NOT OPENAL_LIBRARIES )
		# try using a general FindOpenAL.cmake
		find_package( OpenAL )
		if( OPENAL_FOUND )
			set( OPENAL_LIBRARIES ${OPENAL_LIBRARY} )
			set( OPENAL_LIBRARY ${OPENAL_LIBRARY} CACHE INTERNAL "" FORCE )
			set( OPENAL_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR} )
			set( OPENAL_ROOT_DIR ${OPENAL_INCLUDE_DIR} )
		endif( OPENAL_FOUND )
	endif( NOT OPENAL_LIBRARIES )
	
	
endif( NOT VOPENAL_FOUND )

find_package_handle_standard_args( VOpenAL "OPENAL could not be found" OPENAL_ROOT_DIR OPENAL_LIBRARIES )


