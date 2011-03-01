# Search for precompiled BULLET path

include( FindPackageHandleStandardArgs )

if( NOT VBULLET_FOUND )

	find_path( BULLET_DIR include/btBulletCollisionCommon.h PATHS $ENV{BULLET_DIR}/${VISTA_HWARCH} $ENV{BULLET_DIR} CACHE "Bullet package directory" )

	if( BULLET_DIR )
		message( STATUS "Found Bullet in ${BULLET_DIR}" )
		
		set( BULLET_INC_DIR ${BULLET_DIR}/lib )
		set( BULLET_LIB_DIR ${BULLET_DIR}/include )
		set( BULLET_LIBRARIES
			optimized BulletCollision
			optimized BulletDynamics
			optimized LinearMath
			optimized BulletSoftBody
			optimized BulletGIMPACTUtils
			optimized ConvexDecomposition
			debug BulletCollisionD
			debug BulletDynamicsD
			debug LinearMathD
			debug BulletSoftBodyD
			debug BulletGIMPACTUtilsD
			debug ConvexDecompositionD
		)	
		
		
		
	else( BULLET_DIR )		
		find_package( BULLET )
		
		if( BULLET_FOUND )
			set( BULLLET_INC_DIR ${BULLET_INCLUDE_DIR} )
			#BULLET_LIBRARIES already set by find_package
		endif( BULLET_FOUND )
		
	endif( BULLET_DIR )
	
	find_package_handle_standard_args( VBullet "Bullet could not be found" BULLET_INC_DIR BULLET_LIBRARIES )  
	
	if( VBULLET_FOUND )
		macro( vista_use_bullet )
				include_directories( ${BULLET_INC_DIR} )
				link_directories( ${BULLET_LIB_DIR} )
				list( APPEND LIBRARIES ${BULLET_LIBRARIES} )
		endmacro( vista_use_bullet )
	endif( VBULLET_FOUND )

endif( NOT VBULLET_FOUND )
