# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  config.vm.box = "debian/testing64"
  config.vbguest.auto_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 4
    vb.memory = "8192"

    vb.customize ["storagectl", :id, "--name", "SATA Controller", "--portcount", 30 ]
    [1, 2, 3, 4, 5, 6, 7].each do |var|
      file_to_disk = "./disk/disk#{var}.vdi"
      unless File.exist?(file_to_disk)
        vb.customize ['createhd', '--filename', file_to_disk, '--size', 20 * 1024]
      end
      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', "#{var}", '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
    end



  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
set -ex
cd /vagrant
./scripts/base-config.sh
./scripts/disc-config.sh
./scripts/netplan.sh
./scripts/base-k8s-config.sh
./scripts/install-containerd.sh
./scripts/install-kubernetes-components.sh
./scripts/deploy-k8s.sh

./scripts/kube/helm-controller.sh
./scripts/kube/cert-manager.sh
./scripts/kube/metallb.sh
./scripts/kube/ingress-nginx.sh
  SHELL
end
