# Windows build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildIt(strBuildType='Default', strCompiler = 'MSVC_10_64BIT', bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault'):

    #make sure we are on windows system
    if sys.platform != 'win32':
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Win32 build on non Windows system\n\n',-1)
        
    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
    strBasepath = os.getcwd()
    
        
    strVCVersion = strCompiler.split('_')[1]
    if not strVCVersion.isdigit():
        sys.stderr.write('\n\n*** ERROR *** Formt of Visual Studio version\n\n')
        ExitGently(-1)
    
    strArch = ''
    strMSCV = 'Visual Studio ' + strVCVersion
    if '64BIT' in strCompiler:
        strArch = '-x64'
        strMSCV += ' Win64'
    
    if strBuildFolder is 'JenkinsDefault':
        strBuildFolder='build'#.win32' + strArch + '.vc' + strVCVersion #shortening this one because of vc10 bug regarding filename length 
    
    if not os.path.exists(strBuildFolder):
        VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)
    else:
       if True == bDeleteCMakeCache:
            shutil.rmtree(strBuildFolder)#clean cmake build
            sys.stdout.write("\nDeleting Cache\nElapsed time : " + str(int(time.time()-fStartTime)) + " seconds\n")
            VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)

    os.chdir(os.path.join(strBasepath, strBuildFolder))
    
    #configure cmake
    strCMakeCmd = 'cmake.exe -G "' + strMSCV + '" ' + os.path.join(strBasepath)
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCMakeCmd)
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()

    if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):        
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Cmake failed to generate configuration\n\n',-1)
        
    #make it
    if strBuildType is not 'Default':
        MSVCBuildCall(strBuildType)
    else:
        MSVCBuildCall('Debug')
        MSVCBuildCall('Release')    

    os.chdir(os.path.join(strBasepath))
       
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()

def MSVCBuildCall(strBuildType):
        sys.stdout.write('\nStarting to build '+strBuildType+ '\n')
        strVC = 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
        strVC += ' & msbuild ALL_BUILD.vcxproj /property:configuration=' + strBuildType
        strVC += ' /m /clp:ErrorsOnly'
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strVC)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()