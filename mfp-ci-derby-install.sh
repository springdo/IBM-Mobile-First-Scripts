#!/bin/bash
set -o errexit


# Print debugging info
echo "Printing current env for debugging purposes"
printenv
echo "Printing whoami"
whoami
export SCRIPT_DIR=`pwd`

source $SCRIPT_DIR/common-functions.sh

# set the current env params.
setEnvironment


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

