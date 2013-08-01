# Linux build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildIt(strBuildType, strCompiler = 'GCC_DEFAULT', bDeleteCMakeCache = True):
    VistaPythonCommon.CheckForVistaEnv()

    sys.stdout.write('Buildtype: ' + strBuildType + '\n')
    sys.stdout.write('Compiler: ' + strCompiler + '\n')
    sys.stdout.flush()
    
    fStartTime=time.time()
    strBasepath = os.getcwd()
    
    #make sure we are on linux system
    if sys.platform == 'linux2':
        
        strSysName = os.uname()[0].upper()
        strMachine = os.uname()[4].upper()
        strBuildFolder = 'build.' + strSysName + '.' + strMachine + '.' + strCompiler + '.' + strBuildType
        
        if not os.path.exists(strBuildFolder):
            VistaPythonCommon.SimpleSysCall('mkdir ' + strBuildFolder)
        else:
           if True == bDeleteCMakeCache:
                shutil.rmtree(strBuildFolder)#clean cmake build
                sys.stdout.write("\nDeleting Cache\nElapsed time : " + str(int(time.time()-fStartTime)) + " seconds\n")
                VistaPythonCommon.SimpleSysCall('mkdir ' + strBuildFolder)

        os.chdir(os.path.join(strBasepath, strBuildFolder))
                
        #check compiler if we are on gpucluster
        strGCCEnv = ''
        if (0 == os.uname()[1].find('linuxgpu')):
            if 'GCC_DEFAULT' in strCompiler:
                strGCCEnv = 'module unload gcc;module unload intel;module load gcc;'
            elif 'GCC_47' in strCompiler:
                strGCCEnv = 'module unload gcc;module unload intel;module load gcc/4.7;'
            elif 'GCC_48' in strCompiler:
                strGCCEnv = 'module unload gcc;module unload intel;module load gcc/4.8;'
            elif 'INTEL_CXX' in strCompiler:
                strGCCEnv = 'module unload gcc;module unload intel;module load intel;'
            else:
                sys.stderr.write('unsupported compiler-version: ' + strCompiler)
                VistaPythonCommon.ExitGently(-1)

        #configure cmake
        strCMakeCmd = strGCCEnv + 'cmake -DCMAKE_BUILD_TYPE=' + strBuildType + ' ' + os.path.join(strBasepath)
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strCMakeCmd)
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()

        if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):
            sys.stderr.write('\n\n*** ERROR *** Cmake failed to generate configuration\n\n')
            VistaPythonCommon.ExitGently(-1)

        #log gcc version
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strGCCEnv + '$CXX -v')
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()
            
        #make it
        if (0 == os.uname()[1].find('linuxgpu')):
            iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall('who | wc -l')
            if 0==int(strConsoleOutput):
                iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strGCCEnv + 'make -j')
            else:
                iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strGCCEnv + 'make -j2')
        else:
            iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strGCCEnv + 'make')
            
        sys.stdout.write(strConsoleOutput)
        sys.stdout.flush()
        os.chdir(strBasepath)
        
    else:
        sys.stderr.write('\n\n*** ERROR *** Linux build on non Linux system\n\n')
        VistaPythonCommon.ExitGently(-1)
        
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()
    