# General build script designed for jenkins
# $Id

import  sys, VistaBuildLinux, VistaBuildWin

#strBuildType = Debug | Release
#strCompiler format: NAME_VERSION[_ARCHITECTURE] ARCHITECTURE not needed for Linux, 64Bit anyway, examples: GCC_44, MSVC_10_64BIT
def BuildIt(strBuildType, strCompiler, bDeleteCMakeCache = True):
    
    if sys.platform == 'linux2':
        VistaBuildLinux.BuildIt(strBuildType, strCompiler, bDeleteCMakeCache)
        
    elif sys.platform == 'win32':
        VistaBuildWin.BuildIt(strBuildType, strCompiler, bDeleteCMakeCache)
    else:
        sys.err.write('Unsupported Platform ' + sys.platform)
        sys.err.flush()