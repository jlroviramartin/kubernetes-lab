# -*- mode: ruby -*-
# vi: set ft=ruby :

# Imagen para las máquinas virtuales
#IMAGE_NAME = "bento/ubuntu-20.04"
IMAGE_NAME = "bento/centos-7.8"

# Número de nodos
N = 2

# Identificador de red que se va a usar: 192.168.#{NET}.xxx
NET = 5

# Nombre de la conexión de red que se va a utilizar
BRIDGE = "Vagrant" # "Intel(R) Dual Band Wireless-AC 8265"

# Configuración samba
SMB_USERNAME = "xxx"
#SMB_PASSWORD = ...

# Datos de red
ANSIBLE_IP = "192.168.#{NET}.5"
MASTER_IP = "192.168.#{NET}.60"
PREFIX = 24
GATEWAY_IP = "192.168.#{NET}.1"
NETWORK_CIDR = "192.168.#{NET}.0/24"

Vagrant.configure("2") do |config|
  # https://docs.vagrantup.com.

  config.vm.define "k8s-ansible" do |ansible|
    ansible.vm.box = IMAGE_NAME
    ansible.vm.network "public_network", ip: ANSIBLE_IP, bridge: BRIDGE
    ansible.vm.hostname = "k8s-ansible.local"

    ansible.vm.provider "hyperv" do |hv|
      hv.vmname = "k8s-ansible"
      hv.maxmemory = "2048"
      hv.cpus = 2
      hv.enable_virtualization_extensions = true
      hv.linked_clone = true
    end

#    ansible.vm.provider "virtualbox" do |vb|
#      vb.name = "k8s-ansible"
#      vb.gui = false
#      vb.memory = "2048"
#      vb.cpus = 2
#    end

    ansible.vm.provision "file", source: "./scripts", destination: "/tmp/scripts"
    ansible.vm.provision "shell", privileged: false, inline: <<-SHELL
      cd /tmp/scripts

      sh ifcfg.sh #{ANSIBLE_IP} #{PREFIX} #{GATEWAY_IP} 192.168.1.15 8.8.8.8 8.8.4.4
      sh install-ansible.sh

      cd
      rm -r /tmp/scripts
    SHELL

    ansible.vm.synced_folder '.', '/vagrant', disabled: true
#    ansible.vm.synced_folder "./vagrant_data", "/vagrant_data", type: "smb", smb_username: SMB_USERNAME, smb_password: SMB_PASSWORD
  end

  config.vm.define "k8s-master" do |master|
    master.vm.box = IMAGE_NAME
    master.vm.network "public_network", ip: MASTER_IP, bridge: BRIDGE
    master.vm.hostname = "k8s-master.local"

    master.vm.provider "hyperv" do |hv|
      hv.vmname = "k8s-master"
      hv.maxmemory = "2048"
      hv.cpus = 2
      hv.enable_virtualization_extensions = true
      hv.linked_clone = true
    end

#    master.vm.provider "virtualbox" do |vb|
#      vb.name = "k8s-master"
#      vb.gui = false
#      vb.memory = "2048"
#      vb.cpus = 2
#    end

    master.vm.provision "file", source: "./scripts", destination: "/tmp/scripts"
    master.vm.provision "shell", privileged: false, inline: <<-SHELL
      cd /tmp/scripts

      sh ifcfg.sh #{MASTER_IP} #{PREFIX} #{GATEWAY_IP} 192.168.1.15 8.8.8.8 8.8.4.4

      if ! grep -q "k8s-node" "/etc/hosts"
      then
        for j in {1..#{N}}
        do
          echo 192.168.#{NET}.$((60 + j)) k8s-node-$j.local k8s-node-$j | sudo tee -a /etc/hosts
        done
      fi

      sh install-docker.sh
      sh install-kubernetes-common.sh
      sh install-kubernetes-master.sh #{MASTER_IP} #{NETWORK_CIDR}

      cd
      rm -r /tmp/scripts
    SHELL

    master.vm.synced_folder '.', '/vagrant', disabled: true
#    master.vm.synced_folder "./vagrant_data", "/vagrant_data", type: "smb", smb_username: SMB_USERNAME, smb_password: SMB_PASSWORD
  end

  (1..N).each do |i|

    IP = "192.168.#{NET}.#{60 + i}"

    config.vm.define "k8s-node-#{i}" do |node|
      node.vm.box = IMAGE_NAME
      node.vm.network "public_network", ip: IP, bridge: BRIDGE
      node.vm.hostname = "k8s-node-#{i}.local"

      node.vm.provider "hyperv" do |hv|
        hv.vmname = "k8s-node-#{i}"
        hv.maxmemory = "2048"
        hv.cpus = 2
        hv.enable_virtualization_extensions = true
        hv.linked_clone = true
      end

#      node.vm.provider "virtualbox" do |vb|
#        vb.name = "k8s-node-#{i}"
#        vb.gui = false
#        vb.memory = "2048"
#        vb.cpus = 2
#      end

      node.vm.provision "file", source: "./scripts", destination: "/tmp/scripts"
      node.vm.provision "shell", privileged: false, inline: <<-SHELL
        cd /tmp/scripts

        sh ifcfg.sh #{IP} #{PREFIX} #{GATEWAY_IP} 192.168.1.15 8.8.8.8 8.8.4.4

        if ! grep -q "k8s-master" "/etc/hosts"
        then
          echo #{MASTER_IP} k8s-master.local k8s-master | sudo tee -a /etc/hosts
          for j in {1..#{N}}
          do
            if [ "$j" -ne #{i} ]
            then
              echo 192.168.#{NET}.$((60 + j)) k8s-node-$j.local k8s-node-$j | sudo tee -a /etc/hosts
            fi
          done
        fi

        sh install-docker.sh
        sh install-kubernetes-common.sh
        sh install-kubernetes-node.sh #{MASTER_IP}

        cd
        rm -r /tmp/scripts
      SHELL

      node.vm.synced_folder '.', '/vagrant', disabled: true
#      node.vm.synced_folder "./vagrant_data", "/vagrant_data", type: "smb", smb_username: SMB_USERNAME, smb_password: SMB_PASSWORD
    end
  end
end
