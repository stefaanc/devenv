# Get IP address for the line to add
$IPAddress = $args[0]

# Get name of the server to add
$ServerName = $args[1]

# Get option
# -Append
$Option = $args[2]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Update-HostsFile.ps1 $IPAddress $ServerName $Option"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Update hosts file"
echo "#"

$Hosts = Get-Content C:\Windows\system32\drivers\etc\hosts
$Line = $IPAddress.PadRight(15) + '   ' + $ServerName + ' ' + $ServerName + '.localdomain'

function AppendLine {
    $Hosts | ForEach-Object {
        if ( $Option -eq '-append' ) {
            if ( $_.Contains(" $IPAddress") ) {
                $Line = $_ + ' ' + $ServerName + ' ' + $ServerName + '.localdomain'
            }
            else {
                Write-Output $_
            }
        }
        else {
            if ( -not $_.Contains(" $ServerName") ) {
                Write-Output $_
            }
        }
    } ; Write-Output $Line
}

$Hosts = AppendLine

$Hosts | Out-File -FilePath "C:\Windows\system32\drivers\etc\hosts" -Force -Encoding ASCII
echo $Hosts

#Restart-Service -Name AcrylicServiceController | Out-Default   # Acrylic v0.9.35
Restart-Service -Name AcrylicDNSProxySvc | Out-Default   # Acrylic v0.9.39
echo ""
