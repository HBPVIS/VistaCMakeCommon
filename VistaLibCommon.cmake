include( VistaCommon )

if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	changevardefault( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE STRING "distribution directory" FORCE )
endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )

changevardefault( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries if ON, static libraries if OFF" FORCE )

macro( vista_install )
	if( ${ARGC} EQUAL 0 OR ${ARGC} GREATER 3 )
		message( SEND_ERROR "Invalid number of arguments for vista_install! usage: vista_install( TargetName [ IncludeSubDirectory ] [ LibrarySubDirectory ] ) - with optional subdirectories appended to the include / lib subdirs" )
	endif( ${ARGC} EQUAL 0 OR ${ARGC} GREATER 3 )
	
	if( ${ARGC} GREATER 1 )
		set( _VISTA_INCLUDE_SUBDIR "include/${ARGV1}" )
	else( ${ARGC} GREATER 1 )
		set( _VISTA_INCLUDE_SUBDIR "include" )
	endif( ${ARGC} GREATER 1 )
	
	if( ${ARGC} GREATER 2 )
		set( _VISTA_LIB_SUBDIR "lib/${ARGV2}" )
	else( ${ARGC} GREATER 2 )
		set( _VISTA_LIB_SUBDIR "lib" )
	endif( ${ARGC} GREATER 2 )
	
	
	install( TARGETS ${ARGV0}
		LIBRARY DESTINATION ${_VISTA_LIB_SUBDIR}
		ARCHIVE DESTINATION ${_VISTA_LIB_SUBDIR}
		RUNTIME DESTINATION ${_VISTA_LIB_SUBDIR}
	)
	install( DIRECTORY	.
		DESTINATION ${_VISTA_INCLUDE_SUBDIR}
		FILES_MATCHING PATTERN "*.h"
		PATTERN "build" EXCLUDE
		PATTERN ".svn" EXCLUDE
		PATTERN "CMakeFiles" EXCLUDE
	)
	install( FILES ${CMAKE_CURRENT_BINARY_DIR}/Debug/${ARGV0}D.pdb
		DESTINATION ${_VISTA_LIB_SUBDIR}
		CONFIGURATIONS Debug
	)
	install( FILES ${CMAKE_CURRENT_BINARY_DIR}/RelWithDebugInfo/${ARGV0}.pdb
		DESTINATION ${_VISTA_LIB_SUBDIR}
		CONFIGURATIONS RelWithDebugInfo
	)
endmacro()
