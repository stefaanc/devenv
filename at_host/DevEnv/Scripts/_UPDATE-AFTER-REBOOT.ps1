Set-NetConnectionProfile -InterfaceAlias "vEthernet (Virtual Switch Internal)" -NetworkCategory Private | Out-Default

if ( -not (Get-NetFirewallRule -DisplayName "DNS (UDP-In)") ) {
    New-NetFirewallRule -DisplayName "DNS (UDP-In)" -Direction Inbound -Action Allow -Profile Private -Protocol UDP -LocalPort 53 
}
