#!/bin/bash -v

set -o errexit
set -o xtrace
set -o nounset

MY_DIR=`dirname $0`
#source "/home/devops/Documents/WL_Build_Deploy/common.sh"

# Print debugging info
echo "Printing current env for debugging purposes"
printenv
echo "Printing whoami"
whoami


applyPuppet()
{
	echo "applying puppet script"
	cd ${WORKSPACE}/puppet
	pwd
        puppet apply --verbose puppetmaster.pp
}

changeParams()
{
	cd ${WORKSPACE}/puppet
	PUPPETMASTER=$(cat ${WORKSPACE}/puppet/puppetmaster.pp)
	echo "\$puppetFiles= \"${WORKSPACE}/puppet\" $PUPPETMASTER" > ${WORKSPACE}/puppet/puppetmaster.pp


	PARAMS=$(cat ${WORKSPACE}/puppet/params.pp)
	echo "\$LIBERTY_TARGET= \"${LIBERTY_TARGET}\"" > ${WORKSPACE}/puppet/params.pp
	echo "\$SERVER_NAME= \"${SERVER_NAME}\"" >> ${WORKSPACE}/puppet/params.pp
	echo "\$defaultHttpPort= \"${HTTP_PORT}\"" >> ${WORKSPACE}/puppet/params.pp
	echo "\$CONTEXT_ROOT= \"${CONTEXT_ROOT}\"" >> ${WORKSPACE}/puppet/params.pp
	echo "\$defautlHttpsPort= \"${HTTPS_PORT}\" $PARAMS" >> ${WORKSPACE}/puppet/params.pp

}


changeParams
applyPuppet


