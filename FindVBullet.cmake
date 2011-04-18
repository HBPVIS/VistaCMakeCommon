# Search for precompiled BULLET path

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VBULLET_FOUND )
	vista_find_package_root( Bullet include/btBulletCollisionCommon.h )

	if( BULLET_ROOT_DIR )		
		set( BULLET_INCLUDE_DIRS ${BULLET_ROOT_DIR}/include )
		set( BULLET_LIBRARY_DIRS ${BULLET_ROOT_DIR}/lib )
		set( BULLET_LIBRARIES
			optimized BulletCollision
			optimized BulletDynamics
			optimized LinearMath
			optimized BulletSoftBody
			optimized GIMPACTUtils
			optimized ConvexDecomposition
			debug BulletCollisionD
			debug BulletDynamicsD
			debug LinearMathD
			debug BulletSoftBodyD
			debug GIMPACTUtilsD
			debug ConvexDecompositionD
		)			
		
	#else( BULLET_ROOT_DIR )		
	#	find_package( BULLET )
		
	#	if( BULLET_FOUND )
			#BULLET_LIBRARIES and BULLET_LIBRARIES already set by find_package
	#		set( BULLET_LIBRARY_DIRS "" )
	#	endif( BULLET_FOUND )
		
	endif( BULLET_ROOT_DIR )

endif( NOT VBULLET_FOUND )

find_package_handle_standard_args( VBullet "Bullet could not be found" BULLET_INCLUDE_DIRS BULLET_LIBRARIES ) 
set( BULLET_FOUND ${VBULLET_FOUND} )
