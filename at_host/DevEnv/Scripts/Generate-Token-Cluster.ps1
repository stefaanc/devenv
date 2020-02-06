# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Generate-Token-Cluster.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "generate-token-cluster-$ClusterName"
$CMD = "~/devenv/scripts/generate-token-cluster.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option

echo "#"
echo "# Copy token from root@$ClusterName.localdomain:/root/.certs to $HOME\.certs"
echo "#"

pscp -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/.certs/cluster.* $HOME\.certs
echo ""
