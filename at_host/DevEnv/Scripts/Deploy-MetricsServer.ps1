# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Deploy-MetricsServer.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "deploy-metricsserver-$ClusterName"
$CMD = "~/devenv/scripts/deploy-metricsserver.sh"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
