# $Id: FindZMQ.cmake 21620 2011-05-30 10:28:48Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VZMQ_FOUND )

	vista_find_package_root( ZMQ include/zmq.h NAMES ZMQ zeromq ZeroMQ Zeromq DEBUG_OUTPUT)

	if( ZMQ_ROOT_DIR )
		
		vista_find_library_uncached( NAMES zmq ZMQ libzmq
									PATHS "${ZMQ_ROOT_DIR}/lib"
									CACHE "ZMQ library" )

		set( ZMQ_INCLUDE_DIRS ${ZMQ_ROOT_DIR}/include )
		
		if( ${ZMQ_VERSION_STRING} VERSION_GREATER 3.0)
			if( UNIX )
				#UNIX is easy, as usual
				set( ZMQ_LIBRARY_DIRS ${ZMQ_ROOT_DIR}/lib )
			elseif(WIN32)
				#zmq 3.x puts the dlls in a separate bin directory AND differentiates 
				#between win32 and x86_64 builds
				if(VISTA_64BIT) 
					set( ZMQ_LIBRARY_DIRS 
						 ${ZMQ_ROOT_DIR}/lib/x64
						 ${ZMQ_ROOT_DIR}/bin/x64 )
				elseif(VISTA_32BIT)
					set( ZMQ_LIBRARY_DIRS 
						 ${ZMQ_ROOT_DIR}/lib/Win32
						 ${ZMQ_ROOT_DIR}/bin/Win32 )
				endif(VISTA_64BIT)
				#zmq insists on libraries being named libzmq.lib and libzmq.dll
				set(ZMQ_LIBRARIES libzmq)
			endif(UNIX)
		else( )
			#for older versions ==> just use the standard lib path
			set( ZMQ_LIBRARY_DIRS ${ZMQ_ROOT_DIR}/lib)
		endif( )
		
		#get_filename_component( ZMQ_LIBRARY_DIRS "${VISTA_UNCACHED_LIBRARY}" PATH )
		#get_filename_component( ZMQ_LIBRARIES "${VISTA_UNCACHED_LIBRARY}" NAME )
	endif( ZMQ_ROOT_DIR )

endif( NOT VZMQ_FOUND )

find_package_handle_standard_args( VZMQ "ZMQ could not be found" ZMQ_ROOT_DIR ZMQ_LIBRARIES)

