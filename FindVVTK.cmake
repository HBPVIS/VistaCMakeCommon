# $Id$

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VVTK_FOUND )

	# VTK hides it config file quite well, so we have to search it explicitely
	set( _SEARCH_PREFIXES )
	if( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )
		list( APPEND _SEARCH_PREFIXES
				"$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/${VISTA_HWARCH}/lib/*"
				"$ENV{${_PACKAGE_NAME_UPPER}_ROOT}/lib/*"
		)
	endif( EXISTS "$ENV{${_PACKAGE_NAME_UPPER}_ROOT}" )

	foreach( _PATH $ENV{VRDEV} $ENV{VISTA_EXTERNAL_LIBS}  ${CMAKE_PREFIX_PATH} $ENV{CMAKE_PREFIX_PATH} )
		file( TO_CMAKE_PATH ${_PATH} _PATH )
		list( APPEND _SEARCH_PREFIXES
				"${_PATH}/VTK*/${VISTA_HWARCH}/lib/*"
				"${_PATH}/VTK*/lib/*"
				"${_PATH}/VTK/*/${VISTA_HWARCH}/lib/*"
				"${_PATH}/VTK/*/lib/*"
				"${_PATH}/vtk*/${VISTA_HWARCH}/lib/*"
				"${_PATH}/vtk*/lib/*"
				"${_PATH}/vtk/*/${VISTA_HWARCH}/lib/*"
				"${_PATH}/vtk/*/lib/*"
		)
	endforeach( _PATH $ENV{VRDEV} $ENV{VISTA_EXTERNAL_LIBS} ${CMAKE_PREFIX_PATH} $ENV{CMAKE_PREFIX_PATH} )

	foreach( _PATH ${_SEARCH_PREFIXES} )
		file( GLOB _TMP_FILES "${_PATH}/VTKConfig.cmake" )
		foreach( _FILE ${_TMP_FILES} )
			file( TO_CMAKE_PATH ${_FILE} _FOUND_FILE )
			string( REPLACE "/VTKConfig.cmake" "" _FOUND_PATH ${_FOUND_FILE} )
			file( TO_CMAKE_PATH ${_FOUND_PATH} _FOUND_PATH )
			list( APPEND VTK_CONFIG_DIRS ${_FOUND_PATH} )
		endforeach( _FILE ${_TMP_FILES} )
	endforeach( _PATH ${_PREFIX_PATHES} )
	if( VTK_CONFIG_DIRS )
		list( REMOVE_DUPLICATES VTK_CONFIG_DIRS )
	endif( VTK_CONFIG_DIRS )

	find_package( VTK ${VVTK_FIND_VERSION} PATHS ${VTK_DIR} ${VTK_CONFIG_DIRS} )

	if( VTK_FOUND )
		# a VTKConfig.cmake has been found and loaded

		# check if debug libraries are available
		set( _TMP_VTK_DEBUG_LIB "_TMP_VTK_DEBUG_LIB-NOTFOUND" CACHE INTERNAL "" FORCE )
		find_library( _TMP_VTK_DEBUG_LIB "vtkCommonD" PATH ${VTK_LIBRARY_DIRS} NO_DEFAULT_PATH )
		if( _TMP_VTK_DEBUG_LIB )
			set( _DEBUG_AVAILABLE TRUE )
		else( _TMP_VTK_DEBUG_LIB )
			set( _DEBUG_AVAILABLE FALSE )
		endif( _TMP_VTK_DEBUG_LIB )
		set( _TMP_VTK_DEBUG_LIB "_TMP_VTK_DEBUG_LIB-NOTFOUND" CACHE INTERNAL "" FORCE )

		if( _DEBUG_AVAILABLE )
			set( VTK_LIBRARIES	optimized vtkCommon
								optimized vtkDICOMParser
								optimized vtkexoIIc
								optimized vtkexpat
								optimized vtkFiltering
								optimized vtkfreetype
								optimized vtkftgl
								optimized vtkGenericFiltering
								optimized vtkGeovis
								optimized vtkGraphics
								optimized vtkHybrid
								optimized vtkImaging
								optimized vtkInfovis
								optimized vtkIO
								optimized vtkjpeg
								optimized vtklibxml2
								optimized vtkNetCDF
								optimized vtkpng
								optimized vtkRendering
								optimized vtksys
								optimized vtktiff
								optimized vtkViews
								optimized vtkVolumeRendering
								optimized vtksqlite
								optimized vtkmetaio
								optimized vtkverdict
								optimized vtkproj4
								optimized vtkWidgets
								optimized vtkzlib
								debug vtkCommonD
								debug vtkDICOMParserD
								debug vtkexoIIcD
								debug vtkexpatD
								debug vtkFilteringD
								debug vtkfreetypeD
								debug vtkftglD
								debug vtkGenericFilteringD
								debug vtkGeovisD
								debug vtkGraphicsD
								debug vtkHybridD
								debug vtkImagingD
								debug vtkInfovisD
								debug vtkIOD
								debug vtkjpegD
								debug vtklibxml2D
								debug vtkNetCDFD
								debug vtkpngD
								debug vtkRenderingD
								debug vtksysD
								debug vtktiffD
								debug vtkViewsD
								debug vtkVolumeRenderingD
								debug vtksqliteD
								debug vtkmetaioD
								debug vtkverdictD
								debug vtkproj4D
								debug vtkWidgetsD
								debug vtkzlibD
			)

		else( _DEBUG_AVAILABLE ) # no debug libraries available
			set( VTK_LIBRARIES	vtkCommon
								vtkDICOMParser
								vtkexoIIc
								vtkexpat
								vtkFiltering
								vtkfreetype
								vtkftgl
								vtkGenericFiltering
								vtkGeovis
								vtkGraphics
								vtkHybrid
								vtkImaging
								vtkInfovis
								vtkIO
								vtkjpeg
								vtklibxml2
								vtkNetCDF
								vtkpng
								vtkRendering
								vtksys
								vtktiff
								vtkViews
								vtkVolumeRendering
								vtksqlite
								vtkmetaio
								vtkverdict
								vtkproj4
								vtkWidgets
								vtkzlib
			)

		endif( _DEBUG_AVAILABLE )

		# VTK's dlls are in the VTK_RUNTIME_LIBRARY_DIRS, so we have to add this to the library dirs
		# to find them
		set( VTK_LIBRARY_DIRS ${VTK_LIBRARY_DIRS} ${VTK_RUNTIME_LIBRARY_DIRS} )
		set( VTK_ROOT_DIR ${VTK_INSTALL_PREFIX} )

		# note that there is also a VTK_USE_FILE, which will automatically be called
		# by vista_use_package
	endif( VTK_FOUND )
endif( NOT VVTK_FOUND )

find_package_handle_standard_args( VVTK "VTK could not be found" VTK_ROOT_DIR )
set( VTK_FOUND ${VVTK_FOUND} )
