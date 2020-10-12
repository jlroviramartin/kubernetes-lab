#!/bin/bash

# https://stackoverflow.com/a/13322549
ip="$(ifconfig eth0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')"

echo ===== Parameters =====

echo ip = $ip

echo ===== Creating kubernetes repository =====

if [ ! -f /etc/yum.repos.d/kubernetes.repo ]; then
    cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
fi

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i "s/^SELINUX=enforcing$/SELINUX=permissive/" /etc/selinux/config

# https://github.com/kubernetes/kubernetes/issues/53533
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

echo ===== Updating 00-system.conf =====

sudo sed -i "/^[ \\t]*net[.]bridge[.]bridge-nf-call-ip6tables[ \\t]*=/ d" /usr/lib/sysctl.d/00-system.conf
sudo sed -i "/^[ \\t]*net[.]bridge[.]bridge-nf-call-iptables[ \\t]*=/ d" /usr/lib/sysctl.d/00-system.conf
sudo sed -i "/^[ \\t]*net[.]bridge[.]bridge-nf-call-arptables[ \\t]*=/ d" /usr/lib/sysctl.d/00-system.conf
sudo sed -i "/^[ \\t]*net[.]ipv4[.]ip_forward[ \\t]*=/ d" /usr/lib/sysctl.d/00-system.conf

cat <<EOF | sudo tee -a /usr/lib/sysctl.d/00-system.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo ===== Installing kubelet, kubeadm and kubectl =====

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo ===== Configuring kubelet =====

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/kubelet-integration/
# /etc/sysconfig/kubelet

sudo touch /etc/sysconfig/kubelet
sudo sed -i "/^[ \\t]*KUBELET_EXTRA_ARGS[ \\t]*=/ d" /etc/sysconfig/kubelet
echo "KUBELET_EXTRA_ARGS=--node-ip=$ip" | sudo tee -a /etc/sysconfig/kubelet

echo ===== Enabling and running kubelet service =====

sudo systemctl enable --now kubelet
