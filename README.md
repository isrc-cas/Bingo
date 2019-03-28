# bingo

Building Machine Learning Operating System - Scripts and Document
--------------------------------------------------------------------------------

### 现有寒武纪 SDK 及 Docker 镜像使用注意

1. 解压后请先修改两处：
  - 将 `run-cambricon-test-docker.sh` 脚本中的 `Cambricon-Test-V3` 改成 `Cambricon-Test`。
  - 将 `Cambricon-Test-V3.tar` 解压后的文件夹名称 `Cambricon-Test-V3` 改成 `Cambricon-Test`。

2. 导入寒武纪 Docker 镜像命令：
  ```sh
  sudo docker load < cambricon-test-v3.0-docker-image.tar
  ```

制作 ISO 镜像
--------------------------------------------------------------------------------
ISO 镜像脚本使用方法：
```sh
git clone https://isrc.iscas.ac.cn/gitlab/riscv/bingo
cd iso-scripts
./build-iso-image.sh # need sudo
```

**TODO:**
  - 修改启动画面
  - 解决 ISO 镜像安装过程报错

**Questions:**
  - ISO 镜像中需要包含哪些框架？
  - 只放 CPU 版还是同时也放 GPU 版？

Docker 镜像维护
--------------------------------------------------------------------------------
| 完成情况                 |                                              任务                                                       |
| :----------------------: | :-----------------------------------------------------------------------------------------------------: |
| :heavy_check_mark:       | 维护官方仓库和 Deepo 仓库的自动脚本，自动周期推送至位于 http://isrc.iscas.ac.cn/ 服务器的 Registry 仓库 |
| :heavy_multiplication_x: | Deepo 构建的 Docker 仓库正确性验证，自动化脚本                                                          |
| :heavy_multiplication_x: | Registry 仓库使用说明文档                                                                               |
| :heavy_multiplication_x: | [Deepo](https://github.com/ufoym/deepo) 的使用及维护方法                                                |
| :heavy_multiplication_x: | 尝试用 Docker 包的方式提供训练数据仓库                                                                  |

寒武纪 Docker 镜像
--------------------------------------------------------------------------------

寒武纪镜像尝试拆分完成，目前支持框架如下：

| REPOSITORY                            |  TAG    | size    |
| :-----------------------------------: | :-----: | :-----: |
| isrc.iscas.ac.cn/tensorflow-cambricon |  latest | 2.51GB  |
| isrc.iscas.ac.cn/caffe-cambricon      |  latest | 3.1GB   |
| isrc.iscas.ac.cn/mxnet-cambricon      |  latest | 2.68GB  |

#### TODO

将模型文件和训练图片等文件，以镜像的方式提供，在数据容器内运行 NFS 之类的服务，以此与执行容器共享数据．

寒武纪镜像生成：
```sh
sudo docker build -t caffe-cambricon:latest -f ../caffe.Dockerfile .
sudo docker build -t mxnet-cambricon:latest -f ../mxnet.Dockerfile .
sudo docker build -t tensorflow-cambricon:latest -f ../tensorflow.Dockerfile .
```

寒武纪容器运行方法：
```sh
sudo docker run -it   --privileged  --rm \
-v /home/iscas-x/build-cambricon-docker-images/dataset-image/dataset/:/home/Cambricon/dataset \
caffe-cambricon bash
```

在容器中运行 examples：
```sh
cd caffe/examples/classification/classification_offline_multicore/
./run.sh alexnet dense float16 1 4 8
```

#### 注意
1. `-v /lib/:/lib`/lib 目录的挂载是在容器中 load 驱动程序的关键。
2.  `tools/ cnrt/ cnml/` 等路径为寒武纪 runtime 所必须依赖的链接库，而非额外的不知名框架。
