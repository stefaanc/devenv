# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-Users-ChartMuseumUI.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "create-users-chartmuseumui-$ClusterName"
$CMD = "~/devenv/scripts/create-users-chartmuseumui.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
