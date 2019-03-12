# enter chroot
mount none -t devpts /dev/pts
export HOME=/root
export LC_ALL=C

apt-get update
apt-get install --yes dbus
dbus-uuidgen > /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl

# install docker
sudo apt-get install --yes wget
wget -qO- https://get.docker.com/ | sh

# mount cgroupfs for Docker pull operation
cgroupfs_mount() {
        # see also https://github.com/tianon/cgroupfs-mount/blob/master/cgroupfs-mount
        if grep -v '^#' /etc/fstab | grep -q cgroup \
                || [ ! -e /proc/cgroups ] \
                || [ ! -d /sys/fs/cgroup ]; then
                return
        fi
        if ! mountpoint -q /sys/fs/cgroup; then
                mount -t tmpfs -o uid=0,gid=0,mode=0755 cgroup /sys/fs/cgroup
        fi
        (
                cd /sys/fs/cgroup
                for sys in $(awk '!/^#/ { if ($4 == 1) print $1 }' /proc/cgroups); do
                        mkdir -p $sys
                        if ! mountpoint -q $sys; then
                                if ! mount -n -t cgroup -o $sys cgroup $sys; then
                                        rmdir $sys || true
                                fi
                        fi
                done
        )
}
cgroupfs_mount

# pull tensorflow and pytorch docker image
nohup dockerd &
echo "sleep 5s"
sleep 5
docker pull tensorflow/tensorflow
#docker pull pytorch/pytorch

# stop dockerd
pkill dockerd

# umount cgroupfs
cd /sys/fs/cgroup
for sys in *; do
    if mountpoint -q $sys; then
        umount $sys
    fi
    if [ -d $sys ]; then
        rmdir $sys || true
    fi
done
cd -

ln -s /bin/true /sbin/initctl

# install grub-pc
# For more information, see: https://gist.github.com/sawanoboly/9829017
echo "grub-pc grub-pc/install_devices multiselect /dev/sda" | debconf-set-selections
apt-get install --yes grub-pc

# Install packages needed for Live System
apt-get install --yes ubuntu-standard casper lupin-casper
apt-get install --yes discover laptop-detect os-prober
apt-get install --yes linux-generic

# Install GUI (Optional)
apt-get install --yes ubiquity-frontend-gtk

# clean environment
#-------------------------------------------------------------------------------
rm /var/lib/dbus/machine-id
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
#umount -lf /dev/pts

#-------------------------------------------------------------------------------
#Finish clean
exit