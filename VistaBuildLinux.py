# Linux build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory                                                                                                                 
def BuildIt(strBuildType='Default', strCompiler = 'GCC_DEFAULT', strCMakeVariables = '', bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault', bRunTests = False ):
    
    #make sure we are on linux system
    if sys.platform != 'linux2':
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Linux build on non Linux system\n\n',-1)

    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.write('CMake Definitions: ' + strCMakeVariables + '\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
        
 
    
    # pretty ugly we switch standard build and jenkins by the buildfolder and then ignore it ...
    # but that works for windows. the reason behind this is, that you need a folder for debug and one for release anyway
    if strBuildFolder is 'JenkinsDefault':        
        MakeJenkinsBuild(strBuildType, strCompiler, strCMakeVariables, bDeleteCMakeCache,bRunTests)
    else:
        MakeLinuxStandardBuild(strCompiler,bDeleteCMakeCache)
    
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()
    
    
def MakeLinuxStandardBuild(strCompiler,bDeleteCMakeCache):
    strBuildFolder='build_LINUX.X86_64' 
    strCompilerEnv = GetCompilerEnvCall(strCompiler)
    
    if not os.path.exists(strBuildFolder):
        VistaPythonCommon.SysCall(strCompilerEnv+'$VISTA_CMAKE_COMMON/MakeLinuxBuildStructure.sh')
    else:
       if True == bDeleteCMakeCache:
            shutil.rmtree(strBuildFolder,True)#clean cmake build
            VistaPythonCommon.SysCall(strCompilerEnv+'$VISTA_CMAKE_COMMON/MakeLinuxBuildStructure.sh')
    
    os.chdir(os.path.join(os.getcwd(), strBuildFolder))
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make -j')        
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()
    
def MakeJenkinsBuild(strBuildType, strCompiler, strCMakeVariables, bDeleteCMakeCache,bRunTests):
    strSysName = os.uname()[0].upper()
    strMachine = os.uname()[4].upper()
    strBuildFolder = 'build.' + strSysName + '.' + strMachine + '.' + strCompiler + '.' + strBuildType
    if strBuildType is 'Default':
        VistaPythonCommon.ExitError('right now BuildType Default is not supported for Jenkins and Linux',-1)
        
    if not os.path.exists(strBuildFolder):
        VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)
    else:
       if True == bDeleteCMakeCache:
            shutil.rmtree(strBuildFolder)#clean cmake build
            VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)

    strBasePath = os.getcwd()
    os.chdir(os.path.join(strBasePath, strBuildFolder))
            
    #check compiler if we are on gpucluster
    strCompilerEnv = GetCompilerEnvCall(strCompiler)

    #configure cmake
    strCMakeCmd = strCompilerEnv + 'cmake -DCMAKE_BUILD_TYPE=' + strBuildType + ' ' + strCMakeVariables + ' ' + os.path.join(strBasePath)
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCMakeCmd)
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()

    if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):        
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Cmake failed to generate configuration\n\n',-1)

    #log gcc version
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + '$CXX -v')
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()
        
    #make it
    if (0 == os.uname()[1].find('linuxgpu')):
        iRC, strConsoleOutput = VistaPythonCommon.SysCall('who | wc -l')
        if 0==int(strConsoleOutput):
            iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make -j')
        else:
            iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make -j2')
    else:
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make')
    
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()
    
    #execute tests
    if True == bRunTests:
        iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make test')
        
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()
        
#since every syscall opens a new shell we have to set environment each time :(
def GetCompilerEnvCall(strCompiler):
    if (0 == os.uname()[1].find('linuxgpu')):
        liCompilerDef = strCompiler.split('_', 1)
        if (len(liCompilerDef) != 0):
            if 'INTEL' in liCompilerDef[0]:
                return 'module unload gcc;module unload intel;module load intel;'
            elif 'GCC' in liCompilerDef[0]:
                if (len(liCompilerDef) > 1):
                    if 'DEFAULT' in liCompilerDef[1]:
                        return 'module unload gcc;module unload intel;module load gcc;'
                    else:
                        return 'module unload gcc;module unload intel;module load gcc/' + liCompilerDef[1] + ';'
            else:
                sys.stderr.write('unsupported compiler-version: ' + strCompiler)
                VistaPythonCommon.ExitGently(-1)
        else:
            return ''
    else:
        return ''
        