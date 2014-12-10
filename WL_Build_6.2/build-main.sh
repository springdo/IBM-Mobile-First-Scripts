#!/bin/bash -v

set -o errexit
set -o xtrace
set -o nounset

MY_DIR=`dirname $0`
source "/home/devops/Documents/WL_Build_Deploy/common.sh"

# Print debugging info
echo "Printing current slave env for debugging purposes"
printenv
echo "Printing whoami"
whoami


buildAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} build-Adapter -Dbasedir="${MY_WORKSPACE}" \
        -DworklightServerUrl=${WORKLIGHT_SERVER_URL} \
        -DexternalWorklightServerUrl=${WORKLIGHT_EXTERNAL_SERVER_URL} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dpath.to.project=${WORKLIGHT_PROJECT} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} 
}

buildApps()
{
   ${LOCAL_ANT} -f ${ANTFILE} build-Apps -DworklightServerUrl=${WORKLIGHT_SERVER_URL} \
        -DexternalWorklightServerUrl=${WORKLIGHT_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${WORKLIGHT_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${WORKLIGHT_PROJECT} 
}

deployAdapters()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Adapter -DworklightServerUrl=${WORKLIGHT_SERVER_URL} \
        -DexternalWorklightServerUrl=${WORKLIGHT_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${WORKLIGHT_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${WORKLIGHT_PROJECT} 

}

deployApps()
{
    ${LOCAL_ANT} -f ${ANTFILE} deploy-Apps -DworklightServerUrl=${WORKLIGHT_SERVER_URL} \
        -DexternalWorklightServerUrl=${WORKLIGHT_EXTERNAL_SERVER_URL} \
        -Dworklight.port=${WORKLIGHT_PORT} \
        -DoutputFolder=$LOCAL_ANT_OUTPUT_FOLDER \
        -Dworklight.ant.tools.dir=${ANT_DIR} \
        -Dworklight.server.install.dir=${MY_WORKSPACE}../Liberty \
        -Dworklight.jars.dir=${ANT_DIR} \
        -Dworklight.adapter.dir="MovieTimes" \
        -DProjectName=${PROJECT_NAME} \
        -Dpath.to.project=${WORKLIGHT_PROJECT} 
}

gitTag()
{
	cd $WORKLIGHT_GIT_PROJECT
	git tag $JOB_NAME.$BUILD_NUMBER
	cd $WORKSPACE
}

gitCheckout(){
	cd $WORKLIGHT_PROJECT
	git checkout -f $TAG
}

# order to do things in ::
gitTag


if [ "$DEPLOYER_ENV" == "SI" ]; then
        gitCheckout
elif [ "$DEPLOYER_ENV" == "UAT" ]; then
        gitCheckout
else
        echo "No gitCheckout - building develop"
	cd $WORKLIGHT_PROJECT
	NO_BRANCH=$(git branch | grep "*" | cut -d'(' -f 2) 
	if [ "$NO_BRANCH" == "no branch)" ]; then
		echo "No gitCheckout - building off tag"
	else 
		TAG="develop"
		gitCheckout
	fi
fi 

setEnvironment $DEPLOYER_ENV

buildAdapters

buildApps

deployAdapters

deployApps

