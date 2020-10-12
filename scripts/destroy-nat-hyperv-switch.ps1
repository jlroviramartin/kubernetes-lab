# See: https://www.petri.com/using-nat-virtual-switch-hyper-v

$NatName="Vagrant"
$IPAddress="192.168.5.1"
$PrefixLength=24
$IPPrefix="192.168.5.0/24"

#$NatName="WSL"
#$IPAddress="172.18.80.1"
#$PrefixLength=20
#$IPPrefix="172.18.80.0/20"

Remove-VMSwitch -Name $NatName -Confirm:$false
Remove-NetIPAddress -IPAddress $IPAddress -PrefixLength $PrefixLength -InterfaceAlias "vEthernet ($NatName)" -Confirm:$false
Remove-NetNAT -Name $NatName -InternalIPInterfaceAddressPrefix $IPPrefix -Confirm:$false -Force
