include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VFFTW_FOUND )
    vista_find_package_root( fftw include/fftw3.h ) # find dir containing 'fftw3.h'
    if( FFTW_ROOT_DIR )
        set( FFTW_INCLUDE_DIRS ${FFTW_ROOT_DIR})
        set( FFTW_LIBRARY_DIRS ${FFTW_ROOT_DIR})
    endif( FFTW_ROOT_DIR )
endif( NOT VFFTW_FOUND )

find_package_handle_standard_args( Vfftw "FFTW could not be found" FFTW_ROOT_DIR )