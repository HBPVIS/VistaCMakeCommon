# $Id: FindVGLEW.cmake 21620 2011-05-30 10:28:48Z dr165799 $

if( NOT VOPENMP_FOUND )
	message( FATAL_ERROR "OpenMPUseFile included although OpenMP was not found" )
elseif( NOT OPENMPUSEFILE_CALLED )
	set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS}" )
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${OpenMP_CXX_FLAGS}" )
    set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${OpenMP_EXE_LINKER_FLAGS}" )
	
	set( OPENMPUSEFILE_CALLED 1 )
endif()


