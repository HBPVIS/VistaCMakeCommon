# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VAXIS2_FOUND )

	vista_find_package_root( AXIS2 include/axis2_addr.h ) # Arbitrary header chosen

	if( AXIS2_ROOT_DIR )
		set( AXIS2_LIBRARIES 
			optimized axiom
			optimized axis2_engine
			optimized axis2_http_receiver
			optimized axis2_http_sender
			optimized axis2_parser
			optimized axis2_tcp_receiver
			optimized axis2_tcp_sender
			optimized axis2_xpath
			optimized axutil
			optimized guththila
			optimized neethi
			debug axiomD
			debug axis2_engineD
			debug axis2_http_receiverD
			debug axis2_http_senderD
			debug axis2_parserD
			debug axis2_tcp_receiverD
			debug axis2_tcp_senderD
			debug axis2_xpathD
			debug axutilD
			debug guththilaD
			debug neethiD
		)
		mark_as_advanced( AXIS2_LIBRARIES )

		set( AXIS2_INCLUDE_DIRS ${AXIS2_ROOT_DIR}/include )
		set( AXIS2_LIBRARY_DIRS ${AXIS2_ROOT_DIR}/lib )
	endif( AXIS2_ROOT_DIR )

endif( NOT VAXIS2_FOUND )

find_package_handle_standard_args( VAXIS2 "AXIS2 could not be found" AXIS2_ROOT_DIR )

