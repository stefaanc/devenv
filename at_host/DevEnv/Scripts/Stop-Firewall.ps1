# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Stop-Firewall.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "stop-firewall-$VMName"
$CMD = "~/devenv/scripts/stop-firewall.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
