#!/bin/bash

pwd ;
#cd mashling-cicd/sample-recipes/builds/latest/reference-gateway ;
cd builds/latest/reference-gateway ;
	if [ "${TRAVIS_OS_NAME}" != windows ]; then
		cp -r reference-gateway-"${TRAVIS_OS_NAME}".zip ${GOPATH} ;
		cd ${GOPATH}
		pwd ;
		chmod 777 reference-gateway-"${TRAVIS_OS_NAME}".zip ;
		unzip -o reference-gateway-"${TRAVIS_OS_NAME}".zip ;
		ls ;
	#if [ "${TRAVIS_OS_NAME}" != windows ]; then
		#./reference-gateway-"${TRAVIS_OS_NAME}" & HTTP_STATUS=$(curl -i -X PUT -d '{"name":"CAT"}' http://localhost:9096/pets | grep -c 'HTTP/1.1 200 OK' )
		#if [ $HTTP_STATUS -eq 1 ]; then
		#	echo  success message "$HTTP_STATUS" ;
		#	echo "PUT Method passed"
		#fi
		

		# Function to check get response from CURL
		function URL {
		./reference-gateway-"${TRAVIS_OS_NAME}" & RESPONSE=$(curl -so /dev/null -w "%{http_code}\n" ${1})
		if [[ $RESPONSE = 200 ]]; then
			echo "Success with ${RESPONSE} on ${1}" ;
			echo "GET Method passed"
			#exit 0 ;
		fi
		}    
		URL http://localhost:9096/pets/40

		# Using CURL to validate binray
		./reference-gateway-"${TRAVIS_OS_NAME}".exe & HTTP_STATUS=$(curl -i -X GET  http://localhost:9096/pets/2 | grep -c 'HTTP/1.1 200 OK' )
        if [ $HTTP_STATUS -eq 1 ]; then
	        echo  success message "$HTTP_STATUS" ;
	        echo "GET Method Test case 2 passed"
        fi      	
	fi

	cd ${GOPATH}/src/github.com/TIBCOSoftware/recip1/samples-recipes/builds/latest/reference-gateway ;
	ls ;
	pwd ;
