# Windows build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildIt(strBuildType='Default', strCompiler = 'MSVC_10_64BIT', strCMakeVariables = '', bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault', bRunTests = False, bInstall = False):

    #make sure we are on windows system
    if sys.platform != 'win32':
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Win32 build on non Windows system\n\n',-1)
        
    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.write('CMake Definitions: ' + strCMakeVariables + '\n')
   
    
    if True == bRunTests:
        sys.stdout.write('Executing tests\n')
    if True == bInstall:
        sys.stdout.write('Make install\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
    strBasepath = os.getcwd()
    
        
    strVCVersion = strCompiler.split('_')[1]
    if not strVCVersion.isdigit():
        sys.stderr.write('\n\n*** ERROR *** Formt of Visual Studio version\n\n')
        ExitGently(-1)
    
    #strArch = ''
    #strMSCV = 'Visual Studio ' + strVCVersion
    #if '64BIT' in strCompiler:
        #strArch = '-x64'
        #strMSCV += ' Win64'
    
    if strBuildFolder is 'JenkinsDefault':
        strBuildFolder='build'#.win32' + strArch + '.vc' + strVCVersion #shortening this one because of vc10 bug regarding filename length 
    
    if not os.path.exists(strBuildFolder):
        VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)
    else:
       if True == bDeleteCMakeCache:
            shutil.rmtree(strBuildFolder,True)#clean cmake build
            sys.stdout.write("\nDeleting Cache\nElapsed time : " + str(int(time.time()-fStartTime)) + " seconds\n")
            VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)

    os.chdir(os.path.join(strBasepath, strBuildFolder))
    
    #configure cmake
    strCMakeCmd = 'cmake.exe -G "' + getMSVCGeneratorString(strCompiler,strVCVersion) + '" ' + strCMakeVariables + ' ' + os.path.join(strBasepath)
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCMakeCmd)
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()

    if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):        
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Cmake failed to generate configuration\n\n',-1)
        
    #make it
    if strBuildType is not 'Default':
        MSVCBuildCall(strBuildType, strVCVersion)
    else:
        MSVCBuildCall('Debug', strVCVersion)
        MSVCBuildCall('Release', strVCVersion)  
    
    #execute tests
    if True == bRunTests:
        if strBuildType is not 'Default':
            MSVCTestCall(strBuildType, strVCVersion)
        else:
            MSVCTestCall('Debug', strVCVersion)
            MSVCTestCall('Release', strVCVersion)     
        
    #install
    if True == bInstall:
        MSVCInstallCall("ALL_BUILD", strVCVersion)    
        
    os.chdir(os.path.join(strBasepath))
    
    if True == bDeleteCMakeCache:
        CleanWorkspace(os.path.join(strBasepath, strBuildFolder))
       
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()
    
def CleanWorkspace(strdirpath):
    sys.stdout.write("\nCleaning *.obj files from "+strdirpath+"\n")
    for (dirpath, dirnames, filenames) in os.walk(strdirpath):        
        for filename in filenames:
            temp, fileExtension = os.path.splitext(filename)
            if fileExtension == '.obj': 
                try:
                    os.remove(os.sep.join([dirpath,filename]))
                except:
                    sys.stderr.out("Error while deleting "+os.sep.join([dirpath,filename]))
    sys.stdout.flush()

def MSVCBuildCall(strBuildType, strVCVersion):
        sys.stdout.write('\nStarting to build '+strBuildType+ '\n')
        strVC = getVCvarsall( strVCVersion )
        strVC += ' & msbuild ALL_BUILD.vcxproj /property:configuration=' + strBuildType
        strVC += ' /maxcpucount '
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strVC)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()
        
def MSVCTestCall(strBuildType, strVCVersion):
        sys.stdout.write('\nStarting to build Tests \n')
        strVC = getVCvarsall( strVCVersion )
        strVC += ' & msbuild RUN_TESTS.vcxproj /property:configuration=' + strBuildType
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strVC,ExitOnError = False)
        if 0 != iRC:
            strVC = 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
            strVC += ' & msbuild RUN_TESTS_VERBOSE.vcxproj '
            iRC, strConsoleOutput = VistaPythonCommon.SysCall(strVC,ExitOnError = True)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()
        
def MSVCInstallCall( strTarget = "ALL_BUILD" , strVCVersion = "10" ):
        sys.stdout.write('\nStarting to build Tests \n')
        strVC = getVCvarsall( strVCVersion )
        strVC += ' & msbuild INSTALL.vcxproj '
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strVC)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()

def getVCvarsall( strVCVersion ): #  or 11
    if "10" == strVCVersion:
        return 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
    elif "11" == strVCVersion:
        return 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 11.0\\VC\\vcvarsall.bat" x86'
    elif "09" == strVCVersion:
        return 'call "c:\\Program Files (x86)\\Microsoft Visual Studio 9.0\\VC\\vcvarsall.bat" x86'
    else:
        sys.stderr.write('\n\n*** ERROR *** Unsupported MSVC Version\n')
        sys.stderr.write('Supported are: 09, 10 and 11.\n Given is:'+strVCVersion)
        ExitGently(-1)
        
def getMSVCGeneratorString(strCompiler, strVCVersion):
    strMSVCGenerator='Visual Studio '
    strArch=''
    strVersion=''
    
    if '64BIT' in strCompiler:
        strArch += ' Win64'    
    
    if "10" == strVCVersion:
        strVersion='10'
    elif "11" == strVCVersion:
        strVersion='11'
    elif "09" == strVCVersion:
        strVersion='9 2008'
    elif "08" == strVCVersion:
        strVersion='8 2005'
    else:
        sys.stderr.write('\n\n*** ERROR *** Unsupported MSVC Version\n')
        sys.stderr.write('Supported are: 08,09, 10 and 11.\n Given is:'+strVCVersion)
        ExitGently(-1)
    return strMSVCGenerator+strVersion+strArch

