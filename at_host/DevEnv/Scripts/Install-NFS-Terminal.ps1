# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install_NFS-Terminal.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "install-nfs-terminal-$ClusterName"
$CMD = "~/devenv/scripts/install-nfs-terminal.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
