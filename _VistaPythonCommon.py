# Common python stuff
# $Id

import sys, os, subprocess
from optparse import OptionParser
out = sys.stdout   ## use out.write('foobar') for multiplatform and pythonindependant prints
err = sys.stderr

__optionparser = None


#flush streambuffers and quit
def ExitGently(iReturnCode = 0):
    err.flush()
    out.flush()
    os._exit(iReturnCode)
    
#shell or commandline call of strCmd
#    @return Errorcode and Commandoutput
def SimpleSysCall(strCmd, ExitOnError = True):
    iReturnCode = 0
    
    pCall = subprocess.Popen(strCmd, universal_newlines=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
    strOutput = pCall.communicate()[0]
    iReturnCode = int(pCall.returncode)
    if iReturnCode != 0:
        out.write(strOutput)
        err.write('Systemcall with command ' + strCmd + ' failed wit return ' + str(iReturnCode) + '\n')
        out.flush()
        err.flush()
        if True == ExitOnError:
            os._exit(iReturnCode)
    return iReturnCode, strOutput
    
#checks existance of environmentvariable strEnvvar and corresponding path 
#    @return True if variable and path exist      
def CheckForEnv(strEnvvar):
    if os.getenv(strEnvvar)!=None:
        out.write(strEnvvar+': '+os.getenv(strEnvvar)+'\n')
        if os.path.exists(os.getenv(strEnvvar)):
            return True
        else:
            err.write('*** ERROR *** Path of '+strEnvvar+' does not exist\n')
            return False
    else:
        err.write('*** ERROR *** '+strEnvvar+' not set\n')
        return False
    
#checks VISTA_CMAKE_COMMON and VISTA_EXTERNAL_LIBS  
def CheckForVistaEnv():
    if not CheckForEnv("VISTA_CMAKE_COMMON"):
        ExitGently(0)
    if not CheckForEnv("VISTA_EXTERNAL_LIBS"):
        ExitGently(0)

def Exit(ErrorMessage):
    out.flush()
    err.write('\n'+ErrorMessage+'\n')
    err.flush()    
    os._exit(1)

def syscall(cmd,ExitOnError=False):
    if __optionparser is not None:
        (options, args) = __optionparser.parse_args()
        if True == options.verbose:
            out.write(cmd+'\n')
    out.write('syscall '+cmd+'\n')
    out.flush()
    err.flush()
    #for arg in args:
    #    out.write(arg)
    #    out.write(' ')
    #out.write('\n')
    RC=0
    p = subprocess.Popen(cmd, universal_newlines=True, stdout=subprocess.PIPE,stderr=subprocess.STDOUT,shell=True)
    #out.write(p.communicate()[0])
    output = p.communicate()[0]
    RC=int(p.returncode)
    if RC != 0:
        out.write(output)
        err.write('Systemcall with command '+cmd+' returned '+str(RC)+'\n')
        out.flush()
        err.flush()
        if True == ExitOnError:
            os._exit(RC)
    return RC, output

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

def CheckForCMakeError(ConsoleText):
    if 'CMake Error' in ConsoleText:
        return True
    else:
        return False
    

CHECKS()
