set( VISTA_BUILDINFO_VARIABLES_GENERAL
						# variables that change behavior
						BUILD_SHARED_LIBS
						CMAKE_ABSOLUTE_DESTINATION_FILES
						CMAKE_AUTOMOC_RELAXED_MODE
						CMAKE_BACKWARDS_COMPATIBILITY
						CMAKE_BUILD_TYPE
						CMAKE_COLOR_MAKEFILE
						CMAKE_CONFIGURATION_TYPES
						CMAKE_DEBUG_TARGET_PROPERTIES
						CMAKE_ERROR_DEPRECATED
						CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION
						CMAKE_FIND_LIBRARY_PREFIXES
						CMAKE_FIND_LIBRARY_SUFFIXES
						CMAKE_FIND_PACKAGE_WARN_NO_MODULE
						CMAKE_IGNORE_PATH
						CMAKE_INCLUDE_PATH
						CMAKE_INSTALL_DEFAULT_COMPONENT_NAME
						CMAKE_INSTALL_PREFIX
						CMAKE_LIBRARY_PATH
						CMAKE_MFC_FLAG
						CMAKE_MODULE_PATH
						CMAKE_NOT_USING_CONFIG_FLAGS
						CMAKE_PREFIX_PATH
						CMAKE_PROGRAM_PATH
						CMAKE_SKIP_INSTALL_ALL_DEPENDENCY
						CMAKE_SYSTEM_IGNORE_PATH
						CMAKE_SYSTEM_INCLUDE_PATH
						CMAKE_SYSTEM_LIBRARY_PATH
						CMAKE_SYSTEM_PREFIX_PATH
						CMAKE_SYSTEM_PROGRAM_PATH
						CMAKE_USER_MAKE_RULES_OVERRIDE
						CMAKE_WARN_DEPRECATED
						CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION
						
						#variables that describe the build						
						APPLE
						BORLAND
						CMAKE_CL_64
						CMAKE_COMPILER_2005
						CMAKE_HOST_APPLE
						CMAKE_HOST_SYSTEM
						CMAKE_HOST_SYSTEM_NAME
						CMAKE_HOST_SYSTEM_PROCESSOR
						CMAKE_HOST_SYSTEM_VERSION
						CMAKE_HOST_UNIX
						CMAKE_HOST_WIN32
						CMAKE_LIBRARY_ARCHITECTURE
						CMAKE_LIBRARY_ARCHITECTURE_REGEX
						CMAKE_OBJECT_PATH_MAX
						CMAKE_SYSTEM
						CMAKE_SYSTEM_NAME
						CMAKE_SYSTEM_PROCESSOR
						CMAKE_SYSTEM_VERSION
						CYGWIN
						ENV
						MSVC
						MSVC10
						MSVC11
						MSVC12
						MSVC60
						MSVC70
						MSVC71
						MSVC80
						MSVC90
						MSVC_IDE
						MSVC_VERSION
						UNIX
						WIN32
						XCODE_VERSION

						#variables that control the build						
						CMAKE_ARCHIVE_OUTPUT_DIRECTORY
						CMAKE_AUTOMOC
						CMAKE_AUTOMOC_MOC_OPTIONS
						CMAKE_BUILD_WITH_INSTALL_RPATH
						CMAKE_DEBUG_POSTFIX
						CMAKE_EXE_LINKER_FLAGS
						CMAKE_Fortran_FORMAT
						CMAKE_Fortran_MODULE_DIRECTORY
						CMAKE_GNUtoMS
						CMAKE_INCLUDE_CURRENT_DIR
						CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE
						CMAKE_INSTALL_NAME_DIR
						CMAKE_INSTALL_RPATH
						CMAKE_INSTALL_RPATH_USE_LINK_PATH
						CMAKE_LIBRARY_OUTPUT_DIRECTORY
						CMAKE_LIBRARY_PATH_FLAG
						CMAKE_LINK_DEF_FILE_FLAG
						CMAKE_LINK_DEPENDS_NO_SHARED
						CMAKE_LINK_INTERFACE_LIBRARIES
						CMAKE_LINK_LIBRARY_FILE_FLAG
						CMAKE_LINK_LIBRARY_FLAG
						CMAKE_MACOSX_BUNDLE
						CMAKE_MODULE_LINKER_FLAGS
						CMAKE_NO_BUILTIN_CHRPATH
						CMAKE_PDB_OUTPUT_DIRECTORY
						CMAKE_POSITION_INDEPENDENT_CODE
						CMAKE_RUNTIME_OUTPUT_DIRECTORY
						CMAKE_SHARED_LINKER_FLAGS
						CMAKE_SKIP_BUILD_RPATH
						CMAKE_SKIP_INSTALL_RPATH
						CMAKE_STATIC_LINKER_FLAGS
						CMAKE_TRY_COMPILE_CONFIGURATION
						CMAKE_USE_RELATIVE_PATHS
						CMAKE_VISIBILITY_INLINES_HIDDEN
						CMAKE_WIN32_EXECUTABLE
						EXECUTABLE_OUTPUT_PATH
						LIBRARY_OUTPUT_PATH
						
						#variables that provide information
						CMAKE_AR
						CMAKE_ARGC
						CMAKE_ARGV0
						CMAKE_BINARY_DIR
						CMAKE_BUILD_TOOL
						CMAKE_CACHEFILE_DIR
						CMAKE_CACHE_MAJOR_VERSION
						CMAKE_CACHE_MINOR_VERSION
						CMAKE_CACHE_PATCH_VERSION
						CMAKE_CFG_INTDIR
						CMAKE_COMMAND
						CMAKE_CROSSCOMPILING
						CMAKE_CTEST_COMMAND
						CMAKE_CURRENT_BINARY_DIR
						CMAKE_CURRENT_LIST_DIR
						CMAKE_CURRENT_LIST_FILE
						CMAKE_CURRENT_LIST_LINE
						CMAKE_CURRENT_SOURCE_DIR
						CMAKE_DL_LIBS
						CMAKE_EDIT_COMMAND
						CMAKE_EXECUTABLE_SUFFIX
						CMAKE_EXTRA_GENERATOR
						CMAKE_EXTRA_SHARED_LIBRARY_SUFFIXES
						CMAKE_GENERATOR
						CMAKE_GENERATOR_TOOLSET
						CMAKE_HOME_DIRECTORY
						CMAKE_IMPORT_LIBRARY_PREFIX
						CMAKE_IMPORT_LIBRARY_SUFFIX
						CMAKE_LINK_LIBRARY_SUFFIX
						CMAKE_MAJOR_VERSION
						CMAKE_MAKE_PROGRAM
						CMAKE_MINIMUM_REQUIRED_VERSION
						CMAKE_MINOR_VERSION
						CMAKE_PARENT_LIST_FILE
						CMAKE_PATCH_VERSION
						CMAKE_PROJECT_NAME
						CMAKE_RANLIB
						CMAKE_ROOT
						CMAKE_SCRIPT_MODE_FILE
						CMAKE_SHARED_LIBRARY_PREFIX
						CMAKE_SHARED_LIBRARY_SUFFIX
						CMAKE_SHARED_MODULE_PREFIX
						CMAKE_SHARED_MODULE_SUFFIX
						CMAKE_SIZEOF_VOID_P
						CMAKE_SKIP_RPATH
						CMAKE_SOURCE_DIR
						CMAKE_STANDARD_LIBRARIES
						CMAKE_STATIC_LIBRARY_PREFIX
						CMAKE_STATIC_LIBRARY_SUFFIX
						CMAKE_TWEAK_VERSION
						CMAKE_VERBOSE_MAKEFILE
						CMAKE_VERSION
						CMAKE_VS_PLATFORM_TOOLSET
						CMAKE_XCODE_PLATFORM_TOOLSET
						PROJECT_BINARY_DIR
						PROJECT_NAME
						PROJECT_SOURCE_DIR
					)
	
set( VISTA_BUILDINFO_VARIABLES_PER_TARGET 	
						CMAKE_EXE_LINKER_FLAGS
						CMAKE_STATIC_LINKER_FLAGS
						CMAKE_SHARED_LINKER_FLAGS
						CMAKE_MODULE_LINKER_FLAGS
					)
set( VISTA_BUILDINFO_VARIABLES_LANGUAGE
						_ARCHIVE_APPEND
						_ARCHIVE_CREATE
						_ARCHIVE_FINISH
						_COMPILER
						_COMPILER_ABI
						_COMPILER_ID
						_COMPILER_LOADED
						_COMPILER_VERSION
						_COMPILE_OBJECT
						_CREATE_SHARED_LIBRARY
						_CREATE_SHARED_MODULE
						_CREATE_STATIC_LIBRARY
						_FLAGS
						_FLAGS_DEBUG
						_FLAGS_MINSIZEREL
						_FLAGS_RELEASE
						_FLAGS_RELWITHDEBINFO
						_IGNORE_EXTENSIONS
						_IMPLICIT_INCLUDE_DIRECTORIES
						_IMPLICIT_LINK_DIRECTORIES
						_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
						_IMPLICIT_LINK_LIBRARIES
						_LIBRARY_ARCHITECTURE
						_LINKER_PREFERENCE
						_LINKER_PREFERENCE_PROPAGATES
						_LINK_EXECUTABLE
						_OUTPUT_EXTENSION
						_PLATFORM_ID
						_SIZEOF_DATA_PTR
						_SOURCE_FILE_EXTENSIONS
					)

set( VISTA_BUILDINFO_GLOBAL_PROPERTIES 						
						ALLOW_DUPLICATE_CUSTOM_TARGETS
						AUTOMOC_TARGETS_FOLDER
						DEBUG_CONFIGURATIONS
						DISABLED_FEATURES
						ENABLED_FEATURES
						ENABLED_LANGUAGES
						FIND_LIBRARY_USE_LIB64_PATHS
						FIND_LIBRARY_USE_OPENBSD_VERSIONING
						GLOBAL_DEPENDS_DEBUG_MODE
						GLOBAL_DEPENDS_NO_CYCLES
						IN_TRY_COMPILE
						PACKAGES_FOUND
						PACKAGES_NOT_FOUND
						PREDEFINED_TARGETS_FOLDER
						REPORT_UNDEFINED_PROPERTIES
						RULE_LAUNCH_COMPILE
						RULE_LAUNCH_CUSTOM
						RULE_LAUNCH_LINK
						RULE_MESSAGES
						TARGET_ARCHIVES_MAY_BE_SHARED_LIBS
						TARGET_SUPPORTS_SHARED_LIBS
						USE_FOLDERS
						__CMAKE_DELETE_CACHE_CHANGE_VARS_ 
					)
set( VISTA_BUILDINFO_FOLDER_PROPERTIES 
						ADDITIONAL_MAKE_CLEAN_FILES
						CLEAN_NO_CUSTOM
						COMPILE_DEFINITIONS
						COMPILE_OPTIONS
						DEFINITIONS
						EXCLUDE_FROM_ALL
						IMPLICIT_DEPENDS_INCLUDE_TRANSFORM
						INCLUDE_DIRECTORIES
						INCLUDE_REGULAR_EXPRESSION
						INTERPROCEDURAL_OPTIMIZATION
						LINK_DIRECTORIES
						LISTFILE_STACK
						MACROS
						PARENT_DIRECTORY
						RULE_LAUNCH_COMPILE
						RULE_LAUNCH_CUSTOM
						RULE_LAUNCH_LINK
						TEST_INCLUDE_FILE
					)
set( VISTA_BUILDINFO_FOLDER_PROPERTIES_CONFIG
						COMPILE_DEFINITIONS
						INTERPROCEDURAL_OPTIMIZATION			
					)
					
set( VISTA_BUILDINFO_TARGET_PROPERTIES
				#ALIASED_TARGET
				ARCHIVE_OUTPUT_DIRECTORY
				ARCHIVE_OUTPUT_NAME
				AUTOMOC
				AUTOMOC_MOC_OPTIONS
				BUILD_WITH_INSTALL_RPATH
				BUNDLE
				BUNDLE_EXTENSION
				COMPATIBLE_INTERFACE_BOOL
				COMPATIBLE_INTERFACE_STRING
				COMPILE_DEFINITIONS
				COMPILE_FLAGS
				COMPILE_OPTIONS
				DEBUG_POSTFIX
				DEFINE_SYMBOL
				ENABLE_EXPORTS
				EXCLUDE_FROM_ALL
				EXCLUDE_FROM_DEFAULT_BUILD
				EXPORT_NAME
				EchoString
				FOLDER
				FRAMEWORK
				Fortran_FORMAT
				Fortran_MODULE_DIRECTORY
				GENERATOR_FILE_NAME
				GNUtoMS
				HAS_CXX
				IMPLICIT_DEPENDS_INCLUDE_TRANSFORM
				IMPORTED
				IMPORTED_CONFIGURATIONS
				IMPORTED_IMPLIB
				IMPORTED_LINK_DEPENDENT_LIBRARIES
				IMPORTED_LINK_INTERFACE_LANGUAGES
				IMPORTED_LINK_INTERFACE_LIBRARIES
				IMPORTED_LINK_INTERFACE_MULTIPLICITY
				IMPORTED_LOCATION
				IMPORTED_NO_SONAME
				IMPORTED_SONAME
				IMPORT_PREFIX
				IMPORT_SUFFIX
				INCLUDE_DIRECTORIES
				INSTALL_NAME_DIR
				INSTALL_RPATH
				INSTALL_RPATH_USE_LINK_PATH
				INTERFACE_COMPILE_DEFINITIONS
				INTERFACE_COMPILE_OPTIONS
				INTERFACE_INCLUDE_DIRECTORIES
				INTERFACE_LINK_LIBRARIES
				INTERFACE_POSITION_INDEPENDENT_CODE
				INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
				INTERPROCEDURAL_OPTIMIZATION
				LABELS
				LIBRARY_OUTPUT_DIRECTORY
				LIBRARY_OUTPUT_NAME
				LINKER_LANGUAGE
				LINK_DEPENDS
				LINK_DEPENDS_NO_SHARED
				LINK_FLAGS
				LINK_INTERFACE_LIBRARIES
				LINK_INTERFACE_MULTIPLICITY
				LINK_LIBRARIES
				LINK_SEARCH_END_STATIC
				LINK_SEARCH_START_STATIC
				LOCATION
				MACOSX_BUNDLE
				MACOSX_BUNDLE_INFO_PLIST
				MACOSX_FRAMEWORK_INFO_PLIST
				MACOSX_RPATH
				NAME
				NO_SONAME
				OSX_ARCHITECTURES
				OUTPUT_NAME
				PDB_NAME
				PDB_OUTPUT_DIRECTORY
				POSITION_INDEPENDENT_CODE
				POST_INSTALL_SCRIPT
				PREFIX
				PRE_INSTALL_SCRIPT
				PRIVATE_HEADER
				PROJECT_LABEL
				PUBLIC_HEADER
				RESOURCE
				RULE_LAUNCH_COMPILE
				RULE_LAUNCH_CUSTOM
				RULE_LAUNCH_LINK
				RUNTIME_OUTPUT_DIRECTORY
				RUNTIME_OUTPUT_NAME
				SKIP_BUILD_RPATH
				SOURCES
				SOVERSION
				STATIC_LIBRARY_FLAGS
				SUFFIX
				TYPE
				VERSION
				VISIBILITY_INLINES_HIDDEN
				VS_DOTNET_REFERENCES
				VS_DOTNET_TARGET_FRAMEWORK_VERSION
				VS_GLOBAL_KEYWORD
				VS_GLOBAL_PROJECT_TYPES
				VS_GLOBAL_ROOTNAMESPACE
				VS_KEYWORD
				VS_SCC_AUXPATH
				VS_SCC_LOCALPATH
				VS_SCC_PROJECTNAME
				VS_SCC_PROVIDER
				VS_WINRT_EXTENSIONS
				VS_WINRT_REFERENCES
				WIN32_EXECUTABLE
			)
set( VISTA_BUILDINFO_TARGET_PROPERTIES_CONFIG
				ARCHIVE_OUTPUT_DIRECTORY
				ARCHIVE_OUTPUT_NAME
				COMPILE_DEFINITIONS
				EXCLUDE_FROM_DEFAULT_BUILD
				IMPORTED_IMPLIB
				IMPORTED_LINK_DEPENDENT_LIBRARIES
				IMPORTED_LINK_INTERFACE_LANGUAGES
				IMPORTED_LINK_INTERFACE_LIBRARIES
				IMPORTED_LINK_INTERFACE_MULTIPLICITY
				IMPORTED_LOCATION
				IMPORTED_NO_SONAME
				IMPORTED_SONAME
				INTERPROCEDURAL_OPTIMIZATION
				LIBRARY_OUTPUT_DIRECTORY
				LIBRARY_OUTPUT_NAME
				LINK_FLAGS
				LINK_INTERFACE_LIBRARIES
				LINK_INTERFACE_MULTIPLICITY
				LOCATION
				MAP_IMPORTED_CONFIG
				OSX_ARCHITECTURES
				OUTPUT_NAME
				PDB_NAME
				PDB_OUTPUT_DIRECTORY
				RUNTIME_OUTPUT_DIRECTORY
				RUNTIME_OUTPUT_NAME
				STATIC_LIBRARY_FLAGS
			)

# internal helper macros - not to be used outside of this file
macro( vista_internal_write_variable _VAR )
	if( ${_VAR} )
		set( INFO_STRING "${INFO_STRING}\n\t\t${_VAR}:\n\t\t\t\t${${_VAR}}" )
	endif()
endmacro()
macro( vista_internal_write_prop _PROP )
	get_property( _VALUE ${ARGN} PROPERTY ${_PROP} )
	if( _VALUE )
		set( INFO_STRING "${INFO_STRING}\n\t\t${_PROP}:\n\t\t\t\t${_VALUE}" )
	endif()
endmacro()
			
# vista_create_info_file( PACKAGE_NAME TARGET_DIR INSTALL_DIR )
# creates an info file that contains general information and settings about the build
# this can be usefull to later find out how and whith what settigns a package was build
# the file is called <PACKAGE_NAME>BuildInfo[BuildType].txt and
# is created in TARGET_DIR and installed to INSTALL_DIR
macro( vista_create_info_file _PACKAGE_NAME _TARGET_DIR _INSTALL_DIR )
	vista_find_package( SVN QUIET )
	string( TOUPPER ${_PACKAGE_NAME} _PACKAGE_NAME_UPPER )
	set( INFO_STRING "This file is auto-generated by the VistaCMakeCommon\n"
						"It contains build and configuration info for the project\n" )

	if( MSVC )
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo.txt" )
		set( _CONFIGS ${CMAKE_CONFIGURATION_TYPES} )
	else()
		set( INFO_FILENAME "${_TARGET_DIR}/${${_PACKAGE_NAME_UPPER}_OUTPUT_NAME}BuildInfo${CMAKE_BUILD_TYPE}.txt" )
		set( _CONFIGS ${CMAKE_BUILD_TYPE} )
	endif()

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
	endif()
	vista_get_svn_info( _SVN_REV _SVN_REPOS _SVN_DATE )
	if( _SVN_REV )
		set( INFO_STRING "${INFO_STRING}\nSVN revision:            ${_SVN_REV}" )
		set( INFO_STRING "${INFO_STRING}\nSVN repositiory:         ${_SVN_REPOS}" )
		set( INFO_STRING "${INFO_STRING}\nSVN last commit:         ${_SVN_DATE}" )
	endif()
	if( UNIX )
		if( VISTA_USE_RPATH )
			set( INFO_STRING "${INFO_STRING}\nUsing RPath:             ON" )
		else()
			set( INFO_STRING "${INFO_STRING}\nUsing RPath:             OFF" )
		endif()
	endif()

	set( INFO_STRING "${INFO_STRING}\n\nDEPENDENCIES" )
	set( INFO_STRING "${INFO_STRING}\nvista_use_package calls:" )
	foreach( _ARG ${${_PACKAGE_NAME_UPPER}_DEPENDENCIES} )
		if( _ARG STREQUAL "package" )
			set( INFO_STRING "${INFO_STRING}\n\t" )
		else()
			set( INFO_STRING "${INFO_STRING}${_ARG} " )
		endif()
	endforeach()
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
		endif()
		set( INFO_STRING "${INFO_STRING}\n    Root Dir             ${${_DEP_UPPER}_ROOT_DIR}" )
		set( INFO_STRING "${INFO_STRING}\n    Lib dirs:            ${${_DEP_UPPER}_INCLUDE_DIRS}" )
		set( INFO_STRING "${INFO_STRING}\n    Library dirs:        ${${_DEP_UPPER}_LIBRARY_DIRS}" )
		set( INFO_STRING "${INFO_STRING}\n    Definitions:         ${${_DEP_UPPER}_DEFINITIONS}" )
		set( INFO_STRING "${INFO_STRING}\n    Libraries:           ${${_DEP_UPPER}_LIBRARIES}" )
		if( DEFINED ${_DEP_UPPER}_USE_FILE )
			set( INFO_STRING "${INFO_STRING}\n    Use File:            ${${_DEP_UPPER}_USE_FILE}" )
		endif()
		if( DEFINED ${_DEP_UPPER}_HWARCH )
			set( INFO_STRING "${INFO_STRING}\n    Use File:            ${${_DEP_UPPER}_HWARCH}" )
		endif()
	endforeach()

	set( INFO_STRING "${INFO_STRING}\n\nConfigured with VistaCMakeCommon" )
	if( NOT VISTACOMMON_FILE_LOCATION )
		set( INFO_STRING "${INFO_STRING}\n\t<unknown VistaCMakeCommon location/version>" )
	else()
		set( INFO_STRING "${INFO_STRING}\n\tLocation:             ${VISTACOMMON_FILE_LOCATION}" )
		get_filename_component( _CMAKECOMMON_DIR "${VISTACOMMON_FILE_LOCATION}" PATH )
		vista_get_svn_info( _SVN_REV _SVN_REPOS _SVN_DATE "${_CMAKECOMMON_DIR}" )
		if( _SVN_REV )
			set( INFO_STRING "${INFO_STRING}\n\tSVN revision:            ${_SVN_REV}" )
			set( INFO_STRING "${INFO_STRING}\n\tSVN repositiory:         ${_SVN_REPOS}" )
			set( INFO_STRING "${INFO_STRING}\n\tSVN last commit:         ${_SVN_DATE}" )
		endif()
	endif()

	
	
	set( INFO_STRING "${INFO_STRING}\n\nCMAKE GLOBAL PROPERTIES" )
	foreach( _PROP ${VISTA_BUILDINFO_GLOBAL_PROPERTIES} )
		vista_internal_write_prop( ${_PROP} GLOBAL )
	endforeach()
	
	set( INFO_STRING "${INFO_STRING}\n\nCMAKE DIRECTORY PROPERTIES" )
	set( INFO_STRING "${INFO_STRING}\n\tGeneral" )
	foreach( _PROP ${VISTA_BUILDINFO_FOLDER_PROPERTIES} )
		vista_internal_write_prop( ${_PROP} DIRECTORY )
	endforeach()
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n\tConfiguration : ${_CONFIG}" )
		foreach( _PROP ${VISTA_BUILDINFO_TARGET_PROPERTIES_CONFIG} )
			vista_internal_write_prop( ${_PROP}_${_CONFIG} DIRECTORY )
		endforeach()
	endforeach()
	
	set( INFO_STRING "${INFO_STRING}\n\nCMAKE TARGET PROPERTIES" )
	set( INFO_STRING "${INFO_STRING}\n\tGeneral" )
	foreach( _PROP ${VISTA_BUILDINFO_TARGET_PROPERTIES} )
		vista_internal_write_prop( ${_PROP} TARGET ${_PACKAGE_NAME} )
	endforeach()
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n\tConfiguration : ${_CONFIG}" )
		foreach( _PROP ${VISTA_BUILDINFO_TARGET_PROPERTIES_CONFIG} )
			vista_internal_write_prop( ${_PROP}_${_CONFIG} TARGET ${_PACKAGE_NAME} )
		endforeach()
		vista_internal_write_prop( ${_CONFIG}_OUTPUT_NAME TARGET ${_PACKAGE_NAME} )
		vista_internal_write_prop( ${_CONFIG}_POSTFIX TARGET ${_PACKAGE_NAME} )
	endforeach()	
	
	set( INFO_STRING "${INFO_STRING}\n\nCMAKE GLOBAL VARIABLES" )
	
	# write geneneral variables
	set( INFO_STRING "${INFO_STRING}\n\tGeneral" )
	foreach( _VAR ${VISTA_BUILDINFO_VARIABLES_GENERAL} )
		if( DEFINED ${_VAR} )
				vista_internal_write_variable( ${_VAR} )
		endif()
	endforeach()

	#write config-specific variables
	foreach( _CONFIG ${_CONFIGS} )
		set( INFO_STRING "${INFO_STRING}\n\tConfiguration : ${_CONFIG}" )
		string( TOUPPER ${_CONFIG} _CONFIG_UPPER )
		foreach( _VAR ${VISTA_BUILDINFO_VARIABLES_PER_TARGET} )
			if( DEFINED ${_VAR}_${_CONFIG_UPPER} )
				vista_internal_write_variable( CMAKE_${_LANGUAGE}${_VAR} )
			endif()
		endforeach()
		vista_internal_write_variable( CMAKE_${_CONFIG_UPPER}_POSTFIX )
	endforeach()		

	# write language-specific variables
	get_property( _LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES )
	foreach( _LANGUAGE ${_LANGUAGES} )
		set( INFO_STRING "${INFO_STRING}\n\tLanguage : ${_LANGUAGE}" )		
		foreach( _VAR ${VISTA_BUILDINFO_VARIABLES_LANGUAGE} )
			vista_internal_write_variable( CMAKE_${_LANGUAGE}${_VAR} )
		endforeach()
	endforeach()
		
		
	file( WRITE "${INFO_FILENAME}" "${INFO_STRING}" )
	if( NOT "${_INSTALL_DIR}" STREQUAL "" )
		install( FILES "${INFO_FILENAME}" DESTINATION "${_INSTALL_DIR}"
					PERMISSIONS ${VISTA_INSTALL_PERMISSIONS_NONEXEC} )
	endif( NOT "${_INSTALL_DIR}" STREQUAL "" )
	
	if( ${_PACKAGE_NAME_UPPER}_COPY_EXEC_DIR )
		add_custom_command( TARGET ${_PACKAGE_NAME}
                    POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${INFO_FILENAME}" "${${_PACKAGE_NAME_UPPER}_COPY_EXEC_DIR}"
					COMMENT "Copying info file"
		)
	endif()
endmacro()

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