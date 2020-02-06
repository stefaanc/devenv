# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install_Helm.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "install-helm-$ClusterName"
$CMD = "~/devenv/scripts/install-helm.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
