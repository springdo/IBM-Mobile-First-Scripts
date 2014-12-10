#!/bin/bash -v

set -o errexit
set -o xtrace
set -o nounset

MY_DIR=`dirname $0`
source "/home/devops/Documents/WL_Build_Deploy/common.sh"

setEndPoints() {
	
	cd $TEST_DIR
	echo "Setting the endpoint for node to test the adapters"
	    safeSearchAndReplace "s#process.env.npm_package_config_protocol#'${WORKLIGHT_PROTOCOL}'#c" ${TEST_DIR}/WorklightAdapter/invoke.js
	    safeSearchAndReplace "s#process.env.npm_package_config_port#'${WORKLIGHT_PORT}'#c" ${TEST_DIR}/WorklightAdapter/invoke.js
	    safeSearchAndReplace "s#process.env.npm_package_config_domain#'${LOCAL_MACHINE_IP}'#c" ${TEST_DIR}/WorklightAdapter/invoke.js
	    safeSearchAndReplace "s#process.env.npm_package_config_contextRoot#'${WORKLIGHT_CONTEXT_ROOT}'#c" ${TEST_DIR}/WorklightAdapter/invoke.js
}

installDeps() {

	cd $TEST_DIR
	# hack for silly reasons
	rm -rf $TEST_DIR/node_modules
	npm install WorklightAdapter --cache-min 99999
	npm install --cache-min 99999
}


unitTests()
{
    cd ${TEST_DIR}
    echo "Unit Testing"
    time npm run-script unitTest | grep -v "^>" > ${WORKSPACE}/unitTestResult.xml && rc=$? || rc=$?
    echo "Unit Testing Error Code: $rc"
}

integrationTests()
{
    cd ${TEST_DIR}
    echo "#### Integration Testing ####"
    time npm run-script integrationTest | grep -v "^>" > ${WORKSPACE}/integrationTestResult.xml && rc=$? || rc=$?
    echo "Integration Testing Error Code: $rc"
}

performanceTests()
{
    cd ${TEST_DIR}
    echo "Performance Testing"
    time npm run-script performanceTest  && rc=$? || rc=$?
    echo "Performance Testing Error Code: $rc"
}
failBuildPerf()
{
	cat performance_tests/*.result.csv | grep -o '^[0-9]*' | while read -r TEST_SCORE; do
		echo "processing $TEST_SCORE"
			if [ "$TEST_SCORE" -gt "$NFR_THRESHOLD" ]; then
			echo "score ($TEST_SCORE) failed to pass NFR of $NFR_THRESHOLD"
			exit 9999
		else 
			echo "score ($TEST_SCORE) passes NFR of $NFR_THRESHOLD"		
		fi
	done
}

cleanUI()
{
	PID=$(ps -ef | grep chromium-browser | cut -d' ' -f4 | head -1)
	kill -9 $PID && rc=$? || rc=$?
}

seleniumTests()
{
    cd ${TEST_DIR}
    echo "UI Testing"
    time npm run-script uiTest | grep -v "^>" > ${WORKSPACE}/uiTestResult.xml && rc=$? || rc=$?
    echo "UI Testing Error Code: $rc"
}

setEnvironment $DEPLOYER_ENV

setEndPoints

installDeps

unitTests

#integrationTests

seleniumTests

cleanUI

#performanceTests

#failBuildPerf



