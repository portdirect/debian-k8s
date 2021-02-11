#!/bin/bash
set -ex
sudo apt-get update
sudo apt-get install -y --no-install-recommends mdadm xfsprogs gdisk
sudo mdadm -V



sudo mdadm --create /dev/md0 --level=stripe --raid-devices=2 /dev/sdb /dev/sdc
sudo mdadm --detail /dev/md0

sudo sgdisk /dev/md0 --zap-all

sudo sgdisk /dev/md0 -o

sectors=$(sudo blockdev --getsz /dev/md0)

sudo sgdisk /dev/md0 --new=1:0:$(( sectors / 2 ))
sudo sgdisk /dev/md0 --new=2::+$(( sectors / 4 ))
sudo sgdisk /dev/md0 --largest-new=3


sudo mkfs.xfs -L containerd /dev/md0p1
sudo mkfs.xfs -L kubelet /dev/md0p2
sudo mkfs.xfs -L srv /dev/md0p3


eval `sudo blkid /dev/md0p1 -o export`
mountpoint=/var/lib/containerd/
sudo mkdir -p ${mountpoint}
sudo tee -a /etc/fstab <<EOF
# This is ${DEVNAME} mounted at ${mountpoint}
/dev/disk/by-uuid/${UUID} ${mountpoint} ${TYPE} defaults 0 2
EOF

eval `sudo blkid /dev/md0p2 -o export`
mountpoint=/var/lib/kubelet/
sudo mkdir -p ${mountpoint}
sudo tee -a /etc/fstab <<EOF
# This is ${DEVNAME} mounted at ${mountpoint}
/dev/disk/by-uuid/${UUID} ${mountpoint} ${TYPE} defaults 0 2
EOF

eval `sudo blkid /dev/md0p3 -o export`
mountpoint=/srv
sudo mkdir -p ${mountpoint}
sudo tee -a /etc/fstab <<EOF
# This is ${DEVNAME} mounted at ${mountpoint}
/dev/disk/by-uuid/${UUID} ${mountpoint} ${TYPE} defaults 0 2
EOF


sudo mdadm --create /dev/md1 --level=stripe --raid-devices=2 /dev/sdd /dev/sde
sudo mdadm --detail /dev/md1
sudo mkfs.xfs -L nova /dev/md1
eval `sudo blkid /dev/md1 -o export`
mountpoint=/var/lib/nova/
sudo mkdir -p ${mountpoint}
sudo tee -a /etc/fstab <<EOF
# This is ${DEVNAME} mounted at ${mountpoint}
/dev/disk/by-uuid/${UUID} ${mountpoint} ${TYPE} defaults 0 2
EOF



sudo mount -a || true