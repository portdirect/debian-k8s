#!/bin/bash
set -ex

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  apt-transport-https \
  curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo tee /etc/apt/sources.list.d/kubernetes.list <<EOF
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y --no-install-recommends kubelet kubeadm kubectl conntrack cri-tools ebtables ethtool kubernetes-cni socat
#sudo apt-mark hold kubelet kubeadm kubectl
sudo tee /etc/crictl.yaml <<EOF
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
EOF