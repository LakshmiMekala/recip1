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
                    provider_url=$(echo $url | tr -d '"') ;
                    echo "provider_url is $provider_url";
                    # regular expression for validating URL
                    regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'              
                            #checking if url contains http or not
                            if [[ "$provider_url" =~ $regex ]] ; then
                                path_url=$provider_url ;
                                    if [[ ! $provider_url == *[.git] ]] ; then
                                        path_url=$path_url.git ;    
                                    fi
                                fname=$(echo $path_url | rev | cut -d '/' -f 1 | rev);
                                fname=$(echo $fname | cut -f1 -d '.');
                                echo $fname
                                pushd $GOPATH/src/github.com/TIBCOSoftware ;
                                git clone $path_url "$fname" ;
                                popd ;
                                #publish_gateway ;
                                publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                                echo "$publish";
                                publish_gateway ;
                                    for (( x = 0; x < ${#Gateway[@]}; x++ ))
                                        do
                                        # creating gateway with values from publish
                                        echo "${Gateway[$x]}" ;
                                        mashling create -f $GOPATH/src/github.com/TIBCOSoftware/"$fname"/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                        package_gateway ;
                                        done 
                                                                                                                                                                             
                            else
                                echo "alert 3" ;
                                publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                                echo "$publish";
                                publish_gateway ;
                                    for (( x = 0; x < ${#Gateway[@]}; x++ ))
                                        do
                                            # creating gateway with values from publish
                                            echo "${Gateway[$x]}" ;
                                            mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/"$provider_url"/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                            package_gateway ;
                                        done                              
                            fi
            done                  	
	}

    function package_gateway()
	{
		# If directory exists proceed to next steps	
		if [ -d "${Gateway[$x]}" ]; then
            cd "${Gateway[$x]}"  ;
                mv bin "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
            #    mashling build ;
            #    cp -r bin/flogo.json ../"${Gateway[$x]}" ;
            #    cp -r bin/flogo.json "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                mv  mashling.json "${Gateway[$x]}.mashling.json"
                cp -r "${Gateway[$x]}.mashling.json" "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
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
	echo "alert 0" ;
#	git push -u origin historical-builds;
	echo "alert A 1" ;
#	git stash
	echo "alert 1" ;
#	git checkout master;
	echo "alert 2" ;
#	git checkout historical-builds -- latest ;
#	git add latest ;
	echo "alert 3" ;
#	git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
	echo "alert 4" ;
#	git push -u origin master;
	echo "alert 5" ;
