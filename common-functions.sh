#!/bin/bash -v
set -o errexit


# Note :: absolute dir needed for derby creation
export USER="/Users/donal"

# should point to where you want Liberty to go 
# OR where the wlp directory is
export LIBERTY_TARGET="$USER/Documents/LibertyProfile" 
# should point to the file wlp-developers-runtime-8.5.5.1.jar
# if unpacking is needed uncomment unpackLibertyJar below
export LIBERTY_SOURCE=$LIBERTY_TARGET 

# note the configure-liberty-derby.xml file adds the /WorklightServer dir to this export 
export WORKLIGHT_INSTALL_DIR="/Applications/IBM/MobileFirst_Platform_Server"

export DERBY_ADMIN_DB="WLADMIN"
export WORKLIGHT_DB="WORKLIGHT"
export WORKLIGHT_REP="WLREPORTS"
export CONSOLE_WAR="$WORKLIGHT_INSTALL_DIR/worklightconsole.war"
export SERVICE_WAR="$WORKLIGHT_INSTALL_DIR/worklightadmin.war"
export DERBY_DIR="$LIBERTY_TARGET/derby"

export MY_PATH=$(dirname $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`)
export ANT_TASK=$MY_PATH/configure-liberty-derby.xml


# setEnvironment - idea here is you would have one of these for each MFP Enviornment you have eg DEV, TEST, UAT, SAGING, PROD
setEnvironment() {

    export RECENT_WAR="$USER/Documents/mobfirst/devworks/devworks/bin/devworks.war"
    export MFP_PORT="9080"
    export HOSTNAME="localhost"
    export PROJECT_NAME="devworks"
    export SERVER_NAME="mfp-devworks"
    export MFP_CONTEXT_ROOT="/$PROJECT_NAME"
    export MFP_SERVER_URL="http://$HOSTNAME:$MFP_PORT$MFP_CONTEXT_ROOT"
    export MFP_EXTERNAL_SERVER_URL=$MFP_SERVER_URL # configured as needed
    export MFP_USERNAME="admin"
    export MFP_PASSWORD="admin"
    export ADMIN_CONTEXT="/worklightadmin"
    export ADMIN_URL="http://$HOSTNAME:$MFP_PORT$ADMIN_CONTEXT"   
}




buildAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} build-Adapters \
        -Dbasedir="${MFP_PROJECT}" \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dpath.to.project=${MFP_PROJECT} \
        -DProjectName=${PROJECT_NAME} 
}

buildApps()
{
    ${LOCAL_ANT} -f ${ANTFILE} build-Apps \
        -Dbasedir="${MFP_PROJECT}" \
        -Dworklight.server.host=${MFP_EXTERNAL_SERVER_URL} \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.jars.dir=${ANT_DIR} \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 
}

deployAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Adapters \
        -Dbasedir="${MFP_PROJECT}" \
        -Dworklight.username="${MFP_USERNAME}" \
        -Dworklight.password="${MFP_PASSWORD}" \
        -Dworklight.admin.url="${ADMIN_URL}" \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.jars.dir=${ANT_DIR} \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 

}

deployApps()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Apps \
        -Dbasedir="${MFP_PROJECT}" \
        -Dworklight.username="${MFP_USERNAME}" \
        -Dworklight.password="${MFP_PASSWORD}" \
        -Dworklight.admin.url="${ADMIN_URL}" \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.jars.dir=${ANT_DIR} \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 
}

buildWar()
{	
    ${LOCAL_ANT} -f ${ANTFILE} build-WAR \
        -Dbasedir="${MFP_PROJECT}" \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dpath.to.project=${MFP_PROJECT} \
        -DProjectName=${PROJECT_NAME} 
}

unpackLibertyJar()
{
    mkdir -p $1
    cd $1
    jar xvf $LIBERTY_SOURCE 
    chmod +x $LIBERTY_TARGET/wlp/bin/server
}

createLibertyServer()
{
    echo "creating Liberty server $SERVER_NAME in $LIBERTY_TARGET"
    $LIBERTY_TARGET/wlp/bin/server create $SERVER_NAME 
}

deleteLibertyServer()
{
    echo "deleting Liberty server $SERVER_NAME in $LIBERTY_TARGET"
    rm -r $LIBERTY_TARGET/wlp/usr/servers/$SERVER_NAME  && rc=$? || rc=$?
    echo "Error code was $rc"
    # grab error code incase server does not exist - won't stop script execution
}

deleteDerbyDb()
{
    echo "deleting derby db at $DERBY_DIR"
    rm -r $DERBY_DIR  && rc=$? || rc=$?
    echo "Error code was $rc"
}

install()
{
    ant -f $ANT_TASK -Dworklight.server.install.dir=${WORKLIGHT_INSTALL_DIR} \
            -Dworklight.contextroot=$MFP_CONTEXT_ROOT \
            -Dworklight.project.war.file=$RECENT_WAR \
            -Dappserver.was.installdir=$LIBERTY_TARGET \
            -Dappserver.was85liberty.serverInstance=$SERVER_NAME \
            -Ddatabase.derby.datadir=$DERBY_DIR \
            -Ddatabase.derby.wladmin.dbname=$DERBY_ADMIN_DB \
            -Ddatabase.derby.worklight.dbname=$WORKLIGHT_DB \
            -Ddatabase.derby.worklightreports.dbname=$WORKLIGHT_REP \
            -Dwladmin.console.war=$CONSOLE_WAR \
            -Dwladmin.service.war=$SERVICE_WAR \
            $1
}

libStart()
{   
    echo "start $SERVER_NAME"
    $LIBERTY_TARGET/wlp/bin/server start $SERVER_NAME
}

libStop()
{   
    echo "stop $SERVER_NAME"
    $LIBERTY_TARGET/wlp/bin/server stop $SERVER_NAME  && rc=$? || rc=$?
    echo "Error code was $rc"
}


deployWar()
{    
    # When running the lib server stop it then remove it to clean house each time
    libStop 
    deleteLibertyServer
    deleteDerbyDb

    # unpack a liberty server from the jar file then create a server for MFP to live 
    #unpackLibertyJar
    createLibertyServer

    # install the db used by the admin services
    install "admdatabases" 

    # install the db used by the MFP runtime
    install "databases"

    # install the admin services and console war files
    install "adminstall"

    # install the db used by the admin services
    install "install"

    #start the liberty server
    libStart
}






