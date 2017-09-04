#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	
	function multi_os ()
	{
		cd builds ;
		if [ -n "${TRAVIS_TAG}" ]; then
			echo Creating build with release version:"${TRAVIS_TAG}";
				if [ -d "$namefolder-${TRAVIS_TAG}" ]; then			
					cd "$namefolder-${TRAVIS_TAG}";
					create_gateway;
				else
					mkdir "$namefolder-${TRAVIS_TAG}";
					cd "$namefolder-${TRAVIS_TAG}";
					create_gateway;				
				fi
		 fi	
		if [ -z "${TRAVIS_TAG}" ]; then
			echo Creating build with travis build number:"${TRAVIS_BUILD_NUMBER}" ;
				if [ -d "$namefolder-${TRAVIS_BUILD_NUMBER}" ]; then			
					cd "$namefolder-${TRAVIS_BUILD_NUMBER}";
					create_gateway;
				else
					mkdir "$namefolder-${TRAVIS_BUILD_NUMBER}";
					cd "$namefolder-${TRAVIS_BUILD_NUMBER}";
					create_gateway;				
				fi
		fi
	}
	
	function create_gateway()
	{
		echo "Creating gateway"
		Gateway=({"envoy-invoker-mashling","inline-gateway","kafka-conditional-gateway","kafka-reference-gateway","KafkaTrigger-To-KafkaActivity-mashling","KafkaTrigger-To-RestActivity-mashling","reference-gateway","RestTrigger-To-KafkaActivity-mashling","rest-conditional-gateway"})	
			# get length of an array		
			tLen="${#Gateway[@]}"
				for (( i=0; i<"${tLen}"; i++ ));
				do
					echo "${Gateway[$i]}-${TRAVIS_OS_NAME}";
				# creating gateway	
					mashling create -f ../../../../mashling-cli/samples/"${Gateway[$i]}".json "${Gateway[$i]}-${TRAVIS_OS_NAME}";
						# If directory exists proceed to next steps	
							if [ -d "${Gateway[$i]}-${TRAVIS_OS_NAME}" ]; then
							cd "${Gateway[$i]}-${TRAVIS_OS_NAME}"  ;
							mv bin "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mashling build ;
							cp -r bin/flogo.json ../"${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							cp -r bin/flogo.json "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mv  mashling.json "${Gateway[$i]}.mashling.json"
							cp -r "${Gateway[$i]}.mashling.json" "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							rm -r bin src vendor pkg ;
										cd "${Gateway[$i]}-${TRAVIS_OS_NAME}";
												if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
													fname="${Gateway[$i]}-${TRAVIS_OS_NAME}-$GOOS-$GOARCH.exe" ;
													echo "$fname" ;
													fnamelc="${fname,,}" ;
													echo "$fnamelc" ;													
													destfname="${Gateway[$i]}-${TRAVIS_OS_NAME}.exe" ;
													echo "$destfname" ;
													destfnamelc="${destfname,,}" ;
													echo "$destfnamelc" ;
													mv $fnamelc $destfnamelc ;
												fi
										zip -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" *;
										cp "${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../../"${Gateway[$i]}-${TRAVIS_OS_NAME}" ;		
										cd .. ;
							rm -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							cd ..;
							# For linux binary, recipe name is gateway name.
								if [ "${TRAVIS_OS_NAME}" == "linux" ] ; then	
									mv "${Gateway[$i]}-${TRAVIS_OS_NAME}" "${Gateway[$i]}" ;
									cp -r "${Gateway[$i]}" ../latest
								else
							#For mac and windows recipe name will be updated in gateway folder itself
									pwd
									cp "${Gateway[$i]}-${TRAVIS_OS_NAME}"/"${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" "${Gateway[$i]}" ;
									cd "${Gateway[$i]}" ;
									cd ..;
									cp -r "${Gateway[$i]}-${TRAVIS_OS_NAME}"/"${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../latest/"${Gateway[$i]}" ;
									rm  -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
								fi	
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
	

	ls ;
	pwd ;
	git add .;  
	echo "alert -1" ;
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	echo "alert 0" ;
	git push -u origin recipe;
	echo "alert A 1" ;
	git stash
	echo "alert 1" ;
	git checkout master;
	echo "alert 2" ;
	git checkout recipe -- latest ;
	git add latest ;
	echo "alert 3" ;
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	echo "alert 4" ;
	git push -u origin master;
	echo "alert 5" ;
