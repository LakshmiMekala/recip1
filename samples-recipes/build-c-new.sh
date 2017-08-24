#!/bin/bash
	function multi_os ()
	{
		cd builds ;
		if [ -n "${TRAVIS_TAG}" ]; then
			echo Creating build with release version:"${TRAVIS_TAG}";
				if [ -d "${TRAVIS_TAG}" ]; then			
					cd "${TRAVIS_TAG}";
					create_gateway;
				else
					mkdir "${TRAVIS_TAG}";
					cd "${TRAVIS_TAG}";
					create_gateway;				
				fi
		 fi	
		if [ -z "${TRAVIS_TAG}" ]; then
			echo Creating build with travis build number:"${TRAVIS_BUILD_NUMBER}" ;
				if [ -d "${TRAVIS_BUILD_NUMBER}" ]; then			
					cd "${TRAVIS_BUILD_NUMBER}";
					create_gateway;
				else
					mkdir "${TRAVIS_BUILD_NUMBER}";
					cd "${TRAVIS_BUILD_NUMBER}";
					create_gateway;				
				fi
		fi
	}
	
	function create_gateway()
	{
		echo "Creating gateway"
		Gateway=({"envoy-invoker-mashling","inline-gateway","KafkaTrigger-To-KafkaActivity-mashling","KafkaTrigger-To-RestActivity-mashling","RestTrigger-To-KafkaActivity-mashling"})	
			# get length of an array		
			tLen="${#Gateway[@]}"
				for (( i=0; i<"${tLen}"; i++ ));
				do
					Gateway="${Gateway,,}" ;
					echo "$Gateway-${TRAVIS_OS_NAME}";
					
				# creating gateway	
					mashling create -f ../../../../mashling-cli/samples/"$Gateway".json "$Gateway-${TRAVIS_OS_NAME}";
							cd "$Gateway-${TRAVIS_OS_NAME}"  ;
							mv bin "$Gateway-${TRAVIS_OS_NAME}" ;
							mashling build ;
							cp -r bin/flogo.json ../"$Gateway-${TRAVIS_OS_NAME}" ;
							cp -r bin/flogo.json "$Gateway-${TRAVIS_OS_NAME}" ;
							mv  mashling.json "$Gateway.mashling.json"
							cp -r "$Gateway.mashling.json" "$Gateway-${TRAVIS_OS_NAME}" ;
							rm -r bin src vendor pkg ;
										cd "$Gateway-${TRAVIS_OS_NAME}";
												if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
													#fname="$Gateway-${TRAVIS_OS_NAME}-$GOOS-$GOARCH" ;
													#echo "$fname" ;
													#fnamelc="${fname,,}" ;
													#echo "$fnamelc" ;													
													#destfname="$Gateway-${TRAVIS_OS_NAME}" ;
													#echo "$destfname" ;
													#destfnamelc="${destfname,,}" ;
													#echo "$destfnamelc" ;
													#mv fnamelc.exe destfnamelc.exe ;
													mv "$Gateway-${TRAVIS_OS_NAME}-$GOOS-$GOARCH.exe" "$Gateway-${TRAVIS_OS_NAME}.exe"
												fi
										zip -r "$Gateway-${TRAVIS_OS_NAME}" *;
										echo "alert 4" ;
										ls ;
										cp "$Gateway-${TRAVIS_OS_NAME}.zip" ../../"$Gateway-${TRAVIS_OS_NAME}" ;
										echo "alert 17" ;		
										cd .. ;
							ls ;
							echo "alert 3" ;
							echo "4" ;
							rm -r "$Gateway-${TRAVIS_OS_NAME}" ;
							ls;
							echo "alert 4" ;
							ls;
							cd ..;
					echo "alert 10" ;
					ls ;
					# For linux binary, recipe name is gateway name.
						if [ "${TRAVIS_OS_NAME}" == "linux" ] ; then	
							mv "$Gateway-${TRAVIS_OS_NAME}" "$Gateway" ;
							echo "alert 11";
							ls ;
							cp -r "$Gateway" ../latest
						else
					#For mac and windows recipe name will be updated in gateway folder itself
							pwd
							cp "$Gateway-${TRAVIS_OS_NAME}"/"$Gateway-${TRAVIS_OS_NAME}.zip" "$Gateway" ;
							cd "$Gateway" ;
							echo "123" ;
							ls ;
							cd ..;
							cp -r "$Gateway-${TRAVIS_OS_NAME}"/"$Gateway-${TRAVIS_OS_NAME}.zip" ../latest/"$Gateway" ;
							rm  -r "$Gateway-${TRAVIS_OS_NAME}" ;
							echo "Test account" ;
							ls;	
						fi
				done
				cd .. ;
	}
			
	if [ "${TRAVIS_OS_NAME}" == "osx" ] ;then
		multi_os ;
	fi     	
	if [ "${TRAVIS_OS_NAME}" == "linux" ] ;then
		multi_os ;
	fi
	if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
		export GOOS=windows
		export GOARCH=amd64
		multi_os ;
	fi
   
    git config user.email "lmekala@tibco.com";
	git config user.name "LakshmiMekala"
	
	git checkout master;
	git add .; 
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	git push --set-upstream origin master;
