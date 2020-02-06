# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Deploy-NginxIngress.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "deploy-nginxingress-$ClusterName"
$CMD = "~/devenv/scripts/deploy-nginxingress.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
