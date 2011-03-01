# $Id$
import os, sys

localSourceFileName = "_SourceFiles.cmake"
backupExtension = ".BAK"
excludeDirs = [ "cvs", ".svn", "build", "built", "cmake" ]

def Backup( fileName ):
	if os.path.exists( fileName ):
		iCount = 1
		backupFile = fileName + backupExtension
		while os.path.exists( backupFile ):
			iCount = iCount + 1
			backupFile = fileName + backupExtension + str(iCount)
		os.rename( fileName, backupFile )
		print( "Backing up " + fileName )

def GetSourceFilesAndDirs( path ):
	files = []
	dirs = []
	for item in os.listdir( path ):
		if( os.path.isdir( os.path.join( path, item ) ) ):
			dirs.append( item )
		else:
			ext = os.path.splitext( item )[1]
			if ext==".cpp" or ext==".h":
				files.append( item )
	files.sort()
	dirs.sort()
	return files, dirs
	
def GenSourceListForSubdir( dirName, parentDir, relDir = "", relSourceGroup = "" ):
	if( dirName in excludeDirs ):
		return False
	sourceSubDirs = []
	fullDirName = os.path.join( parentDir, dirName )	
	print( "GenSourceListForSubdir( " + fullDirName + ")" )
	
	if( relDir == "" ):
		relDir = dirName
	else:
		relDir = relDir + "/" + dirName
	localSourceGroup = dirName
	if( dirName == "" or dirName == "src" or dirName == "Src" or dirName == "source" or dirName == "Source" ):
		localSourceGroup = "Source Files"
	if( relSourceGroup == "" ):
		relSourceGroup = localSourceGroup
	else:
		relSourceGroup = relSourceGroup + "\\\\" + localSourceGroup
		
	if( relDir == "" ):
		relDir = "."

	sourceFiles, subDirs = GetSourceFilesAndDirs( fullDirName )
	
	# recursively generate sourcefiles for subdirs
	for dir in subDirs:
		if GenSourceListForSubdir( dir, fullDirName, relDir, relSourceGroup ):
			sourceSubDirs.append( dir )
			
	if( len( sourceSubDirs ) == 0 and len( sourceFiles ) == 0 ):
		print( "found no sources" )
		return False # no source directory
	
	fileName = os.path.join( fullDirName, "_SourceFiles.cmake" )
	# make sure we dont overwrite other stuff: create backups
	Backup( fileName )	
	
	fileHandle = open( fileName, "w" )
		
	# write source files info
	fileHandle.write( "set( RelativeDir \"" + relDir + "\" )\n" )
	fileHandle.write( "set( LocalSourceGroup \"" + relSourceGroup + "\" )\n" )
	if( len( sourceSubDirs ) >  0 ):
		fileHandle.write( "set( SubDirs " )
		for dir in sourceSubDirs:
			fileHandle.write( dir + " " )
		fileHandle.write( ")\n" )
	fileHandle.write( "\n" )
	if( len( sourceFiles ) > 0 ):
		fileHandle.write( "set( DirFiles\n" )
		for file in sourceFiles:
			fileHandle.write( "\t" + file + "\n" )
		fileHandle.write( ")\n" )
		fileHandle.write( "\n" )
		fileHandle.write( "set( LocalSourceGroupFiles "" )\n" )
		fileHandle.write( "foreach( File ${DirFiles} )\n" )
		fileHandle.write( "\tlist( APPEND LocalSourceGroupFiles \"${RelativeDir}/${File}\" )\n" )
		fileHandle.write( "\tlist( APPEND ProjectSources \"${RelativeDir}/${File}\" )\n" )
		fileHandle.write( "endforeach()\n" )
		fileHandle.write( "source_group( \"${LocalSourceGroup}\" FILES ${LocalSourceGroupFiles} )\n" )		
		fileHandle.write( "\n" )
	if( len( sourceSubDirs ) >  0 ):
		fileHandle.write( "set( SubDirFiles \"\" )\n" )
		fileHandle.write( "foreach( Dir ${SubDirs} )\n" )
		fileHandle.write( "\tlist( APPEND SubDirFiles \"${RelativeDir}/${Dir}/_SourceFiles.cmake\" )\n" )
		fileHandle.write( "endforeach()\n" )
		fileHandle.write( "\n" )
		fileHandle.write( "foreach( SubDirFile ${SubDirFiles} )\n" )
		fileHandle.write( "\tinclude( ${SubDirFile} )\n" )
		fileHandle.write( "endforeach()\n" )
		fileHandle.write( "\n" )
		
	return True
	
def GenSourceLists( startDir ):
	sourceSubDirs = [] # should usually be just src, but oh well
	sourceFiles, subDirs = GetSourceFilesAndDirs( startDir )

	#check if there are toplevel sourcefiles
	if( len( sourceFiles ) > 0 ):
		GenSourceListForSubdir( "", startDir )
		sourceSubDirs.append( "." )
	else:
		for dir in subDirs:
				isSourceDir = GenSourceListForSubdir( dir, startDir )
				if isSourceDir:
					sourceSubDirs.append( dir )

	return sourceSubDirs
	

def GenCMakeForLib( startDir, projectName ):
	sourceSubDirs = GenSourceLists( startDir )
					
	listsFile = os.path.join( startDir, "CMakeLists.txt" )
	print( listsFile )
	Backup( listsFile )
	
	fileHandle = open( listsFile, "w" )
	
	fileHandle.write( "cmake_minimum_required( VERSION 2.6 )\n" )
	fileHandle.write( "project( " + projectName + " )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "list( APPEND CMAKE_MODULE_PATH \"$ENV{VISTA_CMAKE_COMMON}\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "include( VistaLibCommon )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "if( WIN32 )\n" )
	fileHandle.write( "\tadd_definitions( -D" + str.upper( projectName ) + "_EXPORTS )\n" )
	fileHandle.write( "endif( WIN32 )\n" )
	fileHandle.write( "\n" )
	for dir in sourceSubDirs:
		fileHandle.write( "include( \"" + dir + "/" + localSourceFileName + "\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "add_library( " + projectName + " ${ProjectSources} )\n" )
	fileHandle.write( "target_link_libraries( " + projectName + "\n" )
	fileHandle.write( "\t${LIBRARIES}\n" )
	fileHandle.write( ")\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "install( TARGETS " + projectName + "\n" )
	fileHandle.write( "\tLIBRARY DESTINATION lib\n" )
	fileHandle.write( "\tARCHIVE DESTINATION lib\n" )	
	fileHandle.write( "\tRUNTIME DESTINATION lib )\n" )
	fileHandle.write( "install( DIRECTORY" )	
	for dir in sourceSubDirs:
		fileHandle.write( "\t" + dir )	
	fileHandle.write( "\n" )	
	fileHandle.write( "\tDESTINATION include/" + projectName + "\n" )	
	fileHandle.write( "\tFILES_MATCHING PATTERN \"*.h\"\n" )	
	fileHandle.write( "\tPATTERN \"build\" EXCLUDE\n" )	
	fileHandle.write( "\tPATTERN \".svn\" EXCLUDE\n" )	
	fileHandle.write( "\tPATTERN \"CMakeFiles\" EXCLUDE )\n" )
	fileHandle.write( "\n" )
	

def GenCMakeForApp( startDir, projectName ):
	sourceSubDirs = GenSourceLists( startDir )
					
	listsFile = os.path.join( startDir, "CMakeLists.txt" )
	print( listsFile )
	Backup( listsFile )
	
	fileHandle = open( listsFile, "w" )
	
	fileHandle.write( "cmake_minimum_required( VERSION 2.6 )\n" )
	fileHandle.write( "project( " + projectName + " )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "list( APPEND CMAKE_MODULE_PATH \"$ENV{VISTA_CMAKE_COMMON}\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "include( VistaAppCommon )\n" )
	fileHandle.write( "\n" )
	for dir in sourceSubDirs:
		fileHandle.write( "include( \"" + dir + "/" + localSourceFileName + "\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "#EXEC_NAME Is set inside VistaAppCommon to include the D for debug builds\n" )
	fileHandle.write( "add_executable( ${EXEC_NAME} ${ProjectSources} )\n" )
	fileHandle.write( "target_link_libraries( ${EXEC_NAME}\n" )
	fileHandle.write( "\t${LIBRARIES}\n" )
	fileHandle.write( ")\n" )
	fileHandle.write( "\n" )
	




if len( sys.argv ) >= 2 and sys.argv[1] != "-h" and sys.argv[1] != "--help" :
	startDir = sys.argv[1]
	argcount = 1
	buildAsApp = True
	onlyBuildSourceLists = False
	projectName = os.path.basename( startDir )
	while( argcount < len( sys.argv ) ):
		arg = sys.argv[argcount]
		if( arg == "-app" or arg == "-application" ):
			buildAsApp = True
		elif( arg == "-lib" or arg == "-library" ):
			buildAsApp = False
		elif( arg == "-source" or arg == "-src" ):
			onlyBuildSourceLists = True
		elif( arg == "-name" ):
			argcount = argcount + 1
			projectName = sys.argv[argcount]
		else:
			print( "unknown parameter: " + arg )
		argcount = argcount + 1
	
	if onlyBuildSourceLists:
		GenSourceLists( startDir )
	else:
		if buildAsApp:
			GenCMakeForApp( startDir, projectName )
		else:
			GenCMakeForLib( startDir, projectName )	
else:
	print( "Usage:" )
	print( "GenCakeList MainDir [Options]" )
	print( "Options" )
	print( "  -app | -application      : the project will be configured as an application [default]" )
	print( "  -lib | -library          : the project will be configured as a library " )
	print( "  -src | -source           : if set, only the " + localSourceFileName + "-files will be updated" )
	print( "  - name                   : specify name of the project. if omitted, the directory name will be used instead" )

print("note: underlines in foldernames will cause errors!")
