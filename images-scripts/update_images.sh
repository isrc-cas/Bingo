#!/bin/bash

function checkImage(){
	update_results=`sudo docker pull $1`
	if [[ $update_results =~ "Status: Downloaded newer image" ]]
	then
    		echo "$1 : Downloaded newer image!" >>  "$2.log"
		return 1

	elif [[ $update_results =~ "Status: Image is up to date" ]]
	then
    		echo "$1 : Image is up to date!"
		return 0
	else
		echo "$1 : Error $update_results" >> "$2.log"
		return 2
	fi
}
current=`date "+%Y-%m-%d-%H:%M:%S"`
logname="image_updated_$current"
update=false
#tmpId=""
tmpTag=""
i=1
while read line
do
  array=(${line// / })
  if [[ ${array[0]} =~ "isrc.iscas.ac.cn" ]]
  then 
     tag="${array[0]}-official:${array[1]}"
  else
     tag="${array[0]}:${array[1]}"
  fi
  if [[ $tag =~ "isrc.iscas.ac.cn" ]] 
  then 
      	if [[ $update == true ]] 
      	then
     	 	echo `docker tag $tmpTag $tag`
      		#echo `docker push $tmpTag $tag`
        fi
  else
	echo "$i: $tag"
        let i++
      	update=false
      	checkImage $tag $logname
      	result=$?
      	if [[ $result -eq 1 ]]
      	then 
         	update=true
          	tmpTag=$tag 
      	fi
  fi
  	#id=${array[2]}
done < 'list-config'
