#!/bin/bash
set -o errexit
set -o xtrace
set -o nounset


# script to convert MFP project into a BB10 webworks project.
# Run from the root of the $MFP_PROJECT/apps/$APP_NAME dir	
# Ensure you have run mfp build to copy the resouces into web dirs.
#
#
# https://www.ibm.com/developerworks/community/blogs/worklight/entry/worklight_blackberry10_project_with_webworks_sdk_2_0?lang=en

export WORKSPACE=`pwd`
export LOCAL_ANT="/usr/local/bin/ant"
export WEB_WORKS_PROJ=${1:-"bb10webworks"}

updateBB1MFPProject()
{
	cd $WORKSPACE/blackberry10/native
	$LOCAL_ANT qnx "upgrade-webworks-SDK-2.x"
}

createWebWorksProject()
{
	cd $WORKSPACE
	webworks create $WEB_WORKS_PROJ
	rm -r $WEB_WORKS_PROJ/www/*
	cp -r blackberry10/native/www/webresources $WEB_WORKS_PROJ/www
	cp blackberry10/native/www/*.png  $WEB_WORKS_PROJ/www
	cp blackberry10/native/www/config.xml $WEB_WORKS_PROJ
}

addDeviceGlobalPlugins()
{
	cd $WORKSPACE/$WEB_WORKS_PROJ
	webworks plugin add org.apache.cordova.device
	webworks plugin add org.apache.cordova.globalization
}

# do in this order
updateBB1MFPProject

createWebWorksProject

addDeviceGlobalPlugins

cd $WORKSPACE
