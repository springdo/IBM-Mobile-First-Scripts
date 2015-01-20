#!/bin/bash -v
set -o errexit
set -o xtrace
set -o nounset



# Print debugging info
echo "Printing current env for debugging purposes"
printenv
echo "Printing whoami"
whoami


# Set some variables
export SCRIPT_DIR=`pwd`
# script executing from CIBuild dir INSIDE of the proj. this is to resolve this.
export MFP_PROJECT=$(cd ..; pwd)

# export LOCAL_ANT=`type -p ant || echo '/scratch/inst_ant/apache-ant-1.9.2/bin/ant'`
#export LOCAL_ANT="/home/virtuser/IBM/MobileFirst_Platform_Server/tools/apache-ant-1.8.4/bin/ant"
export LOCAL_ANT="/usr/local/bin/ant"

export ANT_DIR=$SCRIPT_DIR
export ANTFILE="${ANT_DIR}/build.xml"
# could use either - prob better to go hostbame
export LOCAL_MACHINE_IP=$(ifconfig eth0 | grep 'inet\ ' | cut -f2 -d':' | cut -f1 -d' ')

# setEnvironment - idea here is you would have one of these for each MFP Enviornment you have eg TEST, UAT, SAGING, PROD
setEnvironment() {
    # IHS is entry point !
    export MFP_PORT="8080"
    export HOSTNAME="bvm040.dub.usoh.ibm.com"
    export PROJECT_NAME="worklight"
    export MFP_CONTEXT_ROOT="/$PROJECT_NAME"
    export ADMIN_CONTEXT="/wladmin"
    export MFP_SERVER_URL="http://$HOSTNAME:$MFP_PORT$MFP_CONTEXT_ROOT"
    export MFP_EXTERNAL_SERVER_URL=$MFP_SERVER_URL
    export LIB_INST="/home/virtuser/IBM/WebSphere/Liberty"
    export MFP_USERNAME="demo"
    export MFP_PASSWORD="demo"
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

}


deployWar()
{
	
}

#setEnvironment 

buildWar

#buildAdapters

#buildApp

deployWar

#deployAdapters

#deployApps

