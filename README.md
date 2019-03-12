# bingo

Building Machine Learning Operating System - Scripts and Document
--------------------------------------------------------------------------------

### 现有寒武纪 SDK 及 Docker 镜像使用注意

1. 解压后请先修改两处：
    * 将 `run-cambricon-test-docker.sh` 脚本中的 `Cambricon-Test-V3` 改成 `Cambricon-Test`。
    * 将 `Cambricon-Test-V3.tar` 解压后的文件夹名称 `Cambricon-Test-V3` 改成 `Cambricon-Test`。

2. 导入寒武纪 Docker 镜像命令：
    ```bash
    sudo docker load < cambricon-test-v3.0-docker-image.tar
    ```

制作 ISO 镜像
--------------------------------------------------------------------------------
ISO 镜像脚本使用方法：
```bash
git clone https://isrc.iscas.ac.cn/gitlab/suhang/devops
cd iso-scripts
./build-iso-image.sh #neet sudo
```
**TODO:**
    * 修改启动画面
    * 解决cgroup umount不完全的问题

**Questions:**
    * ISO 镜像中需要包含哪些框架？
    * 只放 CPU 版还是同时也放 GPU 版？

Docker 镜像维护
--------------------------------------------------------------------------------
[:heavy_multiplication_x:] 维护官方仓库和 Deepo 仓库的自动脚本，自动周期推送至位于 http://isrc.iscas.ac.cn/ 服务器的 Registry 仓库
[:heavy_multiplication_x:] Deepo 构建的 Docker 仓库正确性验证，自动化脚本

[:heavy_multiplication_x:] Registry 仓库使用说明
[:heavy_multiplication_x:] [Deepo](https://github.com/ufoym/deepo) 的使用及维护方法

[:heavy_multiplication_x:] 尝试用 Docker 包的方式提供训练数据仓库

寒武纪 Docker 包尝试拆分
--------------------------------------------------------------------------------
TODO
