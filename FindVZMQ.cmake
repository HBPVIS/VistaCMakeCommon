# $Id: FindZMQ.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VZMQ_FOUND )

	vista_find_package_root( ZMQ include/zmq.h NAMES ZeroMQ zeromq Zeromq)

	if( ZMQ_ROOT_DIR )
		vista_find_library_uncached( NAMES zmq ZMQ libzmq
									PATHS "${ZMQ_ROOT_DIR}/lib"
									CACHE "ZMQ library" )

		set( ZMQ_INCLUDE_DIRS ${ZMQ_ROOT_DIR}/include )
		set( ZMQ_LIBRARY_DIRS ${ZMQ_ROOT_DIR}/lib )
		get_filename_component( ZMQ_LIBRARY_DIRS "${VISTA_UNCACHED_LIBRARY}" PATH )
		get_filename_component( ZMQ_LIBRARIES "${VISTA_UNCACHED_LIBRARY}" NAME )
	endif( ZMQ_ROOT_DIR )

endif( NOT VZMQ_FOUND )

find_package_handle_standard_args( VZMQ "ZMQ could not be found" ZMQ_ROOT_DIR ZMQ_LIBRARIES)

