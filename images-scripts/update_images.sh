#!/bin/bash

function checkImage(){
        update_results=`sudo docker pull $1`
        if [[ $update_results =~ "Status: Downloaded newer image" ]]
        then
                echo "$1 : Downloaded newer image!"
                return 1

        elif [[ $update_results =~ "Status: Image is up to date" ]]
        then
                echo "$1 : Image is up to date!"
                return 0
        else
                echo "$1 $update_results " >> 'log.txt'
                return 2
        fi
}
update=false
tmpId=""
tmpTag=""
i=1
while read line
do
  array=(${line// / })
  tag="${array[0]}:${array[1]}"
  echo "$i: $tag"
  let i++
  if [[ $tag =~ "isrc.iscas.ac.cn" ]]
  then
      echo "$tag"
  else
      update=false
      checkImage $tag
      result=$?
      if [[ $result -eq 1 ]]
      then
                update=true
                tmpTag=tag
      fi
  fi
  id=${array[2]}
done < 'tags_list'
