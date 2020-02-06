# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Deploy-ChartMuseum.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "deploy-chartmuseum-$ClusterName"
$CMD = "~/devenv/scripts/deploy-chartmuseum.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
