# $Id$

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

	endif( BULLET_ROOT_DIR )

endif( NOT VBULLET_FOUND )

find_package_handle_standard_args( VBullet "Bullet could not be found" BULLET_ROOT_DIR )

