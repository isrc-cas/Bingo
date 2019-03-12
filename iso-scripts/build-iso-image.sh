sudo apt-get update
sudo apt-get install --yes debootstrap

mkdir -p work/chroot
cd work
#sudo debootstrap --arch=$(uname -m) $(lsb_release -cs) chroot https://mirrors.tuna.tsinghua.edu.cn/ubuntu/
sudo debootstrap --arch=amd64 $(lsb_release -cs) chroot https://mirrors.tuna.tsinghua.edu.cn/ubuntu/

# `mount --bind chroot chroot` step is necessary for Docker to run
# For more information, see links below:
# https://github.com/moby/moby/issues/34817#issuecomment-330872420
# http://wiki.baserock.org/guides/build-failures/#index7h2
sudo mount --bind chroot chroot

# The following three commands is necessary, for system call.
# For more information, see links below:
# https://github.com/moby/moby/issues/7585#issuecomment-77587659
sudo mount --bind /dev chroot/dev
sudo mount --bind /sys chroot/sys
sudo mount --bind /proc chroot/proc

sudo cp /etc/hosts chroot/etc/hosts
sudo cp /etc/resolv.conf chroot/etc/resolv.conf
sudo cp /etc/apt/sources.list chroot/etc/apt/sources.list
sudo cp ../in-chroot.sh chroot/root/

# enter chroot environment
sudo chroot chroot /bin/bash /root/in-chroot.sh

#sudo systemctl stop docker.service

#sudo umount chroot/dev
#sudo umount chroot/sys
#sudo umount chroot/proc
#TODO umount chroot
# 暂时无法解决挂载的问题，所以重启后继续
echo "fail to solve umount problem, continue after reboot"
exit