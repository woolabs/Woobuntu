#!/bin/sh

echo "You need following packages to continue:squashfs-tools dchroot\n"
#Depends on dchroot to create iso
sudo apt-get install squashfs-tools dchroot mkisofs -y
mkdir /tmp/livecd
sudo mount -o loop $1 /tmp/livecd
mkdir -p ~/livecd/cd
rsync --exclude=/casper/filesystem.squashfs -a /tmp/livecd/ ~/livecd/cd
mkdir ~/livecd/squashfs  ~/livecd/custom
sudo modprobe squashfs
sudo mount -t squashfs -o loop /tmp/livecd/casper/filesystem.squashfs ~/livecd/squashfs/
sudo cp -a ~/livecd/squashfs/* ~/livecd/custom
sudo cp /etc/resolv.conf /etc/hosts ~/livecd/custom/etc/
sudo cp mdk3-v6-fix.tar.gz ~/livecd/custom/root
sudo cp wine-qqintl.zip ~/livecd/custom/root
sudo cp wooyun-firefox.tar.gz ~/livecd/custom/root
sudo cp mozilla_profile.tar.gz ~/livecd/custom/root
sudo cp woobuntu_chroot_build.sh ~/livecd/custom/root
sudo chroot ~/livecd/custom /root/woobuntu_chroot_build.sh
sudo umount -lf ~/livecd/custom/proc
sudo umount -lf ~/livecd/custom/sys

chmod +w ~/livecd/cd/casper/filesystem.manifest
#chmod +w ~/livecd/cd/preseed/xubuntu.seed
#cat > ~/livecd/cd/preseed/xubuntu.seed <<EOF
#d-i debian-installer/locale string zh_CN
#d-i mirror/http/mirror select CN.archive.ubuntu.com
#d-i clock-setup/utc boolean false
#d-i time/zone string Asia/Shanghai
#d-i clock-setup/ntp boolean true
#tasksel tasksel/first multiselect xubuntu-desktop
#d-i pkgsel/update-policy select none
#d-i finish-install/reboot_in_progress note
#EOF
sudo chroot ~/livecd/custom dpkg-query -W --showformat='${Package} ${Version}\n' > ~/livecd/cd/casper/filesystem.manifest
sudo cp ~/livecd/cd/casper/filesystem.manifest ~/livecd/cd/casper/filesystem.manifest-desktop

sudo mksquashfs ~/livecd/custom ~/livecd/cd/casper/filesystem.squashfs

sudo rm ~/livecd/cd/md5sum.txt
sudo bash -c 'cd ~/livecd/cd && find . -type f -exec md5sum {} +' > md5sum.txt

cd ~/livecd/cd
sudo mkisofs -r -V "Woobuntu-Live" -b isolinux/isolinux.bin -c isolinux/boot.cat -cache-inodes -J -l -no-emul-boot -boot-load-size 4 -boot-info-table -o /root/woobuntu-current-amd64.iso .

sudo umount ~/livecd/squashfs/
sudo umount /tmp/livecd
#sudo rm -fr ~/livecd/

echo "build finished"
