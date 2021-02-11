#!/bin/bash
set -ex

sudo tee /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
EOF
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system