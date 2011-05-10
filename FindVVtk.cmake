include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VVTK_FOUND )
	vista_find_package_root( Vtk include/vtkDataWriter.h )

	if( VTK_ROOT_DIR )
		set( VTK_INCLUDE_DIRS ${VTK_ROOT_DIR}/include )
		set( VTK_LIBRARY_DIRS ${VTK_ROOT_DIR}/lib ${VTK_ROOT_DIR}/bin )
		set( VTK_LIBRARIES
			optimized vtkCommon
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

	endif( VTK_ROOT_DIR )

endif( NOT VVTK_FOUND )

find_package_handle_standard_args( VVtk "Vtk could not be found" VTK_ROOT_DIR )
set( VTK_FOUND ${VVTK_FOUND} )
