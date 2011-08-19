# $Id: FindZMQ.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VZMQ_FOUND )

	vista_find_package_root( ZMQ include/zmq.h )

	if( ZMQ_ROOT_DIR )
		find_library( ZMQ_LIBRARIES NAMES libzmq ZMQ
					PATHS ${ZMQ_ROOT_DIR}/lib
					CACHE "ZMQ library" )
		mark_as_advanced( ZMQ_LIBRARIES )

		set( ZMQ_INCLUDE_DIRS ${ZMQ_ROOT_DIR}/include )
		set( ZMQ_LIBRARY_DIRS ${ZMQ_ROOT_DIR}/lib )
		get_filename_component( ZMQ_LIBRARY_DIRS ${ZMQ_LIBRARIES} PATH )

	endif( ZMQ_ROOT_DIR )

endif( NOT VZMQ_FOUND )

find_package_handle_standard_args( VZMQ "ZMQ could not be found" ZMQ_ROOT_DIR )

