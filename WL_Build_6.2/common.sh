#!/bin/bash -v

set -o errexit
set -o xtrace
set -o nounset

# Print debugging info
echo "Printing current slave env for debugging purposes"
printenv
echo "Printing whoami"
whoami


export MY_WORKSPACE=`pwd`
export WORKLIGHT_GIT_PROJECT="/home/devops/Documents/WorklightProject/IBMAppCenter"
export WORKLIGHT_PROJECT="${WORKSPACE}/IBMAppCenter"
 # same as the servername?

# export LOCAL_ANT=`type -p ant || echo '/scratch/inst_ant/apache-ant-1.9.2/bin/ant'`
export LOCAL_ANT="/usr/bin/ant"
export LOCAL_ANT_OUTPUT_FOLDER="${MY_WORKSPACE}/antoutput/"
export ANT_DIR="/home/devops/Documents/WL_Build_Deploy"
export ANTFILE="${ANT_DIR}/build.xml"
export LOCAL_MACHINE_IP=$(ifconfig eth0 | grep 'inet\ ' | cut -f2 -d':' | cut -f1 -d' ')
export TEST_DIR="$WORKLIGHT_PROJECT/adapters/Testing"
export NFR_THRESHOLD="375"


setCI() {
    export WORKLIGHT_PORT="1080"
    export WORKLIGHT_PROTOCOL="http"
    export WORKLIGHT_SERVER_URL="http://$LOCAL_MACHINE_IP:$WORKLIGHT_PORT/worklightconsole"
    export WORKLIGHT_EXTERNAL_SERVER_URL=$WORKLIGHT_SERVER_URL
    export PROJECT_NAME="cidevopsworklight"    
    export WORKLIGHT_CONTEXT_ROOT="/cidevopsworklight"
    export LIB_INST="/home/devops/ci/Liberty/wlp"


}

setSI() {
    export WORKLIGHT_PORT="2080"
    export WORKLIGHT_PROTOCOL="http"
    export WORKLIGHT_SERVER_URL="http://$LOCAL_MACHINE_IP:$WORKLIGHT_PORT/worklightconsole"
    export WORKLIGHT_EXTERNAL_SERVER_URL=$WORKLIGHT_SERVER_URL
    export PROJECT_NAME="sidevopsworklight"
    export WORKLIGHT_CONTEXT_ROOT="/sidevopsworklight"
    export LIB_INST="/home/devops/si/Liberty/wlp"
}

setUAT() {
    export WORKLIGHT_PORT="3080"
    export WORKLIGHT_PROTOCOL="http"
    export WORKLIGHT_SERVER_URL="http://$LOCAL_MACHINE_IP:$WORKLIGHT_PORT/worklightconsole"
    export WORKLIGHT_EXTERNAL_SERVER_URL=$WORKLIGHT_SERVER_URL
    export PROJECT_NAME="uatdevopsworklight"
    export WORKLIGHT_CONTEXT_ROOT="/uatdevopsworklight"
    export LIB_INST="/home/devops/uat/Liberty/wlp"
}

setEnvironment()
{
    #$1 is $DEPLOYER_ENV

    echo "setEnvironment: $1"

    if [ "$1" == "CI" ]; then
        setCI
    elif [ "$1" == "SI" ]; then
        setSI
    elif [ "$1" == "UAT" ]; then
        setUAT
    else
        echo "You need to set the \$DEPLOYER_ENV environment variable"
        exit 1
    fi
}


safeSearchAndReplace()
{
    perl -p -i -e "BEGIN { -f \$ARGV[0] or die 'file missing' } $1" $2
}

