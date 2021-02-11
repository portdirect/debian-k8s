#!/bin/bash
set -ex

sudo apt-get install -y netplan.io

sudo systemctl disable --now networking
sudo systemctl stop ifup@enp0s3.service
sudo apt-get purge -y ifupdown

sudo systemctl enable --now systemd-networkd

sudo tee /etc/netplan/netplan.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
        dhcp4: true
EOF
sudo netplan apply