#!/bin/bash

set -o errexit

LIBERTY_TARGET=${1:-"/Users/donal/Documents/LibertyProfile/"} # should point to where you want Liberty to go
RECENT_WAR=${2:-"/Users/donal/Documents/mobfirst/WorklightProj/bin/WorklightProj.war"} # points to any WAR file
LIBERTY_SOURCE=$3 # should point to the file wlp-developers-runtime-8.5.5.1.jar
WORKLIGHT_INSTALL_DIR=${4:-"/Applications/IBM/MobileFirst_Platform_Server"}
SERVER_NAME=${5:-"mfps63"}
CONTEXT_ROOT=${6:-"/worklight"}
DERBY_ADMIN_DB=${7:-"WLADMIN"}
WORKLIGHT_DB=${8:-"WORKLIGHT"}
WORKLIGHT_REP=${9:-"WLREPORTS"}
CONSOLE_WAR="$WORKLIGHT_INSTALL_DIR/worklightconsole.war"
SERVICE_WAR="$WORKLIGHT_INSTALL_DIR/worklightadmin.war"
DERBY_DIR="/private/var/ibm/MobileFirst_Platform_Server/derby"
#DERBY_DIR="/Users/donal/Documents/LibertyProfile"

MY_PATH=$(dirname $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`)
ANT_TASK=$MY_PATH/configure-liberty-derby.xml

libertyMaker()
{
	mkdir -p $1
	cd $1
	x§$LIBERTY_SOURCE
	chmod +x $LIBERTY_TARGET/wlp/bin/server
	$LIBERTY_TARGET/wlp/bin/server create $SERVER_NAME 
}
 
installMFS()
{
	ant -f $ANT_TASK -Dworklight.server.install.dir=${WORKLIGHT_INSTALL_DIR} \
			-Dworklight.contextroot=$CONTEXT_ROOT \
			-Dworklight.project.war.file=$RECENT_WAR \
			-Dappserver.was.installdir=$LIBERTY_TARGET \
			-Dappserver.was85liberty.serverInstance=$SERVER_NAME \
			-Ddatabase.derby.datadir=$DERBY_DIR \
			-Ddatabase.derby.wladmin.dbname=$DERBY_ADMIN_DB \
			-Ddatabase.derby.worklight.dbname=$WORKLIGHT_DB \
			-Ddatabase.derby.worklightreports.dbname=$WORKLIGHT_REP \
			-Dwladmin.console.war=$CONSOLE_WAR \
			-Dwladmin.service.war=$SERVICE_WAR \
			databases admdatabases install adminstall 

}

hackyWorkaround()
{
	please chown -R donal:wheel $DERBY_DIR/$DERBY_ADMIN_DB

}

libStart()
{	
	echo "start $SERVER_NAME"
	$LIBERTY_TARGET/wlp/bin/server start $SERVER_NAME
	#/Users/donal/Documents/LibertyProfile/wlp/bin/server stop
}

installMFS
libStart

