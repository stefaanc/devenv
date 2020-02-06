# Get name of virtual machine
$VMName = $args[0]

# Get option
# -NoPrompt
$Option = $args[1]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Update-Guest.ps1 $VMName $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "prepare-update-devenv-$VMName"
$CMD = "~/devenv/scripts/prepare-update-devenv.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option

echo "#"
echo "# Copy files from $HOME\DevEnv\@guest to root@$VMName.localdomain:/root"
echo "#"

pscp  -r -i $HOME\.certs\putty.ppk $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "update-guest-$VMName"
$CMD = ". ~/devenv/scripts/chmod-devenv.sh"
Run-GuestScript $VMName $CMDName "$CMD" $Option
