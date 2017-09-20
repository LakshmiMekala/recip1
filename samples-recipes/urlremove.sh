#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	
	function create_dest_directory ()
	{
		cd master-builds ;
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
	
	function create_gateway()
	{
	#	if [ "${TRAVIS_OS_NAME}" == "osx" ] ;then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
		brew install jq
	#	fi
        echo "test 0" ;
		#Extracting publish binaries from recipe_registry.json
        publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq '.recipe_repos[0].publish') ;
        echo "test 1" ;
		echo $publish #="KafkaTrigger-To-KafkaPublsher, KafkaTrigger-To-RestInvoker, RestTrigger-To-KafkaPublisher" ;
        echo "test 2" ;
		#Removing spaces from publish
        publish=$(echo $publish | tr -d ' ') ;
        echo "test 3" ;
		#Removing double quotes from publish
		publish=$(echo $publish | tr -d '"') ;
        echo "test 3A" ;
		# separating string using comma and reading publish into Gateway
		IFS=\, read -a Gateway <<<"$publish" ;
		echo "test 4" ;
        set | grep ^IFS= ;
		echo "test 5" ;
		#separating arrays ny line
        IFS=$' \t\n' ;
		echo "test 6" ;
		#fetching Gateway
        set | grep ^Gateway=\\\|^publish= ;
		echo "test 7" ;

		for (( i = 0; i < ${#Gateway[@]}; i++ ))
			do
  			echo "${Gateway[$i]}" ;
				# creating gateway	
                     if [ ! "${TRAVIS_OS_NAME}" == "OSX" ] ;then
                        echo "${Gateway[$i]}" ;
                        gwname="${Gateway[$i]}" ;
                        echo "$gwname" ;
                        Gatewaylc[$i]="${gwname,,}" ;
                        echo "${Gatewaylc[$i]}" ;
                    fi 
					mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$i]}"/"${Gateway[$i]}".json "${Gateway[$i]}";
						# If directory exists proceed to next steps	
							if [ -d "${Gateway[$i]}" ]; then
							cd "${Gateway[$i]}"  ;
							mv bin "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
							mv  mashling.json "${Gateway[$i]}.mashling.json" ;
                            if [[ ! "${TRAVIS_OS_NAME}" == "OSX" ]] ; then
                            cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$i]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gatewaylc[$i]}"
                            else
                            cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$i]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$i]}"
                            fi
							cp -r "${Gateway[$i]}.mashling.json" "${Gateway[$i]}-${TRAVIS_OS_NAME}" ;
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
								echo "failed to create ${Gateway[$i]}-${TRAVIS_OS_NAME} gateway" 
								echo "directory ${Gateway[$i]}-${TRAVIS_OS_NAME}" not found
								exit 1
						fi
				done
				cd .. ;
	}
			
	if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
		export GOOS=windows
		export GOARCH=amd64			
	fi
    create_dest_directory ;
    create_gateway ;

	cd .. ;
   # Calling function to create recipes binaries 
  #  multi_os ;

    git config user.email "lmekala@tibco.com";
	git config user.name "LakshmiMekala"
	
	
	ls ;
	pwd ;
	git add .;  
	echo "alert -1" ;
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
   git push