# $Id$
import os, sys, re

localSourceFileName = "_SourceFiles.cmake"
backupExtension = ".BAK"
excludeDirs = [ "cvs", ".svn", "build", "built", "cmake" ]
sourceExtensions = [ ".c", ".cpp", ".h" ]

findSetListRegEx = re.compile( r'set\(\s*(\S+)\s*\Z' )
findSetVarRegEx = re.compile( r'set\(\s*(\S+)\s+(\S+)\s*\)' )
findForEachRegEx = re.compile( r'foreach\(\s+File\s+\$\{(\w+)\}' )
findSourceGroupRegEx = re.compile( r'source_group\(\s*"*\$\{(\w+)\}"*\s*FILES.*\)' )


def CheckIsSourceFile( entry ):
	name, ext = os.path.splitext( entry )
	if ext in sourceExtensions:
		return True
	else:
		return False

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
			name, ext = os.path.splitext( item )
			if ext in sourceExtensions:
				files.append( item )
	files.sort()
	dirs.sort()
	return files, dirs
	
def GenSourceListForSubdir( dirName, parentDir, renew, relDir = "", relSourceGroup = "" ):
	if( dirName in excludeDirs ):
		return False
	sourceSubDirs = []
	fullDirName = os.path.join( parentDir, dirName )	
	
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
		if GenSourceListForSubdir( dir, fullDirName, renew, relDir, relSourceGroup ):
			sourceSubDirs.append( dir )			
			
	if( len( sourceSubDirs ) == 0 and len( sourceFiles ) == 0 ):
		return False # no source directory
	
	fileName = os.path.join( fullDirName, "_SourceFiles.cmake" )
	
	if( os.path.exists( fileName ) and not renew ):
		# the file already exists, we just need to update it
		#first,we just read the file
		fileHandle = open( fileName, "r" )
		origLines = fileHandle.readlines()
		fileHandle.close()		
		
		SourceFileGroups = {}
		existingSourceFiles = []
		SourceFileGroupsNames = {}
		dictVariables = {}
				
		inSet = False
		currentSet = ""
		setEntries = []
		
		#first, we parse the file once and check for all source files already in there
		for line in origLines:
			line = line.strip()
			
			if inSet:
				# check if the set closes
				if line == ")":
					inSet = False
					if len( setEntries ) > 0:
						SourceFileGroups[currentSet] = setEntries
				else:
					if CheckIsSourceFile( line ):
						setEntries.append( line )
						existingSourceFiles.append( line )							
			else:
				result = re.match( findSetListRegEx, line )
				if result:
					inSet = True
					currentSet = result.group(1)
					setEntries = []
				else:
					result = re.match( findSetVarRegEx, line )
					if result:
						dictVariables[ result.group(1) ] = result.group(2)
					else:
						# we also need to check if it defines a sourcegroup's name
						# therefore, we first observe all foreach() loops to find the name
						result = re.match( findForEachRegEx, line )
						if result:
							currentSet = result.group(1)
						else:
							result = re.match( findSourceGroupRegEx, line )
							if result:
								SourceFileGroupsNames[currentSet] = result.group(1)
					
		#now, we check which files are not in the file yet
		missingFiles = []
		for file in sourceFiles:
			if( not file in existingSourceFiles ):
				missingFiles.append( file )
			else:
				existingSourceFiles.remove( file )
						
		# check if anything changed at all
		if( len( missingFiles ) == 0 and len( existingSourceFiles ) == 0 ):
			return True
				
		#now, files in missingFiles need to be added to the default source group
		if( len( missingFiles ) > 0 ):
			if not "DirFiles" in SourceFileGroups:
				SourceFileGroups["DirFiles"] = []				
			for file in missingFiles:
				SourceFileGroups["DirFiles"].append( file )
			SourceFileGroups["DirFiles"].sort()
			
		#we also need to remove files that don't exist anymore
		for file in existingSourceFiles:
			for group in SourceFileGroups.values():
				if file in group:
					group.remove( file )
				
		# additionally, we default sourcegroups with no prior name
		for name in SourceFileGroups.keys():
			if not name in SourceFileGroupsNames:
				SourceFileGroupsNames[name] = name + "_SourceGroup"
			
		# we ensure that the SourceFileGroupsNames[name] variable exists, by initializing
		# non-existing ones to RelativeSourceGroup
		for name, entry in SourceFileGroupsNames.items():
			if not entry in dictVariables:
				dictVariables[entry] = "\"RelativeSourceGroup\""
		
		# make sure we dont break anything permanently: backup
		Backup( fileName )
					
		# no file there yet, just create a new one		
		fileHandle = open( fileName, "w" )
			
		# write source files info
		fileHandle.write( "set( RelativeDir \"" + relDir + "\" )\n" )
		fileHandle.write( "set( RelativeSourceGroup \"" + relSourceGroup + "\" )" )
		fileHandle.write( "\n" )
		if( len( sourceSubDirs ) >  0 ):
			fileHandle.write( "set( SubDirs " )
			for dir in sourceSubDirs:
				fileHandle.write( dir + " " )
			fileHandle.write( ")\n" )
		fileHandle.write( "\n" )
		for name, list in SourceFileGroups.items():
			fileHandle.write( "set( " + name + "\n" )
			for file in list:
				fileHandle.write( "\t" + file + "\n" )
			fileHandle.write( ")\n" )
			fileHandle.write( "set( " + SourceFileGroupsNames[name] + " " + dictVariables[SourceFileGroupsNames[name]] + " )\n" )
			fileHandle.write( "\n" )
		for name, list in SourceFileGroups.items():
			fileHandle.write( "set( LocalSourceGroupFiles "" )\n" )
			fileHandle.write( "foreach( File ${" + name + "} )\n" )
			fileHandle.write( "\tlist( APPEND LocalSourceGroupFiles \"${RelativeDir}/${File}\" )\n" )
			fileHandle.write( "\tlist( APPEND ProjectSources \"${RelativeDir}/${File}\" )\n" )
			fileHandle.write( "endforeach()\n" )
			fileHandle.write( "source_group( ${" + SourceFileGroupsNames[name] + "} FILES ${LocalSourceGroupFiles} )\n" )
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
		
		
	else:
		# make sure we dont break anything permanently: backup
		Backup( fileName )
		
		# no file there yet, or we should overwrite it -> just create a new one		
		fileHandle = open( fileName, "w" )
			
		# write source files info
		fileHandle.write( "set( RelativeDir \"" + relDir + "\" )\n" )
		fileHandle.write( "set( RelativeSourceGroup \"" + relSourceGroup + "\" )" )
		fileHandle.write( "\n" )
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
			fileHandle.write( "set( DirFiles_SourceGroup \"${RelativeSourceGroup}\" )\n" )
			fileHandle.write( "\n" )
			fileHandle.write( "set( LocalSourceGroupFiles "" )\n" )
			fileHandle.write( "foreach( File ${DirFiles} )\n" )
			fileHandle.write( "\tlist( APPEND LocalSourceGroupFiles \"${RelativeDir}/${File}\" )\n" )
			fileHandle.write( "\tlist( APPEND ProjectSources \"${RelativeDir}/${File}\" )\n" )
			fileHandle.write( "endforeach()\n" )
			fileHandle.write( "source_group( ${DirFiles_SourceGroup} FILES ${LocalSourceGroupFiles} )\n" )		
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

	
def GenSourceLists( startDir, renew ):
	sourceSubDirs = [] # should usually be just src, but oh well
	sourceFiles, subDirs = GetSourceFilesAndDirs( startDir )

	#check if there are toplevel sourcefiles
	if( len( sourceFiles ) > 0 ):
		GenSourceListForSubdir( "", startDir, renew )
		sourceSubDirs.append( "." )
	else:
		for dir in subDirs:
				isSourceDir = GenSourceListForSubdir( dir, startDir, renew )
				if isSourceDir:
					sourceSubDirs.append( dir )

	return sourceSubDirs
	

def GenCMakeForLib( startDir, projectName, renew, linkVistaCoreLibs ):
	sourceSubDirs = GenSourceLists( startDir, renew )
					
	listsFile = os.path.join( startDir, "CMakeLists.txt" )
	Backup( listsFile )
	
	fileHandle = open( listsFile, "w" )
	
	fileHandle.write( "cmake_minimum_required( VERSION 2.6 )\n" )
	fileHandle.write( "project( " + projectName + " )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "list( APPEND CMAKE_MODULE_PATH \"$ENV{VISTA_CMAKE_COMMON}\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "include( VistaLibCommon )\n" )
	fileHandle.write( "\n" )
	if linkVistaCoreLibs:
		fileHandle.write( "find_package_versioned( VistaCoreLibs \"SETI\" )\n" )
		fileHandle.write( "vista_use_CoreLibs()\n" )
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
	if linkVistaCoreLibs:		
		fileHandle.write( "	\t${VISTACORELIBS_LIBRARIES}\n" )	
	fileHandle.write( ")\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "vista_install( " + projectName + " )\n" )
	fileHandle.write( "\n" )
	

def GenCMakeForApp( startDir, projectName, renew, linkVistaCoreLibs ):
	sourceSubDirs = GenSourceLists( startDir, renew )
					
	listsFile = os.path.join( startDir, "CMakeLists.txt" )
	Backup( listsFile )
	
	fileHandle = open( listsFile, "w" )
	
	fileHandle.write( "cmake_minimum_required( VERSION 2.6 )\n" )
	fileHandle.write( "project( " + projectName + " )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "list( APPEND CMAKE_MODULE_PATH \"$ENV{VISTA_CMAKE_COMMON}\" )\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "include( VistaAppCommon )\n" )
	fileHandle.write( "\n" )
	if linkVistaCoreLibs:
		fileHandle.write( "find_package_versioned( VistaCoreLibs \"SETI\" )\n" )
		fileHandle.write( "vista_use_CoreLibs()\n" )
		fileHandle.write( "\n" )
	for dir in sourceSubDirs:
		fileHandle.write( "include( \"" + dir + "/" + localSourceFileName + "\" )\n" )
	fileHandle.write( "\n" )	
	fileHandle.write( "add_executable( " + projectName + " ${ProjectSources} )\n" )
	fileHandle.write( "target_link_libraries( " + projectName + "\n" )
	if linkVistaCoreLibs:		
		fileHandle.write( "	\t${VISTACORELIBS_LIBRARIES}\n" )	
	fileHandle.write( ")\n" )
	fileHandle.write( "\n" )
	fileHandle.write( "vista_configure_app( " + projectName + " )\n" )
	fileHandle.write( "vista_set_app_outdir( " + projectName + " ${CMAKE_CURRENT_SOURCE_DIR} )\n" )
	fileHandle.write( "\n" )
	




if len( sys.argv ) >= 2 and sys.argv[1] != "-h" and sys.argv[1] != "--help" :
	startDir = sys.argv[1]
	argcount = 2
	buildAsApp = True
	onlyBuildSourceLists = False
	projectName = os.path.basename( startDir )
	renew = False
	linkVistaCoreLibs = False	
	while( argcount < len( sys.argv ) ):
		arg = sys.argv[argcount]
		if( arg == "-app" or arg == "-application" ):
			buildAsApp = True
		elif( arg == "-lib" or arg == "-library" ):
			buildAsApp = False
		elif( arg == "-renew" ):
			renew = True
			buildAsApp = False
		elif( arg == "-linkcorelibs" ):
			linkVistaCoreLibs = True
		elif( arg == "-source" or arg == "-src" ):
			onlyBuildSourceLists = True
		elif( arg == "-name" ):
			argcount = argcount + 1
			projectName = sys.argv[argcount]		
		else:
			print( "unknown parameter: " + arg )
		argcount = argcount + 1
	
	if onlyBuildSourceLists:
		GenSourceLists( startDir, renew )
	else:
		if buildAsApp:
			GenCMakeForApp( startDir, projectName, renew, linkVistaCoreLibs )
		else:
			GenCMakeForLib( startDir, projectName, renew, linkVistaCoreLibs )	
else:
	print( "Usage:" )
	print( "GenCakeList MainDir [Options]" )
	print( "Options" )
	print( "  -app                     : the project will be configured as an application" )	
	print( "  -lib                     : the project will be configured as a library " )
	print( "  -src                     : if set, only the " + localSourceFileName + "-files will be updated  [default]" )
	print( "  -name                    : specify name of the project. if omitted, the directory name will be used instead" )
	print( "  -renew                   : if set, no file will be updated, but instead all files are created completely new" )
	print( "  -linkcorelibs            : the project will be configured to link the VistaCoreLibs (in their latest release by default)" )

print("note: underlines in foldernames will cause errors!")
