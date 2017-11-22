#!/bin/bash
	
#    aws cp -r $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds
	name="${TRAVIS_REPO_SLUG}" ;
	namefolder=${name:14} ;
	pushd $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes
    # Fetching short commit id
    commitId=$(git diff --name-only HEAD~1) ;
    echo $commitId
    #Copying files changed in commit to info.log file
    echo $(git log -m -1 --name-status $commitId) >> $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/info.log ;
    recipeName=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/info.log) ;
    popd ;
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
                    var y=0;
                    echo $recipeName ;
                    echo "${Gateway[$x]}/${Gateway[$x]}.json" ;
                    echo "${Gateway[$x]}/manifest" ;
                    if [[ $recipeName =~ ${Gateway[$x]}/${Gateway[$x]}.json ]] || [[ $recipeName =~ ${Gateway[$x]}/manifest ]];then
                        echo "${Gateway[$x]} found in current commit" ;
                        echo "${Gateway[$x]}" ;                        
                        recipeCreate[y]=${Gateway[$x]} ;
                        echo "value for ${Gateway[$x]}=recipeCreate[y]" ;
                        echo "$recipeCreate[y]" ;
                        y=y+1 ;
                    else
                        echo "${Gateway[$x]} not found in current commit ";
                    #    recipeDelete=$Gateway[$x] ;
                    fi
                    recipeInfo ;                                                          
                done
            done                  	
	}

    function buildgateway()
    {
        tLen="${#recipeCreate[@]}" ;
        for (( y=0; y<"${tLen}"; y++ ))
        # if [[ -d  $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes ]]; then
        #                         # creating gateway with values from publish
        #                         displayImage=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json | jq '.gateway.display_image') ;
        #                         displayImage=$(echo $displayImage | tr -d '"') ;
        #                         mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${Gateway[$x]}"/"${Gateway[$x]}".json "${Gateway[$x]}";
        #                         binarycheck ;                         
        # else
        #                 echo "exiting the build as provider path is not a directory" ;
        #                 exit 1 ;
        # fi  
        do
        if [[ -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/${recipeCreate[$y]}/${recipeCreate[$y]}.json ]] || [[ -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/${recipeCreate[$y]}/manifest ]] ; then
            displayImage=$(cat $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${recipeCreate[$y]}"/"${recipeCreate[$y]}".json | jq '.gateway.display_image') ;
            displayImage=$(echo $displayImage | tr -d '"') ;
            mashling create -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${recipeCreate[$y]}"/"${recipeCreate[$y]}".json "${recipeCreate[$y]}";
            binarycheck ;
        #    recipeInfo ;
        fi
        done
    }

    function binarycheck()
    {
        if [ "${OS_NAME[$k]}" == "windows" ] ; then
            fname="${recipeCreate[$y]}-${GOOSystem[$k]}-$GOARCH.exe" ;
            fnamelc="${fname,,}" ;
            if [[ -f $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${recipeCreate[$y]}"/bin/$fnamelc ]];then
               package_gateway ;
            else
               echo "${recipeCreate[$y]} binary not found"
               exit 1;     
            fi
        else
            fname="${recipeCreate[$y]}-${GOOSystem[$k]}-$GOARCH" ;
            fnamelc="${fname,,}" ;
            if [[ -f $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${recipeCreate[$y]}"/bin/$fnamelc ]] ;then
                package_gateway ;
            else
                echo "${recipeCreate[$y]} binary not found"
                exit 1;
            fi        
        fi 
    }

    function package_gateway()
	{
		# If directory exists proceed to next steps	
		if [ -d "${recipeCreate[$y]}" ]; then
             cd "${recipeCreate[$y]}"  ;
                mv bin "${recipeCreate[$y]}-${OS_NAME[$k]}" ;
                mv  mashling.json "${recipeCreate[$y]}.mashling.json" ;
                cp -r "${recipeCreate[$y]}.mashling.json" "${Gateway[$x]}-${OS_NAME[$k]}" ;
                echo $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${recipeCreate[$y]}"/"$displayImage"
                if [[ -f $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${recipeCreate[$y]}"/"$displayImage" ]]; then
                cp -r $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipes/"${recipeCreate[$y]}"/$displayImage $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/"${recipeCreate[$y]}"
                echo "alert test";
                fi
                echo "test 123"
                echo "$displayImage";
                rm -r src vendor pkg ;
                    # Changing directory to  binary containing folder
                    cd "${recipeCreate[$y]}-${OS_NAME[$k]}";
                        if [ "${OS_NAME[$k]}" == "windows" ] ; then
							fname="${recipeCreate[$y]}-${GOOSystem[$k]}-$GOARCH.exe" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${recipeCreate[$y]}.exe" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;
                        else
                            fname="${recipeCreate[$y]}-${GOOSystem[$k]}-$GOARCH" ;
							echo "$fname" ;
							fnamelc="${fname,,}" ;
							echo "$fnamelc" ;													
							destfname="${recipeCreate[$y]}" ;
							echo "$destfname" ;
							destfnamelc="${destfname,,}" ;
							echo "$destfnamelc" ;
							mv $fnamelc $destfnamelc ;												
						fi
                        zip -r "${recipeCreate[$y]}-${OS_NAME[$k]}" *;
                        cp "${recipeCreate[$y]}-${OS_NAME[$k]}.zip" ../../"${recipeCreate[$y]}" ;		
                    cd .. ;
                rm -r "${recipeCreate[$y]}-${OS_NAME[$k]}" ;
            cd ..;
            # Copying gateway into latest folder
            cp -r "${recipeCreate[$y]}" ../latest ;
            # Exit if directory not found
		else
			echo "failed to create ${recipeCreate[$y]} gateway" 
			echo "directory ${recipeCreate[$y]}" not found
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
                        buildgateway ; 
                        cp -r $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"/* $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp ;
                        rm -rf $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder"
                done

        mv $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/tmp $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";    
        cd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes ;

        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";
        cp $GOPATH/src/github.com/TIBCOSoftware/mashling-recipes/recipe_registry.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest;
        
        
        
        
        pushd $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp ;
        echo "alert json 4" ;
        jq -s '.' recipe-*.json > recipeinfo.json
        echo "alert json 5" ;
        cp recipeinfo.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest
        cp recipeinfo.json $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/"$destFolder";
        echo "alert json 6" ;
        rm -rf $GOPATH/src/github.com/TIBCOSoftware/recip1/samples-recipes/master-builds/latest/temp ;
        git add .
        git commit -m "uploading v1"
        git push
        popd ;





    

