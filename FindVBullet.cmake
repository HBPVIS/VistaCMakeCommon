# Search for precompiled BULLET path

include( FindPackageHandleStandardArgs )

if( NOT VBULLET_FOUND )

	find_path( BULLET_ROOT_DIR include/btBulletCollisionCommon.h
				PATHS	$ENV{BULLET_ROOT}/${VISTA_HWARCH} $ENV{BULLET_ROOT} 
						$ENV{VRDEV}/SOLID/${VISTA_HWARCH} $ENV{VRDEV}/SOLID/
				CACHE "Bullet package directory" )

	if( BULLET_ROOT_DIR )
		message( STATUS "Found Bullet in ${BULLET_ROOT_DIR}" )
		
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
		
	else( BULLET_ROOT_DIR )		
		find_package( BULLET )
		
		if( BULLET_FOUND )
			#BULLET_LIBRARIES and BULLET_LIBRARIES already set by find_package
			set( BULLET_LIBRARY_DIRS "" )
		endif( BULLET_FOUND )
		
	endif( BULLET_ROOT_DIR )	
	
	macro( vista_use_bullet )
			include_directories( ${BULLET_INCLUDE_DIRS} )
			link_directories(  ${BULLET_LIBRARY_DIRS} )
	endmacro( vista_use_bullet )


endif( NOT VBULLET_FOUND )

find_package_handle_standard_args( VBullet "Bullet could not be found" BULLET_INCLUDE_DIRS BULLET_LIBRARIES )  
