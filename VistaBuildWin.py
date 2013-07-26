# Windows build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildIt(strBuildType, strCompiler = 'MSVC_10_64BIT', bDeleteCMakeCache = True):
    VistaPythonCommon.CheckForVistaEnv()

    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
    strBasepath = os.getcwd()
    
    #make sure we are on windows system
    if sys.platform == 'win32':
            
        strVCVersion = strCompiler.split('_')[1]
        if not strVCVersion.isdigit():
            sys.stderr.write('\n\n*** ERROR *** Formt of Visual Studio version\n\n')
            ExitGently(-1)
        
        strArch = ''
        strMSCV = 'Visual Studio ' + strVCVersion
        if '64BIT' in strCompiler:
            strArch = '-x64'
            strMSCV += ' Win64'
            
        strBuildFolder='build.win32' + strArch + '.vc' + strVCVersion        
        
        if not os.path.exists(strBuildFolder):
            VistaPythonCommon.SimpleSysCall('mkdir ' + strBuildFolder)
        else:
           if True == bDeleteCMakeCache:
                shutil.rmtree(strBuildFolder)#clean cmake build
                sys.stdout.write("\nDeleting Cache\nElapsed time : " + str(int(time.time()-fStartTime)) + " seconds\n")
                VistaPythonCommon.SimpleSysCall('mkdir ' + strBuildFolder)

        os.chdir(os.path.join(strBasepath, strBuildFolder))
        
        #configure cmake
        strCMakeCmd = 'cmake.exe -G "' + strMSCV + '" -DCMAKE_CONFIGURATION_TYPES=' + strBuildType + ' ' + os.path.join(strBasepath)
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strCMakeCmd)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()

        if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):
            sys.stderr.write('\n\n*** ERROR *** Cmake failed to generate configuration\n\n')
            VistaPythonCommon.ExitGently(-1)
            
        #make it
        strVC = 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
        strVC += ' & msbuild ALL_BUILD.vcxproj /property:configuration=' + strBuildType
        strVC += ' /m /clp:ErrorsOnly'
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strVC)
        
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()
        os.chdir(os.path.join(strBasepath))
    
    else:
        sys.stderr.write('\n\n*** ERROR *** Win32 build on non Windows system\n\n')
        VistaPythonCommon.ExitGently(-1)
        
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()
