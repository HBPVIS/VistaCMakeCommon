# This file contains common settings and macros for setting up Vista projects

# PACKAGE MACROS
# find_package_versioned( PACKAGE_NAME _EXTENDED_VERSION_NAME ... )
# vista_use_package( PACKAGE [VERSION] [EXACT] [[COMPONENTS | REQUIRED] comp1 comp2 ... ] [QUIET] [FIND_DEPENDENCIES] )
# vista_configure_app( _TARGET_NAME )
# vista_configure_lib( _TARGET_NAME )
# vista_install( TARGET [INCLUDE_SUBDIRECTORY [LIBRARY_SUBDIRECTORY] ] )
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
#	VISTA_64BIT				- TRUE if 64BIT-System, FALSE on 32bit
# adds some general flags/configurations
#	sets CMAKE_DEBUG_POSTFIX to "D"
#	enables global cmake property USE_FOLDERS - allows grouping of projects in msvc
#	conditionally adds DEBUG and OS definitions
#	some visual studio flags
#	VISTA_USE_RPATH cache flag to enable/disable use of RPATH
#	currently scans XYZConfig.cmake files in VISTA_CMAKE_COMMON/configs, and deletes outdated ones


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


# replace_svn_revision_tag( STRING )
# if the string equals an svn $Id$ or $rev$ entry, the svn revision is extracted and replaces the string
macro( replace_svn_revision_tag _STRING_VAR )
	string( REGEX MATCH "^\\$Revision: ([0-9]+)\\$$" _MATCH_SUCCESS ${${_STRING_VAR}} )
	if( NOT _MATCH_SUCCESS )
		string( REGEX MATCH "^\\$Id: [^ ]+ ([0-9]+) .*" _MATCH_SUCCESS ${${_STRING_VAR}} )
	endif( NOT _MATCH_SUCCESS )
	if( _MATCH_SUCCESS )
		set( ${_STRING_VAR} ${CMAKE_MATCH_1} )
	endif( _MATCH_SUCCESS )	
endmacro( replace_svn_revision_tag VARIABLE_STRING_VAR )


macro( clean_former_copied_package_configs _PACKAGE_NAME _PACKAGE_ROOT_DIR )
	file( GLOB_RECURSE _ALL_VERSION_FILES "$ENV{VISTA_CMAKE_COMMON}/configs/${_PACKAGE_NAME}*/${_PACKAGE_NAME}ConfigVersion.cmake" )
	foreach( _FILE ${_ALL_VERSION_FILES} )
		include( ${_FILE} )
		if( PACKAGE_REFERENCE_OUTDATED OR ${_PACKAGE_ROOT_DIR} STREQUAL ${PACKAGE_REFERENCE_DIR} )
			string( REGEX MATCH "($ENV{VISTA_CMAKE_COMMON}/configs/.+)/cmake/.*" _MATCHED ${_FILE} )
			if( _MATCHED )
				set( _DIR ${CMAKE_MATCH_1} )			
				message( STATUS "Removing previous config copied to \"${_DIR}\"" )
				file( REMOVE_RECURSE ${_DIR} )
			endif( _MATCHED )
		endif( PACKAGE_REFERENCE_OUTDATED OR ${_PACKAGE_ROOT_DIR} STREQUAL ${PACKAGE_REFERENCE_DIR} )
	endforeach( _FILE ${_ALL_VERSION_FILES} )
endmacro( clean_former_copied_package_configs _PACKAGE_NAME _PACKAGE_ROOT_DIR )



###########################
###   Package macros    ###
###########################

# find_package_versioned( PACKAGE_NAME _EXTENDED_VERSION_NAME ... )
# works like the normal find_package, but allows to use an extended version
macro( find_package_versioned _PACKAGE_NAME _VERSION_NAME )
	set( _ARGS_LIST ${ARGV} )
	list( REMOVE_ITEM _ARGS_LIST ${_PACKAGE_NAME} ${_VERSION_NAME} )
	set( ${_PACKAGE_NAME}_FIND_VERSION_EXT ${_VERSION_NAME} )
	set( PACKAGE_FIND_VERSION_EXT ${_VERSION_NAME} )
	find_package( ${_PACKAGE_NAME} 0.0.0 ${_ARGS_LIST} )
	set( PACKAGE_FIND_VERSION_EXT )	
	set( ${_PACKAGE_NAME}_FIND_VERSION_EXT )
endmacro( find_package_versioned _PACKAGE_NAME _VERSION_NAME )


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
	
	# parse arguments
	set( _FIND_PACKAGE_ARGS )
	set( _FIND_DEPENDENCIES FALSE )
	set( _PACKAGE_VERSION "" )
	set( _QUIET FALSE )
	set( _REQUIRED FALSE )
	set( _USING_COMPONENTS FALSE )
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
		elseif( ${_ARG} STREQUAL "${ARGV0}" )
			# it's okay, just the name
		elseif( ${_ARG} STREQUAL "${ARGV1}" )
			# the requested version
			set( _PACKAGE_VERSION ${_ARG} )
		elseif( _PARSE_COMPONENTS )
			list( APPEND _FIND_PACKAGE_ARGS ${_ARG} )
			set( _USING_COMPONENTS TRUE )
		else()
			message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Unknown argument [${_ARG}]" )
		endif( ${_ARG} STREQUAL "FIND_DEPENDENCIES" )
	endforeach( _ARG ${ARGV} )
	
	if( NOT VISTA_USING_${_PACKAGE_NAME_UPPER} OR _USING_COMPONENTS )
		# find package		
		if( _PACKAGE_VERSION )
			string( REGEX MATCH "^[0-9\\.]*$" _MATCH ${_PACKAGE_VERSION} )
			if( _MATCH )
				find_package( V${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} )
			else( _MATCH )
				find_package_versioned( V${_PACKAGE_NAME} ${_PACKAGE_VERSION} ${_FIND_PACKAGE_ARGS} )
			endif( _MATCH )
		else( _PACKAGE_VERSION )
			find_package( V${_PACKAGE_NAME} ${_FIND_PACKAGE_ARGS} )
		endif( _PACKAGE_VERSION )
				
		set( ${_PACKAGE_NAME_UPPER}_FOUND ${${_PACKAGE_NAME_UPPER}_FOUND} )
		
		#if found - set required variables
		if( V${_PACKAGE_NAME_UPPER}_FOUND )
			include_directories( ${${_PACKAGE_NAME_UPPER}_INCLUDE_DIRS} )
			link_directories( ${${_PACKAGE_NAME_UPPER}_LIBRARY_DIRS} )
			add_definitions( ${${_PACKAGE_NAME_UPPER}_DEFINITIONS} )
			
			# check if HWARCH matches
			if( ${_PACKAGE_NAME_UPPER}_HWARCH AND NOT ${${_PACKAGE_NAME_UPPER}_HWARCH} STREQUAL ${VISTA_HWARCH} )
				message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package was built as ${${_PACKAGE_NAME_UPPER}_HWARCH}, but is used with ${VISTA_HWARCH}" )
			endif( ${_PACKAGE_NAME_UPPER}_HWARCH AND NOT ${${_PACKAGE_NAME_UPPER}_HWARCH} STREQUAL ${VISTA_HWARCH} )
			
			#set variables for Vista BuildSystem to track dependencies
			list( APPEND VISTA_USE_PACKAGE_LIBRARIES ${${_PACKAGE_NAME_UPPER}_LIBRARIES} )
			# TODO: removing duplicates also removes optimized and debug flags...
			#list( REMOVE_DUPLICATES VISTA_USE_PACKAGE_LIBRARIES )
			list( APPEND VISTA_TARGET_LINK_DIRS ${${_PACKAGE_NAME_UPPER}_LIBRARY_DIRS} )
			if( _PACKAGE_VERSION )
				list( APPEND VISTA_TARGET_DEPENDENCIES "${_PACKAGE_NAME}-${_PACKAGE_VERSION}" )
			else( _PACKAGE_VERSION )
				list( APPEND VISTA_TARGET_DEPENDENCIES "${_PACKAGE_NAME}" )
			endif( _PACKAGE_VERSION )
			set( VISTA_USING_${_PACKAGE_NAME_UPPER} TRUE )
			
			# we dont want to add second-level dependencies to VISTA_TARGET_DEPENDENCIES, so be buffer it and reset it later
			set( _TMP_VISTA_TARGET_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} )
			
			#handle dependencies
			foreach( _DEPENDENCY ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES} )
				string( REGEX MATCH "^([^\\-]+)\\-(.+)$" _MATCHED ${_DEPENDENCY} )
				if( _MATCHED )
					set( _DEP_PACKAGE ${CMAKE_MATCH_1} )
					set( _DEP_VERSION ${CMAKE_MATCH_2} )
				else( _MATCHED )
					set( _DEP_PACKAGE ${_DEPENDENCY} )
				endif( _MATCHED )
				string( TOUPPER ${_DEP_PACKAGE} _DEP_UPPER )
				if( _FIND_DEPENDENCIES )
					if( NOT ${_DEP_UPPER}_FOUND AND NOT V${_DEP_UPPER}_FOUND )
						# find and use the dependency. If it fails, utter a warning
						if( NOT _QUIET )
							message( STATUS "Automatically adding \"${_PACKAGE_NAME}\" dependency \"${_DEPENDENCY}\"" )
						endif( NOT _QUIET )
						vista_use_package( ${_DEP_PACKAGE} ${_DEP_VERSION} FIND_DEPENDENCIES )
						if( NOT V${_DEP_UPPER}_FOUND AND NOT _QUIET )
							message( WARNING "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY}\", but including it failed" )
						endif( NOT V${_DEP_UPPER}_FOUND AND NOT _QUIET )
					endif( NOT ${_DEP_UPPER}_FOUND AND NOT V${_DEP_UPPER}_FOUND )
				else( _FIND_DEPENDENCIES )
					# check if dependencies are already included. If not, utter a warning					
					if( NOT ${_DEP_UPPER}_FOUND AND NOT V${_DEP_UPPER}_FOUND AND NOT _QUIET )
						message( "vista_use_package( ${_PACKAGE_NAME} ) - Package depends on \"${_DEPENDENCY}\", which was not found yet" )
					endif( NOT ${_DEP_UPPER}_FOUND AND NOT V${_DEP_UPPER}_FOUND AND NOT _QUIET )
				endif( _FIND_DEPENDENCIES )
			endforeach( _DEPENDENCY ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES} )

			#restire dependencies before recursive include
			set( VISTA_TARGET_DEPENDENCIES ${_TMP_VISTA_TARGET_DEPENDENCIES} )			
			
		endif( V${_PACKAGE_NAME_UPPER}_FOUND )	
	endif( NOT VISTA_USING_${_PACKAGE_NAME_UPPER} OR _USING_COMPONENTS )
	
endmacro( vista_use_package _PACKAGE_NAME )

# vista_configure_app( _TARGET_NAME )
# sets some general properties for the target to configure it as application
#	sets default value for CMAKE_INSTALL_PREFIX (if not set otherwise) to source directory
#	sets the Application Name to _TARGET_NAME with "D"-PostFix under Debug
#	if not overwritten, sets the outdir to the target's source directory
#	creates a shell script that sets the path to find required libraries
#	for MSVC, a *.vcproj.user file is created, setting Working Directory and Path Environment
macro( vista_configure_app _TARGET_NAME )
	string( TOUPPER ${_TARGET_NAME} _TARGET_NAME_UPPER )
	if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
		vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}" CACHE PATH "distribution directory" FORCE )
	endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	
	set( ${_TARGET_NAME}_TARGET_TYPE "APP" )

	set_target_properties( ${_TARGET_NAME} PROPERTIES OUTPUT_NAME_DEBUG				"${_TARGET_NAME}D" )
	set_target_properties( ${_TARGET_NAME} PROPERTIES OUTPUT_NAME_RELEASE			"${_TARGET_NAME}" )
	set_target_properties( ${_TARGET_NAME} PROPERTIES OUTPUT_NAME_MINSIZEREL 		"${_TARGET_NAME}" )
	set_target_properties( ${_TARGET_NAME} PROPERTIES OUTPUT_NAME_RELWITHDEBINFO	"${_TARGET_NAME}" )
	
	if( NOT DEFINED ${${_TARGET_NAME_UPPER}_TARGET_OUTDIR} )		
		vista_set_outdir( ${_TARGET_NAME} ${CMAKE_CURRENT_SOURCE_DIR} )
	endif( NOT DEFINED ${${_TARGET_NAME_UPPER}_TARGET_OUTDIR} )
	
	# we store the dependencies as required
	set( ${_TARGET_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	# create a script that sets the path
	if( VISTA_TARGET_LINK_DIRS )
		if( WIN32 )
			find_file( VISTA_ENVIRONMENT_SCRIPT_FILE "set_path.bat_proto" ${CMAKE_MODULE_PATH} )
			mark_as_advanced( VISTA_ENVIRONMENT_SCRIPT_FILE )
			if( VISTA_ENVIRONMENT_SCRIPT_FILE )
				configure_file(
						${VISTA_ENVIRONMENT_SCRIPT_FILE}
						${${_TARGET_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_TARGET_NAME}.bat
						@ONLY
				)
			endif( VISTA_ENVIRONMENT_SCRIPT_FILE )
		elseif( MSVC )
			find_file( VISTA_ENVIRONMENT_SCRIPT_FILE "set_path.sh_proto" ${CMAKE_MODULE_PATH} )
			mark_as_advanced( VISTA_ENVIRONMENT_SCRIPT_FILE )
			if( VISTA_ENVIRONMENT_SCRIPT_FILE )
				configure_file(
						${VISTA_ENVIRONMENT_SCRIPT_FILE}
						${${_TARGET_NAME_UPPER}_TARGET_OUTDIR}/set_path_for_${_TARGET_NAME}.sh
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
			
			set( _WORK_DIR ${${_TARGET_NAME_UPPER}_TARGET_OUTDIR} )
		
			set( _ENVIRONMENT )
			if( VISTA_TARGET_LINK_DIRS )
				set( _ENVIRONMENT "PATH=${VISTA_TARGET_LINK_DIRS};%PATH%" )
			endif( VISTA_TARGET_LINK_DIRS )
			
			configure_file(
				${VISTA_VCPROJUSER_PROTO_FILE}
				${CMAKE_CURRENT_BINARY_DIR}/${_TARGET_NAME}.vcproj.user
				@ONLY
			)
		else( VISTA_VCPROJUSER_PROTO_FILE )
			message( WARNING "vista_configure_app( ${_TARGET_NAME} ) - could not find file VisualStudio.vcproj.user_proto" )
		endif( VISTA_VCPROJUSER_PROTO_FILE )
	endif( MSVC )
endmacro( vista_configure_app )

# vista_configure_lib( _TARGET_NAME )
# sets some general properties for the target to configure it as application
#	sets default value for CMAKE_INSTALL_PREFIX (if not set otherwise) to /dist/VISTA_HWARCH
#	if not overwritten, sets the outdir to the target's source directory
#	adds *_EXPORT or *_STATIC definition
macro( vista_configure_lib _TARGET_NAME )
	if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
		vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE PATH "distribution directory" FORCE )
	endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	
	set( ${_TARGET_NAME}_TARGET_TYPE "LIB" )
		
	if( NOT ${_TARGET_NAME_UPPER}_TARGET_OUTDIR )
		vista_set_outdir( ${_TARGET_NAME} "${CMAKE_BINARY_DIR}/lib" )
	endif( NOT ${_TARGET_NAME_UPPER}_TARGET_OUTDIR )
	
	# we store the dependencies as required
	set( ${_TARGET_NAME_UPPER}_DEPENDENCIES ${VISTA_TARGET_DEPENDENCIES} CACHE INTERNAL "" FORCE )
	
	string( TOUPPER ${_TARGET_NAME} _NAME_UPPER )
	vista_set_defaultvalue( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries if ON, static libraries if OFF" FORCE )
	if( WIN32 )
		if( BUILD_SHARED_LIBS )
			set_target_properties( ${_TARGET_NAME} PROPERTIES COMPILE_FLAGS -D${_NAME_UPPER}_EXPORTS )
		else( BUILD_SHARED_LIBS )
			set_target_properties( ${_TARGET_NAME} PROPERTIES COMPILE_FLAGS -D${_NAME_UPPER}_STATIC )
		endif( BUILD_SHARED_LIBS )	
	endif( WIN32 )
endmacro( vista_configure_lib _TARGET_NAME)

# vista_install( TARGET [INCLUDE_SUBDIRECTORY [LIBRARY_SUBDIRECTORY] ] )
# can only be called after vista_configure_[app|lib]
# installs generic files (headers, librarys, executables, .pdb's)
# headers will be installed to include, or to include/INCLUDE_SUBDIRECTORY
# libraries/dlls will be installed to lib, or to lib/LIBRARY_SUBDIRECTORY
# executables will be installed toplevel
macro( vista_install _PACKAGE_NAME )
	if( ${ARGC} EQUAL 0 OR ${ARGC} GREATER 3 )
		message( SEND_ERROR "Invalid number of arguments for vista_install! usage: vista_install( TargetName [ IncludeSubDirectory ] [ LibrarySubDirectory ] ) - with optional subdirectories appended to the include / lib subdirs" )
	endif( ${ARGC} EQUAL 0 OR ${ARGC} GREATER 3 )
	
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	
	if( ${ARGC} GREATER 1 )
		set( ${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR "include/${ARGV1}" )
	else( ${ARGC} GREATER 1 )
		set( ${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR "include" )
	endif( ${ARGC} GREATER 1 )
	
	if( ${ARGC} GREATER 2 )
		set( ${_PACKAGE_NAME_UPPER}_LIB_SUBDIR "lib/${ARGV2}" )
	else( ${ARGC} GREATER 2 )
		set(${_PACKAGE_NAME_UPPER}_LIB_SUBDIR "lib" )
	endif( ${ARGC} GREATER 2 )	
	
	if( ${_TARGET_NAME}_TARGET_TYPE STREQUAL "APP" )
		install( TARGETS ${_PACKAGE_NAME}
			RUNTIME DESTINATION "./"
		)
	else( ${_TARGET_NAME}_TARGET_TYPE STREQUAL "APP" )
		install( TARGETS ${_PACKAGE_NAME}
			LIBRARY DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR}
			ARCHIVE DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR}
			RUNTIME DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR}
		)
		install( DIRECTORY	.
			DESTINATION ${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR}
			FILES_MATCHING PATTERN "*.h"
			PATTERN "build" EXCLUDE
			PATTERN ".svn" EXCLUDE
			PATTERN "CMakeFiles" EXCLUDE
		)
		if( MSVC )
			install( DIRECTORY "${${_PACKAGE_NAME_UPPER}_TARGET_OUTDIR}/"
				DESTINATION ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR}
				FILES_MATCHING PATTERN "*.pdb"
			)
		endif( MSVC )
	endif( ${_TARGET_NAME}_TARGET_TYPE STREQUAL "APP" )	
endmacro()

# vista_create_cmake_configs( TARGET [CUSTOM_CONFIG_FILE] )
# can only be called after vista_configure_[app|lib]
# generates XYZConfig.cmake-files for the target, either from a generic prototype or
# from the optional specified one. Each configfile is created twice: one for the build version, and one
# for the install version, which point to different locations
# If the VISTA_CMAKE_ROOT environment variable is set, the XYZConfig.cmake files will also be copied to
# VISTA_CMAKE_ROOT/configs into a subfolder composed from the name, the (optional) version, and either -build or -install
# NOTE: these will be overwritten at the next configure/install, so make sure different versions of the same project
# have different version names
# In Addition to the XYZConfig.cmake files, a generic XYZConfigVersion.cmake file is created if the version has been specified
# using vista_set_version() or vista_adopt_version(), in the same way as the Config files
macro( vista_create_cmake_configs _TARGET )
	set( _PACKAGE_NAME ${_TARGET} )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	set( _PRECONDITION_FAIL FALSE )
	
	if( UNIX )
		set( _CMAKE_SUBDIR "share/cmake" )
	elseif( WIN32 )
		set( _CMAKE_SUBDIR "cmake" )
	endif()
	
	if( ${ARGC} GREATER 1 )	
		#look for custom config file
		if( EXISTS ${ARGV1} )
			set( _CONFIG_PROTO_FILE ${ARGV1} )
		else( EXISTS ${ARGV1} )
			find_file( _${_PACKAGE_NAME}_CONFIG_PROTO_FILE ${ARGV1} PATHS ${CMAKE_MODULE_PATH} PATHS ${CMAKE_CURRENT_SOURCE_DIR} )
			if( NOT _${_PACKAGE_NAME}_CONFIG_PROTO_FILE )
				message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find config file ${ARGV1}" )
				set( _PRECONDITION_FAIL TRUE )
			endif( NOT _${_PACKAGE_NAME}_CONFIG_PROTO_FILE )
			set( _CONFIG_PROTO_FILE ${_${_PACKAGE_NAME}_CONFIG_PROTO_FILE} )
		endif( EXISTS ${ARGV1} )		
	else( ${ARGC} GREATER 1 )
		#use default config file
		find_file( _DEFAULT_CONFIG_PROTO_FILE "PackageConfig.cmake_proto" PATHS ${CMAKE_MODULE_PATH} )
		set( _DEFAULT_CONFIG_PROTO_FILE ${_DEFAULT_CONFIG_PROTO_FILE} CACHE INTERNAL "Default Prototype file for <Package>Config.cmake" )
		if( NOT _DEFAULT_CONFIG_PROTO_FILE )
			message( WARNING "vista_create_cmake_configs( ${_TARGET} ) - Could not find default config file PackageConfig.cmake_proto" )
		endif( NOT _DEFAULT_CONFIG_PROTO_FILE )		
		set( _CONFIG_PROTO_FILE ${_DEFAULT_CONFIG_PROTO_FILE} )
	endif( ${ARGC} GREATER 1 )


	if( NOT EXISTS ${_CONFIG_PROTO_FILE} )
		message( WARNING "vista_create_cmake_configs( ${_TARGET} ) -  Could not find custom Configure file" )
		set( _PRECONDITION_FAIL TRUE )
	endif( NOT EXISTS ${_CONFIG_PROTO_FILE} )
	
	if( NOT _PRECONDITION_FAIL )
		if( EXISTS $ENV{VISTA_CMAKE_COMMON} )
			set( _PACKAGE_CONFIG_TARGET "$ENV{VISTA_CMAKE_COMMON}/configs/${_PACKAGE_NAME}" )
			if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
				set( _PACKAGE_CONFIG_TARGET "${_PACKAGE_CONFIG_TARGET}-${${_PACKAGE_NAME_UPPER}_VERSION_EXT}" )
			else( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
				set( _PACKAGE_CONFIG_TARGET "${_PACKAGE_CONFIG_TARGET}-${VISTA_HWARCH}" )
			endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )		
		endif( EXISTS $ENV{VISTA_CMAKE_COMMON} )
		
		if( _PACKAGE_CONFIG_TARGET )
			# we create two files: one for the build, one for the install version
			# they will both be stored at the same target - however, the build Config is copied on
			# config, while the install variant is copied on (surprise!) install, and will then
			# override the build configs
			if( ${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR )
				set( _PACKAGE_LIBRARY_DIR ${${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR} )
			else()
				get_target_property( _PACKAGE_LIBRARY_DIR ${_PACKAGE_NAME} LIBRARY_OUTPUT_DIRECTORY )
			endif( ${_PACKAGE_NAME_UPPER}_LIBRARY_OUTDIR )
			
			set( _PACKAGE_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
			clean_former_copied_package_configs( ${_PACKAGE_NAME} ${_PACKAGE_ROOT_DIR} )
			set( _PACKAGE_INCLUDE_DIR "${CMAKE_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}" )
			list( REMOVE_DUPLICATES _PACKAGE_INCLUDE_DIR )
			configure_file(	${_CONFIG_PROTO_FILE} "${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}Config.cmake" @ONLY )
			file( COPY "${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}Config.cmake "
					DESTINATION ${_PACKAGE_CONFIG_TARGET}-build/${_CMAKE_SUBDIR} )
			
			set( _PACKAGE_ROOT_DIR "${CMAKE_INSTALL_PREFIX}" )
			clean_former_copied_package_configs( ${_PACKAGE_NAME} ${_PACKAGE_ROOT_DIR} )
			if( ${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR} )
				set( _PACKAGE_INCLUDE_DIR "${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR}" )		
			else( ${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR} )
				set( _PACKAGE_INCLUDE_DIR "${_PACKAGE_ROOT_DIR}/include" )		
			endif( ${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR} )
			if( ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR} )
				set( _PACKAGE_LIBRARY_DIR "${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR}" )
			else( ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR} )
				set( _PACKAGE_LIBRARY_DIR "${_PACKAGE_ROOT_DIR}/lib" )
			endif( ${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR} )
			
			configure_file(	${_CONFIG_PROTO_FILE} "${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}Config.cmake" @ONLY )
			install( FILES
				"${CMAKE_BINARY_DIR}/toinstall/${_CMAKE_SBDIR}/${_PACKAGE_NAME}Config.cmake"
				DESTINATION "${CMAKE_INSTALL_PREFIX}/${_CMAKE_SUBDIR}"
			)
			install( FILES
				"${CMAKE_BINARY_DIR}/toinstall/${_CMAKE_SBDIR}/${_PACKAGE_NAME}Config.cmake"
				DESTINATION "${_PACKAGE_CONFIG_TARGET}-install/${_CMAKE_SUBDIR}"
			)
		else()
			# we create just the install file			
			set( _PACKAGE_ROOT_DIR ${CMAKE_INSTALL_PREFIX} )
			set( _PACKAGE_INCLUDE_DIR ${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_INCLUDE_SUBDIR} )
			set( _PACKAGE_LIBRARY_DIR ${_PACKAGE_ROOT_DIR}/${${_PACKAGE_NAME_UPPER}_LIB_SUBDIR} )
			configure_file(	${_CONFIG_PROTO_FILE} ${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}Config.cmake	@ONLY )
			install( FILES
				${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}Config.cmake
				DESTINATION "${CMAKE_INSTALL_PREFIX}/${_CMAKE_SUBDIR}"
			)
			install( FILES
				${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}Config.cmake
				DESTINATION "${_PACKAGE_CONFIG_TARGET}-install/${_CMAKE_SUBDIR}"
			)
		endif( _PACKAGE_CONFIG_TARGET )
		
		# if there is a version set, we also configure the corresponding version file
		if( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )
			find_file( VISTA_VERSION_PROTO_FILE "PackageConfigVersion.cmake_proto" PATHS ${CMAKE_MODULE_PATH} )
			set( VISTA_VERSION_PROTO_FILE ${VISTA_VERSION_PROTO_FILE} CACHE INTERNAL "" )
			if( VISTA_VERSION_PROTO_FILE )
				set( _VERSION_TYPE 	${${_PACKAGE_NAME_UPPER}_VERSION_TYPE} )
				set( _VERSION_NAME 	${${_PACKAGE_NAME_UPPER}_VERSION_NAME} )
				set( _VERSION_MAJOR ${${_PACKAGE_NAME_UPPER}_VERSION_MAJOR} )
				set( _VERSION_MINOR ${${_PACKAGE_NAME_UPPER}_VERSION_MINOR} )
				set( _VERSION_PATCH ${${_PACKAGE_NAME_UPPER}_VERSION_PATCH} )
				set( _VERSION_TWEAK ${${_PACKAGE_NAME_UPPER}_VERSION_TWEAK} )
				set( _VERSION 		${${_PACKAGE_NAME_UPPER}_VERSION} )
				set( _VERSION_EXT 	${${_PACKAGE_NAME_UPPER}_VERSION_EXT} )
				
				if( _PACKAGE_CONFIG_TARGET )
					set( _PACKAGE_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
					configure_file( ${VISTA_VERSION_PROTO_FILE} ${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake @ONLY )
					file( COPY ${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake 
							DESTINATION ${_PACKAGE_CONFIG_TARGET}-build/${_CMAKE_SUBDIR} )
					
					set( _PACKAGE_ROOT_DIR ${CMAKE_INSTALL_PREFIX} )
					configure_file( ${VISTA_VERSION_PROTO_FILE} ${CMAKE_BINARY_DIR}/toinstall/${_PACKAGE_NAME}ConfigVersion.cmake @ONLY )			
					install( FILES
						"${CMAKE_BINARY_DIR}/toinstall/${_CMAKE_SBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake"
						DESTINATION "${CMAKE_INSTALL_PREFIX}/${_CMAKE_SUBDIR}"
					)
					install( FILES
						"${CMAKE_BINARY_DIR}/toinstall/${_CMAKE_SBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake"
						DESTINATION "${_PACKAGE_CONFIG_TARGET}-install/${_CMAKE_SUBDIR}"
					)
				else()
					# we create just the install file
					set( _PACKAGE_ROOT_DIR ${CMAKE_INSTALL_PREFIX} )					
					configure_file( ${VISTA_VERSION_PROTO_FILE} ${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake @ONLY )
					install( FILES
						${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake
						DESTINATION "${CMAKE_INSTALL_PREFIX}/${_CMAKE_SUBDIR}"
					)
					install( FILES
						${CMAKE_BINARY_DIR}/${_CMAKE_SUBDIR}/${_PACKAGE_NAME}ConfigVersion.cmake
						DESTINATION "${_PACKAGE_CONFIG_TARGET}-install/${_CMAKE_SUBDIR}"
					)
				endif( _PACKAGE_CONFIG_TARGET )
			endif( VISTA_VERSION_PROTO_FILE )
		endif( DEFINED ${_PACKAGE_NAME_UPPER}_VERSION_EXT )			
		
	endif( NOT _PRECONDITION_FAIL )	
endmacro( vista_create_cmake_configs )

# vista_set_outdir( TARGET DIRECTORY )
# sets the outdir of the target to the directory
# should be used after calling vista_configuer_[app|lib]
macro( vista_set_outdir _TARGET_NAME _TARGET_DIR )
	string( TOUPPER ${_TARGET_NAME} _TARGET_NAME_UPPER )
	set_target_properties( ${_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
	set_target_properties( ${_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
	set_target_properties( ${_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
	set_target_properties( ${_TARGET_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
	if( NOT VISTA_${_TARGET_NAME}_TARGET_TYPE OR VISTA_${_TARGET_NAME}_TARGET_TYPE STREQUAL "LIB" )
		set_target_properties( ${_TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_DEBUG ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELEASE ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL ${_TARGET_DIR} )
		set_target_properties( ${_TARGET_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO ${_TARGET_DIR} )
	endif( NOT VISTA_${_TARGET_NAME}_TARGET_TYPE OR VISTA_${_TARGET_NAME}_TARGET_TYPE STREQUAL "LIB" )
	set( ${_TARGET_NAME_UPPER}_TARGET_OUTDIR ${_TARGET_DIR} CACHE INTERNAL "" FORCE )
endmacro( vista_set_outdir _TARGET_NAME TARGET_DIR )

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
if( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( ALREADY_CONFIGURED_ONCE TRUE CACHE INTERNAL "defines if this is the first config run or not" )
	set( FIRST_CONFIGURE_RUN TRUE )
else( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( FIRST_CONFIGURE_RUN FALSE )
endif( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )

if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	SET( VISTA_64BIT TRUE )
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	SET( VISTA_64BIT FALSE )
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

if( WIN32 )
	if( VISTA_64BIT )
		set( VISTA_HWARCH "win32-x64" )
	else( VISTA_64BIT )
		set( VISTA_HWARCH "win32" )
	endif( VISTA_64BIT )
	
	if( MSVC )
		if( MSVC80 )
			set( VISTA_HWARCH "${VISTA_HWARCH}.vc8" )
		elseif( MSVC90 )
			set( VISTA_HWARCH "${VISTA_HWARCH}.v90" )
		elseif( MSVC10 )
			set( VISTA_HWARCH "${VISTA_HWARCH}.vc10" )
		else( MSVC80 )
			message( WARNING "VistaCommon - Unknown MSVC version" )
			set( VISTA_HWARCH "${VISTA_HWARCH}.vc" )
		endif( MSVC80 )
	else( MSVC )
		message( WARNING "VistaCommon - using WIN32 without Visual Studio - this will probably fail - use at your own risk!" )
	endif( MSVC )
elseif( APPLE )
	set( VISTA_HWARCH "DARWIN" )
elseif( UNIX )
	if( VISTA_64BIT )
		set( VISTA_HWARCH "LINUX.X86_64" )
	else( VISTA_64BIT )
		set( VISTA_HWARCH "LINUX.X86" )
	endif( VISTA_64BIT )
else( WIN32 )
	message( WARNING "VistaCpmmon - Unsupported hardware architecture - use at your own risk!" )
	set( VISTA_HWARCH "UNKOWN_ARCHITECTURE" )
endif( WIN32 )

set( CMAKE_DEBUG_POSTFIX "D" )
set_property( GLOBAL PROPERTY USE_FOLDERS ON )
set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG" )
# Should we use rpath? This enables us to use OpenSG etc. within the Vista* libraries without having
# to set a LIBRARY_PATH while linking against these libraries
set( VISTA_USE_RPATH ON CACHE BOOL "Use rpath" )
mark_as_advanced( VISTA_USE_RPATH )

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
if( EXISTS $ENV{VISTA_CMAKE_COMMON} AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )
	set( VISTA_CHECKED_COPIED_CONFIG_FILES TRUE )	
	file( GLOB_RECURSE _ALL_VERSION_FILES "$ENV{VISTA_CMAKE_COMMON}/configs/*ConfigVersion.cmake" )
	foreach( _FILE ${_ALL_VERSION_FILES} )
		include( ${_FILE} )
		if( PACKAGE_REFERENCE_OUTDATED )
		string( REGEX MATCH "($ENV{VISTA_CMAKE_COMMON}/configs/.+)/cmake/.*" _MATCHED ${_FILE} )
		if( _MATCHED )
			set( _DIR ${CMAKE_MATCH_1} )			
			message( STATUS "Removing outdated configs copied to \"${_DIR}\"" )
			file( REMOVE_RECURSE ${_DIR} )
		endif( _MATCHED )
		endif( PACKAGE_REFERENCE_OUTDATED )
	endforeach( _FILE ${_ALL_VERSION_FILES} )
endif( EXISTS $ENV{VISTA_CMAKE_COMMON} AND NOT VISTA_CHECKED_COPIED_CONFIG_FILES )
