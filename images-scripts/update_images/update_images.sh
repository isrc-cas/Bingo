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
<<<<<<< HEAD:images-scripts/update_images/update_images.sh
  array=(${line// / })
  tag="${array[0]}:${array[1]}"
  if [[ $tag =~ "isrc.iscas.ac.cn" ]] 
  then 
      	if [[ $update == true ]] 
      	then
     	 	echo `docker tag $tmpTag $tag`
                #获得镜像的sha256值
		respo=${array[0]#*/}
                sha256=`curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET  http://192.168.8.10:5000/v2/${respo}/manifests/${array[1]} 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'`
                if [-n "$sha256"]
		then
			#根据sha256，删除对应镜像
                	echo `curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://192.168.8.10:5000/v2/${respo}/manifests/${sha256}`
               		#垃圾回收
	        	echo `docker exec -it registry  /bin/registry garbage-collect  /etc/docker/registry/config.yml`
		fi
		#上传新镜像
		echo `docker push $tag`
=======
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
>>>>>>> b31691f77c2700110b2df53346ac72ada79abaf0:images-scripts/update_images.sh
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
