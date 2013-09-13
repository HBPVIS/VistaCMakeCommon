# $Id: FindVMKL.cmake 31553 2012-08-13 13:21:14Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )
include( VistaCommon )

if( NOT VMKL_FOUND )
	vista_find_package_root( MKL include/mkl.h PATHS "C:/Program Files (x86)/Intel/Composer XE 2013/mkl/" "$ENV{MKLROOT}" )
	
	if( MKL_ROOT_DIR )
		if( WIN32 )
			include_directories( "${MKL_ROOT_DIR}/include" )
			if( VISTA_64BIT )
				link_directories( "${MKL_ROOT_DIR}/lib/intel64" )
				vista_add_pathscript_dynamic_lib_path( "${MKL_ROOT_DIR}/../redist/intel64/mkl" )
				list( APPEND MKL_LIBRARIES mkl_core mkl_lapack95_lp64 mkl_rt )
			else()
				link_directories( "${MKL_ROOT_DIR}/lib/ia32" )
				vista_add_pathscript_dynamic_lib_path( "${MKL_ROOT_DIR}/../redist/ia32/mkl" )
				list( APPEND MKL_LIBRARIES mkl_core mkl_lapack95 mkl_rt )
			endif()
		else()
			include_directories( "${MKL_ROOT_DIR}/include" )
			if( VISTA_64BIT )
				link_directories( "${MKL_ROOT_DIR}/lib/intel64" )
				vista_add_pathscript_dynamic_lib_path( "${MKL_ROOT_DIR}/lib/intel64" )
				list( APPEND MKL_LIBRARIES mkl_core mkl_intel_lp64 mkl_intel_thread iomp5 )
			else()
				link_directories( "${MKL_ROOT_DIR}/lib/ia32" )
				vista_add_pathscript_dynamic_lib_path( "${MKL_ROOT_DIR}/lib/ia32" )
				list( APPEND MKL_LIBRARIES mkl_core mkl_lapack95 mkl_rt iomp5 )
			endif()
		endif()
	endif()	

endif( NOT VMKL_FOUND )

find_package_handle_standard_args( VMKL "MKL could not be found" MKL_ROOT_DIR MKL_LIBRARIES )

