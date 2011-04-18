# vista_find_package_root( PACKAGE [EXAMPLE_FILE | FILES file1 file2 ...] [DONT_ALLOW_UNVERSIONED] [QUIET] [FOLDERS folder1 folder2 ...] )
macro( vista_find_package_root _PACKAGE_NAME )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	string( TOLOWER ${_PACKAGE_NAME} _PACKAGE_NAME_LOWER )

	if( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
	
		if( V${_PACKAGE_NAME}_FIND_VERSION_EXT )
			set( _REQUESTED_VERSION ${V${_PACKAGE_NAME}_FIND_VERSION_EXT} )
		elseif( V${_PACKAGE_NAME}_FIND_VERSION )
			set( _REQUESTED_VERSION ${V${_PACKAGE_NAME}_FIND_VERSION} )
		elseif( ${_PACKAGE_NAME}_FIND_VERSION_EXT )
			set( _REQUESTED_VERSION ${${_PACKAGE_NAME}_FIND_VERSION_EXT} )
		elseif( ${_PACKAGE_NAME}_FIND_VERSION )
			set( _REQUESTED_VERSION ${${_PACKAGE_NAME}_FIND_VERSION} )
		else()
			set( _REQUESTED_VERSION )
		endif( V${_PACKAGE_NAME}_FIND_VERSION_EXT )
		
		# parse arguments
		set( _SEARCH_FILES ${ARGV1} )
		set( _PACKAGE_FOLDER_NAMES ${_PACKAGE_NAME} ${_PACKAGE_NAME_UPPER} ${_PACKAGE_NAME_LOWER} )
		set( _DONT_ALLOW_UNVERSIONED FALSE )
		set( _QUIET FALSE )	
		set( _NEXT_IS_FOLDER FALSE )
		set( _NEXT_IS_FILE FALSE )
		foreach( _ARG ${ARGV} )
			if( ${_ARG} STREQUAL ${ARGV0} )
				# package name - skip
			elseif( ${_ARG} STREQUAL ${ARGV1} )
				if( ${_ARG} STREQUAL "FILES" )
					set( _SEARCH_FILES "NAMES" )
					set( _NEXT_IS_FILE TRUE )
				endif( ${_ARG} STREQUAL "FILES" )
				set( _NEXT_IS_FOLDER FALSE )
			elseif( ${_ARG} STREQUAL "FILES" )
				set( _SEARCH_FILES "NAMES" )
				set( _NEXT_IS_FOLDER FALSE )
				set( _NEXT_IS_FILE TRUE )
			elseif( ${_ARG} STREQUAL "FILES" )
				set( _NEXT_IS_FOLDER TRUE )
				set( _NEXT_IS_FILE FALSE )
			elseif( ${_ARG} STREQUAL "DONT_ALLOW_UNVERSIONED" )
				set( _DONT_ALLOW_UNVERSIONED TRUE )
				set( _NEXT_IS_FILE FALSE )
				set( _NEXT_IS_FOLDER FALSE )
			elseif( ${_ARG} STREQUAL "QUIET" )
				set( _QUIET TRUE )
				set( _NEXT_IS_FILE FALSE )
				set( _NEXT_IS_FOLDER FALSE )
			elseif( _NEXT_IS_FOLDER )
				list( APPEND _PACKAGE_FOLDER_NAMES ${_ARG} )
			elseif( _NEXT_IS_FILE )
				list( APPEND _SEARCH_FILES ${_ARG} )
			endif( ${_ARG} STREQUAL ${ARGV0} )
		endforeach( _ARG ${ARGV} )
		
		set( _SEARCH_PATHES_VERSIONED )
		set( _SEARCH_PATHES_UNVERSIONED )
		
		foreach( _FOLDER ${_PACKAGE_FOLDER_NAMES} )
			if( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
				list( APPEND _SEARCH_PATHES_VERSIONED
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_FOLDER}-${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_FOLDER}-${_REQUESTED_VERSION}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_REQUESTED_VERSION}
				)
				list( APPEND _SEARCH_PATHES_UNVERSIONED
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT} 
				)
			endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
			if( EXISTS "$ENV{VRDEV}" )
				list( APPEND _SEARCH_PATHES_VERSIONED
						$ENV{VRDEV}/${_FOLDER}/${_FOLDER}-${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{VRDEV}/${_FOLDER}/${_FOLDER}-${_REQUESTED_VERSION}
						$ENV{VRDEV}/${_FOLDER}/${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{VRDEV}/${_FOLDER}/${_REQUESTED_VERSION}
						$ENV{VRDEV}/${_FOLDER}-${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{VRDEV}/${_FOLDER}-${_REQUESTED_VERSION}
				)
				list( APPEND _SEARCH_PATHES_UNVERSIONED
						$ENV{VRDEV}/${_FOLDER}/current/${VISTA_HWARCH}
						$ENV{VRDEV}/${_FOLDER}/current
						$ENV{VRDEV}/${_FOLDER}/${VISTA_HWARCH}
						$ENV{VRDEV}/${_FOLDER}
				)
			endif( EXISTS "$ENV{VRDEV}" )
		endforeach( _FOLDER _PACKAGE_FOLDER_NAMES )

		if( DEFINED _REQUESTED_VERSION )
			set( ${_PACKAGE_NAME_UPPER}_ROOT_DIR "OpenSGDIR-NOTFOUND" )
			find_path( ${_PACKAGE_NAME_UPPER}_ROOT_DIR 
				${_SEARCH_FILES}
				PATHS ${_SEARCH_PATHES_VERSIONED}
				DOC "${_PACKAGE_NAME} package root directory" 
			)
			if( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
				if( _DONT_ALLOW_UNVERSIONED )
					if( NOT _QUIET )
						message( WARNING "Package \"${_PACKAGE_NAME}\" could not be found with version \"${_REQUESTED_VERSION}\"" )
					endif( NOT _QUIET )
				else( _DONT_ALLOW_UNVERSIONED )
					if( NOT _QUIET )
						message( STATUS "Package \"${_PACKAGE_NAME}\" with version \"${_REQUESTED_VERSION}\" not found - searching for unversioned package" )
					endif( NOT _QUIET )				
					find_path( ${_PACKAGE_NAME_UPPER}_ROOT_DIR 
							${_SEARCH_FILES}
							PATHS ${_SEARCH_PATHES_UNVERSIONED}
							DOC "${_PACKAGE_NAME} package root directory" 
					)
					
				endif( _DONT_ALLOW_UNVERSIONED )				
			endif( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
		else( DEFINED _REQUESTED_VERSION )
			find_path( ${_PACKAGE_NAME_UPPER}_ROOT_DIR 
				${_SEARCH_FILES}
				PATHS ${_SEARCH_PATHES_UNVERSIONED}
				DOC "${_PACKAGE_NAME} package root directory" 
			)
		endif( DEFINED _REQUESTED_VERSION )
		mark_as_advanced( ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
	endif( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
endmacro( vista_find_package_root _PACKAGE_NAME _EXAMPLE_FILE )


