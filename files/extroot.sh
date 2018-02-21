#!/bin/sh

set -e
##################################################
# extroot (a.k.a. pivot-overlay)
# This assumes we have a 2 partions usb key at the ready:
#   /dev/sda1 -> swap partition LABEL="swapfs"
#   /dev/sda2 -> ext4 partition (overlay) LABEL=overlayfs"
# E.G:
#   root@gw00:~# block info
#   /dev/mtdblock2: UUID="babd86bf-59725bf1-d9cfae42-be909ef9" VERSION="4.0" MOUNT="/rom" TYPE="squashfs"
#   /dev/mtdblock3: MOUNT="/overlay" TYPE="jffs2"
#   /dev/sda1: UUID="971f9d68-4934-49c6-916d-3863559e71b1" LABEL="swapfs" VERSION="1" TYPE="swap"
#   /dev/sda2: UUID="d812eccb-606c-47b4-975e-1c53ba7c8910" LABEL="overlayfs" VERSION="1.0" TYPE="ext4"
##################################################

# install requirement to make use of a usb stick

# see: https://lede-project.org/docs/user-guide/extroot_configuration
opkg update && opkg install block-mount kmod-fs-ext4 kmod-usb-storage \
  e2fsprogs kmod-usb-ohci kmod-usb-uhci fdisk

# creating swap and enabling
mkswap -L swapfs /dev/sda1
# swapon /dev/sda1

# create a mountpoint and mount the usb share
# mkfs.ext4 -L overlayfs /dev/sda2
mount -t ext4 /dev/sda2 /mnt -o rw,

# duplicate data
tar -C /overlay -cvf - . | tar -C /mnt -xf - ; umount /mnt

# edit fstab
block detect > /etc/config/fstab
sed -i s/option$'\t'enabled$'\t'\'0\'/option$'\t'enabled$'\t'\'1\'/ /etc/config/fstab
sed -i s#/mnt/sda2#/overlay# /etc/config/fstab
# cat /etc/config/fstab

# enable fstab (just to make sure)
/etc/init.d/fstab enable

# the reboot seems necessary to apply the previous packages,
# maybe insmod would do it
reboot

# opkg update && opkg install openssh-sftp-server zsh

# opkg update && opkg install python3 python3-pip
# opkg install openssh-server openssh-client openssh-client-utils openssh-sftp-server
# /etc/init.d/sshd enable
# /etc/init.d/sshd start
