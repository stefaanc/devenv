# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install_HelmPush.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "install-helmpush-$ClusterName"
$CMD = "~/devenv/scripts/install-helmpush.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
