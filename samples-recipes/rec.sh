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
	#	if [ "${TRAVIS_OS_NAME}" == "osx" ] ;then
	#	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
	#	brew install jq
	#	fi
        echo "test 0" ;
		#Extracting publish binaries from recipe_registry.json



#######################################################new code
#		jq -r 'to_entries[] | "\(.key)\t\(.value.url)"' ../../../../mashling-recipes/recipe_registry.json |
#		while read url
#			do
#			echo "url=" $url ;
#			url=$(echo $url | tr -d '"' | tr -d ' ' ) ;
#			echo "url=" $url ;
#			if [[ "$url" == http* ]] ; then
#                    echo "$url" ;
 #                   echo "alert 2" ;
#                    jq -r 'to_entries[] | "\(.key)\t\(.value.publish)"' ../../../../mashling-recipes/recipe_registry.json |
#                    echo "$publish";            
#                else
#                    jq -r 'to_entries[] | "\(.key)\t\(.value.publish)"' ../../../../mashling-recipes/recipe_registry.json |
#                    echo "alert 3" ;
#                    echo "$publish";                              
#                fi
#			done
#############################################################















		array_length=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos | length') ; 
		echo "length of array = $array_length" ;
        tLenA="${#array_length[@]}" ;
		   # for (( j = 0; j < "${tLenA}"; j++ ))
           #     do
                echo "value of j=$j" ;
           #     done
                url=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos[] | .url') ;
                echo "value of url=$url" ;
                url=$(echo $url | tr -d '"') ;
                echo "$url";
                echo "alert 0" ;
                #sepa
                IFS=' ' read -a array_url <<<"$url" ;
                echo "alert 0A" ;
                set | grep ^IFS= ;
                echo "alert 0B" ;
                set | grep ^array_url=\\\|^url= ;
                echo "alert 0C" ;

                for (( i = 0; i < ${#array_url[@]}; i++ ))
                do
                echo "${array_url[$i]}" ;
                done
                


                publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos[] | .publish') ;
                echo "value of publish= $publish";
                url=$(echo $publish | tr -d '"') ;
                echo "$publish";
                echo "alert 0" ;
                #sepa                
                IFS=' ' read -a array_publish <<<"$publish" ;
                set | grep ^IFS= ;                
                set | grep ^array_publish=\\\|^publish= ;
                for (( i = 0; i < ${#array_publish[@]}; i++ ))
                do
                echo "${array_publish[$i]}" ;
                done




                if [[ "$url" == http* ]] ; then
                    echo "$url" ;
                    echo "alert 2" ;
                #    publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos[j].publish') ;
                    echo "$publish";            
                else
                #    publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos[j].publish') ;
                    echo "alert 3" ;
                    echo "$publish";                              
                fi
             #   done
    #    publish=$(cat ../../../../mashling-recipes/recipe_registry.json | jq '.recipe_repos[0].publish') ;
        echo "test 1" ;
		echo "$publish" ;
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
			done

		
			tLen="${#Gateway[@]}"
				
				cd .. ;
	}
			
	if [ "${TRAVIS_OS_NAME}" == "windows" ] ;then
		export GOOS=windows
		export GOARCH=amd64
		multi_os ;
	else
		multi_os ;	
	fi

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
   
