include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VHDF5_FOUND )
	vista_find_package_root( VHDF5 include/hdf5.h NAMES hdf5 HDF5 )

	if( HDF5_ROOT_DIR )
		set( HDF5_INCLUDE_DIRS ${HDF5_ROOT_DIR}/include/ )
		set( HDF5_LIBRARY_DIRS ${HDF5_ROOT_DIR}/lib )
		set( HDF5_LIBRARIES hdf5 )
	endif( HDF5_ROOT_DIR )

endif( NOT VHDF5_FOUND )

find_package_handle_standard_args( VHDF5 "hdf5 could not be found" VHDF5_ROOT_DIR )
