# $Id: FindVSmartBody.cmake 21495 2011-05-25 07:52:18Z dr165799 $

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSMARTBODY_FOUND )
	vista_find_package_root( SmartBody /src/SmartBody/sb/SBTypes.h NAMES SmartBodySDK smartbody SmartBody )
    
	if( SMARTBODY_ROOT_DIR )
		set( SMARTBODY_INCLUDE_DIRS 
			${SMARTBODY_ROOT_DIR}/src/SmartBody
			${SMARTBODY_ROOT_DIR}/include
			${SMARTBODY_ROOT_DIR}/include/vhcl
			${SMARTBODY_ROOT_DIR}/include/steersuite
            ${SMARTBODY_ROOT_DIR}/include/steersuite/external
			${SMARTBODY_ROOT_DIR}/python27/include
			${SMARTBODY_ROOT_DIR}/include/bonebus
			${SMARTBODY_ROOT_DIR}/include/wsp                      
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
                ${SMARTBODY_ROOT_DIR}/lib
                ${SMARTBODY_ROOT_DIR}/python27/libs
                ${SMARTBODY_ROOT_DIR}/3rdParty/lib
               )
        else(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set( SMARTBODY_LIBRARY_DIRS
                ${SMARTBODY_ROOT_DIR}/bin    #not sure if necessary but this way it is added to runtime_path
                ${SMARTBODY_ROOT_DIR}/lib
                ${SMARTBODY_ROOT_DIR}/python27/libs            
               )
        endif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        
        if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")            
        else() # Linux   
            list(APPEND SMARTBODY_LIBRARY_DIRS
                /usr/local_rwth/sw/boost/1_53_0/gcc-openmpi/lib
                /usr/local_rwth/sw/python/2.7.5/x86_64/lib
            )    
        endif()
        
        
        set( SMARTBODY_LIBRARIES            
            optimized SmartBody
            debug SmartBody_d
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
    endif()
endif( NOT VSMARTBODY_FOUND )

find_package_handle_standard_args( VSmartBody "SmartBody could not be found" SMARTBODY_ROOT_DIR )
