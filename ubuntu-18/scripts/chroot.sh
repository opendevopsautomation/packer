#!/bin/bash

#This simply runs the boot_changes script, which was created in the earlier step, under chroot mode
#The called script changes the root and grub configuration

set -x

readonly local mntpoint="/mnt"
chmod +x /mnt/tmp/boot_changes.sh

mount --bind /proc ${mntpoint}/proc
mount --bind /dev ${mntpoint}/dev
mount --bind /sys ${mntpoint}/sys

#Run this script in chroot mode
chroot ${mntpoint} ./tmp/boot_changes.sh

mkdir -p ${mntpoint}/var/lib/ansible/
cd ${mntpoint}/var/lib/ansible/
rm -rf local
git clone git@github.com:opendevopsautomation/ansible.git local
umount -l /mnt
