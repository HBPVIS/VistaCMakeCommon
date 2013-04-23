#!/bin/bash
# $Id$
## this is an explaining comment
#this is a commented codeline
## debus is a deployment and building script, right now only an alpha version
## please do not use yet
## version early alpha
## changelog:
#
##  TODOS
# make it more general. not its only for CBS
# make more dau checks


basedir=/home/av006de/dev/

a_projects=( VistaCoreLibs VistaFlowLib VflTextRendering VflPieMenus VflGpuParticles CBS_BrainVolume)
a_revisions=(trunk trunk trunk trunk trunk trunk)
a_svnpath=(
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/Vista/trunk/VistaCoreLibs/
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/VistaFlowLib/trunk/
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/VflModules/VflTextRendering/trunk/
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/VflModules/VflPieMenus/trunk/
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/VflModules/VflGpuParticles/trunk/
https://svn.rwth-aachen.de/repos/vrgroup-svn/projects/VflPrototypes/CBS_BrainVolume/trunk/BrainVolRen/
)

_re=0

project=0
revision=0
svnpath=0



# call check function returncode
function check()
{	
	rc=$2
	echo $1 " returned " $rc " for project " $project
	if [[ $rc != 0 ]] ; then
   		exit $rc
	fi
}

function svnco() 
{
	if [ ! -d $project.$revision ];
	then
    	svn co $svnpath $project.$revision --password svn$PW >> /dev/null
	check "svnco" $?
	mkdir -p $project.$revision/build
	mkdir -p $project.$revision/buildD
	_rc="DONE"
	else
		echo "NO svn co for " $project
		_rc="NOTHING_DONE"
	fi
	if [ ! -d $project.$revision/build ];
	then
		mkdir -p $project.$revision/build
	fi
	if [ ! -d $project.$revision/buildD ];
	then
		mkdir -p $project.$revision/buildD
	fi
	
}


function svnup()
{	
	echo "svnup for " $project
	cd $basedir$project.$revision
	svn up --password svn$PW
	check "svnup" $?
}

function rebuilt()
{
	if [ -d $project.$revision/build ];
	then
		rm -rf $project.$revision/build/*
	fi
	if [ -d $project.$revision/buildD ];
	then
		rm -rf $project.$revision/buildD/*
	fi
}

function fcmake()
{
	cd $basedir$project.$revision/buildD
	cmake ../ -DCMAKE_BUILD_TYPE=Debug >> /dev/null
	check "fcmake_D" $?
	cd $basedir$project.$revision/build
	cmake ../ -DCMAKE_BUILD_TYPE=Release >> /dev/null
	check "fcmake" $?
}

function makej()
{
	cd $basedir$project.$revision/buildD
	make -j >> /dev/null
	check "makej_D" $?
	cd $basedir$project.$revision/build
	make -j >> /dev/null
	check "makej" $?
}

function usage()
{
	echo "right now only rebuilt is implemented"
}

if [ ! -e initEnv.sh ];
then
	echo "expecting initEnv.sh file which defines VISTA_CMAKE_COMMON and VISTA_EXTERNAL_LIBS"
	exit -1
else
source initEnv.sh
fi

## we keep some passwords in memory for the runtime of the script
read -s -p "please enter av006de password " PW
echo "\n"

i=0
len=${#a_projects[*]} #Num elements in array
while [ $i -lt $len ]; do
	cd $basedir
	project=0
	revision=0
	svnpath=0
	project=${a_projects[$i]}
	revision=${a_revisions[$i]}
	svnpath=${a_svnpath[$i]}

	if [[ $1 == "rebuilt" ]] ; then
   		rebuilt
	else 
		usage
	fi

	svnco
	if [[ $_rc == "DONE" ]] ; then
		svnup
	fi
	fcmake
	makej
	let i++
done

