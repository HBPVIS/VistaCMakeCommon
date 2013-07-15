import  sys, os, subprocess
from VistaPythonCommon import out,err, syscall,OptionParser,AddVistaPythonCommonArgs

# TODO make a lot of stuff configureable 
# like compilerversion or target
basepath=os.getcwd()
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
                  choices=['GCC447','GCC472','MSVC'],
		  action="append",
                  help="define the compiler(s)")
parser.add_option("-t", "--build-type",
                  dest="build_type",
		  action="append",
		  default=["Debug","Release"],
                  help="define the build_type(s)")
(options, args) = parser.parse_args()


if 'nt' == os.name:	
	buildfolder='build_win.'+options.arch+'.vc10'
	if not os.path.exists(buildfolder):
		syscall('mkdir '+buildfolder,ExitOnError=True)	
	os.chdir(buildfolder)
	if 'X86_64' == options.arch:
		msvc_ver="Visual Studio 10 Win64"
	elif 'X86' == options.arch:
		 msvc_ver="Visual Studio 10"
	else:
		err.write('unsupported architecture '+options.arch)
		os._exit(-1)
	syscall('cmake.exe ../ -g '+msvc_ver,ExitOnError=True)
	for btype in options.build_type:
		tmp='call "c:\\Program Files (x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat" x86'
	        tmp+=' & msbuild ALL_BUILD.vcxproj /property:configuration='
		tmp+=btype+' /clp:ErrorsOnly'
        	syscall(tmp,ExitOnError=True)
	os.chdir(basepath)
	
elif 'posix' == os.name:
	buildfolder='build_LINUX.'+options.arch
	env=''
	if "GCC472"==options.compiler:
		env+='export PATH=/usr/local_rwth/sw/gcc/4.7.2/bin:$PATH;'
		env+='export LD_LIBRARY_PATH=/usr/local_rwth/sw/gcc/4.7.2/lib64:/usr/local_rwth/sw/gcc/4.7.2/lib:$LD_LIBRARY_PATH;'
	if not os.path.exists(buildfolder):
		syscall(env+'$VISTA_CMAKE_COMMON/MakeLinuxBuildStructure.sh',ExitOnError=True)
		os.chdir(buildfolder)
	else:
		os.chdir(buildfolder)
		syscall('./RerunCMake.sh cmake',ExitOnError=True)
	syscall(env+'make',ExitOnError=True)
	syscall(env+'gcc -v')
	os.chdir(basepath)
