# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-KubernetesWorker.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "install-kubernetesworker-$VMName"
$CMD = "~/devenv/scripts/install-kubernetesworker.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
