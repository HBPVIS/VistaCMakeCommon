# $Id: FindVGLEW.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VTETGEN_FOUND )

	vista_find_package_root( TETGEN include/tetgen.h )

	if( TETGEN_ROOT_DIR )
		set( TETGEN_LIBRARIES optimized tetgen debug tetgenD )
		set( TETGEN_INCLUDE_DIRS "${TETGEN_ROOT_DIR}/include" )
		set( TETGEN_LIBRARY_DIRS "${TETGEN_ROOT_DIR}/lib" )

	endif( TETGEN_ROOT_DIR )

endif( NOT VTETGEN_FOUND )

find_package_handle_standard_args( Vtetgen "tetgen could not be found" TETGEN_ROOT_DIR )

