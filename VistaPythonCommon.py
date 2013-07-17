import sys, os, subprocess
from optparse import OptionParser
out = sys.stdout   ## use out.write('foobar') for multiplatform and pythonindependant prints
err = sys.stderr

__optionparser = None

def ExitGently():
    err.flush()
    out.flush()
    os._exit(0)

def syscall(cmd,ExitOnError=False):
		if __optionparser is not None:
			(options, args) = __optionparser.parse_args()
			if True == options.verbose:
				out.write(cmd)
		out.flush()
		err.flush()
	#for arg in args:
	#    out.write(arg)
	#    out.write(' ')
	#out.write('\n')
		RC=0
		try:
				if sys.version_info<(2,7,0):
					#subprocess.check_call(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)
					p = subprocess.Popen(cmd, universal_newlines=True, stdout=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)
					out.write(p.communicate()[0])
					RC=int(p.returncode)
					if RC != 0:						
						err.write('ReturnCode: '+str(RC)+'\n')
						if True == ExitOnError:
							os._exit(returncode)
				else:
					output = subprocess.check_output(cmd,universal_newlines=True,stderr=subprocess.STDOUT,shell=True)
					out.write(str(output))
				#TODO insert ifdef pythonversion. below 2.7 check_call, above check_output
		except subprocess.CalledProcessError as e:
				RC=int(e.returncode)
				err.write(e.cmd)
				if sys.version_info>(2,7,0):
					err.write('\n'+str(e.output)+'\n')
				err.flush()
				if True == ExitOnError:
					out.write("Returncode is: "+e.rwturncode+' \n')
					out.flush()
					os._exit(e.returncode)
		return RC
	#output = subprocess.check_output(cmd, shell=True)

	

#checks VISTA_CMAKE_COMMON and VISTA_EXTERNAL_LIBS
def CHECKS():
    val = os.getenv("VISTA_CMAKE_COMMON")
    if val is None:
        out.write("Exiting, VISTA_CMAKE_COMMON not set\n") 
        ExitGently()
    if not os.path.exists(val):
        out.write("Exiting, Path of VISTA_CMAKE_COMMON ("+val+") does not exist\n")
        ExitGently()
    val = os.getenv("VISTA_EXTERNAL_LIBS")
    if val is None:
        out.write("Exiting, VISTA_EXTERNAL_LIBS not set\n")
        ExitGently()
    if not os.path.exists(val):
        out.write("Exiting, Path of VISTA_CMAKE_COMMON ("+val+") does not exist\n")
        ExitGently()

def AddVistaPythonCommonArgs(parser):
	parser.add_option("-v", action="store_true", dest="verbose", default=False)
	parser.add_option("-q", action="store_false", dest="verbose")
	
	global __optionparser
	__optionparser = parser
	return parser


CHECKS()
