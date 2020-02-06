# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Start-Firewall.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "start-firewall-$VMName"
$CMD = "~/devenv/scripts/start-firewall.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
