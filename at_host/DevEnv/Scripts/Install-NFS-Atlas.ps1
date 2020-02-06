# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install_NFS-Atlas.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "install-nfs-atlas-$ClusterName"
$CMD = "~/devenv/scripts/install-nfs-atlas.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
