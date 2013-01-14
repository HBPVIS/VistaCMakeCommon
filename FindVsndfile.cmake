# $Id: FindVSNDFILE.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSNDFILE_FOUND )
	vista_find_package_root( sndfile include/sndfile.h DEBUG_OUTPUT NAMES libsndfile sndfile )	

	if( SNDFILE_ROOT_DIR )
		set( SNDFILE_INCLUDE_DIRS "${SNDFILE_ROOT_DIR}/include" )		
		set( SNDFILE_LIBRARY_DIRS "${SNDFILE_ROOT_DIR}/lib" "${SNDFILE_ROOT_DIR}/bin" )		
		set( SNDFILE_LIBRARIES "libsndfile-1" )		
	endif( SNDFILE_ROOT_DIR )
endif( NOT VSNDFILE_FOUND )

find_package_handle_standard_args( VSNDFILE "sndfile could not be found" SNDFILE_ROOT_DIR )

