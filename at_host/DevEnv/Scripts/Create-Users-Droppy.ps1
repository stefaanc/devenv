# Get name of cluster
$ClusterName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-Users-Droppy.ps1 $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$ClusterName
#

$CMDName = "create-users-droppy-$ClusterName"
$CMD = "~/devenv/scripts/create-users-droppy.sh $ClusterName"
Run-GuestScript $ClusterName $CMDName "$CMD" $Option
