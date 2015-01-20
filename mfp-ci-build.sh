#!/bin/bash -v
set -o errexit
set -o xtrace
set -o nounset



# Print debugging info
echo "Printing current env for debugging purposes"
printenv
echo "Printing whoami"
whoami



# Set some local variables
export SCRIPT_DIR=`pwd`
# script executing from CIBuild dir INSIDE of the proj. this is to resolve this.
export MFP_PROJECT=$(cd ..; pwd)
export LOCAL_ANT="/usr/local/bin/ant"
export ANT_DIR=$SCRIPT_DIR/ant_jars
export ANTFILE="${ANT_DIR}/build.xml"
# could use either - prob better to go hostbame
# export LOCAL_MACHINE_IP=$(ifconfig eth0 | grep 'inet\ ' | cut -f2 -d':' | cut -f1 -d' ')

source $SCRIPT_DIR/common-functions.sh


setEnvironment 

buildWar

buildAdapters

buildApps

deployWar

deployAdapters

deployApps

