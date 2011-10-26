# $Id: FindVOPENCV.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VOPENCV_FOUND )

	# search config file
	vista_find_package_root( OpenCV OpenCVConfig.cmake NAMES OpenCV ADVANCED )
	if( NOT OPENCV_ROOT_DIR )
		vista_find_package_root( OpenCV share/OpenCV/OpenCVConfig.cmake ADVANCED )
	endif()

	set( OPENCV_FOUND )
	find_package( OpenCV QUIET PATHS ${OPENCV_ROOT_DIR} NO_DEFAULT_PATH )
	# an OpenCVConfig.cmake has been found and loaded
	if( OPENCV_FOUND )
		set( OPENCV_LIBRARIES "${OpenCV_LIBS}" )
		set( OPENCV_LIBRARY_DIRS "${OpenCV_LIB_DIR}" "${OpenCV_DIR}/bin"  )
		set( OPENCV_INCLUDE_DIRS "${OpenCV_INCLUDE_DIRS}" )
		set( OPENCV_VERSION "${OpenCV_VERSION}" )
	endif()
	
endif( NOT VOPENCV_FOUND )

find_package_handle_standard_args( VOpenCV "OpenCV could not be found" OPENCV_LIBRARIES )

