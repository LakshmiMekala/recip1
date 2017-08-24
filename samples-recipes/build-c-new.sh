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
		Gateway=({"envoy-invoker-mashling","RestTrigger-To-KafkaActivity-mashling"})	
			# get length of an array		
			tLen="${#Gateway[@]}"
				for (( i=0; i<"${tLen}"; i++ ));
				do
					echo "${Gateway[$i]}-${TRAVIS_OS_NAME}";
				# creating gateway	
					mashling create -f ../../../../mashling-cli/samples/"${Gateway[$i]}".json "${Gateway[$i]}-${TRAVIS_OS_NAME}";
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
													#mv "${"${Gateway[$i]}-${TRAVIS_OS_NAME}-$GOOS-$GOARCH.exe",,}" "${"${Gateway[$i]}-${TRAVIS_OS_NAME}.exe",,}"
												fi
										zip -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" *;
										echo "alert 4" ;
										ls ;
										cp "${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../../"${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
										echo "alert 17" ;		
										cd .. ;
							ls ;
							echo "alert 3" ;
							echo "4" ;
							rm -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							ls;
							echo "alert 4" ;
							ls;
							cd ..;
					echo "alert 10" ;
					ls ;
					# For linux binary, recipe name is gateway name.
						if [ "${TRAVIS_OS_NAME}" == "linux" ] ; then	
							mv "${Gateway[$i]}-${TRAVIS_OS_NAME}" "${Gateway[$i]}" ;
							echo "alert 11";
							ls ;
							cp -r "${Gateway[$i]}" ../latest
						else
					#For mac and windows recipe name will be updated in gateway folder itself
							pwd
							cp "${Gateway[$i]}-${TRAVIS_OS_NAME}"/"${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" "${Gateway[$i]}" ;
							cd "${Gateway[$i]}" ;
							echo "123" ;
							ls ;
							cd ..;
							cp -r "${Gateway[$i]}-${TRAVIS_OS_NAME}"/"${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../latest/"${Gateway[$i]}" ;
							rm  -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
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
	
	git checkout recipe;
	git add .;  	
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	git push --set-upstream origin recipe;
	git checkout master;
	echo "alert 2" ;
	git checkout branch samples-recipes/builds/latest ;
	echo "alert 3" ;
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	echo "alert 4" ;
	git push --set-upstream origin master;
	echo "alert 5" ;
