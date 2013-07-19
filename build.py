import  sys, os
from VistaPythonCommon import out,err, syscall,AddVistaPythonCommonArgs

# TODO make a lot of stuff configureable 
# like compilerversion or target
basepath=os.getcwd()
_ARCH=''
_COMPILER=''
_BUILD_TYPE=[]
def InitParser():
    parser = OptionParser()
    parser=AddVistaPythonCommonArgs(parser)
    parser.add_option("-a", "--arch", dest="arch",
                      help="define the systemarchitecture(s)",
              type="choice",
               action="store",
              choices=["X86","X86_64"])            
    parser.add_option("-c", "--compiler",
                      dest="compiler",
              type="choice",
                      choices=['GCC44','GCC47','MSVC10'],
              action="append",
                      help="define the compiler(s)")
    parser.add_option("-t", "--build-type",
                      dest="build_type",
              action="append",
              default=["Debug","Release"],
                      help="define the build_type(s)")
    (options, args) = parser.parse_args()
    _ARCH = option.arch
    _BUILD_TYPE = option.build_type
    _COMPILER =  option.compiler

def JenkinsBuild():
    _ARCH=os.getenv('ARCH')
    _BUILD_TYPE=os.getenv('BUILD_TYPE')
    _COMPILER=os.getenv('COMPILER')
    if 'nt' == os.name:    
        buildfolder='build_win.'+_ARCH+'.vc10'
        if not os.path.exists(buildfolder):
            syscall('mkdir '+buildfolder,ExitOnError=True)    
        os.chdir(os.path.join(basepath,buildfolder))
        if 'X86_64' == _ARCH:
            msvc_ver='"Visual Studio 10 Win64"'
        elif 'X86' == _ARCH:
            msvc_ver='"Visual Studio 10"'
        else:
            err.write('unsupported architecture '+_ARCH)
            out.flush()
            err.flush()
            os._exit(-1)
        cmakecmd='cmake.exe -g '+msvc_ver+' -DCMAKE_BUILD_TYPE='+_BUILD_TYPE+' ' +os.path.join(basepath)
        rc, ConsoleOutput = syscall(cmakecmd,ExitOnError=True)
        if(CheckForCMakeError(ConsoleOutput)):
            out.write(ConsoleOutput)
            out.flush()
            err.write('\n\n*** ERROR *** Cmake failed to generate configuration\n\n')
            err.flush()
            os._exit(-1)
        tmp='call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
        tmp+=' & msbuild ALL_BUILD.vcxproj /property:configuration='+_BUILD_TYPE
        tmp+=' /clp:ErrorsOnly'
        syscall(tmp,ExitOnError=True)
        os.chdir(os.path.join(basepath))
    elif 'posix' == os.name:
        buildfolder='build_LINUX.'+_ARCH+_COMPILER+_BUILD_TYPE
        env=''
        if (0 == os.getenv('NODE_NAME').find('linuxgpu')):
            if _COMPILER == 'GCC44':
                env+='module unload gcc;module load gcc;' #currently system default
            elif _COMPILER == 'GCC47':
                env+='module unload gcc;module load gcc/4.7;'
            elif _COMPILER == 'GCC48':
                env+='module unload gcc;module load gcc/4.8;'
            else:
                err.write('unsupported architecture '+_ARCH)
                os._exit(-1)
        if not os.path.exists(buildfolder):
            syscall('mkdir '+buildfolder,ExitOnError=True)
        os.chdir(os.path.join(basepath,buildfolder))
        cmakecmd='cmake -DCMAKE_BUILD_TYPE='+_BUILD_TYPE+' ' +os.path.join(basepath)
        rc, ConsoleOutput = syscall(env+cmakecmd,ExitOnError=True)
        if(CheckForCMakeError(ConsoleOutput)):
            out.write(ConsoleOutput)
            out.flush()
            err.write('\n\n*** ERROR *** Cmake failed to generate configuration\n\n')
            err.flush()
            os._exit(-1)
        if 0==GetUserCountOnHost():
                syscall(env+'make -j',ExitOnError=True)
        else:
                syscall(env+'make -j2',ExitOnError=True)
        syscall(env+'gcc -v')
        os.chdir(basepath)

def GetUserCountOnHost():
        if 'nt' == os.name:
                pass
        elif 'posix' == os.name:
                rc, ConsoleOutput = syscall('who | wc -l',ExitOnError=True)
                return int(ConsoleOutput)
