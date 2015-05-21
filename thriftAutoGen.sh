#!/bin/bash

# Author: Le Thai Son
# A short shell script to:
# + Automatically generate native language code from thrift IDL file
# + Update the newly generated code to the the provided project
# At the moment (Mon, May 21 2015 12:52PM this works best with 
# desiredLanguage=Java || Cpp, IDE = Netbeans)

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
	TEMPFILE="$pjDirPath/nbproject/thrift-autogen-temp.xml"
	# Check if the include element has already existed
	if grep -q $CONTENT $CONFIGFILE
	then
		# If already existed, no need to insert it to the config file
    	echo "> gen-cpp folder has already been included"
	else
		# Else, insert the element to the config file	
    	echo "> gen-cpp folder has not been included yet, attempting to include it to the project"
    	# Add new element to XML file
    	C=$(echo $CONTENT | sed 's/\//\\\//g')
    	# Write the new content to a temporary file
		sed "/<\/incDir>/ s/.*/${C}\n&/" $CONFIGFILE > $TEMPFILE
		# Replace the current configurations file with the temp file
		mv -f $TEMPFILE $CONFIGFILE
	fi
}

desiredLanguage=$1
thriftFileFullname=$2
projectDirPath=$3

# Use thrift to generate native language code
thrift -r --gen $desiredLanguage $thriftFileFullname

# Get the thriftFileName from the thriftFileFullname
# Because it thriftFileName is usually the name of the newly created folder
IFS='.' read -r thriftFileName thriftFileExtension <<< $thriftFileFullname

# Choose the proper way for handling each language
case $desiredLanguage in
    "java" )
		echo "> language = java"
		# Simply copy & overwrite the newly generated java code to the Netbeans project folder
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
		# Other types of language, not implemented yet
		# Attempt to copy the newly generated code to the project folder
		cp -avr gen-$desiredLanguage $projectDirPath
esac

echo "DONE !"
