#!/bin/sh

set -x

if [ -f /etc/disk_added_date ]
then
   echo "disk already added so exiting."
   exit 0
fi

# show disk partition info
lsblk

sudo fdisk -u /dev/sda <<EOF
n
p



w
EOF

sleep 3

sudo partprobe

# show disk partition info
lsblk

sudo pvcreate /dev/sda3
sudo vgextend centos /dev/sda3
sudo lvextend /dev/mapper/centos-root
sudo xfs_growfs /dev/centos/root
#sudo resize2fs /dev/mapper/centos-root

df -h

date > /etc/disk_added_date