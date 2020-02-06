# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install Docker.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "install-docker-$VMName"
$CMD = "~/devenv/scripts/install-docker.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option

echo "#"
echo "# Stop virtual machine $VMName"
echo "#"

Stop-VM -VMName $VMName -Force | Out-Default
echo ""

echo "#"
echo "# Start virtual machine $VMName"
echo "#"

Start-VM -VMName $VMName | Out-Default
echo ""

echo "#"
echo "# Waiting for connectivity to be restored"
echo "#"

Do {
	ping "$VMName.localdomain"
} 
While ($LastExitCode -ne 0)
echo ""
