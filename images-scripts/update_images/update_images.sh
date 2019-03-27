#!/bin/bash

function checkImage(){
  update_results=$(sudo docker pull "$1")
  if [[ $update_results =~ "Status: Downloaded newer image" ]];then
      echo "$1 : Downloaded newer image!" >>  "$2.log"
    return 1
  elif [[ $update_results =~ "Status: Image is up to date" ]];then
      echo "$1 : Image is up to date!"
    return 0
  else
      echo "$1 : Error $update_results" >> "$2.log"
    return 2
  fi
}
current=$(date "+%Y-%m-%d-%H:%M:%S")
logname="image_updated_$current"
update=false
#tmpId=""
tmpTag=""
i=1
while read line; do
  array=(${line// / })
  tag="${array[0]}:${array[1]}"
  if [[ $tag =~ isrc.iscas.ac.cn ]]; then
    if [[ $update == true ]]; then
      docker tag $tmpTag "$tag"
      #get sha256 of docker image
      respo=${array[0]#*/}
      sha256=$(curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET  http://192.168.8.10:5000/v2/"${respo}"/manifests/"${array[1]}" 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}')
      if [ -n "$sha256" ]; then
        #delete the image according to sha256
        curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://192.168.8.10:5000/v2/"${respo}"/manifests/"${sha256}"
        #garbage collect
        docker exec -it registry  /bin/registry garbage-collect  /etc/docker/registry/config.yml
      fi
      #upload the image
      docker push "$tag"
    fi
  else
    echo "$i: $tag"
    (( i++ ))
    update=false
    checkImage "$tag" "$logname"
    result=$?
    if [[ $result -eq 1 ]]; then
      update=true
      tmpTag=$tag
    fi
  fi
done < 'list-config' 
