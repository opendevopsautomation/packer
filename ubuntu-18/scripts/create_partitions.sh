#!/bin/bash

#This script has logic to create partitions volume groups and logical volumes which we will use to create root partition with LVM support

set -x

#Set variables, dev for EBS volume attach, change this if you change in the packer template.
#Mountpoint, to create different mounts and directory in new volume, we will use mntpoint variable
readonly local dev="/dev/xvdf"
readonly local mntpoint="/mnt"

 [ ! -d "${mntpoint}" ] && \
 errx "cannot find mountpoint '${mntpoint}'"

#parted used to create partitions in {dev}
#Will be creating two partitions
#1 for boot {dev}1
#2 for creating volume group and logical volumes

 parted -a optimal "${dev}" mklabel msdos print || \
 exit 1
 parted -a optimal "${dev}" mkpart primary '0%' '1%' set 1 boot on print || \
 exit 1
 parted -a optimal "${dev}" mkpart primary '1%' '100%' set 2 lvm on print || \
 exit 1
 mkfs.xfs "${dev}1" || \
 exit 1

#Create volume group for {dev}2

pvcreate ${dev}2
vgcreate vol_grp ${dev}2

#Create logical volumes from volume group created

lvcreate -L 15G -n lv_root vol_grp
lvcreate -L 25G -n lv_var vol_grp
lvcreate -L 28.5G -n lv_varlog vol_grp
lvcreate -L 10G -n lv_varlogaudit vol_grp
lvcreate -L 4G -n lv_vartmp vol_grp
lvcreate -L 6G -n lv_tmp vol_grp
lvcreate -L 10G -n lv_home vol_grp

#Format the created logical volumes using xfs

mkfs -t xfs  /dev/mapper/vol_grp-lv_varlogaudit
mkfs -t xfs  /dev/mapper/vol_grp-lv_root
mkfs -t xfs  /dev/mapper/vol_grp-lv_vartmp
mkfs -t xfs  /dev/mapper/vol_grp-lv_var
mkfs -t xfs  /dev/mapper/vol_grp-lv_varlog
mkfs -t xfs  /dev/mapper/vol_grp-lv_tmp
mkfs -t xfs  /dev/mapper/vol_grp-lv_home

#Tunable filesystem parameters on ext2/ext3/ext4 filesystems
#tune2fs -m 0 /dev/mapper/vol_grp-lv_varlogaudit
#tune2fs -m 0 /dev/mapper/vol_grp-lv_root
#tune2fs -m 0 /dev/mapper/vol_grp-lv_vartmp
#tune2fs -m 0 /dev/mapper/vol_grp-lv_var
#tune2fs -m 0 /dev/mapper/vol_grp-lv_varlog
#tune2fs -m 0 /dev/mapper/vol_grp-lv_tmp
#tune2fs -m 0 /dev/mapper/vol_grp-lv_home


#Create ${mntpoint}/* directory and mount it to logical volumes created

mount /dev/mapper/vol_grp-lv_root ${mntpoint}/

mkdir -p ${mntpoint}/var ${mntpoint}/tmp  ${mntpoint}/home
mount  /dev/mapper/vol_grp-lv_var ${mntpoint}/var
mkdir -p ${mntpoint}/var/log
mount /dev/mapper/vol_grp-lv_varlog ${mntpoint}/var/log
mount /dev/mapper/vol_grp-lv_home ${mntpoint}/home
mount /dev/mapper/vol_grp-lv_tmp ${mntpoint}/tmp
mkdir -p ${mntpoint}/var/tmp
mount /dev/mapper/vol_grp-lv_vartmp ${mntpoint}/var/tmp
mkdir -p ${mntpoint}/var/log/audit
mount /dev/mapper/vol_grp-lv_varlogaudit ${mntpoint}/var/log/audit

#Copy the data from the root volume to the Logical volume

rsync -avxHAX --exclude={"/home/ubuntu/.ssh/authorized_keys","/var/log","/lost+found","/tmp/*"} --progress / ${mntpoint} || \
exit 1

#Remove the existing ${mntpoint}/etc/fstab file

rm -f ${mntpoint}/etc/fstab

#To mount all mounting points after instance reboot, update ${mntpoint}/etc/fstab file.
echo "/dev/mapper/vol_grp-lv_root / xfs defaults 0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_var /var xfs rw,relatime   0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_varlog /var/log xfs  rw,relatime   0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_tmp /tmp xfs rw,nosuid,nodev,relatime 0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_home /home xfs rw,nodev,relatime 0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_varlogaudit /var/log/audit xfs  rw,relatime   0 0" >> ${mntpoint}/etc/fstab
echo "/dev/mapper/vol_grp-lv_vartmp /var/tmp xfs  rw,relatime  0 0" >> ${mntpoint}/etc/fstab
echo "tmpfs /dev/shm tmpfs  rw,nosuid,nodev,noexec 0 0" >> ${mntpoint}/etc/fstab
