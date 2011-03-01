include( VistaCommon )

#since CMAKE_DEBUG_POSTFIX doesnt work on executables, we have to trick
if( ${CMAKE_BUILD_TYPE} STREQUAL "Debug" )
	set( EXEC_NAME "${PROJECT_NAME}D" )
else( ${CMAKE_BUILD_TYPE} STREQUAL "Debug" )
	set( EXEC_NAME ${PROJECT_NAME} )
endif( ${CMAKE_BUILD_TYPE} STREQUAL "Debug" )

set( CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG" )

changevardefault( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}" CACHE STRING "install directory" FORCE )

# Should we use rpath?
# This enables us to use OpenSG etc. within the Vista* libraries without having
# to set a LIBRARY_PATH while linking against these libraries
set( VISTA_USE_RPATH ON CACHE BOOL "Use rpath" )
mark_as_advanced( VISTA_USE_RPATH )
