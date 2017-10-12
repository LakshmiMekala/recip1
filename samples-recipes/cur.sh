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
        echo $publish ;
        publish=$(echo $publish | tr -d ',') ;
        publish=$(echo $publish | tr -d '"') ;
        echo $featured ;
        featured=$(echo $featured | tr -d ',') ;
        featured=$(echo $featured | tr -d '"') ;
        publish_array=("${publish[@]}" "${featured[@]}") ;
        echo ${publish_array[@]} ;
        # removing string duplicates
        publish_array=$(echo "${publish_array[@]}" | xargs -n1 | sort -u | xargs) ;
        IFS=\  read -a Gateway <<<"$publish_array" ;
        set | grep ^IFS= ;
		#separating arrays ny line
        IFS=$' \t\n' ;
		#fetching Gateway
        set | grep ^Gateway=\\\|^publish_array= ;
    }
    
	function recipe_registry()
	{
		#Extracting publish binaries from recipe_registry.json
    	#array_length=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
        array_length=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
    
		echo "Found $array_length recipe providers." ;        
		    for (( j = 0; j < $array_length; j++ ))
                do
                    echo "value of j=$j" ;
                    #eval provider and publish
                   
                    eval xpath_publish='.recipe_repos[$j].publish' ;
                    eval xpath_featured='.recipe_repos[$j].featured' ;           
                
                    publish=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish) ;
                    featured=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_featured) ;
                    #echo "$publish";
                    publish_gateway ;
                    if [[ -d  $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes ]]; then
                        for (( x = 0; x < ${#Gateway[@]}; x++ ))
                            do
                                # creating gateway with values from publish
                                displayImage=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json | jq '.gateway.display_image') ;
                                displayImage=$(echo $displayImage | tr -d '"') ;
                                architecture ;
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
		if [ -d "${Gateway[$x]}" ]; then
             cd "${Gateway[$x]}"  ;
                mv bin "${Gateway[$x]}-${OS_NAME[$k]}" ;
                mv  mashling.json "${Gateway[$x]}.mashling.json" ;
                cp -r "${Gateway[$x]}.mashling.json" "${Gateway[$x]}-${OS_NAME[$k]}" ;
                echo $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"$displayImage"
                if [[ -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"$displayImage" ]]; then
                cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/$displayImage $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"
                echo "alert test";
                fi
                echo "test 123"
                echo "$displayImage";
                rm -r src vendor pkg ;
                    # Changing directory to  binary containing folder
                    cd "${Gateway[$x]}-${OS_NAME[$k]}";
                        if [ "${OS_NAME[$k]}" == "windows" ] ; then
							fname="${Gateway[$x]}-${GOOSystem[$k]}-$GOARCH.exe" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${Gateway[$x]}.exe" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;
                        else
                            fname="${Gateway[$x]}-${GOOSystem[$k]}-$GOARCH" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${Gateway[$x]}" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;												
						fi
                        zip -r "${Gateway[$x]}-${OS_NAME[$k]}" *;
                        cp "${Gateway[$x]}-${OS_NAME[$k]}.zip" ../../"${Gateway[$x]}" ;		
                    cd .. ;
                rm -r "${Gateway[$x]}-${OS_NAME[$k]}" ;
            cd ..;
            # Copying gateway into latest folder
            cp -r "${Gateway[$x]}" ../latest ;
            # Exit if directory not found
		else
			echo "failed to create ${Gateway[$x]} gateway" 
			echo "directory ${Gateway[$x]}" not found
			exit 1
		fi			
	}
			

############################## new code version 1 #############################


create_dest_directory ;
recipe_registry ;

function architecture()
{ 
    GOOSystem=({"linux","darwin","windows"});
    OS_NAME=({"linux","osx","windows"});
    # GOARCH=({"amd64","amd64","amd64"});
			# get length of an array		
			Len="${#GOOSystem[@]}"
				for (( k=0; k < "${Len}"; k++ ));
				do
                    export GOOS="${GOOSystem[$k]}" ;
                    echo "$GOOS" ;
                    export GOARCH=amd64 ;
                    echo "$GOARCH" ;
                    mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                    package_gateway ;            
                        if [[ ! -d $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp ]]; then
                        mkdir -p $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp
                        fi
                        cd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes
                        cp -r $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/* $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp ;
                        rm -rf $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"
                done
}
        mv $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";    
        cd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes ;
        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder" ;
        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest ;
    
############################################################


    # git config user.email "lmekala@tibco.com";
	# git config user.name "LakshmiMekala"
	
	
	# ls ;
	# pwd ;
	# git add .;  
	# echo "alert -1" ;
	# git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
    # git push ;