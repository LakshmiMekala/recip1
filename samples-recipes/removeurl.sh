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
	
    function publish_gateway()
    {
        publish=$(echo $publish | tr -d ' ') ;
		#Removing double quotes from publish
		publish=$(echo $publish | tr -d '"') ;
		# separating string using comma and reading publish into Gateway
		IFS=\, read -a Gateway <<<"$publish" ;
        set | grep ^IFS= ;
		#separating arrays ny line
        IFS=$' \t\n' ;
		#fetching Gateway
        set | grep ^Gateway=\\\|^publish= ;
    }
    
	function recipe_registry()
	{
	#	if [ "${TRAVIS_OS_NAME}" == "osx" ] ;then
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
		brew install jq
	#	fi
		#Extracting publish binaries from recipe_registry.json
    	#array_length=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
        array_length=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 

		echo "Found $array_length recipe providers." ;        
		    for (( j = 0; j < $array_length; j++ ))
                do
                    echo "value of j=$j" ;
                    #eval url and publish
                    eval xpath='.recipe_repos[$j].url' ;
                    eval xpath_publish='.recipe_repos[$j].publish' ;           
                    #url=$(cat ../../../../mashling-recipes/recipe_registry.json | jq $xpath ) ;
                    url=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath ) ;
                    provider_path=$(echo $url | tr -d '"') ;
                    echo "provider_path is $provider_path";
                    publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                    echo "$publish";
                    publish_gateway ;
                    if [[ -d  $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_path" ]]; then
                        for (( x = 0; x < ${#Gateway[@]}; x++ ))
                            do
                                # creating gateway with values from publish
                                if [ ! "${TRAVIS_OS_NAME}" == "OSX" ] ;then
                                echo "${Gateway[$x]}" ;
                                gwname="${Gateway[$x]}" ;
                                echo "$gwname" ;
                                Gatewaylc[$x]="${gwname,,}" ;
                                echo "${Gatewaylc[$x]}" ;
                                fi 
                                mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_path"/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gatewaylc[$x]}";
                                package_gateway ;
                            done                              
                    else
                        echo "exiting the build as provider path is not a directory" ;
                        exit 1 ;
                    fi                    
            done                  	
	}

    function package_gateway()
	{
		# If directory exists proceed to next steps	
		if [ -d "${Gatewaylc[$x]}" ]; then
             cd "${Gatewaylc[$x]}"  ;
                mv bin "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}" ;
            #    mashling build ;
            #    cp -r bin/flogo.json ../"${Gateway[$x]}" ;
            #    cp -r bin/flogo.json "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                mv  mashling.json "${Gatewaylc[$x]}.mashling.json"
                cp -r "${Gatewaylc[$x]}.mashling.json" "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}" ;
                #cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_path"/"${Gateway[$x]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/mashling-cicd/master-builds/"$destFolder"/"${Gatewaylc[$x]}" ;
                if [[ ! "${TRAVIS_OS_NAME}" == "OSX" ]] ; then
                cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_path"/"${Gateway[$x]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gatewaylc[$x]}"
                else
                cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_path"/"${Gateway[$x]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"
                fi
                rm -r src vendor pkg ;
                    # Changing directory to  binary containing folder
                    cd "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}";
                        if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
							fname="${Gateway[$x]}-$GOOS-$GOARCH.exe" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${Gatewaylc[$x]}.exe" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;												
						fi
                        zip -r "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}" *;
                        cp "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}.zip" ../../"${Gatewaylc[$x]}" ;		
                    cd .. ;
                rm -r "${Gatewaylc[$x]}-${TRAVIS_OS_NAME}" ;
            cd ..;
            # Copying gateway into latest folder
            cp -r "${Gatewaylc[$x]}" ../latest ;
            # Exit if directory not found
		else
			echo "failed to create ${Gatewaylc[$x]} gateway" 
			echo "directory ${Gatewaylc[$x]}" not found
			#exit 1
		fi			
	}
			
	if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
		export GOOS=windows
		export GOARCH=amd64
	fi

create_dest_directory ;
recipe_registry;


	cd ../.. ;
   # Calling function to create recipes binaries 
  #  create_dest_directory ;

    git config user.email "lmekala@tibco.com";
	git config user.name "LakshmiMekala"
	
	
	ls ;
	pwd ;
	git add .;  
	echo "alert -1" ;
	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
    git push ;
