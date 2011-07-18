# $Id: $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSQLITE_FOUND )
	vista_find_package_root( SQLITE include/SQLite/sqlite3.h )

	if( SQLITE_ROOT_DIR )
		set( SQLITE_LIBRARIES
				optimized SQLite
				debug SQLiteD
		)
		mark_as_advanced( SQLITE_LIBRARIES )

		set( SQLITE_INCLUDE_DIRS ${SQLITE_ROOT_DIR}/include )
		set( SQLITE_LIBRARY_DIRS ${SQLITE_ROOT_DIR}/lib )
	endif( SQLITE_ROOT_DIR )
endif( NOT VSQLITE_FOUND )

find_package_handle_standard_args( VSQLITE "SQLITE could not be found" SQLITE_ROOT_DIR )

