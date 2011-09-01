# $Id: FindVChai3D.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VCHAI3D_FOUND )
	vista_find_package_root( Chai3D src/chai3d.h )	

	if( CHAI3D_ROOT_DIR )
		set( CHAI3D_INCLUDE_DIRS ${CHAI3D_ROOT_DIR}/src ${CHAI3D_ROOT_DIR}/external/OpenGL/msvc)
		# Set platform specific CHAI3D path here
		if( UNIX )
			#UNIX is easy, as usual
			set( CHAI3D_LIBRARY_DIRS ${CHAI3D_ROOT_DIR}/bin ${CHAI3D_ROOT_DIR}/lib/lin-x86_64  )
			message( WARNING "FindPackageCHAI3D - UNIX/Linux configuration is untested" )
			if( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
			    set( CHAI3D_DEFINITIONS -D_LINUX )
			endif( ${CMAKE_SYSTEM_NAME} MATCHES "Linux" )
		
		set( CHAI3D_LIBRARIES
			optimized chai3d
			debug chai3d-dbg
		)
			
			
		elseif(WIN32)
			#For WIN32, CHAI3D contains specific libraries for different compilers
			if( MSVC )
				if( MSVC80 )
					set( CHAI3D_LIBRARY_DIRS ${CHAI3D_ROOT_DIR}/bin ${CHAI3D_ROOT_DIR}/lib/msvc8 ${CHAI3D_ROOT_DIR}/external/OpenGL/msvc)		
				elseif( MSVC90 )
					set( CHAI3D_LIBRARY_DIRS ${CHAI3D_ROOT_DIR}/bin ${CHAI3D_ROOT_DIR}/lib/msvc9 ${CHAI3D_ROOT_DIR}/external/OpenGL/msvc)					
				else( MSVC80 )
					message( WARNING "FindPackageCHAI3D - Unknown MSVC version" )
				endif( MSVC80 )
				set( CHAI3D_DEFINITIONS -D_MSVC )
			else( MSVC )
				message( WARNING "FindPackageCHAI3D - using WIN32 without Visual Studio - this will probably fail - use at your own risk!" )
			endif( MSVC )	
			
     		set( CHAI3D_LIBRARIES
	    		optimized chai3d-release
		    	debug chai3d-debug
		)
		endif(UNIX)
		
	else( CHAI3D_ROOT_DIR )
		message( WARNING "vista_find_package_root - scr/chai3d.h not found" )	
	endif( CHAI3D_ROOT_DIR )
endif( NOT VCHAI3D_FOUND )

find_package_handle_standard_args( VChai3D "Chai3D could not be found" CHAI3D_ROOT_DIR CHAI3D_LIBRARIES )

