# $Id$

# This file contains common settings and macros for setting up Vista projects

# PACKAGE MACROS:
# vista_find_package( <package> [version] [EXACT] [QUIET] [[REQUIRED|COMPONENTS] [components...]] [NO_POLICY_SCOPE] [NO_MODULE] )
# vista_use_package( <package> [version] [EXACT] [QUIET] [[REQUIRED|COMPONENTS] [components...]] [NO_POLICY_SCOPE] [NO_MODULE] [FIND_DEPENDENCIES] )
# vista_configure_app( PACKAGE_NAME [OUT_NAME] )
# vista_configure_lib( PACKAGE_NAME [OUT_NAME] )
# vista_install( TARGET [INCLUDE/BIN_SUBDIRECTORY [LIBRARY_SUBDIRECTORY] ] [NO_POSTFIX] )
# vista_install_files_by_extension( SEARCH_ROOT INSTALL_SUBDIR EXTENSION1 [EXTENSION2 ...] )
# vista_create_cmake_config_build( PACKAGE_NAME CONFIG_PROTO_FILE TARGET_DIR )
# vista_create_cmake_config_install( PACKAGE_NAME CONFIG_PROTO_FILE TARGET_DIR )
# vista_create_version_config( PACKAGE_NAME VERSION_PROTO_FILE )
# vista_create_cmake_configs( TARGET [CUSTOM_CONFIG_FILE_BUILD [CUSTOM_CONFIG_FILE_INSTALL] ] )
# vista_set_outdir( TARGET DIRECTORY [USE_CONFIG_SUBDIRS])
# vista_set_version( PACKAGE TYPE NAME [ MAJOR [ MINOR [ PATCH [ TWEAK ]]]] )
# vista_adopt_version( PACKAGE ADOPT_PARENT )
# vista_create_info_file( PACKAGE_NAME TARGET_DIR INSTALL_DIR )
# vista_delete_info_file( PACKAGE_NAME TARGET_DIR )
# vista_create_default_info_file( PACKAGE_NAME )
# vista_create_doxygen_target( DOXYFILE )
# vista_create_uninstall_target( [ON|OFF] )

# UTILITY MACROS:
# vista_set_defaultvalue( <cmake set syntax> )
# vista_add_files_to_sources( TARGET_LIST ROOT_DIR [SOURCE_GROUP group_name] EXTENSION1 [EXTENSION2 ...] )
# vista_conditional_add_subdirectory( VARIABLE_NAME DIRECTORY [ON|OFF] [ADVANCED [MSG string] )
# vista_get_svn_info( REVISION_VARIABLE REPOS_VARIABLE DATE_VARIABLE [DIRECTORY] )
# vista_get_svn_revision( TARGET_VARIABLE )
# replace_svn_revision_tag( STRING )
# vista_enable_all_compiler_warnings()
# vista_enable_most_compiler_warnings()

# GENERAL SETTINGS
# adds info variables
#	FIRST_CONFIGURATION_RUN - true if this is the first configuration run
#   VISTA_HWARCH    - variable describing Hardware architecture, e.g. win32.vc9 or LINUX.X86
#   VISTA_COMPATIBLE_HWARCH - architectures that are compatible to the current HWARCH,
#                        e.g. for win32.vc9 this will be "win32.vc9 win32"
#   VISTA_64BIT     - set to true if the code is compiled for 64bit execution
#   VISTA_PLATFORM_DEFINE - compiler definition for the platform ( -DWIN32 or -DLINUX or -DDARWIN )
# adds some general flags/configurations
#	sets CMAKE_DEBUG_POSTFIX to "D"
#	enables global cmake property USE_FOLDERS - allows grouping of projects in msvc
#	conditionally adds DEBUG and OS definitions
#	some visual studio flags
#	VISTA_USE_RPATH cache flag to enable/disable use of RPATH
#	scans XYZConfig.cmake files in VISTA_CMAKE_COMMON/share, and deletes outdated ones


# avoid multiply includions (for performance reasons )
if( NOT VISTA_COMMON_INCLUDED )
set( VISTA_COMMON_INCLUDED TRUE )

#this package sets the variables VISTA_HWARCH, VISTA_COMPATIBLE_HWARCH and VISTA_64BIT
include( VistaHWArchSettings )
include( VistaFindUtils )

###########################
###   Utility macros    ###
###########################

# vista_set_defaultvalue( <cmake set() syntax> )
# macro for overriding default values of pre-initialized variables
# sets the variable only once
macro( vista_set_defaultvalue _VAR_NAME )
	if( NOT "${VISTA_${_VAR_NAME}_ALREADY_INITIALIZED}" )
		set( _ARGS )
		list( APPEND _ARGS ${ARGV} )
		list( FIND _ARGS FORCE _FORCE_FOUND )
		if( ${_FORCE_FOUND} EQUAL -1 )
			set( ${_ARGS} FORCE )
		else( ${_FORCE_FOUND} EQUAL -1 )
			set( ${_ARGS} )
		endif( ${_FORCE_FOUND} EQUAL -1 )
		set( VISTA_${_VAR_NAME}_ALREADY_INITIALIZED TRUE CACHE INTERNAL "" FORCE )
	endif( NOT "${VISTA_${_VAR_NAME}_ALREADY_INITIALIZED}" )
endmacro( vista_set_defaultvalue )

# vista_add_files_to_sources( TARGET_LIST ROOT_DIR [SOURCE_GROUP group_name] EXTENSION1 [EXTENSION2 ...] )
# searches files with any of the passed extensions in the specified root_dir. These files are added to the
# passed list. If the source_group option is given, the files are also added to the specified source group.
# IMPORTANT NOTE: due to cmake's string replacement hicka-di-hoo, if you want to use subfolders in your sourcegroups,
# you'll have to use 4(!) backslashes as separator (e.g. "folder\\\\subfolder")
macro( vista_add_files_to_sources _TARGET_LIST _SEARCH_ROOT )
	set( _EXTENSIONS ${ARGV} )

	if( ${ARGV2} STREQUAL "SOURCE_GROUP" )
		set( _SOURCE_GROUP ${ARGV3} )
		list( REMOVE_AT _EXTENSIONS 0 1 2 3 )
	else()
		set( _SOURCE_GROUP )
		list( REMOVE_AT _EXTENSIONS 0 1 )
	endif( ${ARGV2} STREQUAL "SOURCE_GROUP" )

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
# value (defaults to ON ). ADVANCED marks the cache variable as advanced. Nothing is done if the specified
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
			add_subdirectory( "${ARGV1}" )
			if( _APPEND_TO_LIST )
				list( APPEND ${_APPEND_TO_LIST} ${ARGV1} )
			endif( _APPEND_TO_LIST )
		endif( ${ARGV0} )
	endif( EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" )
endmacro( vista_conditional_add_subdirectory )


# vista_get_svn_info( REVISION_VARIABLE REPOS_VARIABLE DATE_VARIABLE [DIRECTORY] )
# extracts the svn info (revision, repository, and last change date) of the current source dir
#  and stores it in the target variables. If the current directory is not under svn versioning, the
# variables will be empty. If available, svn is used directly to query the info, otherwise,
# a hand-taylored file parsing is used -- however, this may not work correctly with all versions
# by default, the svn of the current source directory is parsed. However, the optional DIRECTORY
# parameter can be used to specify another directory
macro( vista_get_svn_info _REVISION_VAR _REPOS_VAR _DATE_VAR )
	set( ${_REVISION_VAR} )
	set( ${_REPOS_VAR} )
	set( ${_DATE_VAR} )

	if( ${ARGC} GREATER 3 )
		set( _DIRECTORY ${ARGV3} )
	else( ${ARGC} GREATER 3 )
		set( _DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} )
	endif( ${ARGC} GREATER 3 )

	if( EXISTS "${_DIRECTORY}/.svn/entries" )

		find_package( Subversion QUIET )
		if( SUBVERSION_FOUND )
			set( _TMP_SVN_WC_URL )
			
			# this is an adoption of the official svn macro, to avoid the SEND_ERROR stuff
			
			# the subversion commands should be executed with the C locale, otherwise
			# the message (which are parsed) may be translated, Alex
			set( _Subversion_SAVED_LC_ALL "$ENV{LC_ALL}" )
			SET( ENV{LC_ALL} C )

			execute_process( COMMAND ${Subversion_SVN_EXECUTABLE} info ${_DIRECTORY}
								OUTPUT_VARIABLE _SVN_WC_INFO
								ERROR_VARIABLE Subversion_svn_info_error
								RESULT_VARIABLE Subversion_svn_info_result
								OUTPUT_STRIP_TRAILING_WHITESPACE )

			if( NOT ${Subversion_svn_info_result} EQUAL 0 )
				message( "vista_get_svn_info(): svn info call failed woth error \"${Subversion_svn_info_error}\"" )
			else( NOT ${Subversion_svn_info_result} EQUAL 0 )
				string( REGEX REPLACE "^(.*\n)?URL: ([^\n]+).*"
						"\\2" ${_REPOS_VAR} "${_SVN_WC_INFO}")
				string( REGEX REPLACE "^(.*\n)?Repository Root: ([^\n]+).*"
						"\\2" _VOID_OUTPUT "${_SVN_WC_INFO}")
				string( REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*"
						"\\2" ${_REVISION_VAR} "${_SVN_WC_INFO}")
				string( REGEX REPLACE "^(.*\n)?Last Changed Author: ([^\n]+).*"
						"\\2" _VOID_OUTPUT "${_SVN_WC_INFO}")
				string( REGEX REPLACE "^(.*\n)?Last Changed Rev: ([^\n]+).*"
						"\\2" _VOID_OUTPUT "${_SVN_WC_INFO}")
				string( REGEX REPLACE "^(.*\n)?Last Changed Date: ([^\n]+).*"
						"\\2" ${_DATE_VAR} "${_SVN_WC_INFO}")
			endif( NOT ${Subversion_svn_info_result} EQUAL 0 )

			# restore the previous LC_ALL
			set( ENV{LC_ALL} ${_Subversion_SAVED_LC_ALL} )
			
		else( SUBVERSION_FOUND )
			# check manually - and hope the syntax does not change ;)

			file( STRINGS "${_DIRECTORY}/.svn/entries" _FILE_ENTRIES LIMIT_COUNT 15 )
			list( REMOVE_AT _FILE_ENTRIES 0 ) # remove first entry - the number

			 foreach( _STRING ${_FILE_ENTRIES} )
				if( NOT DEFINED ${_REVISION_VAR} )
					if( ${_STRING} GREATER 0 )
						set( ${_REVISION_VAR} ${_STRING} )
					endif( ${_STRING} GREATER 0 )
				elseif( NOT DEFINED ${_REPOS_VAR} )
					string( REGEX MATCH "/" _MATCHED ${_STRING} )
					if( _MATCHED )
						set( ${_REPOS_VAR} ${_STRING} )
					endif( _MATCHED )
				elseif( NOT DEFINED ${_DATE_VAR} )
					string( REGEX MATCH "[0-9\\-]+T.+" _MATCHED ${_STRING} )
					if( _MATCHED )
						set( ${_DATE_VAR} ${_STRING} )
						break()
					endif( _MATCHED )
				endif( NOT DEFINED ${_REVISION_VAR} )
			 endforeach( _STRING ${_FILE_ENTRIES} )

		endif( SUBVERSION_FOUND )

	endif( EXISTS "${_DIRECTORY}/.svn/entries" )

endmacro( vista_get_svn_info )

# vista_get_svn_revision( TARGET_VARIABLE )
# extracts the svn revision from the file system and stores it in the specified target variable
# for details, see vista_get_svn_info
macro( vista_get_svn_revision _TARGET_VAR )
	vista_get_svn_info( ${_TARGET_VAR} _TMP_SVN_REPOS _TMP_SVN_DATE )
endmacro( vista_get_svn_revision )


# local macro, for use in this file only
function( local_clean_old_config_references _PACKAGE_NAME _PACKAGE_TARGET_FILE _EXCLUDE_DIR )
	string( TOUPPER _PACKAGE_NAME_UPPER ${_PACKAGE_NAME} )
	set( PACKAGE_REFERENCE_EXISTS_TEST TRUE )

	set( _OWN_FILE "${_EXCLUDE_DIR}/${_PACKAGE_NAME}Config.cmake" )
	file( GLOB_RECURSE _ALL_VERSION_FILES "${VISTA_CMAKE_COMMON}/share/${_PACKAGE_NAME}*/${_PACKAGE_NAME}Config.cmake" )
	foreach( _FILE ${_ALL_VERSION_FILES} )
		file( TO_CMAKE_PATH "${_FILE}" _FILE )
		if( NOT _FILE STREQUAL _OWN_FILE )
			set( PACKAGE_REFERENCE_OUTDATED FALSE )
			include( "${_FILE}" )
			if( PACKAGE_REFERENCE_OUTDATED OR "${_PACKAGE_TARGET_FILE}" STREQUAL "${${_PACKAGE_NAME_UPPER}_REFERENCED_FILE}" )
				string( REGEX MATCH "(${VISTA_CMAKE_COMMON}/share/.+)/.*" _MATCHED ${_FILE} )
				if( _MATCHED )
					set( _DIR "${CMAKE_MATCH_1}" )
					message( STATUS "Removing old config reference copied to \"${_DIR}\"" )
					file( REMOVE_RECURSE "${_DIR}" )
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
				list( APPEND ${_LIBRARY_DIR_LIST} "${${_NAME_UPPER}_LIBRARY_DIRS}" )
				list( REMOVE_DUPLICATES ${_LIBRARY_DIR_LIST} )
			endif( ${_NAME_UPPER}_LIBRARY_DIRS )
		endif( "${${_NAME_UPPER}_ROOT_DIR}" STREQUAL "${_ROOT_DIR}" )
	endif( EXISTS "${_CONFIG_FILE}" )
	set( ${_LIBRARY_DIR_LIST} ${${_LIBRARY_DIR_LIST}} PARENT_SCOPE )
endfunction( local_use_existing_config_libs )

# vista_enable_most_compiler_warnings()
# Enables all compiler warnings, excluding some (subjectively less important) ones
macro( vista_enable_all_compiler_warnings )
	if( NOT "${VISTA_SHOW_ALL_WARNINGS_EXECUTED}" )
		set( VISTA_SHOW_ALL_WARNINGS_EXECUTED TRUE CACHE INTERNAL "" )
		if( MSVC )
			set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4" CACHE STRING "Flags used by the compiler during all build types." FORCE )
		elseif( UNIX )
			set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra" CACHE STRING "Flags used by the compiler during all build types." FORCE )
		endif( MSVC )
	endif( NOT "${VISTA_SHOW_ALL_WARNINGS_EXECUTED}" )
endmacro( vista_enable_all_compiler_warnings )


# vista_enable_most_compiler_warnings()
# Enables most compilerwarnings, excluding some (subjectively less important) ones
macro( vista_enable_most_compiler_warnings )
	if( NOT "${VISTA_SHOW_MOST_WARNINGS_EXECUTED}" )
		set( VISTA_SHOW_ALL_WARNINGS_EXECUTED TRUE CACHE INTERNAL "" )
		if( MSVC )
			set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /wd4244 /wd4100 /wd4512 /wd4245 /wd4389" CACHE STRING "Flags used by the compiler during all build types." FORCE )
		elseif( UNIX )
			set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wreorder" CACHE STRING "Flags used by the compiler during all build types." FORCE )
		endif( MSVC )
	endif( NOT "${VISTA_SHOW_MOST_WARNINGS_EXECUTED}" )
endmacro( vista_enable_most_compiler_warnings )



###########################
###   Package macros    ###
###########################

# vista_find_package( <package> [version] [EXACT] [QUIET] [[REQUIRED|COMPONENTS] [components...]] [NO_POLICY_SCOPE] [NO_MODULE] )
# wrapper for the cmake-native find_package with the same (basic) syntax and the following extensions:
# - allows extended versions (e.g. NAME, 1.2.4-8, etc.)
# - checks if a vista-specific FindV<package>.cmake file exists, and prefers this
# - if no module is found, the config files are searched in additional subdirectories
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
	set( _EXACT FALSE )
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
			set( _EXACT TRUE )
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
			message( WARNING "vista_find_package( ${_PACKAGE_NAME} ) - Unknown argument [${_ARG}]" )
		endif( ${_ARG} STREQUAL "FIND_DEPENDENCIES" )
	endforeach( _ARG ${ARGV} )

	set( _DO_FIND TRUE )

	if( ${_PACKAGE_NAME_UPPER}_FOUND )
		set( _DO_FIND FALSE )

		set( _PREVIOUSLY_FOUND_VERSION )
		if( ${_PACKAGE_NAME_UPPER}_VERSION )
			set( _PREVIOUSLY_FOUND_VERSION ${${_PACKAGE_NAME_UPPER}_VERSION} )
		elseif( ${_PACKAGE_NAME}_VERSION )
			set( _PREVIOUSLY_FOUND_VERSION ${${_PACKAGE_NAME}_VERSION} )
		elseif( ${_PACKAGE_NAME_UPPER}_VERSION_STRING )
			set( _PREVIOUSLY_FOUND_VERSION ${${_PACKAGE_NAME_UPPER}_VERSION_STRING} )
		elseif( ${_PACKAGE_NAME}_VERSION_STRING )
			set( _PREVIOUSLY_FOUND_VERSION ${${_PACKAGE_NAME}_VERSION_STRING} )
		elseif( ${_PACKAGE_NAME_UPPER}_VERSION_STRING )
			set( _PREVIOUSLY_FOUND_VERSION ${${_PACKAGE_NAME_UPPER}_VERSION_STRING} )
		endif( ${_PACKAGE_NAME_UPPER}_VERSION )

		if( _PREVIOUSLY_FOUND_VERSION AND _PACKAGE_VERSION )
			# we have to check that we don't include different versions!
			vista_string_to_version( ${_PREVIOUSLY_FOUND_VERSION} "PREVIOUS" )
			vista_string_to_version( ${_PACKAGE_VERSION} "REQUESTED" )
			vista_compare_versions( "REQUESTED" "PREVIOUS" _DIFFERENCE )
			if( _DIFFERENCE EQUAL -1 )
				message( WARNING "vista_find_package( ${_PACKAGE_NAME} ) - Package was previously found with"
				                  " version (${_PREVIOUSLY_FOUND_VERSION}), but is now requested with"
								  " incompatible version (${_PACKAGE_VERSION}) - first found version is used,"
								  " but this may lead to conflicts" )
			elseif( _DIFFERENCE VERSION_GREATER 0.0.0.0 AND _EXACT )
				message( "vista_find_package( ${_PACKAGE_NAME} ) - Package was previously found with"
				                  " version (${_PREVIOUSLY_FOUND_VERSION}), but is now requested with"
								  " different, but compatible version (${_PACKAGE_VERSION}) - first found version is used" )
			#else: prefect match
			endif( _DIFFERENCE EQUAL -1 )
			# we always want to find the sam eversiona gain, so set it to the former one
			set( _PACKAGE_VERSION ${_PREVIOUSLY_FOUND_VERSION} )
		endif( _PREVIOUSLY_FOUND_VERSION AND _PACKAGE_VERSION )

		if( _USING_COMPONENTS )
			# we need to check if the components are already included or not
			# NOTE: this relies on the Find<Package> or <Package>Config file to
			# correctly set the PACKAGENAME_FOUND_COMPONENTS variable - otherwise, a rerun
			# will be performed even if previous finds were sufficient
			if( ${_PACKAGE_NAME_UPPER}_FOUND_COMPONENTS )
				foreach( _COMPONENT ${_PACKAGE_COMPONENTS} )
					list( FIND ${_PACKAGE_NAME_UPPER}_FOUND_COMPONENTS ${_COMPONENT} _COMPONENT_FOUND )
					if( _COMPONENT_FOUND LESS 0 )
						set( _DO_FIND TRUE )
						break()
					endif( _COMPONENT_FOUND LESS 0 )
				endforeach( _COMPONENT ${_PACKAGE_COMPONENTS} )
			else()
				set( _DO_FIND TRUE )
			endif( ${_PACKAGE_NAME_UPPER}_FOUND_COMPONENTS )
		endif( _USING_COMPONENTS )

	endif( ${_PACKAGE_NAME_UPPER}_FOUND )

	if( _DO_FIND )
		# this is somewhat of an intransparent hack: if _MESSAGE_IF_DO_FIND is set, we print a message
		# with it and reset the value. This is to allow vista_use_package to print additional info
		# - no one else should need to use thsi
		if( _MESSAGE_IF_DO_FIND )
			message( STATUS "${_MESSAGE_IF_DO_FIND}" )
			set( _MESSAGE_IF_DO_FIND )
		endif( _MESSAGE_IF_DO_FIND )

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
			foreach( _PATH ${CMAKE_MODULE_PATH} ${CMAKE_ROOT} ${CMAKE_ROOT}/Modules )
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
			set( ${_PACKAGE_NAME_UPPER}_FOUND ${V${_PACKAGE_NAME_UPPER}_FOUND} )
		elseif( _FIND_MODULE_EXISTS )
			find_package( ${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} )
		else( _FIND_VMODULE_EXISTS )
			if( NOT ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
				# we look for additional directories to search for the config files
				# we also search for CoreLibs directories manually
				foreach( _PATH $ENV{${_PACKAGE_NAME_UPPER}_ROOT} ${VISTA_PACKAGE_SEARCH_PATHS} )
					if( EXISTS "${_PATH}" )
						file( TO_CMAKE_PATH ${_PATH} _PATH )
						list( APPEND _SEARCH_PREFIXES
								"${_PATH}/${_PACKAGE_NAME}*/${VISTA_HWARCH}"
								"${_PATH}/${_PACKAGE_NAME}*"
								"${_PATH}/${_PACKAGE_NAME}/*/${VISTA_HWARCH}"
								"${_PATH}/${_PACKAGE_NAME}/*/"
						)
					endif( EXISTS "${_PATH}" )
				endforeach( _PATH ${_SEARCH_DIRS} )

				foreach( _PATH ${_SEARCH_PREFIXES} )
					file( GLOB _TMP_PATHES "${_PATH}" )
					list( APPEND ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS ${_TMP_PATHES} )
				endforeach( _PATH ${_PREFIX_PATHES} )
				if( ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
					list( REMOVE_DUPLICATES ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
				endif( ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )
			endif( NOT ${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS )

			find_package( ${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS}
							PATHS ${${PACKAGE_NAME_UPPER}_ADDITIONAL_CONFIG_DIRS} ${VISTA_PACKAGE_SEARCH_PATHS} )
		endif( _FIND_VMODULE_EXISTS )

	endif( _DO_FIND )

endmacro( vista_find_package )


# vista_use_package( PACKAGE [VERSION] [EXACT] [[COMPONENTS | REQUIRED] comp1 comp2 ... ] [QUIET] [FIND_DEPENDENCIES] )
# finds the desired Package and automatically sets the include dirs, library dirs, definitions for the project.
# Libraries have to be included using the VARIABLE PACKAGENAME_LIBRARIES. Alternatively, VISTA_USE_PACKAGE_LIBRARIES contains
# all libraries that have been linked by vista_use_package calls. Additionally, buildsystem-specific variables are set that
# keep track of dependencies
# Parameters
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
			endif( ${_ARG} STREQUAL "COMPONENTS" OR ${_ARG} STREQUAL "REQUIRED" )
		endforeach( _ARG ${ARGV} )

		# todo: check against components
		if( NOT _COMPONENTS_FOUND )
			set( _REQUIRES_RERUN FALSE )
			# todo: check version
		endif( NOT _COMPONENTS_FOUND )

	endif( VISTA_USE_${_PACKAGE_NAME_UPPER} )

	if( _REQUIRES_RERUN )
		# we first extract some parameters, then try to find the package

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

		# set required variables if package was found AND it wasn't sufficiently included before (in which case _DO_FIND is FALSE )
		if( ${_PACKAGE_NAME_UPPER}_FOUND AND ( _DO_FIND OR NOT VISTA_USE_${_PACKAGE_NAME_UPPER} ) )
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
			list( APPEND VISTA_TARGET_FULL_DEPENDENCIES ${_PACKAGE_NAME} )
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
							#if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
								# find and use the dependency. If it fails, utter a warning
								if( NOT _QUIET )
									set( _MESSAGE_IF_DO_FIND "Automatically adding ${_PACKAGE_NAME}-dependency \"${_DEPENDENCY_ARGS}\"" )
								endif( NOT _QUIET )
								vista_use_package( ${_DEPENDENCY_ARGS} FIND_DEPENDENCIES )
								if( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
									message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY_ARGS}\", but including it failed" )
								endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND AND NOT _QUIET )
							#endif( NOT ${_DEPENDENCY_NAME_UPPER}_FOUND )
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

		endif( ${_PACKAGE_NAME_UPPER}_FOUND AND ( _DO_FIND OR NOT VISTA_USE_${_PACKAGE_NAME_UPPER} ) )
		
		set( VISTA_USE_${_PACKAGE_NAME_UPPER} TRUE )
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

	set( ${_PACKAGE_NAME_UPPER}_TARGET_TYPE "APP" )

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
		if( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
			vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} USE_CONFIG_SUBDIRS )
		else( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
			vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
		endif( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
	endif( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )

	# we store the dependencies as required
	set( ${_PACKAGE_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	set( ${_PACKAGE_NAME_UPPER}_FULL_DEPENDENCIES ${VISTA_TARGET_FULL_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	# create a script that sets the path
	if( VISTA_TARGET_LINK_DIRS )
		if( WIN32 )
			set( _LIBRARY_PATHES ${VISTA_TARGET_LINK_DIRS} )
			set( _DRIVER_PLUGIN_DIRS ${VISTACORELIBS_DRIVER_PLUGIN_DIRS} )
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
			string( REPLACE ";" ":" _LIBRARY_PATHES "${VISTA_TARGET_LINK_DIRS}" )
			string( REPLACE ";" ":" _DRIVER_PLUGIN_DIRS "${VISTACORELIBS_DRIVER_PLUGIN_DIRS}" )
			find_file( VISTA_ENVIRONMENT_SCRIPT_FILE "set_path.sh_proto" ${CMAKE_MODULE_PATH} )
			mark_as_advanced( VISTA_ENVIRONMENT_SCRIPT_FILE )
			if( VISTA_ENVIRONMENT_SCRIPT_FILE )
				configure_file(
						"${VISTA_ENVIRONMENT_SCRIPT_FILE}"
						"${CMAKE_CURRENT_BINARY_DIR}/set_path_for_${_PACKAGE_NAME}.sh"
						@ONLY
				)
				file( COPY "${CMAKE_CURRENT_BINARY_DIR}/set_path_for_${_PACKAGE_NAME}.sh"
						DESTINATION "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}" 
						FILE_PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE
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
				set( _ENVIRONMENT "PATH=${VISTA_TARGET_LINK_DIRS};%PATH%&#x0A;" )
			endif( VISTA_TARGET_LINK_DIRS )
			if( VISTACORELIBS_DRIVER_PLUGIN_DIRS )
				set( _ENVIRONMENT "${_ENVIRONMENT}VISTACORELIBS_DRIVER_PLUGIN_DIRS=${VISTACORELIBS_DRIVER_PLUGIN_DIRS}&#x0A;" )
			endif( VISTACORELIBS_DRIVER_PLUGIN_DIRS )

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

	set( ${_PACKAGE_NAME_UPPER}_TARGET_TYPE "LIB" )

	set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${_PACKAGE_NAME} CACHE INTERNAL "" FORCE )
	if( ${ARGC} GREATER 1 )
		set( ${_PACKAGE_NAME_UPPER}_OUTPUT_NAME ${ARGV1} CACHE INTERNAL "" FORCE )
	endif( ${ARGC} GREATER 1 )

	set_target_properties( ${_PACKAGE_NAME} PROPERTIES OUTPUT_NAME	"${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )

	if( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_PACKAGE_NAME} "${CMAKE_BINARY_DIR}/lib" )
	else( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )
		if( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
			vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} USE_CONFIG_SUBDIRS )
		else( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
			vista_set_outdir( ${_PACKAGE_NAME} ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR} )
		endif( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS )
	endif( NOT DEFINED ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR )

	# we store the dependencies as required
	set( ${_PACKAGE_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	set( ${_PACKAGE_NAME_UPPER}_FULL_DEPENDENCIES ${VISTA_TARGET_FULL_DEPENDENCIES} CACHE INTERNAL "" FORCE )

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

	if( ${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "APP" )
		install( TARGETS ${_PACKAGE_NAME}
			RUNTIME DESTINATION ${${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR}
		)
		#if( WIN32 )
		#	install( FILES "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_PACKAGE_NAME}.bat"
		#				DESTINATION ${${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR} )
		#else( WIN32 )
		#	install( FILES "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_PACKAGE_NAME}.sh"
		#				DESTINATION ${${_PACKAGE_NAME_UPPER}_BIN_INSTALLDIR} )
		#endif( WIN32 )
	else( ${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "APP" )
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
	endif( ${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "APP" )
endmacro()

# vista_install_files_by_extension( SEARCH_ROOT INSTALL_SUBDIR [NON_RECURSIVE] EXTENSION1 [EXTENSION2 ...] )
# searches in SEARCH_ROOT dor all files matching any of the provided extensions, and
# installs them to the specified Subdir
# if NON_RECURSIVE is specified as first parameter after INSTALL_SUBDIR,only the top-level
# SEARCH_ROOT is searched, otherwise, all subdirs are parsed recursively, too
# NOTE: files are searched at configure time, not at install time! Thus, if you add a file
# matching the pattern, you have to configure cmake again to add it to the list of files to
# install
macro( vista_install_files_by_extension _SEARCH_ROOT _INSTALL_SUBDIR )
	set( _EXTENSIONS ${ARGV} )
	if( "${ARGV2}" STREQUAL "NON_RECURSIVE" )
		list( REMOVE_AT _EXTENSIONS 0 1 2 )
		foreach( _EXT ${_EXTENSIONS} )
			file( GLOB _FOUND_FILES "${_SEARCH_ROOT}/*.${_EXT}" )
			install( FILES ${_FOUND_FILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${_INSTALL_SUBDIR} )
		endforeach( _EXT ${_EXTENSIONS} )
	else( "${ARGV2}" STREQUAL "NON_RECURSIVE" )
		list( REMOVE_AT _EXTENSIONS 0 1 )
		foreach( _EXT ${_EXTENSIONS} )
			file( GLOB_RECURSE _FOUND_FILES "${_SEARCH_ROOT}/*.${_EXT}" "${_SEARCH_ROOT}/**/*.${_EXT}" )			
			install( FILES ${_FOUND_FILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/${_INSTALL_SUBDIR} )
		endforeach( _EXT ${_EXTENSIONS} )
	endif( "${ARGV2}" STREQUAL "NON_RECURSIVE" )
endmacro( vista_install_files_by_extension )

# vista_install_files_by_extension( INSTALL_SUBDIR )
# searches for ALL .dll's or .so's in all link directories, and installs them
# to the specified subdir. Only dlls that already exist at configure time will be installed!
# WARNING use with great care! this can potentially copy a whole lot of dlls if
# one of the lib's link dirs contains other dll's, too (e.g. /usr/lib)
macro( vista_install_all_dlls _INSTALL_SUBDIR )		
	foreach( _DIR ${VISTA_TARGET_LINK_DIRS} ${VISTACORELIBS_DRIVER_PLUGIN_DIRS} )
		if( WIN32 )
			vista_install_files_by_extension( ${_DIR} ${_INSTALL_SUBDIR} NON_RECURSIVE "dll" )
		elseif( LINUX )
			vista_install_files_by_extension( ${_DIR} ${_INSTALL_SUBDIR} NON_RECURSIVE "so" )
		endif( WIN32 )
	endforeach( _DIR ${VISTA_TARGET_LINK_DIRS} ${VISTACORELIBS_DRIVER_PLUGIN_DIRS} )
endmacro( vista_install_all_dlls )



# vista_create_cmake_config( PACKAGE_NAME CONFIG_PROTO_FILE TARGET_DIR )
# configures the specified <package>Config.cmake prototype file, and copies it to the
# target directory.
# Has to be called after vista_configure_lib to work properly
# If the cache variable VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON is ON -- and
# VISTA_CMAKE_COMMON env var is set -- a reference to this config is installed
# to VISTA_CMAKE_COMMON/share/. Additionally, previously installed older versions are removed.
# Furthermore, if a ConfigCMake of the same package and version already exists, it is parsed and
# the defined library dirs are adopted - this helps if multiple cmake builds are created for the same
# package
# The following variables are set internally to help configuring the configfile
#     _PACKAGE_NAME          - name of the package
#     _PACKAGE_NAME_UPPER    - uppercase name
#     _PACKAGE_LIBRARY_NAME  - output name of the package (not including Debug Postifix)
#     _PACKAGE_ROOT_DIR      - toplevel file of the package (i.e. directory from which vista_create_cmake_config_build is called)
#     _PACKAGE_LIBRARY_DIRS  - folder where the libraries are output to (not including optional postfixes)
#                              can be overwritten by defining ${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR before calling the macro
#     _PACKAGE_INCLUDE_DIRS  - folder where the header files of the package are
#                              defaults to the current folder and the projects root folder
#                              can be overwritten by defining ${_PACKAGE_NAME_UPPER}_INCLUDE_OUTDIR before calling the macro
#     _PACKAGE_RELATIVE_LIBRARY_DIRS - _PACKAGE_LIBRARY_DIRS relative to current dir
#     _PACKAGE_RELATIVE_INCLUDE_DIRS - _PACKAGE_INCLUDE_DIRS relative to current dir
#     _PACKAGE_DEFINITIONS   - definitions for the package, defaults to nothing
#                              can be overwritten by defining ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS before calling the macro
macro( vista_create_cmake_config_build _PACKAGE_NAME _CONFIG_PROTO_FILE _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )

	# store the directory - it may be used by the versioning lateron
	set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR ${_TARGET_DIR} )

	#if VISTA_CMAKE_COMMON exisits, we give the user the cache options to toggle copying of references
	# to CISTA_CMAKE_COMMON/share on and off
	if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )
		set( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON TRUE CACHE BOOL
			"if enabled, References to <Package>Config.cmake files will be copied to VistaCMakeCommon/share for easier finding" )
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
	set(_PACKAGE_DEFINITIONS )
	if( ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS )
		set( _PACKAGE_DEFINITIONS ${${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS} )
	endif( ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS )

	# if we should create a referenced config file, we create it's target dir
	if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR "${VISTA_CMAKE_COMMON}/share/${_PACKAGE_NAME}" )
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}-${${_PACKAGE_NAME_UPPER}_VERSION_EXT}-build" )
		else( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}-${VISTA_HWARCH}-build" )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )

		# if any reference already exists, we aparse it and append its library dirs to the current one
		# this helps if several different build types are used in different cmake-build-dirs, but
		local_use_existing_config_libs( ${_PACKAGE_NAME} "${_PACKAGE_ROOT_DIR}"
									"${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}/${_PACKAGE_NAME}Config.cmake"
									_PACKAGE_LIBRARY_DIRS )
	endif( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )

	# retrieve relative pathes for library/include dirs
	set( _PACKAGE_RELATIVE_INCLUDE_DIRS )
	foreach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
		file( RELATIVE_PATH _REL_DIR "${_PACKAGE_ROOT_DIR}" "${_DIR}" )
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "${_REL_DIR}" )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_INCLUDE_DIRS} )

	set( _PACKAGE_RELATIVE_LIBRARY_DIRS )
	foreach( _DIR ${_PACKAGE_LIBRARY_DIRS} )		
		file( RELATIVE_PATH _REL_DIR "${_PACKAGE_ROOT_DIR}" "${_DIR}" )
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "${_REL_DIR}" )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_LIBRARY_DIRS} )

	#get_filename_component( _PATH_UP "${CMAKE_CURRENT_SOURCE_DIR}/.." REALPATH  )
	#list( APPEND _PACKAGE_INCLUDE_DIR "${_PATH_UP}" )
	#list( REMOVE_DUPLICATES _PACKAGE_INCLUDE_DIR )

	set( _TARGET_FILENAME "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR}/${_PACKAGE_NAME}Config.cmake" )

	#  configure the actual file
	configure_file(	${_CONFIG_PROTO_FILE} ${_TARGET_FILENAME} @ONLY )

	#if we should create the reference - do so now
	set( _REFERENCED_FILE ${_TARGET_FILENAME} )
	if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		# since prior configure runs may have already added it (before the cache was turned off), we
		# delete any prior copied versions to this location
		local_clean_old_config_references( ${_PACKAGE_NAME} "${_REFERENCED_FILE}" "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}" )
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

# vista_create_cmake_install( PACKAGE_NAME CONFIG_PROTO_FILE TARGET_DIR )
# configures the specified <package>Config.cmake prototype file, stores it in a temporary
# directory, and adds it to the files to install
# Has to be called after vista_configure_lib and vista_install to work properly
# If the cache variable VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON is ON -- and
# VISTA_CMAKE_COMMON env var is set -- a reference to this config is installed
# to VISTA_CMAKE_COMMON/share/.
# The following variables are set internally to help configuring the configfile
#     _PACKAGE_NAME          - name of the package
#     _PACKAGE_NAME_UPPER    - uppercase name
#     _PACKAGE_LIBRARY_NAME  - output name of the package (not including Debug Postifix)
#     _PACKAGE_ROOT_DIR      - toplevel file of the package (i.e. directory from which vista_create_cmake_config_build is called)
#     _PACKAGE_LIBRARY_DIRS  - folder where the libraries are installed to
#     _PACKAGE_INCLUDE_DIRS  - folder where the header files are installed to
#     _PACKAGE_RELATIVE_LIBRARY_DIRS - _PACKAGE_LIBRARY_DIRS relative to current dir
#     _PACKAGE_RELATIVE_INCLUDE_DIRS - _PACKAGE_INCLUDE_DIRS relative to current dir
#     _PACKAGE_DEFINITIONS   - definitions for the package, defaults to nothing
#                              can be overwritten by defining ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS before calling the macro
macro( vista_create_cmake_config_install _PACKAGE_NAME _CONFIG_PROTO_FILE _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )

	# store the directory - it may be used by the versioning lateron
	set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR "${_TARGET_DIR}" )

	#if VISTA_CMAKE_COMMON exisits, we give the user the cache options to toggle copying of references
	# to VISTA_CMAKE_COMMON/share on and off
	if( EXISTS ${VISTA_CMAKE_COMMON} )
		set( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON TRUE CACHE BOOL
			"if enabled, References to <Package>Config.cmake files will be copied to VistaCMakeCommon/share for easier finding" )
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
	set(_PACKAGE_DEFINITIONS )
	if( ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS )
		set( _PACKAGE_DEFINITIONS ${${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS} )
	endif( ${_PACKAGE_NAME_UPPER}_CONFIG_DEFINITIONS )

	#retrieve relative pathes for library/include dirs
	set( _PACKAGE_RELATIVE_INCLUDE_DIRS )
	foreach( _DIR ${_PACKAGE_INCLUDE_DIRS} )
		file( RELATIVE_PATH _REL_DIR "${_PACKAGE_ROOT_DIR}" "${_DIR}" )
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "${_REL_DIR}" )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_INCLUDE_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_INCLUDE_DIRS} )

	set( _PACKAGE_RELATIVE_LIBRARY_DIRS )
	foreach( _DIR ${_PACKAGE_LIBRARY_DIRS} )
		file( RELATIVE_PATH _REL_DIR "${_PACKAGE_ROOT_DIR}" "${_DIR}" )
		if( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "${_REL_DIR}" )
		else( _REL_DIR )
			list( APPEND _PACKAGE_RELATIVE_LIBRARY_DIRS "." )
		endif( _REL_DIR )
	endforeach( _DIR ${_PACKAGE_LIBRARY_DIRS} )

	set( _TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}Config.cmake" )
	# configure the actual file to a local folder, and add it for install
	configure_file(	"${_CONFIG_PROTO_FILE}" "${_TEMPORARY_FILENAME}" @ONLY )
	install( FILES "${_TEMPORARY_FILENAME}" DESTINATION "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR}" )



	set( _REFERENCED_FILE "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR}/${_PACKAGE_NAME}Config.cmake" )


	if( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
		# find proto file
		find_file( VISTA_REFERENCE_CONFIG_PROTO_FILE "PackageConfigReference.cmake_proto" PATH ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_REFERENCE_CONFIG_PROTO_FILE ${VISTA_REFERENCE_CONFIG_PROTO_FILE} CACHE INTERNAL "" FORCE )

		#determine dir (and store it for later use of versions)
		set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR "${VISTA_CMAKE_COMMON}/share/${_PACKAGE_NAME}" )
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}-${${_PACKAGE_NAME_UPPER}_VERSION_EXT}-install" )
		else( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			set( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR
					"${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}-${VISTA_HWARCH}-install" )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )

		if( VISTA_REFERENCE_CONFIG_PROTO_FILE )
			#eliminate older installed configs
			local_clean_old_config_references( "${_PACKAGE_NAME}" "${_REFERENCED_FILE}" "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}" )
			# configure the reference file
			set( _TEMPORARY_REF_FILENAME "${CMAKE_BINARY_DIR}/toinstall/references/${_PACKAGE_NAME}Config.cmake" )
			configure_file(	"${VISTA_REFERENCE_CONFIG_PROTO_FILE}" "${_TARGET_REF_FILENAME}" @ONLY )
			install( FILES "${_TARGET_REF_FILENAME}" DESTINATION "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}" )
		endif( VISTA_REFERENCE_CONFIG_PROTO_FILE )
	else( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
		# since prior configure runs may have already added it (before the cache was turned off), we
		# delete any prior copied versions to this location
		local_clean_old_config_references( ${_PACKAGE_NAME} "${_REFERENCED_FILE}" "" )
	endif( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
endmacro( vista_create_cmake_config_install )

# vista_create_version_config( PACKAGE_NAME VERSION_PROTO_FILE )
# configures the specified <package>ConfigVersion.cmake prototype file.
# for this to work, the version variables have to be set (e.g. using vistaa_set_version),
# at least one of vista_create_cmake_config_build or vista_create_cmake_config_install
# has to be performed
# the version files are placed at the same location as the created config files
# If the cache variable VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON is ON -- and
# VISTA_CMAKE_COMMON env var is set -- references are created too
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
			configure_file( "${_VERSION_PROTO_FILE}" "${_BUILD_VERSION_TARGET}" @ONLY )

			if( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
				set( _REFERENCED_FILE "${_BUILD_VERSION_TARGET}" )
				set( _REFERENCE_TARGET_FILENAME "${${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_REFERENCE_DIR}/${_PACKAGE_NAME}ConfigVersion.cmake" )
				configure_file( "${VISTA_REFERENCE_CONFIG_PROTO_FILE}" "${_REFERENCE_TARGET_FILENAME}" @ONLY )
			endif( VISTA_COPY_BUILD_CONFIGS_REFS_TO_CMAKECOMMON )
		endif( ${_PACKAGE_NAME_UPPER}_BUILD_CONFIG_DIR )

		if( ${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR )
			set( _TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}ConfigVersion.cmake" )
			set( _INSTALL_DIR  "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_DIR}" )
			configure_file( "${_VERSION_PROTO_FILE}" "${_TEMPORARY_FILENAME}" @ONLY )
			install( FILES "${_TEMPORARY_FILENAME}" DESTINATION "${_INSTALL_DIR}" )

			if( VISTA_COPY_INSTALL_CONFIGS_REFS_TO_CMAKECOMMON )
				set( _REFERENCED_FILE "${_INSTALL_DIR}/${_PACKAGE_NAME}ConfigVersion.cmake" )
				set( _REFERENCE_TEMPORARY_FILENAME "${CMAKE_BINARY_DIR}/toinstall/references/${_PACKAGE_NAME}ConfigVersion.cmake" )
				configure_file( "${VISTA_REFERENCE_CONFIG_PROTO_FILE}" "${_REFERENCE_TEMPORARY_FILENAME}" @ONLY )
				install( FILES "${_REFERENCE_TEMPORARY_FILENAME}" DESTINATION "${${_PACKAGE_NAME_UPPER}_INSTALL_CONFIG_REFERENCE_DIR}" )
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
# VISTA_CMAKE_ROOT/share into a subfolder composed from the name, the (optional) version, and either -build or -install
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
		set( VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD "${VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD}" CACHE INTERNAL "Default Prototype file for <Package>Config.cmake in build config" FORCE )
		find_file( VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL "PackageConfig-install.cmake_proto" PATHS ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} )
		set( VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL "${VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL}" CACHE INTERNAL "Default Prototype file for <Package>Config.cmake in install config" FORCE )

		if( NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD OR NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL )
			message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find default config file PackageConfig.cmake_proto" )
			set( _PRECONDITION_FAIL TRUE )
		endif( NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD OR NOT VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL )
		set( _CONFIG_PROTO_FILE_BUILD "${VISTA_DEFAULT_CONFIG_PROTO_FILE_BUILD}" )
		set( _CONFIG_PROTO_FILE_INSTALL "${VISTA_DEFAULT_CONFIG_PROTO_FILE_INSTALL}" )
	endif( ${ARGC} GREATER 1 )


	if( NOT _PRECONDITION_FAIL )
		vista_create_cmake_config_build( ${_PACKAGE_NAME}
											"${_CONFIG_PROTO_FILE_BUILD}"
											"${CMAKE_BINARY_DIR}/cmake" )
		vista_create_cmake_config_install( ${_PACKAGE_NAME}
											"${_CONFIG_PROTO_FILE_INSTALL}"
											"${CMAKE_INSTALL_PREFIX}/share/${_PACKAGE_NAME}/cmake" )

		# if there is a version set, we also configure the corresponding version file
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			find_file( VISTA_VERSION_PROTO_FILE "PackageConfigVersion.cmake_proto" PATHS ${CMAKE_MODULE_PATH} )
			set( VISTA_VERSION_PROTO_FILE "${VISTA_VERSION_PROTO_FILE}" CACHE INTERNAL "" )
			if( VISTA_VERSION_PROTO_FILE )
				vista_create_version_config( ${_PACKAGE_NAME} "${VISTA_VERSION_PROTO_FILE}"
											"${CMAKE_BINARY_DIR}/cmake/${_PACKAGE_NAME}ConfigVersion.cmake" )
			endif( VISTA_VERSION_PROTO_FILE )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )

	endif( NOT _PRECONDITION_FAIL )
endmacro( vista_create_cmake_configs )

# vista_set_outdir( TARGET DIRECTORY [USE_CONFIG_SUBDIRS])
# sets the outdir of the target to the directory
# should be used after calling vista_configuer_[app|lib]
#  if USE_CONFIG_SUBDIRS is added, a postfix will be set for each BuildType (Debug, Release, RelWithDebInfo, ...)
macro( vista_set_outdir _PACKAGE_NAME _TARGET_DIR )
	string( TOUPPER  ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	if( ${ARGC} GREATER 2 AND "${ARGV2}" STREQUAL "USE_CONFIG_SUBDIRS" )
		# use subdirs
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG "${_TARGET_DIR}/Debug" )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE "${_TARGET_DIR}/Release" )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${_TARGET_DIR}/MinSizeRel" )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_TARGET_DIR}/RelWithDebInfo" )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${_TARGET_DIR}" )
		if( NOT VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "LIB" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG "${_TARGET_DIR}/Debug" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE "${_TARGET_DIR}/Release" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${_TARGET_DIR}/MinSizeRel" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_TARGET_DIR}/RelWithDebInfo" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${_TARGET_DIR} ")
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${_TARGET_DIR}/Debug" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${_TARGET_DIR}/Release" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${_TARGET_DIR}/MinSizeRel" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_TARGET_DIR}/RelWithDebInfo" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${_TARGET_DIR}" )
		endif( NOT VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "LIB" )
		set( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS TRUE CACHE INTERNAL "" FORCE )
	else( ${ARGC} GREATER 2 AND "${ARGV2}" STREQUAL "USE_CONFIG_SUBDIRS" )
		# dont use subdirs
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
		set_target_properties( ${_PACKAGE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${_TARGET_DIR} )
		if( NOT VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "LIB" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${_TARGET_DIR}" )
			set_target_properties( ${_PACKAGE_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${_TARGET_DIR}" )
		endif( NOT VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE OR VISTA_${_PACKAGE_NAME_UPPER}_TARGET_TYPE STREQUAL "LIB" )
		set( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR_WITH_CONFIG_SUBDIRS FALSE CACHE INTERNAL "" FORCE )
	endif( ${ARGC} GREATER 2 AND "${ARGV2}" STREQUAL "USE_CONFIG_SUBDIRS" )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )

	set( ${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR "${_TARGET_DIR}" CACHE INTERNAL "" FORCE )
endmacro( vista_set_outdir _PACKAGE_NAME TARGET_DIR )

# vista_set_version( PACKAGE TYPE NAME [ MAJOR [ MINOR [ PATCH [ TWEAK ]]]] )
# sets the extended version info for the package
# TYPE has to be RELEASE, HEAD, BRANCH, or TAG
# NAME can be an arbitrary name (excluding character -)
# MAJOR, MINOR, PATCH, TWEAK are optional version numbers. If svn_rev is specified, an svn revision is extracted if possible
# the macro defines the following
# <PACKAGE>_VERSION_EXT
# <PACKAGE>_VERSION_TYPE
# <PACKAGE>_VERSION_NAME
# <PACKAGE>_VERSION_MAJOR
# <PACKAGE>_VERSION_MINOR
# <PACKAGE>_VERSION_PATCH
# <PACKAGE>_VERSION_TWEAK
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

# vista_create_info_file( PACKAGE_NAME TARGET_DIR INSTALL_DIR )
# creates an info file that contains general information and settings about the build
# this can be usefull to later find out how and whith what settigns a package was build
# the file is called <PACKAGE_NAME>BuildInfo[BuildType].txt and
# is created in TARGET_DIR and installed to INSTALL_DIR
macro( vista_create_info_file _PACKAGE_NAME _TARGET_DIR _INSTALL_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	set( INFO_STRING "This file is auto-generated by the VistaCMakeCommon\n"
						"It contains build and configuration info for the project\n" )

	if( MSVC )
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo.txt" )
		set( _CONFIGS ${CMAKE_CONFIGURATION_TYPES} )
	else()
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo${CMAKE_BUILD_TYPE}.txt" )
		set( _CONFIGS ${CMAKE_BUILD_TYPE} )
	endif( MSVC )

	set( INFO_STRING "${INFO_STRING}\nProjectName:             ${CMAKE_PROJECT_NAME}" )
	set( INFO_STRING "${INFO_STRING}\nPackageName:             ${_PACKAGE_NAME}" )
	set( INFO_STRING "${INFO_STRING}\nOutputeName:             ${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}" )
	set( INFO_STRING "${INFO_STRING}\nHardware architecture:   ${VISTA_HWARCH}" )
	set( INFO_STRING "${INFO_STRING}\nOutDir:                  ${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}" )
	set( INFO_STRING "${INFO_STRING}\nType:                    ${${_PACKAGE_NAME_UPPER}_TARGET_TYPE}" )
	set( INFO_STRING "${INFO_STRING}\nBuildConfig:             ${_CONFIGS}" )
	set( INFO_STRING "${INFO_STRING}\nProject Location:        ${CMAKE_CURRENT_SOURCE_DIR}" )
	if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
		set( INFO_STRING "${INFO_STRING}\nVersion:                 ${${_PACKAGE_NAME_UPPER}_VERSION_EXT}" )
	else()
		set( INFO_STRING "${INFO_STRING}\nVersion:                 <unversioned>" )
	endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
	vista_get_svn_Info( _SVN_REV _SVN_REPOS _SVN_DATE )
	if( _SVN_REV )
		set( INFO_STRING "${INFO_STRING}\nSVN revision:            ${_SVN_REV}" )
		set( INFO_STRING "${INFO_STRING}\nSVN repositiory:         ${_SVN_REPOS}" )
		set( INFO_STRING "${INFO_STRING}\nSVN last commit:         ${_SVN_DATE}" )
	endif( _SVN_REV)
	if( UNIX )
		if( VISTA_USE_RPATH )
			set( INFO_STRING "${INFO_STRING}\nUsing RPath:             ON" )
		else()
			set( INFO_STRING "${INFO_STRING}\nUsing RPath:             OFF" )
		endif( VISTA_USE_RPATH )
	endif( UNIX )

	set( INFO_STRING "${INFO_STRING}\n\nDEPENDENCIES" )
	set( INFO_STRING "${INFO_STRING}\nvista_use_package calls:  ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES}" )
	set( INFO_STRING "${INFO_STRING}\nFull dependency info:" )
	foreach( _DEP ${${_PACKAGE_NAME_UPPER}_FULL_DEPENDENCIES} )
		string( TOUPPER ${_DEP} _DEP_UPPER )
		set( INFO_STRING "${INFO_STRING}\n${_DEP}" )
		if( DEFINED ${_DEP_UPPER}_VERSION_STRING )
			set( INFO_STRING "${INFO_STRING}\n    Version:             ${${_DEP_UPPER}_VERSION_STRING}" )
		elseif( DEFINED ${_DEP_UPPER}_VERSION_EXT )
			set( INFO_STRING "${INFO_STRING}\n    Version:             ${${_DEP_UPPER}_VERSION_EXT}" )
		elseif( DEFINED ${_DEP_UPPER}_VERSION )
			set( INFO_STRING "${INFO_STRING}\n    Version:             ${${_DEP_UPPER}_VERSION}" )
		elseif( DEFINED ${_DEP}_VERSION )
			set( INFO_STRING "${INFO_STRING}\n    Version:             ${${_DEP}_VERSION}" )
		else()
			set( INFO_STRING "${INFO_STRING}\n    Version:             <unknown>" )
		endif( DEFINED ${_DEP_UPPER}_VERSION_STRING )
		set( INFO_STRING "${INFO_STRING}\n    Root Dir             ${${_DEP_UPPER}_ROOT_DIR}" )
		set( INFO_STRING "${INFO_STRING}\n    Lib dirs:            ${${_DEP_UPPER}_INCLUDE_DIRS}" )
		set( INFO_STRING "${INFO_STRING}\n    Library dirs:        ${${_DEP_UPPER}_LIBRARY_DIRS}" )
		set( INFO_STRING "${INFO_STRING}\n    Definitions:         ${${_DEP_UPPER}_DEFINITIONS}" )
		set( INFO_STRING "${INFO_STRING}\n    Libraries:           ${${_DEP_UPPER}_LIBRARIES}" )
		if( DEFINED ${_DEP_UPPER}_USE_FILE )
			set( INFO_STRING "${INFO_STRING}\n    Use File:            ${${_DEP_UPPER}_USE_FILE}" )
		endif( DEFINED ${_DEP_UPPER}_USE_FILE )
		if( DEFINED ${_DEP_UPPER}_HWARCH )
			set( INFO_STRING "${INFO_STRING}\n    Use File:            ${${_DEP_UPPER}_HWARCH}" )
		endif( DEFINED ${_DEP_UPPER}_HWARCH )
	endforeach( _DEP ${VISTA_TARGET_FULL_DEPENDENCIES} )

	set( INFO_STRING "${INFO_STRING}\n\nConfigured with VistaCMakeCommon" )
	if( NOT VISTACOMMON_FILE_LOCATION )
		set( INFO_STRING "${INFO_STRING}\n\t<unknown VistaCMakeCommon location/version>" )
	else( NOT VISTACOMMON_FILE_LOCATION )
		set( INFO_STRING "${INFO_STRING}\n\tLocation:             ${VISTACOMMON_FILE_LOCATION}" )
		get_filename_component( _CMAKECOMMON_DIR "${VISTACOMMON_FILE_LOCATION}" PATH )
		vista_get_svn_Info( _SVN_REV _SVN_REPOS _SVN_DATE "${_CMAKECOMMON_DIR}" )
		if( _SVN_REV )
			set( INFO_STRING "${INFO_STRING}\n\tSVN revision:            ${_SVN_REV}" )
			set( INFO_STRING "${INFO_STRING}\n\tSVN repositiory:         ${_SVN_REPOS}" )
			set( INFO_STRING "${INFO_STRING}\n\tSVN last commit:         ${_SVN_DATE}" )
		endif( _SVN_REV)
	endif( NOT VISTACOMMON_FILE_LOCATION )

	set( INFO_STRING "${INFO_STRING}\n\nCMAKE FOLDER PROPETIES" )
	set( INFO_STRING "${INFO_STRING}\nGeneral" )
	set( _PROPERTIES DEFINITIONS COMPILE_DEFINITIONS INCLUDE_DIRECTORIES LINK_DIRECTORIES )
	foreach( _PROP ${_PROPERTIES} )
		get_directory_property( _VALUE ${_PROP} )
		if( _VALUE )
			set( INFO_STRING "${INFO_STRING}\n    ${_PROP}:\n\t\t\t${_VALUE}" )
		endif( _VALUE )
	endforeach( _PROP ${_PROPERTIES} )

	set( _PROPERTIES COMPILE_DEFINITIONS )
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n${_CONFIG}" )
		string( TOUPPER ${_CONFIG} _CONFIG_UPPER )
		foreach( _PROP ${_PROPERTIES} )
			get_directory_property( _VALUE ${_PROP}_${_CONFIG_UPPER} )
			if( _VALUE )
				set( INFO_STRING "${INFO_STRING}\n    ${_PROP}_${_CONFIG_UPPER}:\n\t\t\t${_VALUE}" )
			endif( _VALUE )
		endforeach( _PROP ${_PROPERTIES} )
	endforeach( _CONFIG ${_CONFIGS} )

	set( INFO_STRING "${INFO_STRING}\n\nCMAKE TARGET CONFIG" )
	set( INFO_STRING "${INFO_STRING}\nGeneral" )
	set( _PROPERTIES OUTPUT_NAME TYPE LOCATION LINK_FLAGS COMPILE_FLAGS
					BUILD_WITH_INSTALL_RPATH INSTALL_RPATH INSTALL_RPATH_USE_LINK_PATH SKIP_BUILD_RPATH
					COMPILE_DEFINITIONS COMPILE_FLAGS IMPORTED_LINK_DEPENDENT_LIBRARIES
	)
	foreach( _PROP ${_PROPERTIES} )
		get_target_property( _VALUE ${_PACKAGE_NAME} ${_PROP} )
		if( _VALUE )
			set( INFO_STRING "${INFO_STRING}\n    ${_PROP}:\n\t\t\t${_VALUE}" )
		endif( _VALUE )
	endforeach( _PROP ${_PROPERTIES} )

	set( _PROPERTIES OUTPUT_NAME LOCATION LINK_FLAGS COMPILE_DEFINITIONS IMPORTED_LINK_DEPENDENT_LIBRARIES LINK_FLAGS )
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n${_CONFIG}" )
		string( TOUPPER ${_CONFIG} _CONFIG_UPPER )
		foreach( _PROP ${_PROPERTIES} )
			get_target_property( _VALUE ${_PACKAGE_NAME} "${_PROP}_${_CONFIG_UPPER}" )
			if( _VALUE )
				set( INFO_STRING "${INFO_STRING}\n    ${_PROP}_${_CONFIG_UPPER}:\n\t\t\t${_VALUE}" )
			endif( _VALUE )
		endforeach( _PROP ${_PROPERTIES} )
	endforeach( _CONFIG ${_CONFIGS} )


	set( INFO_STRING "${INFO_STRING}\n\nCMAKE GLOBAL PROPETIES" )
	set( INFO_STRING "${INFO_STRING}\nGeneral" )
	set( _PROPERTIES CMAKE_SYSTEM CMAKE_BUILD_TOOL CMAKE_GENERATOR CMAKE_VERSION CMAKE_CXX_COMPILER CMAKE_LINKER
							CMAKE_MAKE_PROGRAM CMAKE_CXX_FLAGS CMAKE_SHARED_LINKER_FLAGS CMAKE_CXX_CREATE_SHARED_LIBRARY
							CMAKE_CXX_CREATE_SHARED_MODULE CMAKE_CXX_CREATE_STATIC_LIBRARY CMAKE_CXX_COMPILE_OBJECT CMAKE_CXX_LINK_EXECUTABLE
							CMAKE_CXX_STANDARD_LIBRARIES CMAKE_EXE_LINKER_FLAGS CMAKE_CXX_LINK_EXECUTABLE CMAKE_CXX_LINK_EXECUTABLE
	)
	foreach( _PROP ${_PROPERTIES} )
		if( ${_PROP} )
			set( INFO_STRING "${INFO_STRING}\n    ${_PROP}:\n\t\t\t${${_PROP}}" )
		endif( ${_PROP} )
	endforeach( _PROP ${_PROPERTIES} )

	set( _PROPERTIES CMAKE_CXX_FLAGS CMAKE_EXE_LINKER_FLAGS CMAKE_SHARED_LINKER_FLAGS )
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n${_CONFIG}" )
		string( TOUPPER ${_CONFIG} _CONFIG_UPPER )
		foreach(  ${_PROP}_${_CONFIG_UPPER} )
			#if( ${_PROP} )
				set( INFO_STRING "${INFO_STRING}\n    ${_PROP}_${_CONFIG_UPPER}:\n\t\t\t${"${_PROP}_${_CONFIG_UPPER}"}" )
			#endif( ${_PROP} )
		endforeach(  ${_PROP}_${_CONFIG_UPPER} )
		set( INFO_STRING "${INFO_STRING}\n    CMAKE_${_CONFIG_UPPER}_POSTFIX:\n\t\t\t${CMAKE_${_CONFIG_UPPER}_POSTFIX}" )
	endforeach( _CONFIG ${_CONFIGS} )

	file( WRITE "${INFO_FILENAME}" "${INFO_STRING}" )
	if( NOT "${_INSTALL_DIR}" STREQUAL "" )
		install( FILES "${INFO_FILENAME}" DESTINATION "${_INSTALL_DIR}" )
	endif( NOT "${_INSTALL_DIR}" STREQUAL "" )
endmacro( vista_create_info_file )

# vista_delete_info_file( PACKAGE_NAME TARGET_DIR )
# deletes the build info file for the package at the specified location
macro( vista_delete_info_file _PACKAGE_NAME _TARGET_DIR )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	if( MSVC )
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo.txt" )
	else()
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo${CMAKE_BUILD_TYPE}.txt" )
	endif( MSVC )
	if( EXISTS "${INFO_FILENAME}" )
		file( REMOVE "${INFO_FILENAME}" )
	endif( EXISTS "${INFO_FILENAME}" )
endmacro( vista_delete_info_file )

# vista_create_default_info_file( PACKAGE_NAME )
# uses the cache variable VISTA_CREATE_BUILD_INFO_FILES to determine
# if a build info file should be created, and if so, creates it next to the lib/app,
# and installs it to .../share/VistaBuildInfo
macro( vista_create_default_info_file _PACKAGE_NAME )
	set( VISTA_CREATE_BUILD_INFO_FILES TRUE CACHE BOOL "If enabled, an auto-generated build info file will be generated and installed for each target" )
	if( VISTA_CREATE_BUILD_INFO_FILES )
		string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
		vista_create_info_file( ${_PACKAGE_NAME} "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}" "${CMAKE_INSTALL_PREFIX}/share/VistaBuildInfo" )
	else()
		vista_delete_info_file( ${_PACKAGE_NAME} "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}" )
	endif( VISTA_CREATE_BUILD_INFO_FILES )
endmacro( vista_create_default_info_file )

# vista_create_doxygen_target( DOXYFILE )
# adds a target for creating doxygen info
# only works if Doxygen can be found on the system. If successfull, doxygen can be
# creating by running the "Doxygen" project in MSVC or by calling make Doxygen
macro( vista_create_doxygen_target _DOXYFILE )
	find_package( Doxygen )
	if( NOT DOXYGEN_FOUND )
		message( STATUS "vista_create_doxygen - Doxygen executable not found - cant create doxygen target" )
	else()
		add_custom_target( Doxygen
			${DOXYGEN_EXECUTABLE} "${_DOXYFILE}"
			WORKING_DIRECTORY "${_DOXY_ROOT}"
			COMMENT "Generating API documentation with Doxygen"
		)
		set_target_properties( Doxygen PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD TRUE )
	endif( NOT DOXYGEN_FOUND )
endmacro( vista_create_doxygen_target )

# vista_create_uninstall_target( [ON|OFF] )
# sets a cache variable VISTA_ALLOW_UNINSTALL, with default value of argument (or OFF if no argument is given)
# if VISTA_ALLOW_UNINSTALL is ON, an uninstall target will be created, which removes all previously installed files.
# WARNING: this may accidently remove files that might still be needed - use with care
# Also, the uninstall may leave behind empty directories
macro( vista_create_uninstall_target )
	if( ${ARGC} GREATER 1 )
		set( _DEFAULT ${ARGV0} )
	else()
		set( _DEFAULT "OFF" )
	endif( ${ARGC} GREATER 1 )
	set( VISTA_ALLOW_UNINSTALL ${_DEFAULT} CACHE BOOL "In enabled, an uninstall project will be created. Use at your own risk - may remove wrong files!" )
	if( VISTA_ALLOW_UNINSTALL )
		find_file( VISTA_CMAKE_UNINSTALL_PROTO_FILE "cmake_uninstall.cmake_proto" PATHS ${CMAKE_MODULE_PATH} )
		if( NOT VISTA_CMAKE_UNINSTALL_PROTO_FILE )
			message( AUTHOR_WARNING "cant find cmake_uninstall proto file - uninstall target will not be created." )
		else()
			configure_file( "${VISTA_CMAKE_UNINSTALL_PROTO_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" IMMEDIATE @ONLY )
			if( WIN32 )
				add_custom_target( UNINSTALL "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" )
				set_target_properties( UNINSTALL PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD TRUE )
				set_target_properties( UNINSTALL PROPERTIES FOLDER "CMakePredefinedTargets" )
			else()
				add_custom_target( uninstall "${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake" )
				set_target_properties( uninstall PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD TRUE )
			endif( WIN32 )

		endif( NOT VISTA_CMAKE_UNINSTALL_PROTO_FILE )
	endif( VISTA_ALLOW_UNINSTALL )
endmacro( vista_create_uninstall_target )




###########################
###   General Settings  ###
###########################

# if VISTA_CMAKE_COMMON envvar is set, we buffer it and add it to CMAKE_MODULE_PATH and CMAKE_PREFIX_PATH
if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )
	file( TO_CMAKE_PATH $ENV{VISTA_CMAKE_COMMON} VISTA_CMAKE_COMMON )
	
	# we clean the CMAKE_MODULE_PATH - just in case there are some \ pathes in there
	set( _TMP_MODULE_PATH ${CMAKE_MODULE_PATH} )
	set( CMAKE_MODULE_PATH )
	foreach( _PATH ${_TMP_MODULE_PATH} )
		file( TO_CMAKE_PATH ${_PATH} _CHANGED_PATH )
		list( APPEND CMAKE_MODULE_PATH ${_CHANGED_PATH} )
	endforeach( _PATH )

	list( APPEND CMAKE_MODULE_PATH "${VISTA_CMAKE_COMMON}" "${VISTA_CMAKE_COMMON}/share" )
	list( APPEND CMAKE_PREFIX_PATH "${VISTA_CMAKE_COMMON}" "${VISTA_CMAKE_COMMON}/share" )
	list( REMOVE_DUPLICATES CMAKE_MODULE_PATH )
	list( REMOVE_DUPLICATES CMAKE_PREFIX_PATH )
endif( EXISTS "$ENV{VISTA_CMAKE_COMMON}" )

if( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( ALREADY_CONFIGURED_ONCE TRUE CACHE INTERNAL "defines if this is the first config run or not" )
	set( FIRST_CONFIGURE_RUN TRUE )
else( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( FIRST_CONFIGURE_RUN FALSE )
endif( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )

# general settings/flags
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
add_definitions( ${VISTA_PLATFORM_DEFINE} ) # adds -DWIN32 / -DLINUX or similar


if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE PATH "distribution directory" FORCE )
	set( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT FALSE )
endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )

if( WIN32 )
	if( MSVC )
		vista_set_defaultvalue( CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "CMake configuration types" )
		# msvc disable some warnings
		set( VISTA_DISABLE_GENERIC_MSVC_WARNINGS ON CACHE BOOL "If true, generic warnings (4251, 4275, 4503, CRT_SECURE_NO_WARNINGS) will be set for Visual Studio" )
		if( VISTA_DISABLE_GENERIC_MSVC_WARNINGS )
			add_definitions( /D_CRT_SECURE_NO_WARNINGS /wd4251 /wd4275 /wd4503 )
		endif( VISTA_DISABLE_GENERIC_MSVC_WARNINGS )
		#Enable string pooling
		add_definitions( -GF )
		# Parallel build for Visual Studio?
		set( VISTA_USE_PARALLEL_MSVC_BUILD ON CACHE BOOL "Add /MP flag for parallel build on Visual Studio" )
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
endif( WIN32 )

# we once parse the referenced configs in VISTA_CMAKE_COMMON to remove outdated ones
if( EXISTS "$ENV{VISTA_CMAKE_COMMON}" AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )
	set( VISTA_CHECKED_COPIED_CONFIG_FILES TRUE )
	set( PACKAGE_REFERENCE_EXISTS_TEST TRUE )
	file( GLOB_RECURSE _ALL_VERSION_FILES "$ENV{VISTA_CMAKE_COMMON}/share/*Config.cmake" )
	foreach( _FILE ${_ALL_VERSION_FILES} )
		set( PACKAGE_REFERENCE_OUTDATED FALSE )
		include( ${_FILE} )
		if( PACKAGE_REFERENCE_OUTDATED )
			get_filename_component( _DIR ${_FILE} PATH )
			message( STATUS "Removing outdated configs copied to \"${_DIR}\"" )
			file( REMOVE_RECURSE ${_DIR} )
		endif( PACKAGE_REFERENCE_OUTDATED )
	endforeach( _FILE ${_ALL_VERSION_FILES} )
	set( PACKAGE_REFERENCE_EXISTS_TEST FALSE )
endif( EXISTS "$ENV{VISTA_CMAKE_COMMON}" AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )

set( VISTACOMMON_FILE_LOCATION "VISTACOMMON_FILE_LOCATION-NOTFOUND" CACHE INTERNAL "" FORCE )
find_file( VISTACOMMON_FILE_LOCATION "VistaCommon.cmake" PATHS ${CMAKE_MODULE_PATH} $ENV{CMAKE_MODULE_PATH} NO_DEFAULT_PATH )
set( VISTACOMMON_FILE_LOCATION ${VISTACOMMON_FILE_LOCATION} CACHE INTERNAL "" FORCE )

endif( NOT VISTA_COMMON_INCLUDED ) # this shows we did not include it yet
