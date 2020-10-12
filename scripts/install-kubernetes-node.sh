#!/bin/bash

echo ===== Parameters =====

master_ip=$1

echo master_ip = $master_ip

echo ===== Joining kubernetes cluster =====

# Se instala sshpass. SOLO para testing.
sudo yum install -y sshpass

# Generate kube join command for joining the node to the Kubernetes cluster and store the command in the file join-command
# https://askubuntu.com/a/123080

sshpass -p vagrant ssh -oStrictHostKeyChecking=no vagrant@$master_ip 'sudo kubeadm token create --print-join-command' > /tmp/join-command.sh
chmod u+x /tmp/join-command.sh
sudo /tmp/join-command.sh
