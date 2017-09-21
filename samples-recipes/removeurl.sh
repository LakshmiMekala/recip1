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
		ruby -e "$(cprovider -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
		brew install jq
	#	fi
		#Extracting publish binaries from recipe_registry.json
    	#array_length=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
        array_length=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 

		echo "Found $array_length recipe providers." ;        
		    for (( j = 0; j < $array_length; j++ ))
                do
                    echo "value of j=$j" ;
                    #eval provider and publish
                   
                    eval xpath_publish='.recipe_repos[$j].publish' ;           
                
                    publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                    echo "$publish";
                    publish_gateway ;
                    if [[ -d  $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes ]]; then
                        for (( x = 0; x < ${#Gateway[@]}; x++ ))
                            do
                                # creating gateway with values from publish
                                # if [ ! "${TRAVIS_OS_NAME}" == "OSX" ] ;then
                                # echo "${Gateway[$x]}" ;
                                # gwname="${Gateway[$x]}" ;
                                # echo "$gwname" ;
                                # Gatewaylc[$x]="${gwname,,}" ;
                                # echo "${Gatewaylc[$x]}" ;
                                # fi 
                                displayImage=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json | jq '.gateway.display_image') ;
                                mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                package_gateway ;
                            done                              
                    else
                        echo "exiting the build as provider path is not a directory" ;
                      #  exit 1 ;
                    fi                    
            done                  	
	}

    function package_gateway()
	{
		# If directory exists proceed to next steps	
		if [ -d "${Gateway[$x]}" ]; then
             cd "${Gateway[$x]}"  ;
                mv bin "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                mv  mashling.json "${Gateway[$x]}.mashling.json" ;
                cp -r "${Gateway[$x]}.mashling.json" "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                #cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"displayImage.svg" $GOPATH/src/github.com/TIBCOSoftware/mashling-cicd/master-builds/"$destFolder"/"${Gateway[$x]}" ;
                # if [[ ! "${TRAVIS_OS_NAME}" == "OSX" ]] ; then
                if [[ -f "$displayImage" ]]; then
                #cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/*.svg $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"
                cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/$displayImage $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"
                echo "alert test";
                fi
                echo "test 123"
                echo "$displayImage";
                pushd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}" ;
                ls ;
                echo "test 1"
                popd ;
                # else
                # cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/displayImage.svg $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"
                # echo "test 1234"
                # fi
                rm -r src vendor pkg ;
                    # Changing directory to  binary containing folder
                    cd "${Gateway[$x]}-${TRAVIS_OS_NAME}";
                        if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
							fname="${Gateway[$x]}-$GOOS-$GOARCH.exe" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${Gateway[$x]}.exe" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;												
						fi
                        zip -r "${Gateway[$x]}-${TRAVIS_OS_NAME}" *;
                        cp "${Gateway[$x]}-${TRAVIS_OS_NAME}.zip" ../../"${Gateway[$x]}" ;		
                    cd .. ;
                rm -r "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
            cd ..;
            # Copying gateway into latest folder
            cp -r "${Gateway[$x]}" ../latest ;
            # Exit if directory not found
		else
			echo "failed to create ${Gateway[$x]} gateway" 
			echo "directory ${Gateway[$x]}" not found
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
 #   git push ;
