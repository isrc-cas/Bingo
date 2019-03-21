# docker pull 下列 tag，无法找到镜像源

- dynet-x86_64:latest
    > https://github.com/clab/dynet/blob/master/docker/Dockerfile-x86_64
    > dynet 是手动打的 tag，详见上面的Dockerfile
    > 下同
    > 修正为：quay.io/pypa/manylinux1_x86_64
- dynet-i686:latest
    > 修正为：quay.io/pypa/manylinux1_i686
- pytorch/glow-0.1:latest
    > https://github.com/pytorch/glow/blob/84fd82b2786aba5ef355b197315158bd87d8f389/utils/docker/build.sh
    > 需要手动生成docker镜像，单独处理
- deeposregistry.com/ubuntu:latest
    > 这个镜像意义不明，建议删除
    > 已删除
- caffe2/caffe2:latest
    > https://hub.docker.com/r/caffe2/caffe2/tags
    > caffe2/caffe2 的拉取需要显式指明想要拉取的 tag
    > 已删除该tag

    > 建议在找不到的时候，可以去github官方仓库当中搜索`docker`，往往能找到一些资料
