include( VistaCommon )

# Use a postfix for debug libraries
set( CMAKE_DEBUG_POSTFIX "D" )

changevardefault( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE STRING "distribution directory" FORCE )

changevardefault( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries if ON, static libraries if OFF" )

