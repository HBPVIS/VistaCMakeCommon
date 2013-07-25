# Linux build script designed for jenkins
# $Id

import  sys, os, time, shutil, VistaPythonCommon

#build project in current directory     
def BuildItOnLinux(strBuildType, bDeleteCMakeCache = True, strCompiler = 'GCCDEFAULT'):
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
        if (0 == os.uname()[1].find('linuxgpu')):
            strGCCEnv = ''
            if strCompiler == 'GCCDEFAULT':
                strGCCEnv+='module unload gcc;module load gcc'
            elif strCompiler == 'GCC47':
                strGCCEnv+='module unload gcc;module load gcc/4.7'
            elif strCompiler == 'GCC48':
                strGCCEnv+='module unload gcc;module load gcc/4.8'
            else:
                sys.stderr.write('unsupported gcc-version: ' + strCompiler)
                VistaPythonCommon.ExitGently(-1)
        
            iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strGCCEnv)
            sys.stdout.write(strConsoleOutput)
			sys.stdout.flush()

        #configure cmake
        strCMakeCmd = 'cmake -DCMAKE_BUILD_TYPE=' + strBuildType + ' ' + os.path.join(strBasepath)
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall(strCMakeCmd)
        sys.stdout.write(strConsoleOutput)
		sys.stdout.flush()

        if VistaPythonCommon.CheckForCMakeError(strConsoleOutput):
            sys.stdout.write(strConsoleOutput)
            sys.stderr.write('\n\n*** ERROR *** Cmake failed to generate configuration\n\n')
            VistaPythonCommon.ExitGently(-1)

        #log gcc version
        iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall('gcc -v')
        sys.stdout.write(strConsoleOutput)
		sys.stdout.flush()
            
        #make it
        if (0 == os.uname()[1].find('linuxgpu')):
            iRC, strConsoleOutput = SimpleSysCall('who | wc -l')
            if 0==int(strConsoleOutput):
                VistaPythonCommon.SimpleSysCall('make -j')
            else:
                VistaPythonCommon.SimpleSysCall('make -j2')
        else:
            iRC, strConsoleOutput = VistaPythonCommon.SimpleSysCall('make')
            sys.stdout.write(strConsoleOutput)

        os.chdir(strBasepath)
        
    else:
        sys.stderr.write('\n\n*** ERROR *** Linux build on non Linux system\n\n')
        VistaPythonCommon.ExitGently(-1)
        
    sys.stdout.write("\n\nElapsed time: " + str(int(time.time()-fStartTime)) + " seconds\n")
    sys.stdout.flush()
    