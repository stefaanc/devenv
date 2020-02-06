# Get name of virtual machine
$VMName = $args[0]

# Get name of saved virtual hard disk
$SavedVHDName = $args[1]

# Get option
# -NoPrompt
# -Force
$Option1 = $args[2]
$Option1 = "$Option1".ToLower()
$Option2 = $args[3]
$Option2 = "$Option2".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Save-VHD.ps1 $VMName $SavedVHDName $Option1 $Option2"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName.localdomain
#

$CMDName = "save-devenv-$VMName"
$CMD = "~/devenv/scripts/prepare-save-devenv.sh $SavedVHDName"
if ( ($Option1 -eq '-noprompt') -or ($Option2 -eq '-noprompt') ) {
    Run-GuestScript $VMName $CMDName "$CMD" -NoPrompt
}
else {
    Run-GuestScript $VMName $CMDName "$CMD"
}

echo "#"
echo "# Prepare for restore"
echo "#"

pscp  -i $HOME\.certs\putty.ppk $HOME\DevEnv\@guest\devenv\config\devenv-shells\.devenv_init root@$VMName.localdomain:/root
# sometimes this doesn't seem to happen - VM stopped before the file is written to VHD? => sleep 1
sleep 1 
echo ""

echo "#"
echo "# Stop virtual machine $VMName"
echo "#"

Stop-VM -Name $VMName -Force | Out-Default
echo ""

echo "#"
echo "# Save virtual hard disk"
echo "#"

$VMStoragePath = (Get-Item -Path '~\DevEnv\Virtual Machines').FullName

$VHDName = $VMName + '.vhdx'
$VHDStoragePath = Join-Path -Path $VMStoragePath -ChildPath "$VMName\Virtual Hard Disks\$VHDName"

$SavedVHDStorageName = $SavedVHDName
if ($SavedVHDStorageName -notmatch '\.vhdx$') {
	$SavedVHDStorageName += '.vhdx'
}
$SavedVHDStoragePath = Join-Path -Path $VMStoragePath -ChildPath 'Virtual Hard Disks'
if (-not (Test-Path -Path $SavedVHDStoragePath)) {
    New-Item -Path $VMStoragePath -Name "Virtual Hard Disks" -ItemType Directory
}
$SavedVHDStoragePath = Join-Path -Path $SavedVHDStoragePath -ChildPath $SavedVHDStorageName

Remove-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2

Copy-Item $VHDStoragePath -Destination $SavedVHDStoragePath

$VMHardDiskDrive = Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2 -Path $VHDStoragePath -Passthru
echo ""

echo "#"
echo "# Start virtual machine $VMName"
echo "#"

Start-VM -Name $VMName | Out-Default
echo ""

echo "#"
echo "# Waiting for connectivity to be restored"
echo "#"

Do {
    ping "$VMName.localdomain"
} 
While ($LastExitCode -ne 0)
echo ""

echo "#"
echo "# Pickup new SSH credentials of root@$VMName.localdomain"
echo "#"

Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@$VMName.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
del $HOME\DevEnv\Scripts\_tmp
echo ""

if ($VMName -eq 'repo0') {
    echo "#"
    echo "# Pickup new SSH credentials of root@repository.localdomain"
    echo "#"

    Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@repository.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
    del $HOME\DevEnv\Scripts\_tmp
    echo ""
}
if ($VMName -eq 'dev0') {
    echo "#"
    echo "# Pickup new SSH credentials of root@development.localdomain"
    echo "#"

    Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@development.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
    del $HOME\DevEnv\Scripts\_tmp
    echo ""
}
