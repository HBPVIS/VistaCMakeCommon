# General build script designed for jenkins
# $Id

import  sys, VistaBuildLinux, VistaBuildWin

#strBuildType = Debug | Release | Default
#strCompiler format: NAME_VERSION[_ARCHITECTURE] ARCHITECTURE not needed for Linux, 64Bit anyway, examples: GCC_44, MSVC_10_64BIT
#strBuildFolder = JenkinsDefault | Default # this is a bit ugly but on Windows it will be build or on Linux it will be generated by MakeLinuxBuildStructure.sh
def BuildIt(strBuildType, strCompiler, bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault'):
    
    if sys.platform == 'linux2':
        VistaBuildLinux.BuildIt(strBuildType, strCompiler, bDeleteCMakeCache, strBuildFolder)
        
    elif sys.platform == 'win32':
        VistaBuildWin.BuildIt(strBuildType, strCompiler, bDeleteCMakeCache, strBuildFolder)
        
    else:
        sys.err.write('Unsupported Platform ' + sys.platform)
        sys.err.flush()