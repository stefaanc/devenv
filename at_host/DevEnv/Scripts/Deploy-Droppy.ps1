# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Deploy-Droppy.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "deploy-droppy-$ClusterName"
$CMD = "~/devenv/scripts/deploy-droppy.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
