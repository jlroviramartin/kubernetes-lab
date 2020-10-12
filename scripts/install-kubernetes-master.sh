#!/bin/bash

echo ===== Parameters =====

master_ip=$1
network_cidr+$2

echo master_ip    = $master_ip
echo network_cidr = $network_cidr

echo ===== Initializing kubeadm =====

# Initialize the Kubernetes cluster (master node)

sudo kubeadm init --apiserver-advertise-address=$master_ip --apiserver-cert-extra-sans=$master_ip --node-name k8s-master --pod-network-cidr=$network_cidr

# Setup the kube config file for the vagrant user to access the Kubernetes cluster

mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo ===== Installing Calico =====

# https://kubernetes.io/docs/concepts/cluster-administration/addons/
# Calico: Setup the container networking provider and the network policy engine

kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
