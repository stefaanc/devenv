# Get name of virtual machine
$ClusterName = $args[0]

# Get command
# timeout
# banner
# help
$Command = $args[1]

# Get parameters (capitalization is important)
# timeout: 
#   Parameter1 = the timeout in seconds
# banner:
#   Parameter1 = the banner severity: INFO, WARNING or ERROR
#   Parameter2 = the text, optionally including some HTML tags
# help:
#   no parameters
$Parameter1 = $args[2]
$Parameter2 = $args[3]
$Parameter3 = $args[4]

echo "#"
echo "# ======================================================================="
echo "# Patch-KubernetesDashboard.ps1 $ClusterName $Command $Parameter1 $Parameter2 $Parameter3"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "patch-kubernetesdashboard-$ClusterName"
$CMD = "~/devenv/scripts/patch-kubernetesdashboard.sh $ClusterName $Command `"$Parameter1`" `"$Parameter2`" `"$Parameter3`""
Run-GuestScript $ClusterName $CMDName "$CMD"
