# Get name of cluster
$ClusterName = $args[0]

echo "#"
echo "# ======================================================================="
echo "# Open-NATPorts-Cluster.ps1 $ClusterName"
echo "# ======================================================================="
echo "#"
echo ""

if ( $ClusterName = 'development' ) {
    echo "#"
    echo "# Open port 56443 on NAT"
    echo "#"

    Add-NetNATStaticMapping -ExternalIPAddress "0.0.0.0/24" -ExternalPort 56443 -Protocol TCP -InternalIPAddress "192.168.0.50" -InternalPort 6443 -NATName "NAT Network Internal"
    echo ""
}
else { # ( $ClusterName = 'repository' )
    echo "#"
    echo "# Open port 26443 on NAT"
    echo "#"

    Add-NetNATStaticMapping -ExternalIPAddress "0.0.0.0/24" -ExternalPort 26443 -Protocol TCP -InternalIPAddress "192.168.0.20" -InternalPort 6443 -NATName "NAT Network Internal"
    echo ""
}
