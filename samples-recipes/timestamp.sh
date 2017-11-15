#!/bin/bash
	
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	mkdir -p time
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
        echo "Creating folder - $destFolder /"
        cd "$destFolder";
	}
	
    function publish_gateway()
    {
        publish=$(echo $publish | tr -d ',') ;
        publish=$(echo $publish | tr -d '"') ;
        echo $publish ;
        # removing string duplicates
        publish=$(echo "$publish" | xargs -n1 | sort -u | xargs) ;
        IFS=\  read -a Gateway <<<"$publish" ;
        set | grep ^IFS= ;
		#separating arrays ny line
        IFS=$' \t\n' ;
		#fetching Gateway
        set | grep ^Gateway=\\\|^publish= ;
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

            publish_length=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_publish' | length') ; 
		    echo "Found $publish_length recipes." ;        
		        for (( x=0; x<$publish_length; x++ ))
                do  
                    eval xpath_recipe='.recipe_repos[$j].publish[$x].recipe' ;
                    Gateway[$x]=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_recipe) ;

                    Gateway[$x]=$(echo ${Gateway[$x]} | tr -d '"') ;

                    if [[ -d  $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes ]]; then
                                # creating gateway with values from publish
                                displayImage=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json | jq '.gateway.display_image') ;
                                displayImage=$(echo $displayImage | tr -d '"') ;
                                echo "Start time for creating ${Gateway[$x]} :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
                                mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
                                echo "End time for creating ${Gateway[$x]} :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
                                binarycheck ;
                                recipeInfo ;                          
                    else
                        echo "exiting the build as provider path is not a directory" ;
                        exit 1 ;
                    fi                    
            done
            done                  	
	}

    function binarycheck()
    {
        if [ "${OS_NAME[$k]}" == "windows" ] ; then
            fname="${Gateway[$x]}-${GOOSystem[$k]}-$GOARCH.exe" ;
            fnamelc="${fname,,}" ;
            if [[ -f $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"/bin/$fnamelc ]];then
               package_gateway ;
            else
               echo "${Gateway[$x]} binary not found"
               exit 1;     
            fi
        else
            fname="${Gateway[$x]}-${GOOSystem[$k]}-$GOARCH" ;
            fnamelc="${fname,,}" ;
            if [[ -f $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${Gateway[$x]}"/bin/$fnamelc ]] ;then
                echo "Start time for packing to zip ${Gateway[$x]} :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
                package_gateway ;
                echo "End time for packing ${Gateway[$x]} :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
            else
                echo "${Gateway[$x]} binary not found"
                exit 1;
            fi        
        fi 
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

    function recipeInfo()
    {
        if [[ "${GOOSystem[$k]}" == windows ]]; then      

        echo "alert json 1" ; 
        idvalue="${Gateway[$x]}" ;   
        eval xpath_featured='.recipe_repos[$j].publish[$x].featured' ;
        featuredvalue=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json | jq $xpath_featured) ;
        sourceURL=https://github.com/TIBCOSoftware/mashling-recipes/tree/master/recipes/${Gateway[$x]} ;
        echo "$sourceURL";
        jsonURL=/${Gateway[$x]}/${Gateway[$x]}.mashling.json ;
        imageURL=/${Gateway[$x]}/$displayImage ;
        macurl=/${Gateway[$x]}/${Gateway[$x]}-osx.zip ;
        linuxurl=/${Gateway[$x]}/${Gateway[$x]}-linux.zip ;
        windowsurl=/${Gateway[$x]}/${Gateway[$x]}-windows.zip ;

        echo "alert json 2" ;
        jo -p id=$idvalue featured=$featuredvalue repository_url=$sourceURL json_url=$jsonURL image_url=$imageURL binaries=[$(jo  platform=mac url=$macurl),$(jo  platform=linux url=$linuxurl),$(jo  platform=windows url=$windowsurl)] >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp/recipe1-[$x].json ;
        echo "alert json 3" ;
        jq -s '.[0] * .[1]' $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp/recipe1-[$x].json >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp/recipe-[$x].json ;
        fi
    } 		

############################## new code version 1 #############################

    GOOSystem=({"linux","darwin","windows"});
    OS_NAME=({"linux","osx","windows"});
    # GOARCH=({"amd64","amd64","amd64"});
			# get length of an array		
			Len="${#GOOSystem[@]}"
				for (( k=0; k < "${Len}"; k++ ));
				do
                    export GOOS="${GOOSystem[$k]}" ;
                    echo $GOOS ;
                    echo $GOARCH ;
                    export GOARCH=amd64 ;
                        if [[ ! -d $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp ]]; then
                        mkdir -p $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp
                        fi
                        cd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes
                        create_dest_directory ;
                        recipe_registry ;
                        cp -r $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/* $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp ;
                        rm -rf $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"
                done

        mv $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";    
        cd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes ;

        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";
        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest;
        
        
        
        
        pushd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp ;
        echo "alert json 4" ;
        echo "Start time for creating recipeinfo.json file :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
        jq -s '.' recipe-*.json > recipeinfo.json
        echo "End time for creating recipeinfo.json file :$(date +"%F %T")" >> $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/time/time-$TRAVIS_BUILD_NUMBER.log
        echo "alert json 5" ;
        cp recipeinfo.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest
        cp recipeinfo.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";
        echo "alert json 6" ;
        rm -rf $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp ;
        popd ;


############################################################


      git config user.email "lmekala@tibco.com";
	  git config user.name "LakshmiMekala"
	
	 pushd $GOPATH/src/github.com/TIBCOSoftware/recip1 ;
	# # ls ;
	# # pwd ;
	  git add .;  
	# # echo "alert -1" ;
	 git commit -m "uploading binaries-${TRAVIS_BUILD_NUMBER}";
     git push ;
     popd 




    

