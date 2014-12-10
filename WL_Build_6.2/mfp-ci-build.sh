#!/bin/bash -v
set -o errexit
set -o xtrace
set -o nounset



# Print debugging info
echo "Printing current slave env for debugging purposes"
printenv
echo "Printing whoami"
whoami


# Set some variables
export SCRIPT_DIR=`pwd`
export MY_WORKSPACE=$(cd ..)
export MFP_PROJECT="${WORKSPACE}/WorklightProj"
export ANTFILE="${ANT_DIR}/build.xml"
# export LOCAL_ANT=`type -p ant || echo '/scratch/inst_ant/apache-ant-1.9.2/bin/ant'`
export LOCAL_ANT="/usr/bin/ant"
export MY_OUTPUT="${MY_WORKSPACE}/Artefacts"
mkdir -p 
export ANT_DIR=$SCRIPT_DIR
export LOCAL_MACHINE_IP=$(ifconfig eth0 | grep 'inet\ ' | cut -f2 -d':' | cut -f1 -d' ')


# setEnvironment - idea here is you would have one of these for each MFP Enviornment you have eg TEST, UAT, SAGING, PROD
setEnvironment() {
    # IHS is entry point !
    export MFP_PORT="8080"
    export MFP_PROTOCOL="http"
    export MFP_SERVER_URL="http://$LOCAL_MACHINE_IP:$MFP_PORT/worklightconsole"
    export MFP_EXTERNAL_SERVER_URL=$MFP_SERVER_URL
    export PROJECT_NAME="worklight"    
    export MFP_CONTEXT_ROOT="/worklight"
    export LIB_INST="/home/virtuser/IBM/WebSphere/Liberty"
}

buildAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} build-Adapter 
        -Dbasedir="${MY_WORKSPACE}" \
        -DworklightServerUrl=${MFP_SERVER_URL} \
        -DexternalMFPServerUrl=${MFP_EXTERNAL_SERVER_URL} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dpath.to.project=${MFP_PROJECT} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} 
}

buildApps()
{
   ${LOCAL_ANT} -f ${ANTFILE} build-Apps -DworklightServerUrl=${MFP_SERVER_URL} \
        -DexternalMFPServerUrl=${MFP_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${MFP_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 
}

deployAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Adapter -DworklightServerUrl=${MFP_SERVER_URL} \
        -DexternalMFPServerUrl=${MFP_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${MFP_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 

}

deployApps()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Apps -DworklightServerUrl=${MFP_SERVER_URL} \
        -DexternalMFPServerUrl=${MFP_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${MFP_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${MFP_PROJECT} 
}



setEnvironment 

buildAdapters

buildApps

deployAdapters

deployApps

