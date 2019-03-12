cd work
sudo apt-get install --yes syslinux squashfs-tools genisoimage
mkdir -p image/{casper,isolinux,install}

#TODO vmlinuz need sudo, is that right?
sudo cp chroot/boot/vmlinuz-* image/casper/vmlinuz
sudo cp chroot/boot/initrd.img* image/casper/initrd.lz

# Install isolinux
sudo apt-get install --yes isolinux
cp /usr/lib/ISOLINUX/isolinux.bin image/isolinux/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 image/isolinux/ # for syslinux 5.00 and newer

cp /boot/memtest86+.bin image/install/memtest

#-------------------------------------------------------------------------------
cat << EOF >> image/isolinux/isolinux.txt
splash.rle

************************************************************************

This is an Ubuntu Remix Live CD.

For the default live system, enter "live".  To run memtest86+, enter "memtest"

************************************************************************
EOF

#-------------------------------------------------------------------------------
cat << EOF >> image/isolinux/isolinux.cfg
DEFAULT live
LABEL live
  menu label ^Start or install Ubuntu Remix
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/ubuntu.seed boot=casper initrd=/casper/initrd.lz quiet splash --
LABEL check
  menu label ^Check CD for defects
  kernel /casper/vmlinuz
  append  boot=casper integrity-check initrd=/casper/initrd.lz quiet splash --
LABEL memtest
  menu label ^Memory test
  kernel /install/memtest
  append -
LABEL hd
  menu label ^Boot from first hard disk
  localboot 0x80
  append -
DISPLAY isolinux.txt
TIMEOUT 300
PROMPT 1

#prompt flag_val
#
# If flag_val is 0, display the "boot:" prompt
# only if the Shift or Alt key is pressed,
# or Caps Lock or Scroll lock is set (this is the default).
# If  flag_val is 1, always display the "boot:" prompt.
#  http://linux.die.net/man/1/syslinux   syslinux manpage
EOF

#-------------------------------------------------------------------------------
sudo chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest
sudo cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
REMOVE='ubiquity ubiquity-frontend-gtk ubiquity-frontend-kde casper lupin-casper live-initramfs user-setup discover1 xresprobe os-prober libdebian-installer4'
for i in $REMOVE
do
        sudo sed -i "/${i}/d" image/casper/filesystem.manifest-desktop
done

#-------------------------------------------------------------------------------
echo "start mksquashfs"
sudo mksquashfs chroot image/casper/filesystem.squashfs
echo "finish mksquashfs"
echo "calculate size"
printf $(sudo du -sx --block-size=1 chroot | cut -f1) > image/casper/filesystem.size
echo "finish calculate size"

#-------------------------------------------------------------------------------
echo "start make image/README.diskdefines"
cat << EOF >> image/README.diskdefines
#define DISKNAME  Ubuntu Remix
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  i386
#define ARCHi386  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF
echo "finish make image/README.diskdefines"

#-------------------------------------------------------------------------------
echo "Ubuntu Recognition"
touch image/ubuntu
mkdir image/.disk
cd image/.disk
touch base_installable
echo "full_cd/single" > cd_type
echo "Ubuntu Remix 14.04" > info  # Update version number to match your OS version
echo "http//your-release-notes-url.com" > release_notes_url
cd ../..
echo "finish Ubuntu Recognition"
#-------------------------------------------------------------------------------
echo "start calculate md5sum"
sudo bash -c "cd image && find . -type f -print0 | xargs -0 md5sum | grep -v './md5sum.txt' > md5sum.txt"
echo "finish calculate md5sum"

#-------------------------------------------------------------------------------
cd image
echo "start make iso file"
sudo mkisofs -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../ubuntu-remix.iso .
echo "finish make iso file"
cd ..
