include( VistaCommon )

#since CMAKE_DEBUG_POSTFIX doesnt work on executables, we have to trick

changevardefault( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}" CACHE PATH "install directory" FORCE )

macro( vista_set_app_outdir APP_NAME TARGET_DIR )
	set_target_properties( ${APP_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_DEBUG			${TARGET_DIR} )
	set_target_properties( ${APP_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELEASE			${TARGET_DIR} )
	set_target_properties( ${APP_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO	${TARGET_DIR} )
	set_target_properties( ${APP_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL 		${TARGET_DIR} )
endmacro( vista_set_app_outdir TARGET_DIR )

macro( vista_configure_app APP_NAME )
	set_target_properties( ${APP_NAME} PROPERTIES OUTPUT_NAME_DEBUG				"${APP_NAME}D" )
	set_target_properties( ${APP_NAME} PROPERTIES OUTPUT_NAME_RELEASE			"${APP_NAME}" )
	set_target_properties( ${APP_NAME} PROPERTIES OUTPUT_NAME_MINSIZEREL 		"${APP_NAME}" )
	set_target_properties( ${APP_NAME} PROPERTIES OUTPUT_NAME_RELWITHDEBINFO	"${APP_NAME}" )

	if( MSVC AND NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.vcproj.user )
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
		
		set( _WORK_DIR ${CMAKE_CURRENT_SOURCE_DIR} )

		find_file( _VCPROJUSER_PROTO_FILE "VisualStudio.vcproj.user_proto" )
	
		if( _VCPROJUSER_PROTO_FILE )
			configure_file(
				${_VCPROJUSER_PROTO_FILE}
				${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.vcproj.user
				@ONLY
			)
		else( _VCPROJUSER_PROTO_FILE )
			message( "Warning: could not find file VisualStudio.vcproj.user_proto" )
		endif( _VCPROJUSER_PROTO_FILE )
	endif( MSVC AND NOT EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.vcproj.user )
endmacro( vista_configure_app APP_NAME )