# docker pull 下列 tag，无法找到镜像源

- dynet-x86_64:latest
    > https://github.com/clab/dynet/blob/master/docker/Dockerfile-x86_64
    > 修正为：quay.io/pypa/manylinux1_x86_64
        > manylinux有点意义不明，建议手动修改为dynet，这个镜像在脚本中特殊处理吧。下同。
- dynet-i686:latest
- pytorch/glow-0.1:latest
    > https://github.com/pytorch/glow/blob/84fd82b2786aba5ef355b197315158bd87d8f389/utils/docker/build.sh
    > 需要手动生成docker镜像，单独处理

> 处理完所有问题之后可以删除该文件,需要提醒注意的地方在脚本中以注释的形式写出。
