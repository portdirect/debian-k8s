#!/bin/bash
set -ex
sudo tee /etc/kubernetes/kubeadm-input.yaml <<EOF
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
#controlPlaneEndpoint: intlabs-lb.localdomain:6443
clusterName: intlabs
networking:
  dnsDomain: cluster.local
  podSubnet: 172.16.1.0/24
  serviceSubnet: 172.16.2.0/24
apiServer:
  extraArgs:
    service-node-port-range: 80-32767
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
...
EOF

sudo tee /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS='--cgroup-driver=systemd'
EOF

sudo kubeadm config images pull --config /etc/kubernetes/kubeadm-input.yaml
sudo kubeadm init --upload-certs --config /etc/kubernetes/kubeadm-input.yaml

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

curl https://docs.projectcalico.org/manifests/calico.yaml | \
  sed '/            - name: CALICO_IPV4POOL_IPIP/{n;s/.*/              value: "Never"/}' | \
  sed 's|docker.io|quay.io|g' | \
  sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f -

# NOTE: Wait for dns to be running.
END=$(($(date +%s) + 240))
until kubectl --namespace=kube-system \
        get pods -l k8s-app=kube-dns --no-headers -o name | grep -q "^pod/coredns"; do
  NOW=$(date +%s)
  [ "${NOW}" -gt "${END}" ] && exit 1
  echo "still waiting for dns"
  sleep 10
done
kubectl -n kube-system wait --timeout=240s --for=condition=Ready pods -l k8s-app=kube-dns

# Remove master node taint
kubectl taint nodes --all node-role.kubernetes.io/master-