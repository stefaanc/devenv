# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install_NFS-Depot.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "install-nfs-depot-$ClusterName"
$CMD = "~/devenv/scripts/install-nfs-depot.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
