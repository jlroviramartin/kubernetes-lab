# See: https://www.petri.com/using-nat-virtual-switch-hyper-v

$NatName="Vagrant"
$IPAddress="192.168.5.1"
$PrefixLength=24
$IPPrefix="192.168.5.0/24"

#$NatName="WSL"
#$IPAddress="172.18.80.1"
#$PrefixLength=20
#$IPPrefix="172.18.80.0/20"
#inet 172.18.91.114  netmask 255.255.240.0  broadcast 172.18.95.255

If ($NatName -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $FALSE) {
    'Creating Internal-only switch named $NatName on Windows Hyper-V host...'

    New-VMSwitch -SwitchName $NatName -SwitchType Internal
    New-NetIPAddress -IPAddress $IPAddress -PrefixLength $PrefixLength -InterfaceAlias "vEthernet ($NatName)"
    New-NetNAT -Name $NatName -InternalIPInterfaceAddressPrefix $IPPrefix
}
else {
    '$NatName for static IP configuration already exists; skipping'
}

If ($IPAddress -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $FALSE) {
    'Registering new IP address $IPAddress on Windows Hyper-V host...'

    New-NetIPAddress -IPAddress $IPAddress -PrefixLength $PrefixLength -InterfaceAlias "vEthernet ($NatName)"
}
else {
    '$IPAddress for static IP configuration already registered; skipping'
}

If ($IPPrefix -in (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix) -eq $FALSE) {
    'Registering new NAT adapter for $IPPrefix on Windows Hyper-V host...'

    New-NetNAT -Name $NatName -InternalIPInterfaceAddressPrefix $IPPrefix
}
else {
    '$IPPrefix for static IP configuration already registered; skipping'
}
