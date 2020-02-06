# Get name of cluster
$ClusterName = $args[0]

echo "#"
echo "# ======================================================================="
echo "# Copy-Users.ps1 $ClusterName"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Copy credentials from root@$ClusterName.localdomain:/root/.certs to $HOME\.certs"
echo "#"

#pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/kubernetes-admin $HOME\.certs
pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/beth $HOME\.certs
pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/chaz $HOME\.certs
pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/will $HOME\.certs
pscp -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/hari $HOME\.certs
echo ""

echo "#"
echo "# Copy configs from $HOME\.certs to $HOME\.kube"
echo "#"

Copy-Item $HOME\.certs\beth\*.conf $HOME\.kube -Force 
Copy-Item $HOME\.certs\chaz\*.conf $HOME\.kube -Force 
Copy-Item $HOME\.certs\will\*.conf $HOME\.kube -Force 
Copy-Item $HOME\.certs\hari\*.conf $HOME\.kube -Force 
echo ""

echo "#"
echo "# Copy tokens from $HOME\.certs to $HOME\.certs\.login"
echo "#"

if ( ! (Test-Path -Path $HOME\.certs\.login) ) {
    mkdir $HOME\.certs\.login
}
Copy-Item $HOME\.certs\beth\*.token $HOME\.certs\.login -Force 
Copy-Item $HOME\.certs\beth\*@kube-dashboard.*.conf $HOME\.certs\.login -Force 
echo ""
