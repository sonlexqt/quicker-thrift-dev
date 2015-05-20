#!/bin/bash

# Author: Le Thai Son
# A short shell script to:
# + Automatically generate native language code from thrift IDL file
# + Update the newly generated code the the provided project
# At the moment (Mon, May 18 2015 4:40PM this works best with desiredLanguage=Java || Cpp)

# Arguments:
# $1 : name of the desired language
# $2 : path to the thrift IDL file
# $3 : path to the project directory which will also be the destination of 
# the newly generated code (works best with NetBeans)

function editConfigXMLFile()
{
	language=$1
	pjDirPath=$2
	CONTENT="<pElem>gen-$language</pElem>"
	CONFIGFILE="$pjDirPath/nbproject/configurations.xml"
	# Check if the element has already existed
	if grep -q $CONTENT $CONFIGFILE
	then
    	echo "> gen-cpp folder has already been included"
	else
    	echo "> gen-cpp folder not has been included yet, attempt to include it to the project"
    	# Add new element to XML file
    	C=$(echo $CONTENT | sed 's/\//\\\//g')
		sed "/<\/incDir>/ s/.*/${C}\n&/" CONFIGFILE #TODO cannot add new element to XML file
	fi
}

desiredLanguage=$1
thriftFileFullname=$2
projectDirPath=$3

thrift -r --gen $desiredLanguage $thriftFileFullname

# Get the thriftFileName from the thriftFileFullname
# Because it thriftFileName is usually the name of the newly created folder
IFS='.' read -r thriftFileName thriftFileExtension <<< $thriftFileFullname

case $desiredLanguage in
    "java" )
		echo "> language = java"
		# Attempt to copy the newly generated java code to the Netbeans project folder
		cp -avr gen-$desiredLanguage/$thriftFileName $projectDirPath/src
        ;;
    "cpp" )
		echo "> language = cpp"
		# Attempt to copy the newly generated cpp code in 'gen-cpp' directory 
		# to the Netbeans project folder
		cp -avr gen-$desiredLanguage $projectDirPath
		# And also edit the Netbeans project configurations.xml file
		editConfigXMLFile 'cpp' $projectDirPath
        ;;
    * ) echo "> language = $desiredLanguage"
		# Attempt to copy the newly generated code to the project folder
		cp -avr gen-$desiredLanguage $projectDirPath
esac

echo "DONE !"
