# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-Users-Cluster.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "create-users-cluster-$ClusterName"
$CMD = "~/devenv/scripts/create-users-cluster.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
