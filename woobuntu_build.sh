#!/bin/bash

#Author : woolabs team 
#Maintainer : lxj616@wooyun

chroot_args="-c"

show_help() {

echo " __    __            _                 _         ";
echo "/ / /\ \ \___   ___ | |__  _   _ _ __ | |_ _   _ ";
echo "\ \/  \/ / _ \ / _ \| '_ \| | | | '_ \| __| | | |";
echo " \  /\  / (_) | (_) | |_) | |_| | | | | |_| |_| |";
echo "  \/  \/ \___/ \___/|_.__/ \__,_|_| |_|\__|\__,_|";
echo "                                                 ";

echo "Usage:"
echo "-f	The ubuntu base image you wanna use for woobuntu build"
echo "-o	The output woobuntu image"
echo "-x	Xubuntu optimization for zh_CN & pre-configuration"
echo "-g        gnome-ubuntu optimization for zh_CN & pre-configuration"
echo "-u        Ubuntu original optimization for zh_CN & pre-configuration"
echo "-N        Pre-install NVIDIA driver (Use with causion)"
echo "-V        Pre-install Virtualbox-guest additions (Use with causion)"
echo ""
echo "Example:"
echo ""
echo "./woobuntu_build.sh -f xubuntu-15.10-desktop-amd64.iso -o woobuntu-current-amd64.iso -x"

}

if [ $# = 0 ]
then
    show_help
    exit 0
fi

while getopts "h?f:o:xguNV" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    f)  input_iso=$OPTARG
        ;;
    o)  output_iso=$OPTARG
        ;;
    x)  chroot_args="$chroot_args -x"
        ;;
    g)  chroot_args="$chroot_args -g"
        ;;
    u)  chroot_args="$chroot_args -u"
        ;;
    N)  chroot_args="$chroot_args -N"
        ;;
    V)  chroot_args="$chroot_args -V"
        ;;
    esac
done

echo "You need following packages to continue:squashfs-tools dchroot"
#Depends on dchroot to create iso
sudo apt-get install squashfs-tools dchroot mkisofs -y
#Create temp folder to mount origin iso
mkdir /tmp/livecd
#Mount origin iso to temp folder to extract squashfs file
sudo mount -o loop $input_iso /tmp/livecd
#Create temp folder to store iso image files
mkdir -p livecd/cd
#Don't copy squashfs file as we will repack this file later
rsync --exclude=/casper/filesystem.squashfs -a /tmp/livecd/ livecd/cd
#Create temp folder to mount squashfs file & copy everything out for modification
mkdir livecd/squashfs  livecd/custom
#Need to load before use
sudo modprobe squashfs
#Mount the squash file
sudo mount -t squashfs -o loop /tmp/livecd/casper/filesystem.squashfs livecd/squashfs/
#Copy everything out for modification(squashfs file itself is read-only)
sudo cp -a livecd/squashfs/* livecd/custom
#Enable network related configuration inside chroot env
sudo cp /etc/resolv.conf /etc/hosts livecd/custom/etc/
#Copy wooyun-firefox user-profile into chroot env
sudo cp -r .mozilla livecd/custom/root
#Drop the chroot install script inside
sudo cp woobuntu_chroot_build.sh livecd/custom/root
#Execute the install script inside chroot env
sudo chroot livecd/custom /bin/bash -x /root/woobuntu_chroot_build.sh $chroot_args
#Everything should be done except re-check the mount points
sudo umount -lf livecd/custom/proc
sudo umount -lf livecd/custom/sys

#Renew the manifest
chmod +w livecd/cd/casper/filesystem.manifest
#chmod +w livecd/cd/preseed/xubuntu.seed
#cat > livecd/cd/preseed/xubuntu.seed <<EOF
#d-i debian-installer/locale string zh_CN
#d-i mirror/http/mirror select CN.archive.ubuntu.com
#d-i clock-setup/utc boolean false
#d-i time/zone string Asia/Shanghai
#d-i clock-setup/ntp boolean true
#tasksel tasksel/first multiselect xubuntu-desktop
#d-i pkgsel/update-policy select none
#d-i finish-install/reboot_in_progress note
#EOF
sudo chroot livecd/custom dpkg-query -W --showformat='${Package} ${Version}\n' > livecd/cd/casper/filesystem.manifest
sudo cp livecd/cd/casper/filesystem.manifest livecd/cd/casper/filesystem.manifest-desktop

#Repack the squashfs file
sudo mksquashfs livecd/custom livecd/cd/casper/filesystem.squashfs

#Re-create the md5 file
sudo rm livecd/cd/md5sum.txt
sudo bash -c 'cd livecd/cd && find . -type f -exec md5sum {} +' > livecd/cd/md5sum.txt

#Repack iso file
cd livecd/cd
sudo mkisofs -r -V "Woobuntu-Live" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o output.iso .
mv output.iso ../../ 
cd ../../
mv output.iso $output_iso

#Umount and clean
sudo umount livecd/squashfs/
sudo umount /tmp/livecd
#sudo rm -fr livecd/

echo "build finished"
