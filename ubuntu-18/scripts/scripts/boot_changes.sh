#!/bin/bash
set -x
sed -i 's/GRUB_CMDLINE_LINUX\=\"\"/GRUB_CMDLINE_LINUX\=\"console\=ttyS0,115200n8 console\=tty0 audit\=1 ipv6.disable\=1 net.ifnames\=0 crashkernel\=auto rd.lvm.lv\=vg_sys\/lvroot root\=\/dev\/mapper\/vg_sys-lv_root\"/' /etc/default/grub
sed -i '/GRUB_PRELOAD_MODULES\=lvm/a GRUB_PRELOAD_MODULES\=lvm' /etc/default/grub
update-initramfs -c -k `uname -r`
update-grub2 -o /boot/grub/grub.cfg
grub-install --modules 'part_gpt part_msdos lvm' /dev/xvdf
exit
