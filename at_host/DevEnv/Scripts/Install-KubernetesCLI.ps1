# Get name of cluster
$ClusterName = $args[0]

# Get options
# -Force
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-KubernetesCLI.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Install/upgrade kubernetes-cli"
echo "#"

if ($Option -eq '-force') {
    choco upgrade kubernetes-cli -y
}
else {
    choco upgrade kubernetes-cli
}
echo ""

echo "#"
echo "# Configure kubernetes"
echo "#"

if ( ! (Test-Path -Path ~\.kube) ) {
    mkdir ~\.kube
}

# create local config
if ($Option -eq '-force') {
    Write-Output 'y' | pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/home/beth/.certs/beth/beth@kubernetes.$ClusterName.conf $HOME\.kube
}
else {
    pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/home/beth/.certs/beth/beth@kubernetes.$ClusterName.conf $HOME\.kube
}
if ( ($ClusterName -eq 'development') -or ! (Test-Path -Path ~\.kube\config) ) {
    cp ~\.kube\beth@kubernetes.$ClusterName.conf ~\.kube\config
}

# create local profile
if ( ! (Test-Path -Path ~\.kube\profile.ps1) ) {
    echo `$env:KUBECONFIG=`"$HOME\.kube\config`" | Out-File -FilePath ~\.kube\profile.ps1 -Force -Encoding ASCII
}
$PROFILE = Get-Content -Path ~\.kube\profile.ps1
$PROFILE = $PROFILE | ForEach-Object {
    if ( ($_.Contains('KUBECONFIG')) -and ! ($_.Contains(".kube\beth@kubernetes.$ClusterName.conf")) ) {
        Write-Output ( $_.Trim().TrimEnd('"') + ";$HOME\.kube\beth@kubernetes.$ClusterName.conf`"" )
    }
    else {
        Write-Output $_
    }
}
$PROFILE | Out-File -FilePath "~\.kube\profile.ps1" -Force -Encoding ASCII
. ~\.kube\profile.ps1
echo ""
