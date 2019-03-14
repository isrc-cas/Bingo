# enter chroot
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

apt-get update && apt-get install --yes dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

# For grub-pc
# more information, refer: https://gist.github.com/sawanoboly/9829017
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | debconf-set-selections

echo "LC_ALL=en_US.UTF-8" >> /etc/environment
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen en_US.UTF-8

# Install packages needed for Live System
apt-get install --yes wget cgroupfs-mount ubuntu-standard casper lupin-casper discover laptop-detect os-prober linux-generic linux-modules-extra-$(uname -r) linux-modules-$(uname -r)

# Install GUI (Optional)
apt-get install --yes ubiquity-frontend-gtk ubuntu-desktop

# install docker
wget -qO- https://get.docker.com/ | sh

# mount cgroupfs for dockerd to start
# see also https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
cgroupfs-mount

# pull tensorflow and pytorch docker image
nohup dockerd &
echo "sleep 10s"
sleep 10
docker pull tensorflow/tensorflow
#docker pull pytorch/pytorch

# stop dockerd
pkill dockerd

cgroupfs-umount

# clean environment
#-------------------------------------------------------------------------------
rm /var/lib/dbus/machine-id
#TODO no such file
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

ls /boot/vmlinuz* > list.txt
sum=$(cat list.txt | grep '[^ ]' | wc -l)

if [ $sum -gt 1 ]; then
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/[(.*\)-\([^0-9][+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get --yes purge
fi

rm list.txt

apt-get clean

rm -rf /tmp/*

rm /etc/resolv.conf

#umount -lf /proc
#umount -lf /sys
#umount -lf /dev
umount -lf /dev/pts

#-------------------------------------------------------------------------------
#Finish clean
echo "Finish clean"
exit