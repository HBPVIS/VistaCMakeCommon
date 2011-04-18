include( FindPackageHandleStandardArgs )

#if( NOT DEFINED VISTACORELIBS_EXISTING_DIRS )
	set( VISTACORELIBS_EXISTING_DIRS "" CACHE INTERNAL "internal cache of CoreLibs directories" )
	
	# we also search for CoreLibs directories manually	
	set( _SEARCH_PREFIXES
		"$ENV{VISTA_ROOT}/${VISTA_HWARCH}"
		"$ENV{VISTA_ROOT}"
		"$ENV{DEVELOP}/VistaCoreLibs*/${VISTA_HWARCH}"
		"$ENV{DEVELOP}/VistaCoreLibs*"
		"$ENV{DEVELOP}/VistaCoreLibs*/dist/${VISTA_HWARCH}"
		"$ENV{DEVELOP}/VistaCoreLibs*/dist"
	)
	foreach( _PATH ${_SEARCH_PREFIXES} )
		file( GLOB _TMP_FILES "${_PATH}/include/VistaBase/VistaBaseTypes.h" )
		foreach( _FILE ${_TMP_FILES} )
			string( REPLACE "/include/VistaBase/VistaBaseTypes.h" "" _PATH ${_FILE} )
			file( TO_CMAKE_PATH ${_PATH} _PATH2 )
			list( APPEND VISTACORELIBS_EXISTING_DIRS ${_PATH2} )
		endforeach( _FILE ${_TMP_FILES} )		
	endforeach( _PATH ${_PREFIX_PATHES} )
	list( REMOVE_DUPLICATES VISTACORELIBS_EXISTING_DIRS )
#endif( NOT DEFINED VISTACORELIBS_EXISTING_DIRS )


#if( NOT DEFINED VISTACORELIBS_EXISTING_CONFIG_FILES )
	set( VISTACORELIBS_EXISTING_CONFIG_FILES "" CACHE INTERNAL "internal cache of CoreLibs config files" )
	set( VISTACORELIBS_EXISTING_VERSION_FILES "" CACHE INTERNAL "internal cache of CoreLibs version files" )

	#message( "searching for files" )	
	
	set( _SEARCH_PREFIXES 
		"$ENV{VISTA_CMAKE_COMMON}/configs"
		"${CMAKE_MODULE_PATH}"
		"${CMAKE_PREFIX_PATH}"
		"${CMAKE_FRAMEWORK_PATH}"
		"${CMAKE_APPBUNDLE_PATH}"
		"$ENV{CMAKE_MODULE_PATH}"
		"$ENV{CMAKE_PREFIX_PATH}"
		"$ENV{CMAKE_FRAMEWORK_PATH}"
		"$ENV{CMAKE_APPBUNDLE_PATH}"
		"${VISTA_ROOT}/${VISTA_HWARCH}"
		"${VISTA_ROOT}"
		${VISTACORELIBS_EXISTING_DIRS}
	)
	
	if( WIN32 )
		foreach( _I RANGE 0 9 )
			get_filename_component( _CMAKE_REG_ENTRY_${_I} 
					"[HKEY_CURRENT_USER\\Software\\Kitware\\CMakeSetup\\Settings\\StartPath;WhereBuild${_I}]"
					ABSOLUTE CACHE INTERNAL )
			list( APPEND _SEARCH_PREFIXES ${_CMAKE_REG_ENTRY_${_I}} )
		endforeach( _I RANGE 0 9 )
	endif( WIN32 )

	#we first search for installed Config.cmake files for the VstaBase (which has to be there always)
	foreach( _PATH ${_SEARCH_PREFIXES} )
		if( WIN32 )					
			file( GLOB _TMP_FILES 
				"${_PATH}/VistaCoreLibsConfig.cmake"
				"${_PATH}/VistaBase/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/VistaCoreLibs*/VistaCoreLibsConfig.cmake"
				"${_PATH}/VistaCoreLibs*/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/VistaCoreLibs*/CMake/VistaCoreLibsConfig.cmake"
			)
		elseif( UNIX )
			file( GLOB _TMP_FILES 
				"${_PATH}/VistaCoreLibsConfig.cmake"
				"${_PATH}/share/VistaCoreLibsConfig.cmake"
				"${_PATH}/share/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/share/VistaCoreLibs*/VistaCoreLibsConfig.cmake"
				"${_PATH}/share/VistaCoreLibs*/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/share/cmake/VistaCoreLibs*/VistaCoreLibsConfig.cmake"
				"${_PATH}/lib/VistaCoreLibsConfig.cmake"
				"${_PATH}/lib/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/lib/VistaCoreLibs*/VistaCoreLibsConfig.cmake"
				"${_PATH}/lib/VistaCoreLibs*/cmake/VistaCoreLibsConfig.cmake"
				"${_PATH}/lib/cmake/VistaCoreLibs*/VistaCoreLibsConfig.cmake"						
			)
		endif( WIN32 )
		list( APPEND VISTACORELIBS_EXISTING_CONFIG_FILES ${_TMP_FILES} )
	endforeach( _PATH ${_PREFIX_PATHES} )
	
	if( VISTACORELIBS_EXISTING_CONFIG_FILES )		
		list( REMOVE_DUPLICATES VISTACORELIBS_EXISTING_CONFIG_FILES )
		set( VISTACORELIBS_EXISTING_VERSION_FILES )
		foreach( _CONFIG ${VISTACORELIBS_EXISTING_CONFIG_FILES} )
			#message( "_CONFIG = ${_CONFIG}" )
			string( REPLACE "Config.cmake" "ConfigVersion.cmake" _VERSION ${_CONFIG} )
			list( APPEND VISTACORELIBS_EXISTING_VERSION_FILES ${_VERSION} )
		endforeach( _CONFIG VISTACORELIBS_EXISTING_CONFIG_FILES )
	endif( VISTACORELIBS_EXISTING_CONFIG_FILES )

#endif( NOT DEFINED VISTACORELIBS_EXISTING_CONFIG_FILES )

#message( "Configs: ${VISTACORELIBS_EXISTING_CONFIG_FILES}" )
#message( "Versions: ${VISTACORELIBS_EXISTING_VERSION_FILES}" )
#message( "Dirs: ${VISTACORELIBS_EXISTING_DIRS}" )

set( _CONSIDERED_VERSIONS )


if( VVistaCoreLibs_FIND_VERSION OR VVistaCoreLibs_FIND_VERSION_EXT )
	set( _FOUND_CONFIG "CONFIG-NOTFOUND" )
	set( PACKAGE_FIND_VERSION ${VVistaCoreLibs_FIND_VERSION} )
	set( PACKAGE_FIND_VERSION_MAJOR ${VVistaCoreLibs_FIND_VERSION_MAJOR} )
	set( PACKAGE_FIND_VERSION_MINOR ${VVistaCoreLibs_FIND_VERSION_MINOR} )
	set( PACKAGE_FIND_VERSION_PATCH ${VVistaCoreLibs_FIND_VERSION_PATCH} )
	set( PACKAGE_FIND_VERSION_TWEAK ${VVistaCoreLibs_FIND_VERSION_TWEAK} )
	set( PACKAGE_FIND_VERSION_COUNT ${VVistaCoreLibs_FIND_VERSION_COUNT} )
	set( PACKAGE_FIND_VERSION_EXT ${VVistaCoreLibs_FIND_VERSION_EXT} )
	foreach( _VERSION_FILE ${VISTACORELIBS_EXISTING_VERSION_FILES} )
		string( REPLACE "ConfigVersion.cmake" "Config.cmake" _CONFIG_FILE ${_VERSION_FILE} )
		if( NOT _FOUND_CONFIG )
			if( EXISTS ${_VERSION_FILE} )
				include( ${_VERSION_FILE} )
				if( PACKAGE_VERSION_EXACT OR ( PACKAGE_VERSION_COMPATIBLE AND NOT VistaCoreLibs_FIND_VERSION_EXACT ) )
					set( _FOUND_CONFIG ${_CONFIG_FILE} )
				else( PACKAGE_VERSION_EXACT OR ( PACKAGE_VERSION_COMPATIBLE AND NOT VistaCoreLibs_FIND_VERSION_EXACT ) )					
					list( APPEND _CONSIDERED_VERSIONS "${_CONFIG_FILE} - Version: ${PACKAGE_VERSION}" )
				endif( PACKAGE_VERSION_EXACT OR ( PACKAGE_VERSION_COMPATIBLE AND NOT VistaCoreLibs_FIND_VERSION_EXACT ) )
			else( EXISTS ${_VERSION_FILE} )
				list( APPEND _CONSIDERED_VERSIONS "${_CONFIG_FILE} - <unversioned>" )
			endif( EXISTS ${_VERSION_FILE} )
		endif( NOT _FOUND_CONFIG )
	endforeach( _VERSION_FILE ${VISTACORELIBS_EXISTING_VERSION_FILES} )
	set( PACKAGE_FIND_VERSION )
	set( PACKAGE_FIND_VERSION_EXT )
	
	if( NOT _FOUND_CONFIG )
		message( "FindVistaCoreLibs - no config with requested version \"${PACKAGE_FIND_VERSION}${PACKAGE_FIND_VERSION_EXT}\" has been found. Considered versions:" )
		foreach( _SUB ${_CONSIDERED_VERSIONS} )
			message( "\t${_SUB}" )
		endforeach( _SUB ${_CONSIDERED_VERSIONS} )
	endif( NOT _FOUND_CONFIG )
else( VVistaCoreLibs_FIND_VERSION OR VVistaCoreLibs_FIND_VERSION_EXT )
	# just take the first one
	list( GET VISTACORELIBS_EXISTING_CONFIG_FILES 0 _FOUND_CONFIG )
endif( VVistaCoreLibs_FIND_VERSION OR VVistaCoreLibs_FIND_VERSION_EXT )

if( _FOUND_CONFIG )
	set( VistaCoreLibs_FIND_COMPONENTS ${VVistaCoreLibs_FIND_COMPONENTS} )
	include( ${_FOUND_CONFIG} )
else( _FOUND_CONFIG )
	#todo - find manually
endif( _FOUND_CONFIG )

find_package_handle_standard_args( VVistaCoreLibs "VistaCoreLibs could not be found" VISTACORELIBS_ROOT_DIR )


