# Get name of cluster
$ClusterName = $args[0]

echo "#"
echo "# ======================================================================="
echo "# Import-Certificates.ps1 $ClusterName"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Delete old certificates for kubectl"
echo "#"

$Certs= get-childitem Cert:"CurrentUser\My" | Where-Object { $_.Subject -match "clusters:$ClusterName" }
echo $Certs | Format-Table FriendlyName, Subject
$Certs | Remove-Item

$Certs= get-childitem Cert:"CurrentUser\AuthRoot" | Where-Object { $_.Subject -match "clusters:$ClusterName" }
echo $Certs | Format-Table FriendlyName, Subject
$Certs | Remove-Item
# AuthRoot certificate-creation gets propagated from AuthRoot to Root, but certificate-deletion doesn't
get-childitem Cert:"CurrentUser\Root" | Where-Object { $_.Subject -match "clusters:$ClusterName" } | Remove-Item
echo ""

echo "#"
echo "# Import new certificates for kubectl"
echo "#"

CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@kubernetes.$ClusterName.p12
CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@kubernetes.$ClusterName.p12

CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@apps.$ClusterName.p12
CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@apps.$ClusterName.p12

CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@kube-dashboard.$ClusterName.p12
CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@kube-dashboard.$ClusterName.p12

CertUtil -f -user -p chazchaz -importPFX $HOME\.certs\chaz\chaz@kubernetes.$ClusterName.p12
CertUtil -f -user -p willwill -importPFX $HOME\.certs\will\will@kubernetes.$ClusterName.p12
CertUtil -f -user -p harihari -importPFX $HOME\.certs\hari\hari@kubernetes.$ClusterName.p12

if ( $ClusterName -eq "repository" ) {
    CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@droppy.$ClusterName.p12
    CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@droppy.$ClusterName.p12
    
    CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@chartmuseum-ui.$ClusterName.p12
    CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@chartmuseum-ui.$ClusterName.p12
}

if ( $ClusterName -eq "development" ) {
    CertUtil -f -user -p bethbeth -importPFX $HOME\.certs\beth\beth@kube-apps.$ClusterName.p12
    CertUtil -f -user -p kubekube -importPFX AuthRoot $HOME\.certs\beth\ca@kube-apps.$ClusterName.p12
}

$Certs= get-childitem Cert:"CurrentUser\My" | Where-Object { $_.Subject -match "clusters:$ClusterName" }
echo $Certs | Format-Table FriendlyName, Subject
$Certs= get-childitem Cert:"CurrentUser\AuthRoot" | Where-Object { $_.Subject -match "clusters:$ClusterName" }
echo $Certs | Format-Table FriendlyName, Subject

echo ""
