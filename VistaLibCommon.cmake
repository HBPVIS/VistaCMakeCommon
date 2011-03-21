include( VistaCommon )

if( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )
	vista_set_defaultvalue( CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/dist/${VISTA_HWARCH}" CACHE PATH "distribution directory" FORCE )
endif( CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT )

vista_set_defaultvalue( BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries if ON, static libraries if OFF" FORCE )
