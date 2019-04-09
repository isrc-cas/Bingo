# Registy使用说明

## Registry REST API
1. 列出所有的镜像仓库（repositories):
  ```sh
  # curl -X GET http://<registry_ip>:<registry_port>/v2/_catalog
  curl -X GET http://192.168.8.10:5000/v2/_catalog
  ```

2. 列出指定镜像的所有标签
  ```sh
  # curl -X GET http://<registry_ip>:<registry_port>/v2/<image_name>/tags/list
  curl -X GET http://192.168.8.10:5000/v2/sonnet-official/tags/list
  ```

3. 删除registry中的镜像
    删除registry比较复杂，需要先查到指定标签的镜像的digest (sha256校验和），再根据这个digest来删除。
    下面以删除192.168.37.100:5000/busybox/:0.0.1 镜像为例。
    - 找到该镜像的digest
      ```sh
      curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET  http://192.168.8.10:5000/v2/sonnet-official/manifests/latest 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'
      ```
      Digest输出例子
      ```sh
      sha256:2fa224fc6720472c6b3bb87b23aba7d61e63f9f0fb074e6f38a71391a9b6ba26
      ```
    - 根据digest删除镜像
      ```sh
      curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://192.168.8.10:5000/v2/sonnet-official/manifests/sha256:2fa224fc6720472c6b3bb87b23aba7d61e63f9f0fb074e6f38a71391a9b6ba26
      ```

      **注意：**
        - 因为缺省Docker private registry不允许删除镜像，如果遇到“405 Unsupported” 错误，需要在运行registry容器时设置REGISTRY_STORAGE_DELETE_ENABLED环境变量或参数为true。
      - 即启动registry容器时使用如下命令
        ```sh
        sudo docker run -d -e REGISTRY_STORAGE_DELETE_ENABLED="true"  -p 5000:5000   --restart=always   --name registry   registry:2
        ```
        这里的删除镜像只是删除了一些元数据，需要执行下面的垃圾回收才能真正地从硬盘上删除镜像数据。

    - 垃圾回收
      进入registry容器，执行garbage-collect 命令执行垃圾回收。
      ```sh
      docker exec -it registry  /bin/registry garbage-collect  /etc/docker/registry/config.yml
      ```

## Registry操作
1. 推送一个镜像到registry
  ```sh
  # docker push <registry_ip>:<registry_port>/<image_name>:<image_tag>
  docker push isrc.iscas.ac.cn/sonnet-official:latest
  ```
2. 从registry拉取一个镜像
  ```sh
  # docker pull <registry_ip>:<registry_port>/<image_name>:<image_tag>
  docker pull isrc.iscas.ac.cn/sonnet-official:latest
  ```
3. 更新registry上的镜像
    首先删除registry中该镜像（上述三步骤），再push新的镜像

## Registry相关配置
1. Registry容器删除重新创建后，需要将Registry容器添加到plateforms网络中，才能通过nginx配置的isrc.iscas.ac.cn域名push/pull镜像。（需要保持Registry容器与nginx在同一网络中）在portainer docker管理页面中设置。
