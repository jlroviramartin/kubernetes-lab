#!/bin/bash

echo ===== Installing docker-ce, docker-ce-cli and containerd.io =====

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io

echo ===== Updating docker service =====

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

sudo mkdir /etc/docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

sudo mkdir -p /etc/systemd/system/docker.service.d

sudo systemctl daemon-reload

echo ===== Enabling and running docker service =====

sudo systemctl enable --now docker

echo ===== Adding vagrant to group docker =====

sudo usermod -aG docker vagrant
