# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-GuestTools.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "install-guesttools-$VMName"
$CMD = "~/devenv/scripts/install-guesttools.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
