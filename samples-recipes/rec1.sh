#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	
	function multi_os ()
	{
		cd master-builds ;
		if [ -n "${TRAVIS_TAG}" ]; then
			echo Creating build with release version:"${TRAVIS_TAG}";
				if [ -d "$namefolder-${TRAVIS_TAG}" ]; then			
					cd "$namefolder-${TRAVIS_TAG}";
					recipe_registry;
				else
					mkdir "$namefolder-${TRAVIS_TAG}";
					cd "$namefolder-${TRAVIS_TAG}";
					recipe_registry;				
				fi
		 fi	
		if [ -z "${TRAVIS_TAG}" ]; then
			echo Creating build with travis build number:"${TRAVIS_BUILD_NUMBER}" ;
				if [ -d "$namefolder-${TRAVIS_BUILD_NUMBER}" ]; then			
					cd "$namefolder-${TRAVIS_BUILD_NUMBER}";
					recipe_registry;
				else
					mkdir "$namefolder-${TRAVIS_BUILD_NUMBER}";
					cd "$namefolder-${TRAVIS_BUILD_NUMBER}";
					recipe_registry;				
				fi
		fi
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
    	array_length=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
		echo "length of array = $array_length" ;        
		    for (( j = 0; j < $array_length; j++ ))
                do
                    echo "value of j=$j" ;
                    #eval url and publish
                    eval xpath='.recipe_repos[$j].url' ;
                    eval xpath_publish='.recipe_repos[$j].publish' ;           
                    url=$(cat ../../../../mashling-recipes/recipe_registry.json | jq $xpath ) ;
                    echo "value of url=$url" ;
                    url=$(echo $url | tr -d '"') ;
                    echo "$url";
                    #Removing space from array
                    IFS=' ' read -a array_url <<<"$url" ;
                    set | grep ^IFS= ;
                    set | grep ^array_url=\\\|^url= ;
                    for (( k = 0; k < 1; k++ ))
                        do
                            echo "${array_url[$k]}" ;
                        done
                            #checking if url contains http or not
                            if [[ "$array_url" == http* ]] ; then
                                path_url=$array_url ;
                                fname=$(echo $path_url | rev | cut -d '/' -f 1 | rev);
                                echo $fname
                                    #if URL contains github.com clone github in TIBCOSoftware GOPATH 
                                    if [[ "$array_url" == *github.com* ]] ; then
                                        pushd $GOPATH/src/github.com/TIBCOSoftware ;
                                        git clone $array_url.git "$fname" ;
                                        popd ;
                                        #publish_gateway ;
                                        publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                                        echo "$publish";
                                        publish_gateway ;
                                            for (( x = 0; x < ${#Gateway[@]}; x++ ))
                                                do
                                                    # creating gateway with values from publish
                                                    echo "${Gateway[$x]}" ;
                                                    mashling create -f ../../../../"$fname"/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                                    create_gateway ;
                                                    done											
                                    fi                                                                                                       
                            else
                                echo "alert 3" ;
                                publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                                echo "$publish";
                                publish_gateway ;
                                    for (( x = 0; x < ${#Gateway[@]}; x++ ))
                                        do
                                            # creating gateway with values from publish
                                            echo "${Gateway[$x]}" ;
                                            mashling create -f ../../../../mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                            create_gateway ;
                                        done                              
                            fi
            done                  	
	}

    function create_gateway()
	{
		# If directory exists proceed to next steps	
		if [ -d "${Gateway[$x]}" ]; then
            cd "${Gateway[$x]}"  ;
                mv bin "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                mashling build ;
                cp -r bin/flogo.json ../"${Gateway[$x]}" ;
                cp -r bin/flogo.json "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                mv  mashling.json "${Gateway[$x]}.mashling.json"
                cp -r "${Gateway[$x]}.mashling.json" "${Gateway[$x]}-${TRAVIS_OS_NAME}" ;
                rm -r bin src vendor pkg ;
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
		multi_os ;
	else
		multi_os ;	
	fi

	cd ../.. ;
   # Calling function to create recipes binaries 
  #  multi_os ;

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
   
