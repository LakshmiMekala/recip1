#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	
	function create_dest_directory ()
	{
		
		cd builds ;
        if [ -n "${TRAVIS_TAG}" ]; then
            destFolder="$namefolder-${TRAVIS_TAG}"
        elif [ -z "${TRAVIS_TAG}" ]; then
            destFolder="$namefolder-${TRAVIS_BUILD_NUMBER}"
        fi

        if [ ! -d "$destFolder" ]; then
            mkdir "$destFolder";
        fi
        echo "Creating folder - $destFolder ..."
        cd "$destFolder";

	}

	function binarycheck()
	{
			fname="${Gateway[$i]}";
			fnamelc="${fname,,}" ;
			if [[ -f $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/builds/"$destFolder"/"${Gateway[$i]}"/bin/$fnamelc ]] ;then
                package_gateway ;
            else
                echo "${Gateway[$i]} binary not found"
                exit 1;
            fi

	}
	
	function package_gateway()
	{
		if [ -d "${Gateway[$i]}" ]; then
							cd "${Gateway[$i]}"  ;
							mv bin "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
						#	mashling build ;
						#	cp -r bin/flogo.json ../"${Gateway[$i]}" ;
						#	cp -r bin/flogo.json "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mv  mashling.json "${Gateway[$i]}.mashling.json"
							cp -r "${Gateway[$i]}.mashling.json" "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
						#	rm -r bin src vendor pkg ;
							rm -r src vendor pkg ;
							# Changing directory to  binary containing folder
										cd "${Gateway[$i]}-${TRAVIS_OS_NAME}";
												if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
													fname="${Gateway[$i]}-$GOOS-$GOARCH.exe" ;
													echo "$fname" ;
													fnamelc="${fname,,}" ;
													echo "$fnamelc" ;													
													destfname="${Gateway[$i]}.exe" ;
													echo "$destfname" ;
													destfnamelc="${destfname,,}" ;
													echo "$destfnamelc" ;
													mv $fnamelc $destfnamelc ;												
												fi
										zip -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" *;
										cp "${Gateway[$i]}-${TRAVIS_OS_NAME}.zip" ../../"${Gateway[$i]}" ;		
										cd .. ;
							rm -r "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							cd ..;
                            # Copying gateway into latest folder
							cp -r "${Gateway[$i]}" ../latest ;
						# Exit if directory not found
						else
								echo "failed to create ${Gateway[$i]}-${TRAVIS_OS_NAME} gateway"  ;
								echo "directory ${Gateway[$i]}-${TRAVIS_OS_NAME}" not found ;
								exit 1 ;
						fi
	}

	function create_gateway()
	{
		echo "Creating gateway" ;
		Gateway=({"envoy-invoker-mashling","inline-gateway","kafka-conditional-gateway","kafka-reference-gateway","KafkaTrigger-To-KafkaActivity-mashling","KafkaTrigger-To-RestActivity-mashling","reference-gateway","RestTrigger-To-KafkaActivity-mashling","rest-conditional-gateway"})	
			# get length of an array		
			tLen="${#Gateway[@]}"
				for (( i=0; i<"${tLen}"; i++ ));
				do
					echo "${Gateway[$i]}";
				# creating gateway	
					mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling/cli/samples/"${Gateway[$i]}"/"${Gateway[$i]}".json "${Gateway[$i]}";
					binarycheck
				done				
	}	


	if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
		export GOOS=windows ;
		export GOARCH=amd64 ;
	fi

	create_dest_directory ;
    create_gateway ;
	
	cd ../.. ;