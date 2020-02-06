# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-Users-Guest.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "create-users-guest-$VMName"
$CMD = "~/devenv/scripts/create-users-guest.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
