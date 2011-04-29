include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VLUA_FOUND )
	vista_find_package_root( lua include/lua.h )

	if( LUA_ROOT_DIR )		
		set( LUA_INCLUDE_DIRS ${LUA_ROOT_DIR}/include )
		set( LUA_LIBRARY_DIRS ${LUA_ROOT_DIR}/lib )
		if( WIN32 )
			set( LUA_LIBRARIES
				optimized lua
				debug luaD
			)
		else()
			set( LUA_LIBRARIES lua )
		endif( WIN32 )
		
	endif( LUA_ROOT_DIR )

endif( NOT VLUA_FOUND )

find_package_handle_standard_args( Vlua "lua could not be found" LUA_ROOT_DIR LUA_LIBRARIES ) 

