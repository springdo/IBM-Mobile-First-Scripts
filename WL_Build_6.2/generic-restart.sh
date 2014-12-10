#!/bin/bash -v

set -o errexit
set -o xtrace
set -o nounset

MY_DIR=`dirname $0`
source "/home/devops/Documents/WL_Build_Deploy/common.sh"

# Print debugging info
echo "Printing current env for debugging purposes"
printenv
echo "Printing whoami"
whoami


restartServer()
{
	echo "restarting server $DEPLOYER_ENV"
	ssh -T devops@localhost $LIB_INST/bin/server stop $PROJECT_NAME && rc=$? || rc=$?
    	echo "stop code: $rc"

	ssh -T devops@localhost $LIB_INST/bin/server start $PROJECT_NAME 

}


stopServer()
{
	echo "stopping server $DEPLOYER_ENV"
	ssh -T devops@localhost $LIB_INST/bin/server stop $PROJECT_NAME 

}

setEnvironment $DEPLOYER_ENV

if [ "$JOB_NAME" == "Generic-Server-Restart" ]; then
	restartServer
elif [ "$JOB_NAME" == "Generic-Server-Stop" ]; then
	stopServer
else
	echo "You need to ensure the job name matches either Generic-Server-Restart or Generic-Server-Stop"
	exit 1
fi

