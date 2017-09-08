#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	
	function multi_os ()
	{
		cd ${TRAVIS_BRANCH} ;
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
		Gateway=({"envoy-invoker-mashling","inline-gateway"})	
			# get length of an array		
			tLen="${#Gateway[@]}"
				for (( i=0; i<"${tLen}"; i++ ));
				do
					echo "${Gateway[$i]}-${TRAVIS_OS_NAME}";
				# creating gateway	
					mashling create -f ../../../../mashling-cli/samples/"${Gateway[$i]}".json "${Gateway[$i]}";
						# If directory exists proceed to next steps	
							if [ -d "${Gateway[$i]}" ]; then
							cd "${Gateway[$i]}"  ;
							mv bin "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mashling build ;
							cp -r bin/flogo.json ../"${Gateway[$i]}" ;
							cp -r bin/flogo.json "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mv  mashling.json "${Gateway[$i]}.mashling.json"
							cp -r "${Gateway[$i]}.mashling.json" "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							rm -r bin src vendor pkg ;
							# Changing directory to  binary containing folder
										cd "${Gateway[$i]}-${TRAVIS_OS_NAME}";
												if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
													fname="${Gateway[$i]}-$GOOS-$GOARCH.exe" ;
													echo "$fname" ;
													fnamelc="${fname,,}" ;
													echo "$fnamelc" ;													
													destfname="${Gateway[$i]}-${TRAVIS_OS_NAME}.exe" ;
													echo "$destfname" ;
													destfnamelc="${destfname,,}" ;
													echo "$destfnamelc" ;
													mv $fnamelc $destfnamelc ;
												else
												    mv "${Gateway[$i]}" "${Gateway[$i]}-${TRAVIS_OS_NAME}";
												fi
										zip -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" *;
										cp "${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../../"${Gateway[$i]}" ;		
										cd .. ;
							rm -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							cd ..;
									pwd
									echo "test 1" ;
									ls ;
									echo "test 2" ;
									cd "${Gateway[$i]}" ;
									pwd;
									echo "test 3" ;
									ls ;
									echo "test 4" ;
									cd ..;
									ls ;
									echo "test 5" ;
									cp -r "${Gateway[$i]}" ../latest ;
									ls ;
									echo "test 6" ;
							#		rm  -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
									ls ;
									echo "test 7" ;
							#	fi
						# Exit if directory not found
						else
								echo "failed to create ${Gateway[$i]}-${TRAVIS_OS_NAME} gateway" 
								echo "directory ${Gateway[$i]}-${TRAVIS_OS_NAME}" not found
								exit 1
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
#	git push -u origin historical-builds;
	echo "alert A 1" ;
#	git stash
	echo "alert 1" ;
#	git checkout master;
	echo "alert 2" ;
#	git checkout historical-builds -- latest ;
	git add latest ;
	echo "alert 3" ;
#	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	echo "alert 4" ;
#	git push -u origin master;
	echo "alert 5" ;
