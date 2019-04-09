#!/bin/bash
while read line; do
  array=(${line// / })
  if [[ ${array[0]} =~ "isrc.iscas.ac.cn" ]]; then
    respo=${array[0]#*/}
    tag=${array[1]}
    echo "$respo:$tag ---"
    #get sha256 of image
    sha256=$(curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET  http://192.168.8.10:5000/v2/${respo}/manifests/${tag} 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}')
    #delete image according to sha256
    echo $(curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://192.168.8.10:5000/v2/${respo}/manifests/${sha256})
    #garbage-collect
    echo $(docker exec -it registry  /bin/registry garbage-collect  /etc/docker/registry/config.yml)
  fi
done < 'list-config'
