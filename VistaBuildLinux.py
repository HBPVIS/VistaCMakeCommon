# Linux build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildIt(strBuildType='Default', strCompiler = 'GCC_DEFAULT', bDeleteCMakeCache = True, strBuildFolder='JenkinsDefault'):
    
    #make sure we are on linux system
    if sys.platform != 'linux2':
        VistaPythonCommon.ExitError('\n\n*** ERROR *** Linux build on non Linux system\n\n',-1)

    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
        
    strSysName = os.uname()[0].upper()
    strMachine = os.uname()[4].upper()
    
    # pretty ugly we switch standard build and jenkins by the buildfolder and then ignore it ...
    # but that works for windows. the reason behind this is, that you need a folder for debug and one for release anyway
    if strBuildFolder is 'JenkinsDefault': 
        strBuildFolder = 'build.' + strSysName + '.' + strMachine + '.' + strCompiler + '.' + strBuildType
        MakeJenkinsBuild(strBuildType,strCompiler,bDeleteCMakeCache)
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
            shutil.rmtree(strBuildFolder)#clean cmake build
            VistaPythonCommon.SysCall(strCompilerEnv+'$VISTA_CMAKE_COMMON/MakeLinuxBuildStructure.sh')
    
    os.chdir(os.path.join(os.getcwd(), strBuildFolder))
    iRC, strConsoleOutput = VistaPythonCommon.SysCall(strCompilerEnv + 'make -j')        
    sys.stdout.write(strConsoleOutput)
    sys.stdout.flush()
    
def MakeJenkinsBuild(strBuildType,strCompiler,bDeleteCMakeCache):
    if strBuildType is 'Default':
        VistaPythonCommon.ExitError('right now BuildType Default is not supported for Jenkins and Linux',-1)
        
    if not os.path.exists(strBuildFolder):
        VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)
    else:
       if True == bDeleteCMakeCache:
            shutil.rmtree(strBuildFolder)#clean cmake build
            VistaPythonCommon.SysCall('mkdir ' + strBuildFolder)

    os.chdir(os.path.join(os.getcwd(), strBuildFolder))
            
    #check compiler if we are on gpucluster
    strCompilerEnv = GetCompilerEnvCall(strCompiler)

    #configure cmake
    strCMakeCmd = strCompilerEnv + 'cmake -DCMAKE_BUILD_TYPE=' + strBuildType + ' ' + os.path.join(os.getcwd())
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
        
#since every syscall opens a new shell we have to set environment each time :(
def GetCompilerEnvCall(strCompiler):
    if (0 == os.uname()[1].find('linuxgpu')):
        if 'GCC_DEFAULT' in strCompiler:
            return 'module unload gcc;module unload intel;module load gcc;'
        elif 'GCC_47' in strCompiler:
            return 'module unload gcc;module unload intel;module load gcc/4.7;'
        elif 'GCC_48' in strCompiler:
            return 'module unload gcc;module unload intel;module load gcc/4.8;'
        elif 'INTEL_CXX' in strCompiler:
            return 'module unload gcc;module unload intel;module load intel;'
        else:
            sys.stderr.write('unsupported compiler-version: ' + strCompiler)
            VistaPythonCommon.ExitGently(-1)
    else:
        return ''
        