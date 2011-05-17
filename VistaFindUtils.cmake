# $Id$

include( VistaHWArchSettings )

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
		if( NOT ${INPUT_VERSION_PREFIX}_VERSION_NAME 
				OR ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
			set( _MATCHED TRUE )
		elseif( ${OWN_VERSION_PREFIX}_VERSION_TYPE STREQUAL "RELEASE" AND ( ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL "" ) )
				# for release, we accept either the matching name, or none at all
				set( _MATCHED TRUE )
		endif( NOT ${INPUT_VERSION_PREFIX}_VERSION_NAME 
				OR ${INPUT_VERSION_PREFIX}_VERSION_NAME STREQUAL ${OWN_VERSION_PREFIX}_VERSION_NAME )
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

# vista_find_package_dirs( PACKAGE_NAME EXAMPLE_FILE [NAMES folder1 folder2 ...])
macro( vista_find_package_dirs _PACKAGE_NAME _EXAMPLE_FILE )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	string( TOLOWER ${_PACKAGE_NAME} _PACKAGE_NAME_LOWER )

	set( _ARGS ${ARGV} )
	list( REMOVE_AT _ARGS 0 1 )

	if( WIN32 )
		set( _PACKAGE_FOLDER_NAMES ${_PACKAGE_NAME} )
	else()
		set( _PACKAGE_FOLDER_NAMES ${_PACKAGE_NAME} ${_PACKAGE_NAME_UPPER} ${_PACKAGE_NAME_LOWER} )
	endif( WIN32 )

	set( _NEXT_IS_FOLDER FALSE )
	foreach( _ARG ${_ARGS} )
		if( ${_ARG} STREQUAL "NAMES" )
			set( _NEXT_IS_FOLDER TRUE )
		elseif( _NEXT_IS_FOLDER )
			list( APPEND _PACKAGE_FOLDER_NAMES ${_ARG} )
		else()
			message( WARNING "vista_find_package_dirs() - unknown argument ${_ARG}" )
		endif( ${_ARG} STREQUAL "NAMES" )
	endforeach( _ARG ${_ARGS} )

	set( _SEARCH_DIRS	$ENV{${_PACKAGE_NAME_UPPER}_ROOT}
						$ENV{VRDEV}
						$ENV{VISTA_EXTERNAL_LIBS}
						${CMAKE_PREFIX_PATH}
						$ENV{CMAKE_PREFIX_PATH}
						${CMAKE_SYSTEM_PREFIX_PATH}
						$ENV{CMAKE_SYSTEM_PREFIX_PATH}
	)
	list( REMOVE_ITEM _SEARCH_DIRS "/" )

	set( ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS )
	set( ${_PACKAGE_NAME_UPPER}_CANDIDATE_VERSIONS )
	set( ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
	
	set( _VERSIONED_PATHES )
	set( _UNVERSIONED )
	
	if( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
		# check if PACKAGENAME_ROOT envvar is set and valid
		# if so, use it as unversioned
		if( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_VISTA_HWARCH}/${_EXAMPLE_FILE}" )
			set( _UNVERSIONED "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_VISTA_HWARCH}" )
		elseif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_EXAMPLE_FILE}" )
			set( _UNVERSIONED "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
		endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${_VISTA_HWARCH}/${_EXAMPLE_FILE}" )
	endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
	
	foreach( _PATH ${_SEARCH_DIRS} )
		foreach( _FOLDER ${_PACKAGE_FOLDER_NAMES} )
			# look for pathes with a version
			file( GLOB _TMP_PATHES "${_PATH}/${_FOLDER}/${_FOLDER}-*/" )
			list( APPEND _VERSIONED_PATHES ${_TMP_PATHES} )
			file( GLOB _TMP_PATHES "${_PATH}/${_FOLDER}-*/" )
			list( APPEND _VERSIONED_PATHES ${_TMP_PATHES} )
			
			# look for unversioned pathes
			if( NOT _UNVERSIONED )
				foreach( _HWARCH ${VISTA_COMPATIBLE_HWARCH} )
					if( EXISTS "${_PATH}/${_FOLDER}/${_HWARCH}/${_EXAMPLE_FILE}" )
						# ../NAME/NAME/HWARCH
						set( _UNVERSIONED "${_PATH}/${_FOLDER}/${_HWARCH}" )
						break()
					elseif( EXISTS "${_PATH}/${_HWARCH}/${_EXAMPLE_FILE}" )
						# ../NAME/HWARCH
						set( _UNVERSIONED "${_PATH}/${_HWARCH}" )
						break()
					endif( EXISTS "${_PATH}/${_FOLDER}/${_HWARCH}/${_EXAMPLE_FILE}" )
				endforeach( _HWARCH ${VISTA_COMPATIBLE_HWARCH} )
				
				if( NOT _UNVERSIONED )
					if( EXISTS "${_PATH}/${_FOLDER}/${_EXAMPLE_FILE}" )	
						# ../NAME/NAME
						set( _UNVERSIONED "${_PATH}/${_FOLDER}" )
					elseif( EXISTS "${_PATH}/${_EXAMPLE_FILE}" )
						# ../NAME
						set( _UNVERSIONED "${_PATH}" )
					endif( EXISTS "${_PATH}/${_FOLDER}/${_EXAMPLE_FILE}" )
				endif( NOT _UNVERSIONED )
			endif( NOT _UNVERSIONED )
		endforeach( _FOLDER ${_PACKAGE_FOLDER_NAMES} )
	endforeach( _PATH ${_SEARCH_DIRS} )
	
	if( _UNVERSIONED )
		file( TO_CMAKE_PATH ${_UNVERSIONED} ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
	endif( _UNVERSIONED )
	
	#check unversioned pathes
	foreach( _PATH ${_VERSIONED_PATHES} )
		file( TO_CMAKE_PATH ${_PATH} _PATH )		
		# determine version
		string( REGEX MATCH ".+\\-([0-9.a-zA-Z_\\.]+)$" _MATCHED ${_PATH} )
		if( _MATCHED )
			if( EXISTS "${_PATH}/${_EXAMPLE_FILE}" ) 
				list( APPEND ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS "${_PATH}" )
				list( APPEND ${_PACKAGE_NAME_UPPER}_CANDIDATE_VERSIONS ${CMAKE_MATCH_1} )
			else()
				foreach( _HWARCH ${VISTA_COMPATIBLE_HWARCH} )
					if( EXISTS "${_PATH}/${_HWARCH}/${_EXAMPLE_FILE}" )
						list( APPEND ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS "${_PATH}/${_HWARCH}" )
						list( APPEND ${_PACKAGE_NAME_UPPER}_CANDIDATE_VERSIONS ${CMAKE_MATCH_1} )
						break()
					endif( EXISTS "${_PATH}/${_HWARCH}/${_EXAMPLE_FILE}" )
				endforeach( _HWARCH ${VISTA_COMPATIBLE_HWARCH} )
			elseif( EXISTS "${_PATH}/${_EXAMPLE_FILE}" ) 
				
			endif( EXISTS "${_PATH}/${_EXAMPLE_FILE}" ) 
		else()
			message( WARNING "vista_find_package_dirs cant extract version from \"${_PATH}\" - skipping" )
		endif( _MATCHED )
	endforeach( _PATH ${_VERSIONED_PATHES} )				
			

	
endmacro( vista_find_package_dirs )

# vista_find_package_root( PACKAGE EXAMPLE_FILE [DONT_ALLOW_UNVERSIONED] [QUIET] [NAMES folder1 folder2 ...] [ADVANCED] [NO_CACHE])
macro( vista_find_package_root _PACKAGE_NAME _EXAMPLE_FILE )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	string( TOLOWER ${_PACKAGE_NAME} _PACKAGE_NAME_LOWER )

	if( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
		# parse arguments
		set( _DONT_ALLOW_UNVERSIONED FALSE )
		set( _QUIET FALSE )
		set( _ADVANCED FALSE )
		set( _NO_CACHE FALSE )
		
		set( _ARGS ${ARGV} )
		list( FIND _ARGS "NO_CACHE" _FOUND )
		if( _FOUND GREATER -1 )
			set( _NO_CACHE TRUE )
		endif( _FOUND GREATER -1 )
		list( FIND _ARGS "QUIET" _FOUND )
		if( _FOUND GREATER -1 )
			set( _QUIET TRUE )
		endif( _FOUND GREATER -1 )
		list( FIND _ARGS "ADVANCED" _FOUND )
		if( _FOUND GREATER -1 )
			set( _ADVANCED TRUE )
		endif( _FOUND GREATER -1 )
		list( FIND _ARGS "DONT_ALLOW_UNVERSIONED" _FOUND )
		if( _FOUND GREATER -1 )
			set( _DONT_ALLOW_UNVERSIONED TRUE )
		endif( _FOUND GREATER -1 )
		
		list( REMOVE_ITEM _ARGS "NO_CACHE" "QUIET" "ADVANCED" "DONT_ALLOW_UNVERSIONED" )
		
		#find package dirs
		vista_find_package_dirs( ${_ARGS} )
		
		set( _FOUND_DIR "${_PACKAGE_NAME_UPPER}_ROOT_DIR-NOTFOUND" )
		set( _FOUND_VERSION "" )
		
		# chech if a version is requested
		if( V${_PACKAGE_NAME}_FIND_VERSION_EXT )
			set( _REQUESTED_VERSION ${V${_PACKAGE_NAME}_FIND_VERSION_EXT} )
			set( _VERSION_EXACT ${V${_PACKAGE_NAME}_FIND_VERSION_EXACT} )
		elseif( V${_PACKAGE_NAME}_FIND_VERSION )
			set( _REQUESTED_VERSION ${V${_PACKAGE_NAME}_FIND_VERSION} )
			set( _VERSION_EXACT ${V${_PACKAGE_NAME}_FIND_VERSION_EXACT} )
		elseif( ${_PACKAGE_NAME}_FIND_VERSION_EXT )
			set( _REQUESTED_VERSION ${${_PACKAGE_NAME}_FIND_VERSION_EXT} )
			set( _VERSION_EXACT ${${_PACKAGE_NAME}_FIND_VERSION_EXACT} )
		elseif( ${_PACKAGE_NAME}_FIND_VERSION )
			set( _REQUESTED_VERSION ${${_PACKAGE_NAME}_FIND_VERSION} )
			set( _VERSION_EXACT ${${_PACKAGE_NAME}_FIND_VERSION_EXACT} )
		else()
			set( _REQUESTED_VERSION )
		endif( V${_PACKAGE_NAME}_FIND_VERSION_EXT )		
		
		if( _REQUESTED_VERSION )
			# parse requested version
			vista_string_to_version( ${_REQUESTED_VERSION} "_TEST_VERSION_IN" )
		
			set( _BEST_DIFF 999999999.999999999.999999999.999999999 )
		
			list( LENGTH ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS _COUNT )
			foreach( _INDEX RANGE ${_COUNT} )
				if( _INDEX STREQUAL _COUNT )
					break() # RANGE includes last value, so we have to skip this one
				endif( _INDEX STREQUAL _COUNT )
				list( GET ${_PACKAGE_NAME_UPPER}_CANDIDATE_VERSIONS ${_INDEX} _DIR_VERSION )
				vista_string_to_version( ${_DIR_VERSION} "_TEST_VERSION_DIR" )
				vista_compare_versions( "_TEST_VERSION_IN" "_TEST_VERSION_DIR" _VERSION_DIFFERENCE )
				if( _VERSION_DIFFERENCE VERSION_LESS _BEST_DIFF )
					set( _BEST_DIFF ${_VERSION_DIFFERENCE} )
					list( GET ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS ${_INDEX} _FOUND_DIR )
					set( _FOUND_VERSION ${_DIR_VERSION} )
				endif( _VERSION_DIFFERENCE VERSION_LESS _BEST_DIFF )
			endforeach( _INDEX RANGE ${_COUNT} )
						
			if( NOT _FOUND_DIR )
				if( NOT _DONT_ALLOW_UNVERSIONED AND ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
					set( _FOUND_DIR ${${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED} )
					set( _FOUND_VERSION )
					if( NOT _QUIET )
						message( STATUS "Package root for ${_PACKAGE_NAME} with version ${_REQUESTED_VERSION}"
									"could not be found - using unversioned root" )
					endif( NOT _QUIET )
				endif( NOT _DONT_ALLOW_UNVERSIONED AND ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
			elseif( _BEST_DIFF VERSION_GREATER 0.0.0.0 )
				# no exact match - not found if exact, wrning otherwise
				if( _VERSION_EXACT )
					set( _FOUND_DIR "${_PACKAGE_NAME_UPPER}_ROOT_DIR-NOTFOUND" )
				elseif( NOT QUIET )
					message( STATUS "Package ${_PACKAGE_NAME} not found with version ${_REQUESTED_VERSION} - "
									"using best matching version ${_FOUND_VERSION}" )
				endif( _VERSION_EXACT )
			endif( NOT _FOUND_DIR )
			
			
		else( _REQUESTED_VERSION )
			if( ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
				set( _FOUND_DIR ${${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED} )
				set( _FOUND_VERSION )
			else( ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )				
				set( _BEST_DIFF  )
				
				# find highest version
				list( LENGTH ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS _COUNT )
				foreach( _INDEX RANGE ${_COUNT} )
					if( _INDEX STREQUAL _COUNT ) 
						break() # RANGE includes last value, so we have to skip this one
					endif( _INDEX STREQUAL _COUNT )
					list( GET ${_PACKAGE_NAME_UPPER}_CANDIDATE_VERSIONS ${_INDEX} _DIR_VERSION )					
					vista_string_to_version( ${_DIR_VERSION} "_TEST_VERSION_DIR" )
					if( NOT _BEST_DIFF OR _DIR_VERSION VERSION_GREATER _BEST_DIFF )
						list( GET ${_PACKAGE_NAME_UPPER}_CANDIDATE_DIRS ${_INDEX} _FOUND_DIR )
						set( _FOUND_VERSION ${_DIR_VERSION} )
					endif( NOT _BEST_DIFF OR _DIR_VERSION VERSION_GREATER _BEST_DIFF )
				endforeach( _INDEX RANGE ${_COUNT} )
				
				if( _FOUND_DIR AND NOT _QUIET )
					message( STATUS "Unversioned package root for ${_PACKAGE_NAME} "
									"could not be found - instead using root with highest "
									"version ${_FOUND_VERSION}" )					
				endif( _FOUND_DIR AND NOT _QUIET )
			endif( ${_PACKAGE_NAME_UPPER}_CANDIDATE_UNVERSIONED )
		endif( _REQUESTED_VERSION )
		
		if( _NO_CACHE )
			set( ${_PACKAGE_NAME_UPPER}_ROOT_DIR ${_FOUND_DIR} )
		else( _NO_CACHE )
			set( ${_PACKAGE_NAME_UPPER}_ROOT_DIR ${_FOUND_DIR} 
					CACHE PATH "${_PACKAGE_NAME} package root dir" FORCE )
			if( _ADVANCED )
				mark_as_advanced( ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
			endif( _ADVANCED )
		endif( _NO_CACHE )
		
		if( DEFINED "${_FOUND_VERSION}" )
			set( ${_PACKAGE_NAME_UPPER}_VERSION_STRING ${_FOUND_VERSION} )
			vista_string_to_version( ${_FOUND_VERSION} "${_PACKAGE_NAME_UPPER}" )
		endif( DEFINED "${_FOUND_VERSION}" )
		
	endif( NOT ${_PACKAGE_NAME_UPPER}_ROOT_DIR )
endmacro( vista_find_package_root _PACKAGE_NAME _EXAMPLE_FILE )

#vista_find_unchached_library( ...find_library_parameters... )
# usage is a little special: call exactly as find_library, but WITHOUT the target variable
# the output will be stored in the (uncached) variable VISTA_UNCACHED_LIBRARY
macro( vista_find_library_uncached )
	set( VISTA_UNCACHED_LIB_SEARCH_VARIABLE "DIR-NOTFOUND" CACHE INTERNAL "" FORCE )
	find_library( VISTA_UNCACHED_LIB_SEARCH_VARIABLE ${ARGV} )
	set( VISTA_UNCACHED_LIBRARY ${VISTA_UNCACHED_LIB_SEARCH_VARIABLE} )
	set( VISTA_UNCACHED_LIB_SEARCH_VARIABLE "DIR-NOTFOUND" CACHE INTERNAL "" FORCE )
endmacro()

