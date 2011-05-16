macro( vista_check_version_entry INPUT_VERSION OWN_VERSION DIFFERENCE_OUTPUT_VAR )
	set( ${DIFFERENCE_OUTPUT_VAR} -1 )
	
	if( "${INPUT_VERSION}" STREQUAL "" OR "${OWN_VERSION}" STREQUAL "" )
		# fine for us, just accept
		set( ${DIFFERENCE_OUTPUT_VAR} 0 )
	else()
		string( REGEX MATCH "([0-9]+)\\+$" _STRING_IS_MIN ${INPUT_VERSION} )
		if( _STRING_IS_MIN )
			if( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_1} ) OR ( ${OWN_VERSION} GREATER ${CMAKE_MATCH_1} ) )
				set( ${DIFFERENCE_OUTPUT_VAR} 0 )
			endif( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_1} ) OR ( ${OWN_VERSION} GREATER ${CMAKE_MATCH_1} ) )
		else()
			string( REGEX MATCH "([0-9]+)\\-([0-9]+)$" _STRING_IS_RANGE ${INPUT_VERSION} )
			if( _STRING_IS_RANGE )
				if( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_1} ) OR ( ${OWN_VERSION} GREATER ${CMAKE_MATCH_1} ) )
					if( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_2} ) OR ( ${OWN_VERSION} LESS ${CMAKE_MATCH_2} ) )
						set( ${DIFFERENCE_OUTPUT_VAR} 0 )
					endif( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_2} ) OR ( ${OWN_VERSION} LESS ${CMAKE_MATCH_2} ) )
				endif( ( ${OWN_VERSION} EQUAL ${CMAKE_MATCH_1} ) OR ( ${OWN_VERSION} GREATER ${CMAKE_MATCH_1} ) )
			elseif( "${INPUT_VERSION}" VERSION_EQUAL "${OWN_VERSION}" )
				# exact match
				set( ${DIFFERENCE_OUTPUT_VAR} 0 )
			elseif( "${INPUT_VERSION}" VERSION_LESS "${OWN_VERSION}" )
				# compatible match
				math( EXPR ${DIFFERENCE_OUTPUT_VAR}  "${OWN_VERSION} - ${INPUT_VERSION}" )
			endif( _STRING_IS_RANGE )
		endif( _STRING_IS_MIN )		
	endif( "${INPUT_VERSION}" STREQUAL "" OR  "${OWN_VERSION}" STREQUAL "" )
	
	#message( "vista_check_version_entry( ${INPUT_VERSION} <-> ${OWN_VERSION} )  = ${${DIFFERENCE_OUTPUT_VAR}}" )
endmacro( vista_check_version_entry )

macro( vista_extract_version_part _TARGET _ENTRY _SEPARATOR  )
	set( ${_TARGET} )
	
	if( _REMAINING_VERSION )
		string( REGEX MATCH "^(${_ENTRY})${_SEPARATOR}(.*)$" _MATCH_SUCCESS ${_REMAINING_VERSION} )
		if( _MATCH_SUCCESS )
			# we found a textual start -> type
			set( ${_TARGET} ${CMAKE_MATCH_1} )
			set( _REMAINING_VERSION ${CMAKE_MATCH_2} )
		else( _MATCH_SUCCESS )
			string( REGEX MATCH "^(${_ENTRY})$" _MATCH2_SUCCESS ${_REMAINING_VERSION} )
			if( _MATCH2_SUCCESS )
				# we found a textual start -> type
				set( ${_TARGET} ${CMAKE_MATCH_1} )
				set( _REMAINING_VERSION ${CMAKE_MATCH_2} )
			endif( _MATCH2_SUCCESS )
		endif( _MATCH_SUCCESS )
	endif( _REMAINING_VERSION )
endmacro( vista_extract_version_part )

macro( vista_string_to_version VERSION_STRING VERSION_VARIABLES_PREFIX )
	set( _REMAINING_VERSION ${VERSION_STRING} )
			
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_TYPE  "[a-zA-Z]+"         "_" )
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_NAME  "[a-zA-Z][^\\\\-]+" "\\\\-" )
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_MAJOR "[0-9\\\\+\\\\-]+"  "\\\\." )
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_MINOR "[0-9\\\\+\\\\-]+"  "\\\\." )
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_PATCH "[0-9\\\\+\\\\-]+"  "\\\\." )
	vista_extract_version_part( ${VERSION_VARIABLES_PREFIX}_VERSION_TWEAK "[0-9\\\\+\\\\-]+"  "[$]" )
	
	#if there is just one (textual) entry, it's the name
	if( ${VERSION_VARIABLES_PREFIX}_VERSION_TYPE AND NOT ${VERSION_VARIABLES_PREFIX}_VERSION_NAME AND NOT ${VERSION_VARIABLES_PREFIX}_VERSION_MAJOR )
		set( ${VERSION_VARIABLES_PREFIX}_VERSION_NAME ${${VERSION_VARIABLES_PREFIX}_VERSION_TYPE} )
		set( ${VERSION_VARIABLES_PREFIX}_VERSION_TYPE "" )
	endif( ${VERSION_VARIABLES_PREFIX}_VERSION_TYPE AND NOT ${VERSION_VARIABLES_PREFIX}_VERSION_NAME AND NOT ${VERSION_VARIABLES_PREFIX}_VERSION_MAJOR )	
	
endmacro( vista_string_to_version )

macro( vista_compare_versions INPUT_VERSION_PREFIX OWN_VERSION_PREFIX DIFFERENCE_OUTPUT_VAR )
	set( _MATCHED FALSE )
	set( ${DIFFERENCE_OUTPUT_VAR} -1 )
	
	# check if type matches
	if( NOT ${INPUT_VERSION_PREFIX}_VERSION_TYPE
			OR ${INPUT_VERSION_PREFIX}_VERSION_TYPE STREQUAL "RELEASE" )
		# if no version type is given - we assume release is requested
		if( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
			set( _MATCHED TRUE )
		elseif( ${OWN_VERSION_PREFIX}_VERSION_TYPE STREQUAL "RELEASE" AND ( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL "" ) )
				# for release, we accept either the matching name, or none at all
				set( _MATCHED TRUE )
		endif( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
	elseif( ${INPUT_VERSION_PREFIX}_VERSION_TYPE STREQUAL "HEAD" 
			OR ${INPUT_VERSION_PREFIX}_VERSION_TYPE STREQUAL "BRANCH" 
			OR ${INPUT_VERSION_PREFIX}_VERSION_TYPE STREQUAL "TAG" )
		# 'normal' test - name has to match
		if( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
			set( _MATCHED TRUE )
		endif( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
	else()
		message( WARNING "vista_compare_versions() - version type ${INPUT_VERSION_PREFIX}_VERSION_TYPE = ${${INPUT_VERSION_PREFIX}_VERSION_TYPE} is unknown" )
	endif( NOT ${INPUT_VERSION_PREFIX}_VERSION_TYPE
			OR ${INPUT_VERSION_PREFIX}_VERSION_TYPE STREQUAL "RELEASE" )
			
	message( "head+type correct? ${_MATCHED}")
	if( _MATCHED )
		# version type and name are okay - check number
		vista_check_version_entry( "${${INPUT_VERSION_PREFIX}_VERSION_MAJOR}" "${${OWN_VERSION_PREFIX}_VERSION_MAJOR}" _DIFFERENCE_MAJOR )
		vista_check_version_entry( "${${INPUT_VERSION_PREFIX}_VERSION_MINOR}" "${${OWN_VERSION_PREFIX}_VERSION_MINOR}" _DIFFERENCE_MINOR )
		vista_check_version_entry( "${${INPUT_VERSION_PREFIX}_VERSION_PATCH}" "${${OWN_VERSION_PREFIX}_VERSION_PATCH}" _DIFFERENCE_PATCH )
		vista_check_version_entry( "${${INPUT_VERSION_PREFIX}_VERSION_TWEAK}" "${${OWN_VERSION_PREFIX}_VERSION_TWEAK}" _DIFFERENCE_TWEAK )
		if( _DIFFERENCE_MAJOR GREATER -1 AND _DIFFERENCE_MINOR GREATER -1 AND _DIFFERENCE_PATCH GREATER -1 AND _DIFFERENCE_TWEAK GREATER -1 )
			set( ${DIFFERENCE_OUTPUT_VAR} "${_DIFFERENCE_MAJOR}.${_DIFFERENCE_MINOR}.${_DIFFERENCE_PATCH}.${_DIFFERENCE_TWEAK}" )
		endif( _DIFFERENCE_MAJOR GREATER -1 AND _DIFFERENCE_MINOR GREATER -1 AND _DIFFERENCE_PATCH GREATER -1 AND _DIFFERENCE_TWEAK GREATER -1 )
	endif( _MATCHED )
endmacro( vista_compare_versions )

# vista_find_package_root( PACKAGE [EXAMPLE_FILE | FILES file1 file2 ...] [DONT_ALLOW_UNVERSIONED] [QUIET] [FOLDERS folder1 folder2 ...] [ADVANCED] )
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
		set( _ADVANCED FALSE )
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
			elseif( ${_ARG} STREQUAL "NAMES" )
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
			elseif( ${_ARG} STREQUAL "ADVANCED" )
				set( _ADVANCED TRUE )
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
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_FOLDER}.${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_FOLDER}.${_REQUESTED_VERSION}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_REQUESTED_VERSION}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_REQUESTED_VERSION}
				)
				list( APPEND _SEARCH_PATHES_UNVERSIONED
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${VISTA_HWARCH}
						$ENV{${_PACKAGE_NAME_UPPER}_ROOT} 
				)
			endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
			foreach( _PATH $ENV{VRDEV} $ENV{VISTA_EXTERNAL_LIBS} ${CMAKE_PREFIX_PATH} $ENV{CMAKE_PREFIX_PATH} )
				file( TO_CMAKE_PATH ${_PATH} _PATH )
				list( APPEND _SEARCH_PATHES_VERSIONED
						${_PATH}/${_FOLDER}/${_FOLDER}-${_REQUESTED_VERSION}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}/${_FOLDER}-${_REQUESTED_VERSION}
						${_PATH}/${_FOLDER}/${_FOLDER}.${_REQUESTED_VERSION}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}/${_FOLDER}.${_REQUESTED_VERSION}
						${_PATH}/${_FOLDER}/${_REQUESTED_VERSION}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}/${_REQUESTED_VERSION}
						${_PATH}/${_FOLDER}-${_REQUESTED_VERSION}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}-${_REQUESTED_VERSION}
						${_PATH}/${_FOLDER}.${_REQUESTED_VERSION}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}.${_REQUESTED_VERSION}
				)
				list( APPEND _SEARCH_PATHES_UNVERSIONED
						${_PATH}/${_FOLDER}/current/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}/current
						${_PATH}/${_FOLDER}/${VISTA_HWARCH}
						${_PATH}/${_FOLDER}
				)
			endforeach( _PATH $ENV{VRDEV} $ENV{VISTA_EXTERNAL_LIBS}  ${CMAKE_PREFIX_PATH} $ENV{CMAKE_PREFIX_PATH} )
		endforeach( _FOLDER _PACKAGE_FOLDER_NAMES )

		if( DEFINED _REQUESTED_VERSION )			
			set( ${_PACKAGE_NAME_UPPER}_ROOT_DIR "${_PACKAGE_NAME}DIR-NOTFOUND" )
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
		
		if( _ADVANCED )
			mark_as_advanced( ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
		endif( _ADVANCED )
	endif( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
endmacro( vista_find_package_root _PACKAGE_NAME _EXAMPLE_FILE )


