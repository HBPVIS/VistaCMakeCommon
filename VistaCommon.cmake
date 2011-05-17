# $Id$

# This file contains common settings and macros for setting up Vista projects

# PACKAGE MACROS
# find_package_versioned( PACKAGE_NAME _EXTENDED_VERSION_NAME ... )
# vista_use_package( PACKAGE [VERSION] [EXACT] [[COMPONENTS | REQUIRED] comp1 comp2 ... ] [QUIET] [FIND_DEPENDENCIES] )
# vista_configure_app( _PACKAGE_NAME )
# vista_configure_lib( _PACKAGE_NAME )
# vista_install( TARGET [INCLUDE_SUBDIRECTORY [LIBRARY_SUBDIRECTORY] ] )
# vista_install_files_by_extension( SEARCH_ROOT INSTALL_SUBDIR EXTENSION1 [EXTENSION2 ...] )
# vista_create_cmake_configs( TARGET [CUSTOM_CONFIG_FILE] )
# vista_set_outdir( TARGET DIRECTORY )
# vista_set_version( PACKAGE TYPE NAME [ MAJOR [ MINOR [ PATCH [ TWEAK ]]]] )
# vista_adopt_version( PACKAGE ADOPT_PARENT )

# UTILITY MACROS
# vista_set_defaultvalue( ... )
# vista_conditional_add_subdirectory( VARIABLE_NAME DIRECTORY [ON|OFF] [ADVANCED [MSG string] )
# vista_get_svn_revision( TARGET_VARIABLE )
# replace_svn_revision_tag( STRING )

# GENERAL SETTINGS
# adds info variables
#	FIRST_CONFIGURATION_RUN - true if this is the first configuration run (!!)
#	VISTA_HWARCH			- current os/hardware/compiler architecture
#	VISTA_COMPATIBLE_HWARCH - current os/hardware/compiler architectures that are compatible
#	VISTA_64BIT				- TRUE if 64BIT-System, FALSE on 32bit
# adds some general flags/configurations
#	sets CMAKE_DEBUG_POSTFIX to "D"
#	enables global cmake property USE_FOLDERS - allows grouping of projects in msvc
#	conditionally adds DEBUG and OS definitions
#	some visual studio flags
#	VISTA_USE_RPATH cache flag to enable/disable use of RPATH
#	currently scans XYZConfig.cmake files in VISTA_CMAKE_COMMON/shared, and deletes outdated ones


# avoid multiply includions (for performance reasons )
if( NOT VISTA_COMMON_INCLUDED )
set( VISTA_COMMON_INCLUDED TRUE )

#this package sets the variables VISTA_HWARCH, VISTA_COMPATIBLE_HWARCH and VISTA_64BIT
include( VistaHWArchSettings )

###########################
###   Utility macros    ###
###########################

# vista_set_defaultvalue( ... )
# macro for overriding default values of pre-initialized variables
# sets the variable using the same sysntax as set, but only on the first configuration run
macro( vista_set_defaultvalue )
	if( FIRST_CONFIGURE_RUN )
		set( _ARGS "" )
		list( APPEND _ARGS ${ARGV} )
		list( FIND _ARGS FORCE _FORCE_FOUND )
		if( ${_FORCE_FOUND} EQUAL -1 )
			set( ${_ARGS} FORCE )
		else( ${_FORCE_FOUND} EQUAL -1 )
			set( ${_ARGS} )
		endif( ${_FORCE_FOUND} EQUAL -1 )
	endif( FIRST_CONFIGURE_RUN )
endmacro( vista_set_defaultvalue )

# vista_add_files_to_source_list( TARGET_LIST ROOT_DIR [source_group SOURCE_GROUP] EXTENSION1 [EXTENSION2 ...] )
# searches files with any of the passed extensions in the specified root_dir. These files are added to the 
# passed list. If the source_group option is given, the files are also added to the specified source group.
# IMPORTANT NOTE: due to cmake's string replacement hicka-di-hoo, if you want to use subfolders in your sourcegroups,
# you'll have to use 4(!) backslashes as separator (e.g. "folder\\\\subfolder")
macro( vista_add_files_to_sources _TARGET_LIST _SEARCH_ROOT )
	set( _EXTENSIONS ${ARGV} )		

	if( ${ARGV2} STREQUAL "source_group" )
		set( _SOURCE_GROUP ${ARGV3} )
		list( REMOVE_AT _EXTENSIONS 0 1 2 3 )
	else()
		set( _SOURCE_GROUP )
		list( REMOVE_AT _EXTENSIONS 0 1 )
	endif( ${ARGV2} STREQUAL "source_group" )
	
	set( _FOUND_FILES )
	foreach( _EXT ${_EXTENSIONS} )
		file( GLOB_RECURSE _FOUND_FILES "${_SEARCH_ROOT}/*.${_EXT}" "${_SEARCH_ROOT}/**/*.${_EXT}" )
		list( APPEND ${_TARGET_LIST} ${_FOUND_FILES} )
		if( _SOURCE_GROUP )
			source_group( ${_SOURCE_GROUP} FILES ${_FOUND_FILES} )
		endif( _SOURCE_GROUP )
	endforeach( _EXT ${_EXTENSIONS} )	
endmacro( vista_add_files_to_sources )


# vista_conditional_add_subdirectory( VARIABLE_NAME DIRECTORY [ON|OFF] [ADVANCED [MSG string] )
# creates a cache bool variable with the specified name and cache message, initialized to the desired
# valeu (defaults to ON ). ADVANCED marks the cache variable as advenced. Nothing is done if the specified
# directory does not exist
macro( vista_conditional_add_subdirectory )
	if( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" )	
		set( _VISTA_CONDITIONAL_SET_STATE ON )
		set( _VISTA_CONDITIONAL_SET_ADVANCED FALSE )
		set( _VISTA_CONDITIONAL_SET_MSG "Build the ${ARGV1} library" )
		set( _VISTA_CONDITIONAL_SET_MSG_NEXT FALSE )
		set( _VISTA_CONDITIONAL_ADD_TO_LIST_NEXT FALSE )
		set( _APPEND_TO_LIST "" )
		
		foreach( _ARG ${ARGV} )
			if( _VISTA_CONDITIONAL_SET_MSG_NEXT )
				set( _VISTA_CONDITIONAL_SET_MSG ${_ARG} ${ARGV0} )
				set( _VISTA_CONDITIONAL_SET_MSG_NEXT FALSE )
			elseif( _VISTA_CONDITIONAL_ADD_TO_LIST_NEXT )
				set( _VISTA_CONDITIONAL_ADD_TO_LIST_NEXT FALSE )
				set( _APPEND_TO_LIST ${_ARG} )
			elseif( ${_ARG} STREQUAL "ON" )
				set( _VISTA_CONDITIONAL_SET_STATE ON )
			elseif( ${_ARG} STREQUAL "OFF" )
				set( _VISTA_CONDITIONAL_SET_STATE OFF )
			elseif( ${_ARG} STREQUAL "ADVANCED" )
				set( _VISTA_CONDITIONAL_SET_ADVANCED TRUE )
			elseif( ${_ARG} STREQUAL "MSG" )
				set( _VISTA_CONDITIONAL_SET_MSG_NEXT TRUE )
			elseif( ${_ARG} STREQUAL "ADD_TO_LIST" )
				set( _VISTA_CONDITIONAL_ADD_TO_LIST_NEXT TRUE )
			endif( _VISTA_CONDITIONAL_SET_MSG_NEXT )
		endforeach( _ARG ${ARGV} )	
		
		set( ${ARGV0} ${_VISTA_CONDITIONAL_SET_STATE} CACHE BOOL "${_VISTA_CONDITIONAL_SET_MSG}" )
		if( _VISTA_CONDITIONAL_SET_ADVANCED )
			mark_as_advanced( ${ARGV0} )
		endif( _VISTA_CONDITIONAL_SET_ADVANCED )
		
		if( ${ARGV0} )
			add_subdirectory( ${ARGV1} )
			if( _APPEND_TO_LIST )
				list( APPEND ${_APPEND_TO_LIST} ${ARGV1} )
			endif( _APPEND_TO_LIST )
		endif( ${ARGV0} )
	endif( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" )	
endmacro( vista_conditional_add_subdirectory )


# vista_get_svn_revision( TARGET_VARIABLE )
# extracts the svn revision from the file system and stores it in the specified target variable
macro( vista_get_svn_revision _TARGET_VAR )
	set( ${_TARGET_VAR} )
	if( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.svn/entries" )
		 file( STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/.svn/entries" _FILE_ENTRIES LIMIT_COUNT 10 )
		 set( _NEXT_IS_SVN FALSE )
		 set( _FOUND FALSE )
		 foreach( _STRING ${_FILE_ENTRIES} )
			if( NOT _FOUND AND ${_STRING} STREQUAL "dir" )
				set( _NEXT_IS_SVN TRUE )
			elseif( _NEXT_IS_SVN )
				set( ${_TARGET_VAR} ${_STRING} )
				set( _NEXT_IS_SVN FALSE )
				set( _FOUND TRUE )
			endif( NOT _FOUND AND ${_STRING} STREQUAL "dir" )
		 endforeach( _STRING ${_FILE_ENTRIES} )
	endif( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/.svn/entries" )
endmacro( vista_get_svn_revision )

# local macro, for use in this file only
function( local_clean_old_config_references _PACKAGE_NAME _PACKAGE_TARGET_FILE _EXCLUDE_DIR )
	string( TOUPPER _PACKAGE_NAME_UPPER ${_PACKAGE_NAME} )	
	set( PACKAGE_REFERENCE_EXISTS_TEST TRUE )
	
	set( _OWN_FILE "${_EXCLUDE_DIR}/${_PACKAGE_NAME}Config.cmake" )
	file( GLOB_RECURSE _ALL_VERSION_FILES "${VISTA_CMAKE_COMMON}/shared/${_PACKAGE_NAME}*/${_PACKAGE_NAME}Config.cmake" )
	foreach( _FILE ${_ALL_VERSION_FILES} )
		file( TO_CMAKE_PATH ${_FILE} _FILE )
		if( NOT _FILE STREQUAL _OWN_FILE )
			include( ${_FILE} )
			if( PACKAGE_REFERENCE_OUTDATED OR "${_PACKAGE_TARGET_FILE}" STREQUAL "${${_PACKAGE_NAME_UPPER}_REFERENCED_FILE}" )
				string( REGEX MATCH "(${VISTA_CMAKE_COMMON}/shared/.+)/.*" _MATCHED ${_FILE} )
				if( _MATCHED )
					set( _DIR ${CMAKE_MATCH_1} )			
					message( STATUS "Removing old config reference copied to \"${_DIR}\"" )
					file( REMOVE_RECURSE ${_DIR} )
				endif( _MATCHED )
			endif( PACKAGE_REFERENCE_OUTDATED OR "${_PACKAGE_TARGET_FILE}" STREQUAL "${${_PACKAGE_NAME_UPPER}_REFERENCED_FILE}" )
		endif( NOT _FILE STREQUAL _OWN_FILE )
	endforeach( _FILE ${_ALL_VERSION_FILES} )
	
	set( PACKAGE_REFERENCE_EXISTS_TEST )
endfunction( local_clean_old_config_references _PACKAGE_NAME _PACKAGE_ROOT_DIR )

# local macro, for use in this file only
function( local_use_existing_config_libs _NAME _ROOT_DIR _CONFIG_FILE _LIBRARY_DIR_LIST )
	string( TOUPPER ${_NAME} _NAME_UPPER )
	if( EXISTS "${_CONFIG_FILE}" )		
		include( ${_CONFIG_FILE} )
		if( "${${_NAME_UPPER}_ROOT_DIR}" STREQUAL "${_ROOT_DIR}" )
			if( ${_NAME_UPPER}_LIBRARY_DIRS )
				list( APPEND ${_LIBRARY_DIR_LIST} ${${_NAME_UPPER}_LIBRARY_DIRS} )
				list( REMOVE_DUPLICATES ${_LIBRARY_DIR_LIST} )
			endif( ${_NAME_UPPER}_LIBRARY_DIRS )
		endif( "${${_NAME_UPPER}_ROOT_DIR}" STREQUAL "${_ROOT_DIR}" )
	endif( EXISTS "${_CONFIG_FILE}" )
	set( ${_LIBRARY_DIR_LIST} ${${_LIBRARY_DIR_LIST}} PARENT_SCOPE )
endfunction( local_use_existing_config_libs )



###########################
###   Package macros    ###
###########################

# find_package_versioned( PACKAGE_NAME _EXTENDED_VERSION_NAME ... )
# works like the normal find_package, but allows to use an extended version
# works for both module and config mode - specialist API!
# Usually, use vista-find_package instead
macro( find_package_versioned _PACKAGE_NAME _VERSION_NAME )
	set( _ARGS_LIST ${ARGV} )
	list( REMOVE_ITEM _ARGS_LIST ${_PACKAGE_NAME} ${_VERSION_NAME} )
	set( ${_PACKAGE_NAME}_FIND_VERSION_EXT ${_VERSION_NAME} )
	set( PACKAGE_FIND_VERSION_EXT ${_VERSION_NAME} )
	find_package( ${_PACKAGE_NAME} 0.0.0 ${_ARGS_LIST} )
	set( PACKAGE_FIND_VERSION_EXT )	
	set( ${_PACKAGE_NAME}_FIND_VERSION_EXT )
endmacro( find_package_versioned _PACKAGE_NAME _VERSION_NAME )

macro( vista_find_package _PACKAGE_NAME )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )	
	
	# parse arguments
	set( _FIND_PACKAGE_ARGS )
	set( _FIND_DEPENDENCIES FALSE )
	set( _PACKAGE_VERSION )
	set( _PACKAGE_COMPONENTS )
	set( _QUIET FALSE )
	set( _REQUIRED FALSE )
	set( _USING_COMPONENTS FALSE )
	set( _NO_MODULE FALSE )
	foreach( _ARG ${ARGV} )			
		if( ${_ARG} STREQUAL "FIND_DEPENDENCIES" )
			set( _PARSE_COMPONENTS FALSE )
			set( _FIND_DEPENDENCIES TRUE )
		elseif( ${_ARG} STREQUAL "QUIET" )
			set( _PARSE_COMPONENTS FALSE )
			list( APPEND _FIND_PACKAGE_ARGS "QUIET" )
			set( _QUIET TRUE )
		elseif( ${_ARG} STREQUAL "REQUIRED" )
			set( _PARSE_COMPONENTS TRUE )
			list( APPEND _FIND_PACKAGE_ARGS "REQUIRED" )
			set( _REQUIRED TRUE )
		elseif( ${_ARG} STREQUAL "COMPONENTS" )
			set( _PARSE_COMPONENTS TRUE )
			list( APPEND _FIND_PACKAGE_ARGS "COMPONENTS" )
		elseif( ${_ARG} STREQUAL "EXACT" )
			set( _PARSE_COMPONENTS FALSE )
			list( APPEND _FIND_PACKAGE_ARGS "EXACT" )
		elseif( ${_ARG} STREQUAL "NO_POLICY_SCOPE" )
			set( _PARSE_COMPONENTS FALSE )
			list( APPEND _FIND_PACKAGE_ARGS "NO_POLICY_SCOPE" )	
		elseif( ${_ARG} STREQUAL "NO_MODULE" )
			set( _NO_MODULE TRUE )
			list( APPEND _FIND_PACKAGE_ARGS "NO_MODULE" )	
		elseif( ${_ARG} STREQUAL "${ARGV0}" )
			# it's okay, just the name
		elseif( ${_ARG} STREQUAL "${ARGV1}" )
			# the requested version
			set( _PACKAGE_VERSION ${_ARG} )
		elseif( _PARSE_COMPONENTS )
			list( APPEND _FIND_PACKAGE_ARGS ${_ARG} )
			list( APPEND _PACKAGE_COMPONENTS ${_ARG} )
			set( _USING_COMPONENTS TRUE )
		else()
			message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Unknown argument [${_ARG}]" )
		endif( ${_ARG} STREQUAL "FIND_DEPENDENCIES" )
	endforeach( _ARG ${ARGV} )
	
	set( _DO_FIND TRUE )
	
	if( ${_PACKAGE_NAME_UPPER}_FOUND )
	
		if( "${${_PACKAGE_NAME_UPPER}_FOUND_VERSION}" AND "${_PACKAGE_VERSION}" )
			# we have to check that we don't include different versions!
			if( NOT ${${_PACKAGE_NAME_UPPER}_FOUND_VERSION} STREQUAL ${_PACKAGE_VERSION} )
				message( WARNING "vista_find_package( ${_PACKAGE_NAME} - Requested version \"${_PACKAGE_VERSION}\",
						but was already found with version \"${${_PACKAGE_NAME_UPPER}_FOUND_VERSION}\"  
						\n\tpreviously found version will be used again" )
				set( _PACKAGE_VERSION ${${_PACKAGE_NAME_UPPER}_FOUND_VERSION} )
			endif( NOT ${_PACKAGE_NAME_UPPER}_FOUND_VERSION STREQUAL ${_PACKAGE_VERSION} )
		endif( "${${_PACKAGE_NAME_UPPER}_FOUND_VERSION}" AND "${_PACKAGE_VERSION}" )
		
		if( _PARSE_COMPONENTS )
			# we need to check if the components are already included or not
			# NOTE: this relies on the Find<Package> or <Package>Config file to
			# correctly set the PACKAGE_FOUND_COMPONENTS variable - otherwise, a rerun
			# will be performed even if previous finds were sufficient
			foreach( _COMPONENT ${_PACKAGE_COMPONENTS} )
				list( FIND PACKAGE_FOUND_COMPONENTS ${_COMPONENT} _COMPONENT_FOUND )
				if( NOT _COMPONENT_FOUND )
					set( _DO_FIND TRUE )
					break()
				endif( NOT _COMPONENT_FOUND )
			endforeach( _COMPONENT ${_PACKAGE_COMPONENTS} )
		endif( _PARSE_COMPONENTS )
		
	endif( ${_PACKAGE_NAME_UPPER}_FOUND )
		
	if( _DO_FIND )		
		
		if( _PACKAGE_VERSION )
			# check if it is a "normal" or an extended version
			string( REGEX MATCH "^[0-9\\.]*$" _MATCH ${_PACKAGE_VERSION} )
			if( NOT _MATCH )
				# its an extended version
				set( PACKAGE_FIND_VERSION_EXT ${_PACKAGE_VERSION} )
				set( ${_PACKAGE_NAME}_FIND_VERSION_EXT ${_PACKAGE_VERSION} )
				set( V${_PACKAGE_NAME}_FIND_VERSION_EXT ${_PACKAGE_VERSION} )
				set( _PACKAGE_VERSION 0.0.0.0 )
			endif( NOT _MATCH )
		endif( _PACKAGE_VERSION )
		
		# there can be three differnet options
		# - there is a Vista-custom FindV<PackageName>.cmake
		# - there is a generic Find<PackageName>.cmake
		# - if none of the above, we use config mode
		# however, we skip the first two steps if no module should be found
		set( _FIND_VMODULE_EXISTS FALSE )
		set( _FIND_MODULE_EXISTS FALSE )
		if( NOT _NO_MODULE )
			foreach( _PATH ${CMAKE_MODULE_PATH} )
				if( EXISTS "${_PATH}/FindV${_PACKAGE_NAME}.cmake" )
					set( _FIND_VMODULE_EXISTS TRUE )					
				endif( EXISTS "${_PATH}/FindV${_PACKAGE_NAME}.cmake" )
				if( EXISTS "${_PATH}/Find${_PACKAGE_NAME}.cmake" )
					set( _FIND_MODULE_EXISTS TRUE )					
				endif( EXISTS "${_PATH}/Find${_PACKAGE_NAME}.cmake" )
			endforeach( _PATH ${CMAKE_MODULE_PATH} )
		endif( NOT _NO_MODULE )
		
		

		if( _FIND_VMODULE_EXISTS )
			find_package( V${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} )
			set( ${_PACKAGE_NAME_UPPER}_FOUND V${_PACKAGE_NAME_UPPER}_FOUND )
		elseif( _FIND_MODULE_EXISTS )
			find_package( ${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} )
		else( _FIND_VMODULE_EXISTS )
			# we look for additional directories to search for the config files
			# we also search for CoreLibs directories manually	
			set( _SEARCH_PREFIXES )
			if( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
				list( APPEND _SEARCH_PREFIXES
						"$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${VISTA_HWARCH}"
						"$ENV{${_PACKAGE_NAME_UPPER}_ROOT}"
				)
			endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
			if( EXISTS "$ENV{VRDEV}" )
				list( APPEND _SEARCH_PREFIXES
						"$ENV{VRDEV}/${_PACKAGE_NAME}*/${VISTA_HWARCH}"
						"$ENV{VRDEV}/${_PACKAGE_NAME}*"
						"$ENV{VRDEV}/${_PACKAGE_NAME}/*/${VISTA_HWARCH}"
						"$ENV{VRDEV}/${_PACKAGE_NAME}/*/" 
				)
			endif( EXISTS "$ENV{VRDEV}" )
			
			foreach( _PATH ${_SEARCH_PREFIXES} )
				file( GLOB _TMP_FILES "${_PATH}/cmake/${_PACKAGE_NAME}Config.cmake" )
				foreach( _FILE ${_TMP_FILES} )
					file( TO_CMAKE_PATH ${_FILE} _FOUND_FILE )
					string( REPLACE "/cmake/${_PACKAGE_NAME}Config.cmake" "" _FOUND_PATH ${_FOUND_FILE} )
					file( TO_CMAKE_PATH ${_FOUND_PATH} _FOUND_PATH )
					list( APPEND ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS ${_FOUND_PATH} )
				endforeach( _FILE ${_TMP_FILES} )		
			endforeach( _PATH ${_PREFIX_PATHES} )
			if( ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
				list( REMOVE_DUPLICATES ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
			endif( ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
	
			find_package( ${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} 
							PATHS ${${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS} )
		endif( _FIND_VMODULE_EXISTS )
				
	endif( _DO_FIND )
endmacro( vista_find_package )


# vista_use_package( PACKAGE [VERSION] [EXACT] [[COMPONENTS | REQUIRED] comp1 comp2 ... ] [QUIET] [FIND_DEPENDENCIES] )
# finds the desired Package and automatically sets the include dirs, library dirs, definitions for the project
# libraries have to be included using the VARIABLE PACKAGENAME_LIBRARIES. Alternatively, VISTA_USE_PACKAGE_LIBRARIES contains
# all libraries that have linked by vista_use_package calls
# buildsystem-specific variables. Works like find_package - taking the name, and optionally
# VERSION - string describing the version - either the normal cmake-format XX.YY.ZZ.WW or the vista-specific extended version string
# EXACT specifies that the version has to be matched exactly
# REQUIRED specifies that the package must be found to continue. can optionally be followed by a list of required components
# COMPONENTS can be followed by a list of optional, desired components
# QUIET suppresses any warnings and other output except for errors
# FIND_DEPENDENCIES If set, all packages that are required by the included packages are tried to be found and used automatically
macro( vista_use_package _PACKAGE_NAME )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )

	# check if we need to rerun. this is the case it has not been used yet,
	# or if it has been used, but now additional dependencies are requested
	set( _REQUIRES_RERUN TRUE )	
	if( VISTA_USE_${_PACKAGE_NAME_UPPER} )
		# extract components, to see if they are met already or not
		set( _REQUESTED_COMPONENTS )
		set( _PARSE_COMPONENTS FALSE )
		set( _COMPONENTS_FOUND FALSE )
		foreach( _ARG ${ARGV} )			
			if( ${_ARG} STREQUAL "COMPONENTS" OR ${_ARG} STREQUAL "REQUIRED" )
				set( _PARSE_COMPONENTS TRUE )
			elseif( ${_ARG} STREQUAL "QUIET"
					OR ${_ARG} STREQUAL "EXACT"
					OR ${_ARG} STREQUAL "NO_POLICY_SCOPE" )
				set( _PARSE_COMPONENTS FALSE )
			elseif( _PARSE_COMPONENTS )
				list( APPEND _REQUESTED_COMPONENTS ${_ARG} )
				set( _COMPONENTS_FOUND TRUE )
			endif( ${_ARG} STREQUAL "FIND_DEPENDENCIES" )
		endforeach( _ARG ${ARGV} )
		
		# todo: check against components
		if( NOT _COMPONENTS_FOUND )
			set( _REQUIRES_RERUN FALSE )
			# todo: check version
		endif( NOT _COMPONENTS_FOUND )			
		
	endif( VISTA_USE_${_PACKAGE_NAME_UPPER} )
		
	if( _REQUIRES_RERUN )	
		# package has not yet been used
	
		# we firstextract some parameters, then try to find the package		
		
		set( _ARGUMENTS ${ARGV} )
	
		# parse arguments
		list( FIND _ARGUMENTS "FIND_DEPENDENCIES" _FIND_DEPENDENCIES_FOUND )
		if( _FIND_DEPENDENCIES_FOUND )
			set( _FIND_DEPENDENCIES TRUE )
			list( REMOVE_ITEM _ARGUMENTS "FIND_DEPENDENCIES" )
		else( _FIND_DEPENDENCIES_FOUND )
			set( _FIND_DEPENDENCIES FALSE )
		endif( _FIND_DEPENDENCIES_FOUND )
		
		list( FIND _ARGUMENTS "QUIET" _QUIET_FOUND )
		if( _QUIET_FOUND )
			set( _QUIET TRUE )
		else( _QUIET_FOUND )
			set( _QUIET FALSE )
		endif( _QUIET_FOUND )
			
		# finding will handle differences to already run find's
		vista_find_package( ${ARGV} )
						
		#if found - set required variables
		if( ${_PACKAGE_NAME_UPPER}_FOUND )
			# if a USE_FILE is specified, we assume that it handles all the settings
			# if not, we set the necessary values ourselves
			if( ${_PACKAGE_NAME_UPPER}_USE_FILE )
				include( ${${_PACKAGE_NAME_UPPER}_USE_FILE} )
			else()
				include_directories( ${${_PACKAGE_NAME_UPPER}_INCLUDE_DIRS} )
				link_directories( ${${_PACKAGE_NAME_UPPER}_LIBRARY_DIRS} )
				add_definitions( ${${_PACKAGE_NAME_UPPER}_DEFINITIONS} )
			endif( ${_PACKAGE_NAME_UPPER}_USE_FILE )
			
			
		
			
			# check if HWARCH matches
			if( ${_PACKAGE_NAME_UPPER}_HWARCH AND NOT ${${_PACKAGE_NAME_UPPER}_HWARCH} STREQUAL ${VISTA_HWARCH} )
				message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package was built as ${${_PACKAGE_NAME_UPPER}_HWARCH}, but is used with ${VISTA_HWARCH}" )
			endif( ${_PACKAGE_NAME_UPPER}_HWARCH AND NOT ${${_PACKAGE_NAME_UPPER}_HWARCH} STREQUAL ${VISTA_HWARCH} )
			
			#set variables for Vista BuildSystem to track dependencies
			list( APPEND VISTA_USE_PACKAGE_LIBRARIES ${${_PACKAGE_NAME_UPPER}_LIBRARIES} )
			# TODO: removing duplicates also removes optimized and debug flags...
			#list( REMOVE_DUPLICATES VISTA_USE_PACKAGE_LIBRARIES )
			list( APPEND VISTA_TARGET_LINK_DIRS ${${_PACKAGE_NAME_UPPER}_LIBRARY_DIRS} )
			if( VISTA_TARGET_LINK_DIRS )
				list( REMOVE_DUPLICATES VISTA_TARGET_LINK_DIRS )
			endif( VISTA_TARGET_LINK_DIRS )
			list( APPEND VISTA_TARGET_DEPENDENCIES "package" ${ARGV} )
			set( VISTA_USING_${_PACKAGE_NAME_UPPER} TRUE )
			
			# we dont want to add second-level dependencies to VISTA_TARGET_DEPENDENCIES, so be buffer it and reset it later
			set( _TMP_VISTA_TARGET_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} )
						
			#handle dependencies
			set( _DEPENDENCY_ARGS )
			foreach( _DEPENDENCY ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES} )
				string( REGEX MATCH "^([^\\-]+)\\-(.+)$" _MATCHED ${_DEPENDENCY} )
				if( _DEPENDENCY STREQUAL "package" )
					if( _DEPENDENCY_ARGS AND NOT "${_DEPENDENCY_ARGS}" STREQUAL "" )
						list( GET _DEPENDENCY_ARGS 0 _DEPENDENCY_NAME )
						string( TOUPPER "${_DEPENDENCY_NAME}" _DEPENDENCY_NAME_UPPER )
						if( _FIND_DEPENDENCIES )
							if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
								# find and use the dependency. If it fails, utter a warning
								if( NOT _QUIET )
									message( STATUS "Automatically adding ${_PACKAGE_NAME}-dependency \"${_DEPENDENCY_ARGS}\"" )
								endif( NOT _QUIET )
								vista_use_package( ${_DEPENDENCY_ARGS} FIND_DEPENDENCIES )
								if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
									message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY_ARGS}\", but including it failed" )
								endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
							endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
						else( _FIND_DEPENDENCIES )
							# check if dependencies are already included. If not, utter a warning					
							if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
								message( "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY_ARGS}\", which was not found yet" )
							endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
						endif( _FIND_DEPENDENCIES )
						set( _DEPENDENCY_ARGS )
					endif( _DEPENDENCY_ARGS AND NOT "${_DEPENDENCY_ARGS}" STREQUAL ""  )
				else()
					list( APPEND _DEPENDENCY_ARGS ${_DEPENDENCY} )
				endif( _DEPENDENCY STREQUAL "package" )
			endforeach( _DEPENDENCY ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES} )
			
			# again, since the last package was not yet included
			if( _DEPENDENCY_ARGS AND NOT "${_DEPENDENCY_ARGS}" STREQUAL "" )
				list( GET _DEPENDENCY_ARGS 0 _DEPENDENCY_NAME )
				string( TOUPPER "${_DEPENDENCY_NAME}" _DEPENDENCY_NAME_UPPER )
				if( _FIND_DEPENDENCIES )
					if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
						# find and use the dependency. If it fails, utter a warning
						if( NOT _QUIET )
							message( STATUS "Automatically adding ${_PACKAGE_NAME}-dependency \"${_DEPENDENCY_ARGS}\"" )
						endif( NOT _QUIET )
						vista_use_package( ${_DEPENDENCY_ARGS} FIND_DEPENDENCIES )
						if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
							message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY_ARGS}\", but including it failed" )
						endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
					endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
				else( _FIND_DEPENDENCIES )
					# check if dependencies are already included. If not, utter a warning					
					if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
						message( "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY_ARGS}\", which was not found yet" )
					endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
				endif( _FIND_DEPENDENCIES )
			endif( _DEPENDENCY_ARGS AND NOT "${_DEPENDENCY_ARGS}" STREQUAL ""  )

			#restore dependencies as they were before FIND_DEPENDENCY calls
			set( VISTA_TARGET_DEPENDENCIES ${_TMP_VISTA_TARGET_DEPENDENCIES} )			
			
		endif( ${_PACKAGE_NAME_UPPER}_FOUND )	
	endif( _REQUIRES_RERUN )
	
endmacro( vista_use_package _PACKAGE_NAME )

# vista_configure_app( _PACKAGE_NAME [OUT_NAME] )
# sets some general properties for the target to configure it as application
#	sets default value for CMAKE_INSTALL_PREFIX (if not set otherwise) to source directory
#	sets the Application Name to _PACKAGE_NAME with "D"-PostFix under Debug
#	if not overwritten, sets the outdir to the target's source directory
#	creates a shell script that sets the path to find required libraries
#	for MSVC, a *.vcproj.user file is created, setting Working Directory and Path Environment
macro( vista_configure_app _PACKAGE_NAME )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
		vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE PATH "distribution directory" FORCE )
		set( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE )
	endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	
	set( ${_PACKAGE_NAME}_TARGET_TYPE "APP" )
	
	set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${_PACKAGE_NAME} CACHE INTERNAL "" FORCE )
	if( ${ARGC} GREATER 1 )
		set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${ARGV1} CACHE INTERNAL "" FORCE )
	endif( ${ARGC} GREATER 1 )

	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME_DEBUG			"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}${CMAKE_DEBUG_POSTFIX}" )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME_RELEASE			"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME_MINSIZEREL 		"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME_RELWITHDEBINFO	"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME					"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
	
	if( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_PACKAGE_NAME} ${CMAKE_CURRENT_SOURCE_DIR} )
	else( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
	endif( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
	
	# we store the dependencies as required
	set( ${_PACKAGE_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	# create a script that sets the path
	if( VISTA_TARGET_LINK_DIRS )
		if( WIN32 )
			find_file( VISTA_ENVIRONMENT_SCRIPT_FILE "set_path.bat_proto" ${CMAKE_MODULE_PATH} )
			mark_as_advanced( VISTA_ENVIRONMENT_SCRIPT_FILE )
			if( VISTA_ENVIRONMENT_SCRIPT_FILE )
				configure_file(
						${VISTA_ENVIRONMENT_SCRIPT_FILE}
						${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_PACKAGE_NAME}.bat
						@ONLY
				)
			endif( VISTA_ENVIRONMENT_SCRIPT_FILE )
		elseif( UNIX )
			find_file( VISTA_ENVIRONMENT_SCRIPT_FILE "set_path.sh_proto" ${CMAKE_MODULE_PATH} )
			mark_as_advanced( VISTA_ENVIRONMENT_SCRIPT_FILE )
			if( VISTA_ENVIRONMENT_SCRIPT_FILE )
				configure_file(
						${VISTA_ENVIRONMENT_SCRIPT_FILE}
						${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_PACKAGE_NAME}.sh
						@ONLY
				)
			endif( VISTA_ENVIRONMENT_SCRIPT_FILE )
		endif( WIN32 )
	endif( VISTA_TARGET_LINK_DIRS )
		
	#if we're usign MSVC, we set up a *.vcproj.user file
	if( MSVC )
		find_file( VISTA_VCPROJUSER_PROTO_FILE "VisualStudio.vcproj.user_proto" ${CMAKE_MODULE_PATH} )
		set( VISTA_VCPROJUSER_PROTO_FILE ${VISTA_VCPROJUSER_PROTO_FILE} CACHE INTERNAL "" )
		if( VISTA_VCPROJUSER_PROTO_FILE )
			if( VISTA_64BIT )
				set( _CONFIG_NAME "x64" )
			else( VISTA_64BIT )
				set( _CONFIG_NAME "Win32" )
			endif( VISTA_64BIT )
			
			if( MSVC80 )
				set( _VERSION_STRING "8,00" )
			elseif( MSVC90 )
				set( _VERSION_STRING "9,00" )
			elseif( MSVC10 )
				set( _VERSION_STRING "10,00" )
			endif( MSVC80 )
			
			set( _WORK_DIR ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
		
			set( _ENVIRONMENT )
			if( VISTA_TARGET_LINK_DIRS )
				set( _ENVIRONMENT "PATH=${VISTA_TARGET_LINK_DIRS};%PATH%" )
			endif( VISTA_TARGET_LINK_DIRS )
			
			configure_file(
				${VISTA_VCPROJUSER_PROTO_FILE}
				${CMAKE_CURRENT_BINARY_DIR}/${_PACKAGE_NAME}.vcproj.user
				@ONLY
			)
		else( VISTA_VCPROJUSER_PROTO_FILE )
			message( WARNING "vista_configure_app( ${_PACKAGE_NAME} ) - could not find file VisualStudio.vcproj.user_proto" )
		endif( VISTA_VCPROJUSER_PROTO_FILE )
	endif( MSVC )
endmacro( vista_configure_app )

# vista_configure_lib( _PACKAGE_NAME [OUT_NAME] )
# sets some general properties for the target to configure it as application
#	sets default value for CMAKE_INSTALL_PREFIX (if not set otherwise) to /dist/VISTA_HWARCH
#	if not overwritten, sets the outdir to the target's source directory
#	adds *_EXPORT or *_STATIC definition
macro( vista_configure_lib _PACKAGE_NAME )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )

	if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
		vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE PATH "distribution directory" FORCE )
		set( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE )
	endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	
	set( ${_PACKAGE_NAME}_TARGET_TYPE "LIB" )
	
	set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${_PACKAGE_NAME} CACHE INTERNAL "" FORCE )
	if( ${ARGC} GREATER 1 )
		set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${ARGV1} CACHE INTERNAL "" FORCE )
	endif( ${ARGC} GREATER 1 )

	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME	"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
		
	if( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_PACKAGE_NAME} "${CMAKE_BINARY_DIR}/lib" )	
	else( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
	endif( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
	
	# we store the dependencies as required
	set( ${_PACKAGE_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	
	string( TOUPPER ${_PACKAGE_NAME} _NAME_UPPER )
	vista_set_defaultvalue( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries if ON, static libraries if OFF" FORCE )
	if( WIN32 )
		if( BUILD_SHARED_LIBS )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES COMPILE_FLAGS -D${_NAME_UPPER}_EXPORTS )
		else( BUILD_SHARED_LIBS )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES COMPILE_FLAGS -D${_NAME_UPPER}_STATIC )
		endif( BUILD_SHARED_LIBS )	
	endif( WIN32 )
endmacro( vista_configure_lib _PACKAGE_NAME)

# vista_install( TARGET [INCLUDE/BIN_SUBDIRECTORY [LIBRARY_SUBDIRECTORY] ] [NO_POSTFIX] )
# can only be called after vista_configure_[app|lib]
# installs generic files (headers, librarys, executables, .pdb's)
# headers will be installed to include, or to include/INCLUDE_SUBDIRECTORY, maintaining their
# local subfolder in the project (excluding folders names src, source, or include)
# libraries/dlls will be installed to lib, or to lib/LIBRARY_SUBDIRECTORY
# executables will be installed in a /bin/BIN_SUBDIR subdir
# all the postfixes (bin/lib/include) can be prevented by adding the NO_POSTFIX option
macro( vista_install _PACKAGE_NAME )
	
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	
	set( _USE_POSTFIX TRUE )
	set( _ARGS ${ARGV} )
	list( FIND _ARGS "NO_POSTFIX" _NO_POSTFIX_FOUND_FOUND )
	if( _NO_POSTFIX_FOUND_FOUND GREATER -1 )
		set( _USE_POSTFIX FALSE )
	endif( _NO_POSTFIX_FOUND_FOUND GREATER -1 )
	
	if( _USE_POSTFIX )
		set( ${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR "${CMAKE_INSTALL_PREFIX}/include" ) 
		set( ${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR "${CMAKE_INSTALL_PREFIX}/lib" ) 
		set( ${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR "${CMAKE_INSTALL_PREFIX}/bin" )
	else( _USE_POSTFIX )
		set( ${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR "${CMAKE_INSTALL_PREFIX}" ) 
		set( ${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR "${CMAKE_INSTALL_PREFIX}" ) 
		set( ${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR "${CMAKE_INSTALL_PREFIX}" ) 
	endif( _USE_POSTFIX )
	
	if( ${ARGC} GREATER 1 AND NOT ${ARGV1} STREQUAL "NO_POSTFIX"  )
		set( ${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR "${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR}/${ARGV1}" )
		set( ${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR "${${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR}/${ARGV1}" )
	endif( ${ARGC} GREATER 1 AND NOT ${ARGV1} STREQUAL "NO_POSTFIX"  )
	
	if( ${ARGC} GREATER 2 AND NOT ${ARGV2} STREQUAL "NO_POSTFIX" )
		set( ${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR "${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}/${ARGV2}" )
	endif( ${ARGC} GREATER 2 AND NOT ${ARGV2} STREQUAL "NO_POSTFIX"  )
	
	if( ${_PACKAGE_NAME}_TARGET_TYPE STREQUAL "APP" )
		install( TARGETS ${_PACKAGE_NAME}
			RUNTIME DESTINATION ${${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR}
		)
	else( ${_PACKAGE_NAME}_TARGET_TYPE STREQUAL "APP" )
		install( TARGETS ${_PACKAGE_NAME}
			LIBRARY DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}
			ARCHIVE DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}
			RUNTIME DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}
		)
		get_target_property( _SOURCE_FILES ${_PACKAGE_NAME} SOURCES )
		set( _HEADER_FILES )		
		foreach( _FILE ${_SOURCE_FILES} )
			get_filename_component( _EXTENSION_TMP ${_FILE} EXT )
			string( TOLOWER ${_EXTENSION_TMP} _EXTENSION )
			if( "${_EXTENSION}" STREQUAL ".h" )
				get_filename_component( _PATH ${_FILE} PATH )
				string( REPLACE "src" "" _PATH "${_PATH}" )
				string( REPLACE "source" "" _PATH "${_PATH}" )
				string( REPLACE "include" "" _PATH "${_PATH}" )
				install( FILES 	${_FILE} DESTINATION "${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR}/${_PATH}"	)
			endif( "${_EXTENSION}" STREQUAL ".h" )
		endforeach( _FILE _SOURCE_FILES )

		if( MSVC )
			install( DIRECTORY "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/"
				DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}
				FILES_MATCHING PATTERN "*.pdb"
				PATTERN "build" EXCLUDE
				PATTERN ".svn" EXCLUDE
				PATTERN "CMakeFiles" EXCLUDE
			)
		endif( MSVC )
	endif( ${_PACKAGE_NAME}_TARGET_TYPE STREQUAL "APP" )	
endmacro()

# vista_install_files_by_extension( SEARCH_ROOT INSTALL_SUBDIR EXTENSION1 [EXTENSION2 ...] )
# searches in SEARCH_ROOT dor all files matching any of the provided extensions, and 
# installs them to the specified Subdir
# NOTE: files are searched at configure time, not at install time! Thus, if you add a file
# matching the pattern, you have to configure cmake again to add it to the list of files to
# install
macro( vista_install_files_by_extension _SEARCH_ROOT _INSTALL_SUBDIR )
	set( _EXTENSIONS )
	foreach( _ARG ${ARGV} )
		if( NOT "${_ARG}" STREQUAL "${ARGV0}" AND NOT "${_ARG}" STREQUAL "${ARGV2}" )
			list( APPEND _EXTENSIONS ${_ARG} )
		endif( NOT "${_ARG}" STREQUAL "${ARGV0}" AND NOT "${_ARG}" STREQUAL "${ARGV2}" )
	endforeach( _ARG ${ARGV} )
	foreach( _EXT ${_EXTENSIONS} )
		file( GLOB_RECURSE _FOUND_FILES "${_SEARCH_ROOT}/*.${_EXT}" "${_SEARCH_ROOT}/**/*.${_EXT}" )
		install( FILES ${_FOUND_FILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${_INSTALL_SUBDIR} )
	endforeach( _EXT ${_EXTENSIONS} )	
endmacro( vista_install_files_by_extension )



# vista_create_cmake_config( PACKAGE_NAME CONFIG_PROTO_FILE TARGET_DIR )
macro( vista_create_cmake_config_build _PACKAGE_NAME _CONFIG_PROTO_FILE _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	
	# store the directory - it may be used by the versioning lateron
	set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR ${_TARGET_DIR} )
	
	#if VISTA_CMAKE_COMMON exisits, we give the user the cache options to toggle copying of references
	# to CISTA_CMAKE_COMMON/shared on and off
	if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )
		set( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON TRUE CACHE BOOL 
			"if enabled, References to <Package>Config.cmake files will be copied to VistaCMakeCommon/shared for easier finding" )
	endif( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )	
	
	
	# configure the temporary variables for configuring
	
	set( _PACKAGE_LIBRARY_NAME ${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME} )
	
	# check if the library outdir should be overwritten
	set( _PACKAGE_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
	if( ${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR )
		set( _PACKAGE_LIBRARY_DIRS ${${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR} )
	else()
		set( _PACKAGE_LIBRARY_DIRS ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
	endif( ${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR )
	if( ${_PACKAGE_NAME_UPPER}_INCLUDE_OUTDIR )
		set( _PACKAGE_INCLUDE_DIRS ${${_PACKAGE_NAME_UPPER}_INCLUDE_OUTDIR} )
	else()
		set( _PACKAGE_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}"  )	
		list( REMOVE_DUPLICATES _PACKAGE_INCLUDE_DIRS )
	endif( ${_PACKAGE_NAME_UPPER}_INCLUDE_OUTDIR )
	
	# if we should create a referenced config file, we create it's target dir
	if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR "${VISTA_CMAKE_COMMON}/shared/${_PACKAGE_NAME}" )
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR 
					"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}-${${_PACKAGE_NAME_UPPER}_VERSION_EXT}-build" )
		else( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR 
					"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}-${VISTA_HWARCH}-build" )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
		
		# if any reference already exists, we aparse it and append its library dirs to the current one
		# this helps if several different build types are used in different cmake-build-dirs, but
		local_use_existing_config_libs( ${_PACKAGE_NAME} ${_PACKAGE_ROOT_DIR} 
									"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}/${_PACKAGE_NAME}Config.cmake" 
									_PACKAGE_LIBRARY_DIRS )	
	endif( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
	
	# retrieve relative pathes for library/include dirs
	set( _PACKAGE_RELATIVE_INCLUDE_DIRS )
	foreach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
		file( RELATIVE_PATH _REL_DIR ${_PACKAGE_ROOT_DIR} ${_DIR} )		
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS ${_REL_DIR} )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
	
	set( _PACKAGE_RELATIVE_LIBRARY_DIRS )
	foreach( _DIR ${_PACKAGE_LIBRARY_DIRS} )
		file( RELATIVE_PATH _REL_DIR ${_PACKAGE_ROOT_DIR} ${_DIR} )		
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS ${_REL_DIR} )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_LIBRARY_DIRS} )
	
	#get_filename_component( _PATH_UP "${CMAKE_CURRENT_SOURCE_DIR}/.." REALPATH  )
	#list( APPEND _PACKAGE_INCLUDE_DIR ${_PATH_UP} )
	#list( REMOVE_DUPLICATES _PACKAGE_INCLUDE_DIR )	
	
	set( _TARGET_FILENAME "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR}/${_PACKAGE_NAME}Config.cmake" )
	
	#  configure the actual file
	configure_file(	${_CONFIG_PROTO_FILE} ${_TARGET_FILENAME} @ONLY )
	
	#if we should create the reference - do so now
	set( _REFERENCED_FILE ${_TARGET_FILENAME} )
	if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		# since prior configure runs may have already added it (before the cache was turned off), we
		# delete any prior copied versions to this location
		local_clean_old_config_references( ${_PACKAGE_NAME} ${_REFERENCED_FILE} ${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR} )
		# find proto file
		find_file( VISTA_REFERENCE_CONFIG_PROTO_FILE "PackageConfigReference.cmake_proto" PATH ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_REFERENCE_CONFIG_PROTO_FILE ${VISTA_REFERENCE_CONFIG_PROTO_FILE} CACHE INTERNAL "" FORCE )
		if( VISTA_REFERENCE_CONFIG_PROTO_FILE )
			# configure the actual reference file			
			set( _REFERENCE_TARGET_FILENAME "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}/${_PACKAGE_NAME}Config.cmake" )
			configure_file(	${VISTA_REFERENCE_CONFIG_PROTO_FILE} ${_REFERENCE_TARGET_FILENAME} @ONLY )
		endif( VISTA_REFERENCE_CONFIG_PROTO_FILE )
	else( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		# since prior configure runs may have already added it (before the cache was turned off), we
		# delete any prior copied versions to this location
		local_clean_old_config_references( ${_PACKAGE_NAME} ${_REFERENCED_FILE} "" )
	endif( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
endmacro( vista_create_cmake_config_build )

# vista_create_cmake_config_install( PACKAGE_NAME CONFIG_PROTO_FILE  )
macro( vista_create_cmake_config_install _PACKAGE_NAME _CONFIG_PROTO_FILE _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	
	# store the directory - it may be used by the versioning lateron
	set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR ${_TARGET_DIR} )
	
	#if VISTA_CMAKE_COMMON exisits, we give the user the cache options to toggle copying of references
	# to VISTA_CMAKE_COMMON/shared on and off
	if( EXISTS ${VISTA_CMAKE_COMMON} )
		set( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON TRUE CACHE BOOL 
			"if enabled, References to <Package>Config.cmake files will be copied to VistaCMakeCommon/shared for easier finding" )
	endif( EXISTS ${VISTA_CMAKE_COMMON} )	

	
	# configure the temporary variables for configuring
	
	set( _PACKAGE_LIBRARY_NAME ${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME} )
	
	set( _TARGET_FILENAME "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}Config.cmake" )
	set( _TARGET_REF_FILENAME "${CMAKE_BINARY_DIR}/toinstall/references/${_PACKAGE_NAME}Config.cmake" )

	set( _PACKAGE_ROOT_DIR "${CMAKE_INSTALL_PREFIX}" )
	if( ${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR} )
		set( _PACKAGE_INCLUDE_DIRS "${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR}" )		
	else( ${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR} )
		set( _PACKAGE_INCLUDE_DIRS "${_PACKAGE_ROOT_DIR}/include" )		
	endif( ${${_PACKAGE_NAME_UPPER}_INC_INSTALLDIR} )
	if( ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR} )
		set( _PACKAGE_LIBRARY_DIRS "${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR}" )
	else( ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR} )
		set( _PACKAGE_LIBRARY_DIRS "${_PACKAGE_ROOT_DIR}/lib" )
	endif( ${${_PACKAGE_NAME_UPPER}_LIB_INSTALLDIR} )
	
	#retrieve relative pathes for library/include dirs
	set( _PACKAGE_RELATIVE_INCLUDE_DIRS )
	foreach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
		file( RELATIVE_PATH _REL_DIR ${_PACKAGE_ROOT_DIR} ${_DIR} )
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS ${_REL_DIR} )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
	
	set( _PACKAGE_RELATIVE_LIBRARY_DIRS )
	foreach( _DIR ${_PACKAGE_LIBRARY_DIRS} )
		file( RELATIVE_PATH _REL_DIR ${_PACKAGE_ROOT_DIR} ${_DIR} )		
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS ${_REL_DIR} )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_LIBRARY_DIRS} )
			
	set( _TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}Config.cmake" )
	# configure the actual file to a local folder, and add it for install
	configure_file(	${_CONFIG_PROTO_FILE} ${_TEMPORARY_FILENAME} @ONLY )
	install( FILES ${_TEMPORARY_FILENAME} DESTINATION "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR}" )
	
	
	
	set( _REFERENCED_FILE "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR}/${_PACKAGE_NAME}Config.cmake" )
	
	
	if( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )		
		# find proto file
		find_file( VISTA_REFERENCE_CONFIG_PROTO_FILE "PackageConfigReference.cmake_proto" PATH ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_REFERENCE_CONFIG_PROTO_FILE ${VISTA_REFERENCE_CONFIG_PROTO_FILE} CACHE INTERNAL "" FORCE )
		
		#determine dir (and store it for later use of versions)
		set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR "${VISTA_CMAKE_COMMON}/shared/${_PACKAGE_NAME}" )
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}-${${_PACKAGE_NAME_UPPER}_VERSION_EXT}-install" )
		else( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}-${VISTA_HWARCH}-install" )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )	
	
		if( VISTA_REFERENCE_CONFIG_PROTO_FILE )
			#eliminate older installed configs
			local_clean_old_config_references( ${_PACKAGE_NAME} ${_REFERENCED_FILE} ${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR} )
			# configure the reference file
			set( _TEMPORARY_REF_FILENAME "${CMAKE_BINARY_DIR}/toinstall/references/${_PACKAGE_NAME}Config.cmake" )			
			configure_file(	${VISTA_REFERENCE_CONFIG_PROTO_FILE} ${_TARGET_REF_FILENAME} @ONLY )
			install( FILES ${_TARGET_REF_FILENAME} DESTINATION ${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR} )
		endif( VISTA_REFERENCE_CONFIG_PROTO_FILE )
	else( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
		# since prior configure runs may have already added it (before the cache was turned off), we
		# delete any prior copied versions to this location
		local_clean_old_config_references( ${_PACKAGE_NAME} ${_REFERENCED_FILE} "" )
	endif( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
endmacro( vista_create_cmake_config_install )

# vista_create_version_config ( PACKAGE_NAME VERSION_PROTO_FILE 
macro( vista_create_version_config _PACKAGE_NAME _VERSION_PROTO_FILE )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	
	find_file( VISTA_REFERENCE_CONFIG_PROTO_FILE "PackageConfigReference.cmake_proto" PATH ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
	set( VISTA_REFERENCE_CONFIG_PROTO_FILE ${VISTA_REFERENCE_CONFIG_PROTO_FILE} CACHE INTERNAL "" FORCE )
	
	set( _PACKAGE_LIBRARY_NAME ${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME} )
	
	if( EXISTS ${_VERSION_PROTO_FILE} )
		set( _VERSION_TYPE 	${${_PACKAGE_NAME_UPPER}_VERSION_TYPE} )
		set( _VERSION_NAME 	${${_PACKAGE_NAME_UPPER}_VERSION_NAME} )
		set( _VERSION_MAJOR ${${_PACKAGE_NAME_UPPER}_VERSION_MAJOR} )
		set( _VERSION_MINOR ${${_PACKAGE_NAME_UPPER}_VERSION_MINOR} )
		set( _VERSION_PATCH ${${_PACKAGE_NAME_UPPER}_VERSION_PATCH} )
		set( _VERSION_TWEAK ${${_PACKAGE_NAME_UPPER}_VERSION_TWEAK} )
		set( _VERSION 		${${_PACKAGE_NAME_UPPER}_VERSION} )
		set( _VERSION_EXT 	${${_PACKAGE_NAME_UPPER}_VERSION_EXT} )
		
		if( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR )
			set( _BUILD_VERSION_TARGET "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR}/${_PACKAGE_NAME}ConfigVersion.cmake" )
			configure_file( ${_VERSION_PROTO_FILE} ${_BUILD_VERSION_TARGET} @ONLY )
			
			if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
				set( _REFERENCED_FILE ${_BUILD_VERSION_TARGET} )
				set( _REFERENCE_TARGET_FILENAME "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}/${_PACKAGE_NAME}ConfigVersion.cmake" )
				configure_file( ${VISTA_REFERENCE_CONFIG_PROTO_FILE} ${_REFERENCE_TARGET_FILENAME} @ONLY )
			endif( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		endif( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR )
		
		if( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR )
			set( _TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}ConfigVersion.cmake" )
			set( _INSTALL_DIR  ${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR} )
			configure_file( ${_VERSION_PROTO_FILE} ${_TEMPORARY_FILENAME} @ONLY )
			install( FILES ${_TEMPORARY_FILENAME} DESTINATION ${_INSTALL_DIR} )
			
			if( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
				set( _REFERENCED_FILE "${_INSTALL_DIR}/${_PACKAGE_NAME}ConfigVersion.cmake" )
				set( _REFERENCE_TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/references/${_PACKAGE_NAME}ConfigVersion.cmake" )
				configure_file( ${VISTA_REFERENCE_CONFIG_PROTO_FILE} ${_REFERENCE_TEMPORARY_FILENAME} @ONLY )
				install( FILES ${_REFERENCE_TEMPORARY_FILENAME} DESTINATION ${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR} )
			endif( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
		endif( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR )		
		
	endif( EXISTS ${_VERSION_PROTO_FILE} )	
endmacro( vista_create_version_config )

# vista_create_cmake_configs( TARGET [CUSTOM_CONFIG_FILE_BUILD [CUSTOM_CONFIG_FILE_INSTALL] ] )
# can only be called after vista_configure_[app|lib]
# generates XYZConfig.cmake-files for the target, either from a generic prototype or
# from the optional specified one. Each configfile is created twice: one for the build version, and one
# for the install version, which point to different locations
# If the VISTA_CMAKE_ROOT environment variable is set, the XYZConfig.cmake files will also be copied to
# VISTA_CMAKE_ROOT/shared into a subfolder composed from the name, the (optional) version, and either -build or -install
# NOTE: these will be overwritten at the next configure/install, so make sure different versions of the same project
# have different version names
# In Addition to the XYZConfig.cmake files, a generic XYZConfigVersion.cmake file is created if the version has been specified
# using vista_set_version() or vista_adopt_version(), in the same way as the Config files
macro( vista_create_cmake_configs _TARGET )
	set( _PACKAGE_NAME ${_TARGET} )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	set( _PRECONDITION_FAIL false )
	
	if( ${ARGC} GREATER 1 )	
		if( EXISTS ${ARGV1} )
			#use for custom config file		
			set( _CONFIG_PROTO_FILE_BUILD ${ARGV1} )
			if( ${ARGC} GREATER 2 )
				if( EXISTS ${ARGV2} )
					set( _CONFIG_PROTO_FILE_INSTALL ${ARGV2} )
				else( EXISTS ${ARGV2} )
					message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find config file \"${ARGV2}\"" )
					set( _PRECONDITION_FAIL TRUE )
				endif( EXISTS ${ARGV2} )
			else()
				set( _CONFIG_PROTO_FILE_INSTALL ${ARGV1} )
			endif( ${ARGC} GREATER 2 )			
		else( EXISTS ${ARGV1} )
			message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find config file \"${ARGV1}\"" )
			set( _PRECONDITION_FAIL TRUE )
		endif( EXISTS ${ARGV1} )
	else( ${ARGC} GREATER 1 )
		#use default config file
		find_file( VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD "PackageConfig-build.cmake_proto" PATHS ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD ${VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD} CACHE INTERNAL "Default Prototype file for <Package>Config.cmake in build config" FORCE )
		find_file( VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL "PackageConfig-build.cmake_proto" PATHS ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL ${VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL} CACHE INTERNAL "Default Prototype file for <Package>Config.cmake in install config" FORCE )
				
		if( NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD OR NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL )
			message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find default config file PackageConfig.cmake_proto" )
			set( _PRECONDITION_FAIL TRUE )
		endif( NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD OR NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL )
		set( _CONFIG_PROTO_FILE_BUILD ${VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD} )
		set( _CONFIG_PROTO_FILE_INSTALL ${VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL} )
	endif( ${ARGC} GREATER 1 )


	if( NOT _PRECONDITION_FAIL )		
		vista_create_cmake_config_build( ${_PACKAGE_NAME}
											"${_CONFIG_PROTO_FILE_BUILD}"
											"${CMAKE_BINARY_DIR}/cmake" )
		vista_create_cmake_config_install( ${_PACKAGE_NAME}
											"${_CONFIG_PROTO_FILE_INSTALL}"
											"${CMAKE_INSTALL_PREFIX}/cmake" )
		
		# if there is a version set, we also configure the corresponding version file
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			find_file( VISTA_VERSION_PROTO_FILE "PackageConfigVersion.cmake_proto" PATHS ${CMAKE_MODULE_PATH} )
			set( VISTA_VERSION_PROTO_FILE ${VISTA_VERSION_PROTO_FILE} CACHE INTERNAL "" )
			if( VISTA_VERSION_PROTO_FILE )
				vista_create_version_config( ${_PACKAGE_NAME} "${VISTA_VERSION_PROTO_FILE}"
											"${CMAKE_BINARY_DIR}/cmake/${_PACKAGE_NAME}ConfigVersion.cmake" )				
			endif( VISTA_VERSION_PROTO_FILE )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )			
		
	endif( NOT _PRECONDITION_FAIL )
endmacro( vista_create_cmake_configs )

# vista_set_outdir( TARGET DIRECTORY )
# sets the outdir of the target to the directory
# should be used after calling vista_configuer_[app|lib]
macro( vista_set_outdir _PACKAGE_NAME _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
	set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${_TARGET_DIR} )
	if( NOT VISTA_${_PACKAGE_NAME}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME}_TARGET_TYPE STREQUAL "LIB" )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${_TARGET_DIR} )
	endif( NOT VISTA_${_PACKAGE_NAME}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME}_TARGET_TYPE STREQUAL "LIB" )
	set( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR ${_TARGET_DIR} CACHE INTERNAL "" FORCE )
endmacro( vista_set_outdir _PACKAGE_NAME TARGET_DIR )

# vista_set_version( PACKAGE TYPE NAME [ MAJOR [ MINOR [ PATCH [ TWEAK ]]]] )
# sets the extended version info for the package
# TYPE has to be RELEASE, HEAD, BRANCH, or TAG
# NAME can be an arbitrary name (excluding character -)
# MAJOR, MINOR, PATCH, TWEAK are optional version numbers. If svn_rev is specified, an svn revision is extracted if possible
macro( vista_set_version _PACKAGE _TYPE _NAME )
	string( TOUPPER  ${_PACKAGE} _PACKAGE_UPPER )
	set( ${_PACKAGE_UPPER}_VERSION_TYPE		${_TYPE} )
	set( ${_PACKAGE_UPPER}_VERSION_NAME		${_NAME} )		
	
	if( ${ARGC} GREATER 3 )		
		if( ${ARGV3} STREQUAL "svn_rev" )
			vista_get_svn_revision( ${_PACKAGE_UPPER}_VERSION_MAJOR )
		else( ${ARGV3} STREQUAL "svn_rev" )
			set( ${_PACKAGE_UPPER}_VERSION_MAJOR ${ARGV3} )
		endif( ${ARGV3} STREQUAL "svn_rev" )
		set( ${_PACKAGE_UPPER}_VERSION			"${${_PACKAGE_UPPER}_VERSION_MAJOR}" )
	endif( ${ARGC} GREATER 3 )
	if( ${ARGC} GREATER 4 )
		if( ${ARGV4} STREQUAL "svn_rev" )
			vista_get_svn_revision( ${_PACKAGE_UPPER}_VERSION_MINOR )
		else( ${ARGV4} STREQUAL "svn_rev" )
			set( ${_PACKAGE_UPPER}_VERSION_MINOR ${ARGV4} )
		endif( ${ARGV4} STREQUAL "svn_rev" )
		set( ${_PACKAGE_UPPER}_VERSION			"${${_PACKAGE_UPPER}_VERSION}.${${_PACKAGE_UPPER}_VERSION_MINOR}" )		
	endif( ${ARGC} GREATER 4 )
	if( ${ARGC} GREATER 5 )
		if( ${ARGV5} STREQUAL "svn_rev" )
			vista_get_svn_revision( ${_PACKAGE_UPPER}_VERSION_PATCH )
		else( ${ARGV5} STREQUAL "svn_rev" )
			set( ${_PACKAGE_UPPER}_VERSION_PATCH ${ARGV5} )
		endif( ${ARGV5} STREQUAL "svn_rev" )
		set( ${_PACKAGE_UPPER}_VERSION			"${${_PACKAGE_UPPER}_VERSION}.${${_PACKAGE_UPPER}_VERSION_PATCH}" )		
	endif( ${ARGC} GREATER 5 )
	if( ${ARGC} GREATER 6 )
		if( ${ARGV6} STREQUAL "svn_rev" )
			vista_get_svn_revision( ${_PACKAGE_UPPER}_VERSION_TWEAK )
		else( ${ARGV6} STREQUAL "svn_rev" )
			set( ${_PACKAGE_UPPER}_VERSION_TWEAK 	${ARGV6} )
		endif( ${ARGV6} STREQUAL "svn_rev" )
		set( ${_PACKAGE_UPPER}_VERSION			"${${_PACKAGE_UPPER}_VERSION}.${${_PACKAGE_UPPER}_VERSION_TWEAK}" )
	endif( ${ARGC} GREATER 6 )
	
	set( ${_PACKAGE_UPPER}_VERSION_EXT			"${${_PACKAGE_UPPER}_VERSION_TYPE}_${${_PACKAGE_UPPER}_VERSION_NAME}" )
	if( DEFINED ${_PACKAGE_UPPER}_VERSION )
		set( ${_PACKAGE_UPPER}_VERSION_EXT		"${${_PACKAGE_UPPER}_VERSION_EXT}-${${_PACKAGE_UPPER}_VERSION}" )
	endif( DEFINED ${_PACKAGE_UPPER}_VERSION )
	set( ${_PACKAGE_UPPER}_VERSION_EXT			"${${_PACKAGE_UPPER}_VERSION_EXT}-${VISTA_HWARCH}" )
endmacro( vista_set_version _PACKAGE _TYPE _NAME )

# vista_adopt_version( PACKAGE ADOPT_PARENT )
# sets the version of the package to the one of the adopt parent
macro( vista_adopt_version _NAME _ADOPT_PARENT )
	string( TOUPPER ${_NAME} _NAME_UPPER )
	string( TOUPPER ${_ADOPT_PARENT} _ADOPT_UPPER )
	
	if( ${_ADOPT_UPPER}_VERSION_EXT )
		set( ${_NAME_UPPER}_VERSION_TYPE		${${_ADOPT_UPPER}_VERSION_TYPE} )
		set( ${_NAME_UPPER}_VERSION_NAME		${${_ADOPT_UPPER}_VERSION_NAME} )
		set( ${_NAME_UPPER}_VERSION				${${_ADOPT_UPPER}_VERSION} )
		set( ${_NAME_UPPER}_VERSION_EXT			${${_ADOPT_UPPER}_VERSION_EXT} )
		set( ${_NAME_UPPER}_VERSION_MAJOR		${${_ADOPT_UPPER}_VERSION_MAJOR} )
		set( ${_NAME_UPPER}_VERSION_MINOR		${${_ADOPT_UPPER}_VERSION_MINOR} )
		set( ${_NAME_UPPER}_VERSION_PATCH		${${_ADOPT_UPPER}_VERSION_PATCH} )
		set( ${_NAME_UPPER}_VERSION_TWEAK		${${_ADOPT_UPPER}_VERSION_TWEAK} )
	else( ${_ADOPT_UPPER}_VERSION_EXT )
		message( WARNING "vista_adopt_version( ${_NAME} ${_ADOPT_PARENT} ) - cannot find version info for parent!" )
	endif( ${_ADOPT_UPPER}_VERSION_EXT )
endmacro( vista_adopt_version _NAME _ADOPT_PARENT )




###########################
###   General Settings  ###
###########################

	if( EXISTS "${VISTA_CMAKE_COMMON}" )
		list( APPEND CMAKE_MODULE_PATH "${VISTA_CMAKE_COMMON}/shared" )
		list( APPEND CMAKE_PREFIX_PATH "${VISTA_CMAKE_COMMON}" "${VISTA_CMAKE_COMMON}/shared" )
	endif( EXISTS "${VISTA_CMAKE_COMMON}" )

	if( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
		set( ALREADY_CONFIGURED_ONCE TRUE CACHE INTERNAL "defines if this is the first config run or not" )
		set( FIRST_CONFIGURE_RUN TRUE )
	else( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
		set( FIRST_CONFIGURE_RUN FALSE )
	endif( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )	

	set( CMAKE_DEBUG_POSTFIX "D" )
	set_property( GLOBAL PROPERTY USE_FOLDERS ON )
	set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG" )

	if( UNIX )
		# Should we use rpath? This enables us to use OpenSG etc. within the Vista* libraries without having
		# to set a LIBRARY_PATH while linking against these libraries
		set( VISTA_USE_RPATH ON CACHE BOOL "Automatically set the rpath for external libs" )
		if( VISTA_USE_RPATH )
			set( CMAKE_SKIP_BUILD_RPATH FALSE )
			set( CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE )
		else( VISTA_USE_RPATH )
			set( CMAKE_SKIP_RPATH TRUE )
		endif( VISTA_USE_RPATH )
	endif( UNIX )

	# Platform dependent definitions
	if( UNIX )
		add_definitions( -DLINUX )
	elseif( WIN32 )
		add_definitions( -DWIN32 )
		if( MSVC )
			vista_set_defaultvalue( CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "CMake configuration types" )
			# msvc disable some warnings
			set( VISTA_DISABLE_GENERIC_MSVC_WARNINGS ON CACHE BOOL "If true, generic warnings (4251, 4275, 4503, CRT_SECURE_NO_WARNINGS) will be set for Visual Studio" )
			mark_as_advanced( VISTA_DISABLE_GENERIC_MSVC_WARNINGS )
			if( VISTA_DISABLE_GENERIC_MSVC_WARNINGS )
				add_definitions( /D_CRT_SECURE_NO_WARNINGS /wd4251 /wd4275 /wd4503 )
			endif( VISTA_DISABLE_GENERIC_MSVC_WARNINGS )
			#Enable string pooling
			add_definitions( -GF )
			# Parallel build for Visual Studio?
			set( VISTA_USE_PARALLEL_MSVC_BUILD ON CACHE BOOL "Add /MP flag for parallel build on Visual Studio" )
			mark_as_advanced( VISTA_USE_PARALLEL_MSVC_BUILD )
			if( VISTA_USE_PARALLEL_MSVC_BUILD )
				add_definitions( /MP )
			else()
				remove_definitions(/MP)
			endif(VISTA_USE_PARALLEL_MSVC_BUILD)
			# Check for sse optimization
			if( NOT VISTA_64BIT )
				set( VISTA_USE_MSVC_SSE_OPTIMIZATION ON CACHE BOOL "Use automatic SSE2 optimizations of Visual Studio")
				mark_as_advanced( VISTA_USE_MSVC_SSE_OPTIMIZATION )
				if( VISTA_USE_MSVC_SSE_OPTIMIZATION )
					add_definitions( /arch:SSE2 )
				else()
					remove_definitions( /arch:SSE2 )
				endif( VISTA_USE_MSVC_SSE_OPTIMIZATION )
			endif( NOT VISTA_64BIT )
		endif( MSVC )
	endif( UNIX )


	# TODO: think where to put this
	if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )
		set( VISTA_CHECKED_COPIED_CONFIG_FILES TRUE )
		set( PACKAGE_REFERENCE_EXISTS_TEST TRUE )
		file( GLOB_RECURSE _ALL_VERSION_FILES "$ENV{VISTA_CMAKE_COMMON}/shared/*Config.cmake" )
		foreach( _FILE ${_ALL_VERSION_FILES} )
			include( ${_FILE} )
			if( PACKAGE_REFERENCE_OUTDATED )
				get_filename_component( _DIR ${_FILE} PATH )
				message( STATUS "Removing outdated configs copied to \"${_DIR}\"" )
				file( REMOVE_RECURSE ${_DIR} )
			endif( PACKAGE_REFERENCE_OUTDATED )
		endforeach( _FILE ${_ALL_VERSION_FILES} )
		set( PACKAGE_REFERENCE_EXISTS_TEST FALSE )
	endif( EXISTS "$ENV{VISTA_CMAKE_COMMON}" AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )
	
	if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )
		file( TO_CMAKE_PATH $ENV{VISTA_CMAKE_COMMON} VISTA_CMAKE_COMMON )
		list( APPEND CMAKE_PREFIX_PATH ${VISTA_CMAKE_COMMON} ${VISTA_CMAKE_COMMON}/shared )
	endif( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )	
	
endif( NOT VISTA_COMMON_INCLUDED ) # this shows we did not include it yet
