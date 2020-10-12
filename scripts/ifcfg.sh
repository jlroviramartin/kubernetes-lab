#!/bin/bash

IPADDR=$1
PREFIX=$2
GATEWAY=$3
DNS1=$4
DNS2=$5
DNS3=$6

FILE=/etc/sysconfig/network-scripts/ifcfg-eth0

# Se elimina BOOTPROTO de ifcfg-eth0
sudo sed -i '/^BOOTPROTO=/d' $FILE
sudo sed -i '/^IPADDR=/d' $FILE
sudo sed -i '/^PREFIX=/d' $FILE
sudo sed -i '/^GATEWAY=/d' $FILE
sudo sed -i '/^DNS1=/d' $FILE
sudo sed -i '/^DNS2=/d' $FILE
sudo sed -i '/^DNS3=/d' $FILE

# Se añade la IP estatica a ifcfg-eth0
cat <<EOF | sudo tee -a $FILE
BOOTPROTO=none
IPADDR=$IPADDR
PREFIX=$PREFIX
GATEWAY=$GATEWAY
DNS1=$DNS1
DNS2=$DNS2
DNS3=$DNS3
EOF

# Se reinicia la red
sudo systemctl restart network
