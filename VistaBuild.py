# General build script designed for jenkins
# $Id

import  sys, VistaBuildLinux, VistaBuildWin

#strBuildType = Debug | Release | Default
#strCompiler format:    Linux-GCC:   GCC_VERSION, examples: GCC_4.8, GCC_DEFAULT
#                       Linux-Intel: INTEL_CXX
#                       Windows-VC:  MSVC_VERSION[_64BIT], examples: MSVC_10, MSVC_10_64BIT
#strBuildFolder = JenkinsDefault | Default # this is a bit ugly but on Windows it will be build or on Linux it will be generated by MakeLinuxBuildStructure.sh
#bRunTests triggers Tests
def BuildIt(strBuildType, strCompiler, strCMakeVariables = '', bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault',bRunTests = False, bInstall = False):
    
    if sys.platform == 'linux2':
        VistaBuildLinux.BuildIt(strBuildType, strCompiler, strCMakeVariables, bDeleteCMakeCache, strBuildFolder, bRunTests, bInstall)
        
    elif sys.platform == 'win32':
        VistaBuildWin.BuildIt(strBuildType, strCompiler, strCMakeVariables, bDeleteCMakeCache, strBuildFolder, bRunTests, bInstall)
        
    else:
        sys.err.write('Unsupported Platform ' + sys.platform)
        sys.err.flush()