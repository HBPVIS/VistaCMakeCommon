# $Id$

# Defines Vista_specific variables that describe the hardware architecture and compiler
# throws a warning when the current architecture is not supported
# set variables:
#    VISTA_HWARCH    - variable describing Hardware architecture, e.g. win32.vc9 or LINUX.X86
#    VISTA_COMPATIBLE_HWARCH - architectures that are compatible to the current HWARCH,
#                        e.g. for win32.vc9 this will be "win32.vc9 win32"
#    VISTA_64BIT     - set to true if the code is compiled for 64bit execution
#    VISTA_PLATFORM_DEFINE - compiler definition for the platform ( -DWIN32 or -DLINUX or -DDARWIN )

if( NOT VISTA_HWARCH )

	set( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS TRUE )
	
	if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
		SET( VISTA_64BIT TRUE )
	else()
		SET( VISTA_64BIT FALSE )
	endif()

	if( WIN32 )
		set( VISTA_PLATFORM_DEFINE -DWIN32 )

		if( VISTA_64BIT )
			set( VISTA_HWARCH "win32-x64" )
		else()
			set( VISTA_HWARCH "win32" )
		endif( VISTA_64BIT )
		
		set( VISTA_COMPATIBLE_HWARCH ${VISTA_HWARCH} ${VISTA_COMPATIBLE_HWARCH} )

		if( MSVC )
			if( MSVC80 )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc8" )
			elseif( MSVC90 )
				set( VISTA_COMPATIBLE_HWARCH "${VISTA_HWARCH}.v90" ${VISTA_COMPATIBLE_HWARCH} )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc9" )				
			elseif( MSVC10 )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc10" )
			elseif( MSVC11 )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc11" )
			elseif( MSVC12 )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc12" )
			else()
				message( WARNING "VistaCommon - Unknown MSVC version" )
				set( VISTA_HWARCH "${VISTA_HWARCH}.vc" )
			endif()
		else()
			message( WARNING "VistaCommon - using WIN32 without Visual Studio - this will probably fail - use at your own risk!" )
		endif()

		set( VISTA_COMPATIBLE_HWARCH ${VISTA_HWARCH} ${VISTA_COMPATIBLE_HWARCH} )
		
	elseif( APPLE )
		set( VISTA_PLATFORM_DEFINE -DDARWIN )
		set( VISTA_HWARCH "DARWIN" )
		set( VISTA_COMPATIBLE_HWARCH "DARWIN" )
	elseif( UNIX )
		set( VISTA_PLATFORM_DEFINE -DLINUX )
		if( VISTA_64BIT )
			set( VISTA_HWARCH "LINUX.X86_64" )
			set( VISTA_COMPATIBLE_HWARCH "${VISTA_HWARCH}" "LINUX.IA64" "LINUX" )
		else( VISTA_64BIT )
			set( VISTA_HWARCH "LINUX.X86" )
			set( VISTA_COMPATIBLE_HWARCH "${VISTA_HWARCH}" "LINUX" )
		endif( VISTA_64BIT )		
	else()
		message( WARNING "VistaHWarchSettings - Unsupported hardware architecture - use at your own risk!" )
		set( VISTA_HWARCH "UNKOWN_ARCHITECTURE" )
	endif()
endif()
