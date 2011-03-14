if( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( ALREADY_CONFIGURED_ONCE TRUE CACHE INTERNAL "defines if this is the first config run or not" )
	set( FIRST_CONFIGURE_RUN TRUE )
else( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )
	set( FIRST_CONFIGURE_RUN FALSE )
endif( NOT ALREADY_CONFIGURED_ONCE OR FIRST_CONFIGURE_RUN )

#macro for overriding default values
macro( changevardefault )
	if( FIRST_CONFIGURE_RUN )
		if( ${ARGC} EQUAL 1 )
			set( ${ARGV0} )
		elseif( ${ARGC} EQUAL 2 )
			set( ${ARGV0} ${ARGV1} )
		elseif( ${ARGC} EQUAL 3 )
			set( ${ARGV0} ${ARGV1} ${ARGV2} )
		elseif( ${ARGC} EQUAL 4 )
			set( ${ARGV0} ${ARGV1} ${ARGV2} ${ARGV3} )
		elseif( ${ARGC} EQUAL 5 )
			set( ${ARGV0} ${ARGV1} ${ARGV2} ${ARGV3} ${ARGV4} )
		elseif( ${ARGC} EQUAL 6 )
			set( ${ARGV0} ${ARGV1} ${ARGV2} ${ARGV3} ${ARGV4} ${ARGV5})
		elseif( ${ARGC} EQUAL 7 )
			set( ${ARGV0} ${ARGV1} ${ARGV2} ${ARGV3} ${ARGV4} ${ARGV5} ${ARGV6} )
		else( ${ARGC} EQUAL 1 )
			message( SEND_ERROR "changedvardefault called with invalid number of arguments" ) 
		endif( ${ARGC} EQUAL 1 )
	endif( FIRST_CONFIGURE_RUN )
endmacro( changevardefault )

# use: vista_conditional_add_subdirectory( variable_name directory [ON|OFF] [ADVANCED [MSG string] )
macro( vista_conditional_add_subdirectory )
	set( VISTA_CONDITIONAL_SET_STATE ON )
	set( VISTA_CONDITIONAL_SET_ADVANCED FALSE )
	set( VISTA_CONDITIONAL_SET_MSG "Build the ${ARGV1} library" )
	set( VISTA_CONDITIONAL_SET_MSG_NEXT FALSE )
	
	foreach( ARG ${ARGV} )
		if( VISTA_CONDITIONAL_SET_MSG_NEXT )
			set( VISTA_CONDITIONAL_SET_MSG ${ARG} )
			set( VISTA_CONDITIONAL_SET_MSG_NEXT FALSE )
		elseif( ${ARG} STREQUAL  "ON" )
			set( VISTA_CONDITIONAL_SET_STATE ON )
		elseif( ${ARG} STREQUAL  "OFF" )
			set( VISTA_CONDITIONAL_SET_STATE OFF )
		elseif( ${ARG} STREQUAL  "ADVANCED" )
			set( VISTA_CONDITIONAL_SET_ADVANCED TRUE )
		elseif( ${ARG} STREQUAL  "MSG" )
			set( VISTA_CONDITIONAL_SET_MSG_NEXT TRUE )
		endif( VISTA_CONDITIONAL_SET_MSG_NEXT )
	endforeach( ARG ${ARGV} )
	
	set( ${ARGV0} ${VISTA_CONDITIONAL_SET_STATE} CACHE BOOL "${VISTA_CONDITIONAL_SET_MSG}" )
	if( VISTA_CONDITIONAL_SET_ADVANCED )
		mark_as_advanced( ${ARGV0} )
	endif( VISTA_CONDITIONAL_SET_ADVANCED )
	
	if( ${ARGV0} )
		add_subdirectory( ${ARGV1} )
	endif( ${ARGV0} )
endmacro( vista_conditional_add_subdirectory )

if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	SET( VISTA_64BIT TRUE )
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	SET( VISTA_64BIT FALSE )
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

set( CMAKE_DEBUG_POSTFIX "D" )
set_property( GLOBAL PROPERTY USE_FOLDERS ON )

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
			message( "Warning: unknown msvc version" )
			set( VISTA_HWARCH "${VISTA_HWARCH}.vc" )
		endif( MSVC80 )
	else( MSVC )
		message( "Warning: using WIN32 without Visual Studio - this will probably fail - use at your own risk!" )
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
	message( "Warning: unsupported hardware architecture - use at your own risk!" )
	set( VISTA_HWARCH "UNKOWN_ARCHITECTURE" )
endif( WIN32 )

# Platform dependent definitions
if( UNIX )
    add_definitions(-DLINUX)
elseif( WIN32 )
	add_definitions(-DWIN32)
    if( MSVC )
		changevardefault( CMAKE_CONFIGURATION_TYPES "Release;Debug" CACHE STRING "CMake configuration types" FORCE )
		# msvc disable some warnings
        add_definitions( /D_CRT_SECURE_NO_WARNINGS /wd4251 /wd4275 /wd4503 )
		#Enable string pooling
		add_definitions( -GF )
		# Parallel build for Visual Studio?
		set( VISTA_USE_PARALLEL_BUILD ON CACHE BOOL "Add /MP flag for parallel build on Visual Studio" )
		if( VISTA_USE_PARALLEL_BUILD )
            add_definitions( /MP )
        else()
            remove_definitions(/MP)
        endif(VISTA_USE_PARALLEL_BUILD)
		# Check for sse optimization
		if( NOT VISTA_64BIT )
			set( VISTA_USE_SSE_OPTIMIZATION ON CACHE BOOL "Use automatic SSE2 optimizations")
			if( VISTA_USE_SSE_OPTIMIZATION )
				add_definitions( /arch:SSE2 )
			else()
				remove_definitions( /arch:SSE2 )
			endif( VISTA_USE_SSE_OPTIMIZATION )
		endif( NOT VISTA_64BIT )
    endif( MSVC )
endif( UNIX )


macro( find_package_versioned PACKAGE_NAME VERSION_NAME )

	set( ARGS_LIST ${ARGV} )
	list( FIND ARGS_LIST "REQUIRED" _REQUIRED_FOUND_IN_ARGS )
		
	if( NOT ${PACKAGE_NAME}_FOUND )
		# we first do a regular search with a definitely unused version
		# this will fail, but gives us ${PACKAGE_NAME}_CONSIDERED_CONFIGS
		# with a list of found config files		
		
		list( REMOVE_ITEM ARGS_LIST ${PACKAGE_NAME} ${VERSION_NAME} REQUIRED )
		
		find_package( ${PACKAGE_NAME} 666.666.666.666 QUIET ${ARGS_LIST} )
		
		set( _FIND_SUCCESS FALSE )
		
		foreach( FOUND_CONFIG ${${PACKAGE_NAME}_CONSIDERED_CONFIGS} )
			#string( REGEX MATCH "" ${FOUND_VERSION} _REXEX_MATCH )	
			if( NOT _FIND_SUCCESS )
				string( REGEX MATCH "(.+)Config\\.cmake" _MATCH_SUCCESS ${FOUND_CONFIG} )
				if( _MATCH_SUCCESS )
					# lets look for a corresponding ConfigVersion.cmake file
					set( _VERSION_FILE "" CACHE INTERNAL "internal store to version file" )
					set( _VERSION_FILE "${CMAKE_MATCH_1}ConfigVersion.cmake" )
					if( _VERSION_FILE )
						# let's include the file
						include( ${_VERSION_FILE} )
						if( PACKAGE_VERSION_EXT )
							# it's a specially configured file for custom versioning, so it provides a macro check_custom_versioned
							check_custom_versioned( ${VERSION_NAME} _FIND_SUCCESS )
							if( _FIND_SUCCESS )
								#include actual config file
								include( ${FOUND_CONFIG} )
								if( NOT QUIET )
									message( STATUS "Found Package ${PACKAGE_NAME}" )
									message( STATUS "\tDirectory: ${FOUND_CONFIG}" )
									message( STATUS "\tVersion  : ${PACKAGE_VERSION_EXT}" )
								endif( NOT QUIET )
							else( _FIND_SUCCESS )
								list( APPEND _CANDIDATE_LIST "${FOUND_CONFIG} (Version: ${PACKAGE_VERSION_EXT})" )
							endif( _FIND_SUCCESS )
						else( PACKAGE_VERSION_EXT )
							list( APPEND _CANDIDATE_LIST "${FOUND_CONFIG} (incompatible version file)" )
						endif( PACKAGE_VERSION_EXT )
					else( _VERSION_FILE )
						list( APPEND _CANDIDATE_LIST "${FOUND_CONFIG} (unversioned)" )
					endif( _VERSION_FILE )
				endif( _MATCH_SUCCESS )
					
			endif( NOT _FIND_SUCCESS )
			
			
		endforeach( FOUND_CONFIG ${${PACKAGE_NAME}_CONSIDERED_CONFIGS} )
		
		
		if( NOT _FIND_SUCCESS )
			if( NOT QUIET OR NOT _REQUIRED_FOUND_IN_ARGS EQUAL -1 )
				message( "${PACKAGE_NAME} could not be found. Candidates were:" )
				foreach( CANDIDATE ${_CANDIDATE_LIST} )
					message( "\t${CANDIDATE}" )
				endforeach( CANDIDATE ${_CANDIDATE_LIST} )				
			endif( NOT QUIET OR NOT _REQUIRED_FOUND_IN_ARGS EQUAL -1 )
		endif( NOT _FIND_SUCCESS )
		
		set( ${PACKAGE_NAME}_FOUND _FIND_SUCCESS )
		
	endif( NOT ${PACKAGE_NAME}_FOUND )
	
	if( NOT ${PACKAGE_NAME}_FOUND )
		if( NOT _REQUIRED_FOUND_IN_ARGS EQUAL -1 )
			message( SEND_ERROR "${PACKAGE_NAME} not found!" )
		endif( NOT _REQUIRED_FOUND_IN_ARGS EQUAL -1 )
	endif( NOT ${PACKAGE_NAME}_FOUND )
	
endmacro( find_package_versioned PACKAGE_NAME VERSION_NAME )

macro( configure_and_install_package_version _IN_PACKAGE_NAME )
	find_file( VISTA_VERSION_PROTO_FILE "PackageConfigVersion.cmake_proto" )
	mark_as_advanced( VISTA_VERSION_PROTO_FILE )
	
	string( TOUPPER ${_IN_PACKAGE_NAME} _IN_PACKAGE_NAME_UPPER )
	
	if( NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_TYPE
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_NAME
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_MAJOR
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_MINOR
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_REVISION )
		message( "To correctly configure a versionfile, the following version variables need to be specified:" )
		message( "\t${_IN_PACKAGE_NAME_UPPER}_VERSION_TYPE" )
		message( "\t${_IN_PACKAGE_NAME_UPPER}_VERSION_NAME" )
		message( "\t${_IN_PACKAGE_NAME_UPPER}_VERSION_MAJOR" )
		message( "\t${_IN_PACKAGE_NAME_UPPER}_VERSION_MINOR" )
		message( "\t${_IN_PACKAGE_NAME_UPPER}_VERSION_REVISION" )
	endif( NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_TYPE
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_NAME
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_MAJOR
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_MINOR
		OR NOT ${_IN_PACKAGE_NAME_UPPER}_VERSION_REVISION )
	
	if( VISTA_VERSION_PROTO_FILE )
		set( _VERSION_TYPE		${${_IN_PACKAGE_NAME_UPPER}_VERSION_TYPE} )
		set( _VERSION_NAME		${${_IN_PACKAGE_NAME_UPPER}_VERSION_NAME} )
		set( _VERSION_MAJOR 	${${_IN_PACKAGE_NAME_UPPER}_VERSION_MAJOR} )
		set( _VERSION_MINOR 	${${_IN_PACKAGE_NAME_UPPER}_VERSION_MINOR} )
		set( _VERSION_REVISION	${${_IN_PACKAGE_NAME_UPPER}_VERSION_REVISION} )
		configure_file(
			${VISTA_VERSION_PROTO_FILE}
			${CMAKE_CURRENT_BINARY_DIR}/cmake/${_IN_PACKAGE_NAME}ConfigVersion.cmake
			@ONLY
		)
		if( UNIX )
			install( FILES
				${CMAKE_CURRENT_BINARY_DIR}/cmake/${_IN_PACKAGE_NAME}ConfigVersion.cmake
				DESTINATION "${CMAKE_INSTALL_PREFIX}/share/cmake/${PACKAGE_NAME}"
			)
		elseif( WIN32 )
			install( FILES
				${CMAKE_CURRENT_BINARY_DIR}/cmake/${_IN_PACKAGE_NAME}ConfigVersion.cmake
				DESTINATION "${CMAKE_INSTALL_PREFIX}/cmake"
			)
		endif(UNIX)
	else( VISTA_VERSION_PROTO_FILE )
		message( "Warning( configure_and_install_package_version ) could not find file PackageConfigVersion.cmake_proto" )
	endif( VISTA_VERSION_PROTO_FILE )
	
endmacro( configure_and_install_package_version )

set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG" )

# Should we use rpath?
# This enables us to use OpenSG etc. within the Vista* libraries without having
# to set a LIBRARY_PATH while linking against these libraries
set( VISTA_USE_RPATH ON CACHE BOOL "Use rpath" )
mark_as_advanced( VISTA_USE_RPATH )
