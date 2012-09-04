# $Id: FindVSOFA.cmake 21495 2011-05-25 07:52:18Z tk674006 $

# Tested with: Sofa - Development Version - Revision 7193

include( FindPackageHandleStandardArgs )
include( VistaFindUtils )

if( NOT VSOFA_FOUND )
	vista_find_package_root( SOFA framework/sofa/core/SofaLibrary.h )

	if( SOFA_ROOT_DIR )

		set( SOFA_INCLUDE_DIRS 
			${SOFA_ROOT_DIR}/tools/qt4win/include/QtCore
			${SOFA_ROOT_DIR}/tools/qt4win/include/QtGui
			${SOFA_ROOT_DIR}/tools/qt4win/include/QtOpenGL
			${SOFA_ROOT_DIR}/tools/qt4win/include/QtXml
			${SOFA_ROOT_DIR}/tools/qt4win/include/Qt3Support
			${SOFA_ROOT_DIR}/tools/qt4win/include
			${SOFA_ROOT_DIR}/include/win32
			${SOFA_ROOT_DIR}/include
			${SOFA_ROOT_DIR}/framework
			${SOFA_ROOT_DIR}/modules
			${SOFA_ROOT_DIR}/applications
			${SOFA_ROOT_DIR}/extlibs/miniBoost
			${SOFA_ROOT_DIR}/extlibs/tinyxml
			${SOFA_ROOT_DIR}/extlibs/newmat
			${SOFA_ROOT_DIR}/extlibs/qwt-5.2.0/src
			${SOFA_ROOT_DIR}/extlibs/miniFlowVR/include
			${SOFA_ROOT_DIR}/tools/qt4win/include/ActiveQt
			${SOFA_ROOT_DIR}/tools/qt4win/mkspecs/win32-msvc2008 )
		
		if( WIN32 )
			if( MSVC )
				if( MSVC80 )
					set( SOFA_LIBRARY_DIRS ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC8 ${SOFA_ROOT_DIR}/lib/win32/DebugVC8 ${SOFA_ROOT_DIR}/bin)		
				elseif( MSVC90 )
					set( SOFA_LIBRARY_DIRS ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC9 ${SOFA_ROOT_DIR}/lib/win32/DebugVC9 ${SOFA_ROOT_DIR}/bin)
				else( MSVC80 )
					message( WARNING "FindPackageSOFA - Unknown MSVC version" )
				endif( MSVC80 )				
			else( MSVC )
				message( WARNING "FindPackageSOFA - using WIN32 without Visual Studio - this will probably fail - use at your own risk!" )
			endif( MSVC )
		
			

			set( SOFA_LIBRARIES 
				optimized opengl32.lib
				optimized glu32.lib
				optimized gdi32.lib
				optimized user32.lib
				optimized sofahelper.lib
				optimized sofadefaulttype.lib
				optimized sofacore.lib
				optimized sofacomponentmastersolver.lib
				optimized sofacomponentfem.lib
				optimized sofacomponentinteractionforcefield.lib
				optimized sofacomponentcontextobject.lib
				optimized sofacomponentbehaviormodel.lib
				optimized sofacomponentengine.lib
				optimized sofacomponentlinearsolver.lib
				optimized sofacomponentodesolver.lib
				optimized sofacomponentbase.lib
				optimized sofacomponentloader.lib
				optimized sofacomponentcontroller.lib
				optimized sofacomponentvisualmodel.lib
				optimized sofacomponentmass.lib
				optimized sofacomponentforcefield.lib
				optimized sofacomponentmapping.lib
				optimized sofacomponentconstraint.lib
				optimized sofacomponentcollision.lib
				optimized sofacomponentmisc.lib
				optimized sofacomponent.lib
				optimized sofasimulation.lib
				optimized sofatree.lib
				optimized sofaautomatescheduler.lib
				optimized sofabgl.lib
				optimized sofagui.lib
				optimized qwt.lib
				optimized ${SOFA_ROOT_DIR}/lib/win32/Common/glut32.lib
				optimized comctl32.lib
				optimized AdvAPI32.lib
				optimized Shell32.lib
				optimized WSock32.lib
				optimized WS2_32.lib
				optimized Ole32.lib
				optimized tinyxml.lib
				optimized ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC9/zlib.lib
				optimized ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC9/libpng.lib
				optimized newmat.lib
				optimized ${SOFA_ROOT_DIR}/lib/win32/Common/glew32.lib
				optimized miniFlowVR.lib
				optimized ${SOFA_ROOT_DIR}/tools/qt4win/lib/Qt3Support4.lib
				optimized ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtXml4.lib
				optimized ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtOpenGL4.lib
				optimized ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtGui4.lib
				optimized ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtCore4.lib

				debug opengl32.lib
				debug glu32.lib
				debug gdi32.lib
				debug user32.lib
				debug sofahelperD.lib
				debug sofadefaulttypeD.lib
				debug sofacoreD.lib
				debug sofacomponentmastersolverD.lib
				debug sofacomponentfemD.lib
				debug sofacomponentinteractionforcefieldD.lib
				debug sofacomponentcontextobjectD.lib
				debug sofacomponentbehaviormodelD.lib
				debug sofacomponentengineD.lib
				debug sofacomponentlinearsolverD.lib
				debug sofacomponentodesolverD.lib
				debug sofacomponentbaseD.lib
				debug sofacomponentloaderD.lib
				debug sofacomponentcontrollerD.lib
				debug sofacomponentvisualmodelD.lib
				debug sofacomponentmassD.lib
				debug sofacomponentforcefieldD.lib
				debug sofacomponentmappingD.lib
				debug sofacomponentconstraintD.lib
				debug sofacomponentcollisionD.lib
				debug sofacomponentmiscD.lib
				debug sofacomponentD.lib
				debug sofasimulationD.lib
				debug sofatreeD.lib
				debug sofaautomateschedulerD.lib
				debug sofabglD.lib
				debug sofaguiD.lib
				debug qwtD.lib
				debug ${SOFA_ROOT_DIR}/lib/win32/Common/glut32.lib
				debug comctl32.lib
				debug AdvAPI32.lib
				debug Shell32.lib
				debug WSock32.lib
				debug WS2_32.lib
				debug Ole32.lib
				debug tinyxmlD.lib
				debug ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC9/zlib.lib
				debug ${SOFA_ROOT_DIR}/lib/win32/ReleaseVC9/libpng.lib
				debug newmatD.lib
				debug ${SOFA_ROOT_DIR}/lib/win32/Common/glew32.lib
				debug miniFlowVRD.lib
				debug ${SOFA_ROOT_DIR}/tools/qt4win/lib/Qt3Support4.lib
				debug ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtXml4.lib
				debug ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtOpenGL4.lib
				debug ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtGui4.lib
				debug ${SOFA_ROOT_DIR}/tools/qt4win/lib/QtCore4.lib
			)		
		endif( WIN32 )

		set( SOFA_DEFINITIONS 	-D_MSVC
								-D_WINDOWS
								-DUNICODE
								-DWIN32
								-DQT_LARGEFILE_SUPPORT
								-DSOFA_QT4
								-DSOFA_DEV
								-DSOFA_GUI_QTVIEWER
								-DSOFA_GUI_GLUT
								-DSOFA_DUMP_VISITOR_INFO
								-DSOFA_HAVE_ZLIB
								-DSOFA_HAVE_PNG
								-DSOFA_HAVE_GLEW
								-DSOFA_XML_PARSER_TINYXML
								-DSOFA_GUI_QT
								-DMINI_FLOWVR
								-DQT_QT3SUPPORT_LIB
								-DQT3_SUPPORT
								-DQT_XML_LIB
								-DQT_OPENGL_LIB
								-DQT_GUI_LIB
								-DQT_CORE_LIB
								-DQT_THREAD_SUPPORT )

	endif( SOFA_ROOT_DIR )

endif( NOT VSOFA_FOUND )

find_package_handle_standard_args( VSOFA "SOFA could not be found" SOFA_ROOT_DIR )
