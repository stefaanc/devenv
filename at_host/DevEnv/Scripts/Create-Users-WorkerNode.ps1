# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-Users-WorkerNode.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "create-users-workernode-$VMName"
$CMD = "~/devenv/scripts/create-users-workernode.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
