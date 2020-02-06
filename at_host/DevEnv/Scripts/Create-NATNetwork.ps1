echo "#"
echo "# ======================================================================="
echo "# Create-NATNetwork.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Create VM switch"
echo "#"
$SwitchName="Virtual Switch Internal"

New-VMSwitch -SwitchName $SwitchName -SwitchType Internal | Out-Default
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (Virtual Switch Internal)" | Out-Default
Set-NetConnectionProfile -InterfaceAlias "vEthernet (Virtual Switch Internal)" -NetworkCategory Private | Out-Default
Set-DnsClientServerAddress -InterfaceAlias "vEthernet (Virtual Switch Internal)" -ServerAddresses "192.168.0.1" | Out-Default

$CurrentSuffixes = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name SearchList).SearchList
if ( ! $CurrentSuffixes.Contains("localdomain") ) {
    $NewSuffixes = "localdomain," + $CurrentSuffixes
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name SearchList -Value $NewSuffixes
}
echo ""

echo "#"
echo "# Create NAT network"
echo "#"

New-NetNAT -Name "NAT Network Internal" -InternalIPInterfaceAddressPrefix 192.168.0.0/24 | Out-Default
echo ""
