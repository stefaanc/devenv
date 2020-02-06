# Get name of cluster
$ClusterName = $args[0]

# Get options
# -Force
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-HelmCLI.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Install/upgrade helm"
echo "#"

if ($Option -eq '-force') {
    choco upgrade kubernetes-helm -y
}
else {
    choco upgrade kubernetes-helm
}
echo ""

echo "#"
echo "# Add firewall rules for helm"
echo "#"

if ( -not (Get-NetFirewallRule -DisplayName "helm") ) {
    New-NetFirewallRule -DisplayName "helm" -Direction Inbound -Action Allow -Profile Private -Protocol UDP -Program "C:\programdata\chocolatey\lib\kubernetes-helm\tools\windows-amd64\helm.exe"
    New-NetFirewallRule -DisplayName "helm" -Direction Inbound -Action Allow -Profile Private -Protocol TCP -Program "C:\programdata\chocolatey\lib\kubernetes-helm\tools\windows-amd64\helm.exe"
}
echo ""

echo "#"
echo "# Configure helm"
echo "#"

if ( ! (Test-Path -Path ~\.helm) ) {
    $env:HELM_TLS_VERIFY=""
    $env:HELM_TLS_CA_CERT=""
    $env:HELM_TLS_CERT=""
    $env:HELM_TLS_KEY=""
    $env:TILLER_NAMESPACE=""
    
    helm init --client-only
    echo ""
}

if ($Option -eq '-force') {
    Write-Output 'y' | pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/home/beth/.helm/profile.$ClusterName $HOME\.helm\profile.$ClusterName.ps1
}
else {
    pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/home/beth/.helm/profile.$ClusterName $HOME\.helm\profile.$ClusterName.ps1
}

$PROFILE = Get-Content -Path ~\.helm\profile.$ClusterName.ps1
$PROFILE = $PROFILE | ForEach-Object {
    Write-Output $_.Replace('/','\').Replace('export ','$env:').Replace('alias','# set-alias').Replace('\home\beth',$HOME)
}
$PROFILE | Out-File -FilePath ~\.helm\profile.$ClusterName.ps1 -Force -Encoding ASCII

if ( ($ClusterName -eq 'development') -or ! (Test-Path -Path ~\.helm\profile.ps1) ) {
    cp ~\.helm\profile.$ClusterName.ps1 ~\.helm\profile.ps1
    . ~\.helm\profile.ps1
}
echo ""
