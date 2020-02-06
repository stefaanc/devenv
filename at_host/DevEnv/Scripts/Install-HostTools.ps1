# Get options
# -Force
$Option = $args[2]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-Tools.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Install/upgrade chocolateygui"
echo "#"

if ($Option -eq '-force') {
    choco upgrade chocolateygui -y
}
else {
    choco upgrade chocolateygui
}
echo ""

echo "#"
echo "# Install/upgrade wget"
echo "#"

if ($Option -eq '-force') {
    choco upgrade wget -y
}
else {
   choco upgrade wget
}
echo ""

echo "#"
echo "# Install/upgrade cURL"
echo "#"

if ($Option -eq '-force') {
    choco upgrade cURL -y
}
else {
    choco upgrade cURL
}
echo ""

echo "#"
echo "# Install/upgrade openSSL"
echo "#"

if ($Option -eq '-force') {
    choco upgrade openSSL.light -y
}
else {
    choco upgrade openSSL.light
}
echo ""

echo "#"
echo "# Install/upgrade PuTTY"
echo "#"

if ($Option -eq '-force') {
    choco upgrade PuTTY -y
}
else {
    choco upgrade PuTTY
}
echo ""

echo "#"
echo "# Install/upgrade WinSCP"
echo "#"

if ($Option -eq '-force') {
    choco upgrade WinSCP -y
}
else {
    choco upgrade WinSCP
}
echo ""

echo "#"
echo "# Install/upgrade acrylic-dns-proxy"
echo "#"

if (-not (Test-Path -Path "C:\Program Files (x86)\Acrylic DNS Proxy")) {
    ~/DevEnv/Downloads/Acrylic.exe /S | Out-Default
}
echo ""

echo "#"
echo "# Generate PuTTY-keys"
echo "#"

echo "Please keep this PowerShell running"
echo "Continue in the PuTTY Key Generator window, and close it when finished . . . "
echo ""
echo "Please check that your $HOME\.certs folder contains a 'putty.ppk' file and a 'putty.pub' file"
echo "If you already have PuTTY keys, and want to use them, then you can close the PuTTY Key Generator window"
echo "Otherwise"
echo "- press the Generate button"
echo "- move your cursor around until the green progress bar is complete"
echo "- you can change the key comment.  A typical key comment would be your email address"
echo "- DO NOT put in a key passphrase"
echo "- press the Save public key button"
echo "  - navigate to your $HOME\.certs folder"
echo "  - save with name 'putty.pub'"
echo "- press the Save private key button"
echo "  - navigate to your $HOME\.certs folder"
echo "  - save with name 'putty.ppk'"
echo "- you can now close the PuTTY Key Generator window"
puttygen | Out-Default
echo ""

echo "#"
echo "# Configure acrylic-dns-proxy"
echo "#"

$Insert = ''
$Ini = Get-Content "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicConfiguration.ini" | ForEach-Object {
    if ( $_.StartsWith('LocalIPv4BindingAddress=') ) {
        Write-Output 'LocalIPv4BindingAddress=192.168.0.1'
    }
    elseif ( $_ -eq '[AllowedAddressesSection]' ) {
        $Insert = 'true'
        Write-Output $_
    }
    elseif ($Insert -eq 'true') {
        $Insert = ''
        if ($_ -ne 'IP1=192.168.0.*') {
            Write-Output 'IP1=192.168.0.*'
        }
        Write-Output $_
    }
    else {
        Write-Output $_
    }
}
$Ini | Out-File -FilePath "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicConfiguration.ini" -Force -Encoding ASCII

$Append = ''
Get-Content "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicHosts.txt" | ForEach-Object {
    if ( $_ -eq ('@ C:\Windows\System32\drivers\etc\hosts') ) {
        $Append = 'false'
    }
}
if ( $Append -ne 'false' ) {
    Add-Content "C:\Program Files (x86)\Acrylic DNS Proxy\AcrylicHosts.txt" "`r`n`r`n@ C:\Windows\System32\drivers\etc\hosts"
}

#Restart-Service -Name AcrylicServiceController | Out-Default   # Acrylic v0.9.35
Restart-Service -Name AcrylicDNSProxySvc | Out-Default   # Acrylic v0.9.39
echo ""

echo "#"
echo "# Add firewall rule for DNS-Inbound"
echo "#"

if ( -not (Get-NetFirewallRule -DisplayName "DNS (UDP-In)") ) {
    New-NetFirewallRule -DisplayName "DNS (UDP-In)" -Direction Inbound -Action Allow -Profile Private -Protocol UDP -LocalPort 53 
}
echo ""
