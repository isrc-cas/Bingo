#!/bin/bash
while read line
do
	array=(${line// / })
	if [[ ${array[0]} =~ "isrc.iscas.ac.cn" ]]
	then 
		respo=${array[0]#*/}
		tag=${array[1]}
		echo "$respo:$tag ---"
		#获得镜像的sha256值
		sha256=`curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET  http://192.168.8.10:5000/v2/${respo}/manifests/${tag} 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'`
		#根据sha256，删除对应镜像
		echo `curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://192.168.8.10:5000/v2/${respo}/manifests/${sha256}`
		#垃圾回收
	        echo `docker exec -it registry  /bin/registry garbage-collect  /etc/docker/registry/config.yml`
	fi
done < 'list-config'



