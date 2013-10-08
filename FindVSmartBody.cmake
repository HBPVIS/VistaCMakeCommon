# $Id: FindVSmartBody.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSMARTBODY_FOUND )
	vista_find_package_root( SmartBody /core/smartbody/SmartBody/src/sb/SBTypes.h )
	if( SMARTBODY_ROOT_DIR )
		set( SMARTBODY_INCLUDE_DIRS 
            ${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody/src/ 
            ${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody-dll/include 
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/include
            ${SMARTBODY_ROOT_DIR}/lib/boost/
            ${SMARTBODY_ROOT_DIR}/lib/bonebus/include
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/steerlib/include
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/external/
            ${SMARTBODY_ROOT_DIR}/lib/wsp/wsp/include/
            ${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody/src/external/glew/
            
        )
        
        if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
            list(APPEND SMARTBODY_INCLUDE_DIRS
                ${SMARTBODY_ROOT_DIR}/core/smartbody/Python27/include
            )
            else() # Linux   
            list(APPEND SMARTBODY_INCLUDE_DIRS
                /usr/local_rwth/sw/python/2.7.5/x86_64/include/python2.7/
            )    
        endif()
        
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set( SMARTBODY_LIBRARY_DIRS 
            ${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody/lib
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/lib64
            ${SMARTBODY_ROOT_DIR}/lib/boost/lib
            ${SMARTBODY_ROOT_DIR}/lib/bonebus/lib
            ${SMARTBODY_ROOT_DIR}/lib/wsp/wsp/lib
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/build/win32/Debug
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/build/win32/Release
            ${SMARTBODY_ROOT_DIR}/lib/vhmsg/vhmsg-c/lib64
            ${SMARTBODY_ROOT_DIR}/lib/activemq/activemq-cpp/vs2010-build/DebugDLL64
            ${SMARTBODY_ROOT_DIR}/lib/activemq/activemq-cpp/vs2010-build/ReleaseDLL
            ${SMARTBODY_ROOT_DIR}/lib/xerces-c/lib
		/usr/local_rwth/sw/boost/1_53_0/gcc_4.4.6-openmpi_1.6.4/lib/
		/usr/local_rwth/sw/python/2.7.5/x86_64/lib/
            ${SMARTBODY_ROOT_DIR}/core/smartbody/Python27/libs
        )
        else(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set( SMARTBODY_LIBRARY_DIRS
            /usr/local_rwth/sw/boost/1_53_0/gcc_4.4.6-openmpi_1.6.4/lib/
		/usr/local_rwth/sw/python/2.7.5/x86_64/lib/
		${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody/lib
            #${SMARTBODY_ROOT_DIR}/core/smartbody/SmartBody/src/external/glew
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/lib
            ${SMARTBODY_ROOT_DIR}/lib/boost/lib
            ${SMARTBODY_ROOT_DIR}/lib/bonebus/lib
            ${SMARTBODY_ROOT_DIR}/lib/wsp/wsp/lib
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/build/win32/Debug
            ${SMARTBODY_ROOT_DIR}/core/smartbody/steersuite-1.3/build/win32/Release
            ${SMARTBODY_ROOT_DIR}/lib/vhmsg/vhmsg-c/lib64
            ${SMARTBODY_ROOT_DIR}/lib/activemq/activemq-cpp/vs2010-build/DebugDLL
            ${SMARTBODY_ROOT_DIR}/lib/activemq/activemq-cpp/vs2010-build/ReleaseDLL
            ${SMARTBODY_ROOT_DIR}/lib/xerces-c/lib
            ${SMARTBODY_ROOT_DIR}/lib/xerces-c/bin
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/libsndfile/bin/
            ${SMARTBODY_ROOT_DIR}/lib/activemq/apr/apr/lib/
            ${SMARTBODY_ROOT_DIR}/lib/activemq/apr/apr-util/lib/
            ${SMARTBODY_ROOT_DIR}/lib/activemq/apr/apr-iconv/lib/
            ${SMARTBODY_ROOT_DIR}/core/smartbody/Python27/libs/
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/openal/libs/Win32/ 
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/libsndfile/lib/  
            ${SMARTBODY_ROOT_DIR}/lib/vhcl/libsndfile/bin/
            ${SMARTBODY_ROOT_DIR}/lib/pthreads/lib/
            )
        endif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        
        set( SMARTBODY_LIBRARIES            
            optimized SmartBody
            debug SmartBody_d
            #linux ? xerces-c
            #optimized bonebus
            #debug bonebus_d
            
            #optimized vhmsg
            #optimized wsp
            #debug activemq-cppd
            #optimized libactivemq-cpp.so.14
            
            
            # linux ?boost_filesystem    

        )

    if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        list(APPEND SMARTBODY_LIBRARIES
        optimized xerces-c_3.lib
        debug xerces-c_3D.lib
        glew32 #windows
        optimized vhcl #windows
        debug vhcl_d #windows
        boost_filesystem-vc100-mt-1_51.lib #windows ?
        boost_system-vc100-mt-1_51.lib #windows ?        
        optimized steerlib
        debug steerlibd
    )
    else() # Linux   
    list(APPEND SMARTBODY_LIBRARIES
        xerces-c
        boost_filesystem
        boost_system
	boost_regex
	boost_python
        pprAI
	steerlib
	python2.7
    )    
    endif()
        
	else( SMARTBODY_ROOT_DIR )
		message( WARNING "vista_find_package_root - File named /core/smartbody/SmartBody/src/sb/SBTypes.h not found" )	
	endif( SMARTBODY_ROOT_DIR )
endif( NOT VSMARTBODY_FOUND )

find_package_handle_standard_args( VSMARTBODY "SmartBody could not be found" SMARTBODY_ROOT_DIR )
