# Search for precompiled VISTACORELIBS path
if( NOT VistaCoreLibs_FOUND )

	set( VistaCoreLibs_FOUND "NO" )

	find_path( VISTACORELIBS_ROOT include/VistaBase/VistaBaseConfig.h PATHS $ENV{VISTA_ROOT} CACHE )

	if( VISTACORELIBS_ROOT )
		set( VistaCoreLibs_FOUND "YES" )
		message( STATUS "Found VistaCoreLibs in ${VISTACORELIBS_ROOT}" )
		
		set( VISTACORELIBS_INC_DIR ${VISTACORELIBS_ROOT}/lib )
		set( VISTACORELIBS_LIB_DIR ${VISTACORELIBS_ROOT}/include )
		set( VISTACORELIBS_LIBRARIES
			optimized VistaBase
			optimized VistaAspects
			optimized VistaMath
			optimized VistaTools
			optimized VistaInterProcComm
			optimized VistaDeviceDrivers
			optimized VistaDataFlowNet
			optimized VistaKernel
			optimized VistaKernelOpenSGExt
			debug VistaBaseD
			debug VistaAspectsD
			debug VistaMathD
			debug VistaToolsD
			debug VistaInterProcCommD
			debug VistaDeviceDriversD
			debug VistaDataFlowNetD
			debug VistaKernelD
			debug VistaKernelOpenSGExtD
		)	
		
		macro( useVistaCoreLibs )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES VISTACORELIBS_LIBRARIES )
		endmacro( useVistaCoreLibs )
		
		macro( useVistaCoreLibs_nokernel )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaBase
				optimized VistaAspects
				optimized VistaMath
				optimized VistaTools
				optimized VistaInterProcComm
				optimized VistaDeviceDrivers
				optimized VistaDataFlowNet
				debug VistaBaseD
				debug VistaAspectsD
				debug VistaMathD
				debug VistaToolsD
				debug VistaInterProcCommD
				debug VistaDeviceDriversD
				debug VistaDataFlowNetD
			)
		endmacro( useVistaCoreLibs_nokernel )	
		
		macro( useVistaBase )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaBase
				debug VistaBaseD
			)
		endmacro( useVistaBase )
		
		macro( useVistaAspects )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaAspects
				debug VistaAspectsD
			)
		endmacro( useVistaAspects )
		
		macro( useVistaTools )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaTools
				debug VistaToolsD
			)
		endmacro( useVistaTools )
		
		macro( useVistaMath )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaMath
				debug VistaMathD
			)
		endmacro( useVistaMath )
		
		macro( useVistaInterProcComm )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaInterProcComm
				debug VistaInterProcCommD
			)
		endmacro( useVistaInterProcComm )
		
		macro( useVistaDeviceDriversBase )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaDeviceDriversBase
				debug VistaDeviceDriversBaseD
			)
		endmacro( useVistaDeviceDriversBase )
		
		macro( useVistaDataFlowNet )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaDataFlowNet
				debug VistaDataFlowNetD
			)
		endmacro( useVistaDataFlowNet )
		
		macro( useVistaKernel )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaKernel
				debug VistaKernelD
			)
		endmacro( useVistaKernel )
		
		macro( useVistaKernelOpenSGExt )
			if( NOT SET_PATHES_ALREDY_SET )
				include_directories( ${VISTACORELIBS_INC_DIR} )
				link_directories( ${VISTACORELIBS_LIB_DIR} )
				set( SET_PATHES_ALREDY_SET TRUE INTERNAL )
			endif( NOT SET_PATHES_ALREDY_SET )
			list( APPEND LIBRARIES
				optimized VistaKernelOpenSGExt
				debug VistaKernelOpenSGExtD
			)
		endmacro( useVistaKernelOpenSGExt )

	endif( VISTACORELIBS_ROOT )

endif( NOT VistaCoreLibs_FOUND )
