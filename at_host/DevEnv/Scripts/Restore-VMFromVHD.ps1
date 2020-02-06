# Get name of virtual machine
$VMName = $args[0]

# Get name of saved virtual hard disk
$SavedVHDName = $args[1]

# Get options
# -NoPrompt
# -Force
$Option1 = $args[2]
$Option1 = "$Option1".ToLower()
$Option2 = $args[3]
$Option2 = "$Option2".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Restore-VMFromVHD.ps1 $VMName $SavedVHDName $Option1 $Option2"
echo "# ======================================================================="
echo "#"
echo ""

#
# Delete VM
#

if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
    Delete-VM.ps1 $VMName -Force -NoHeader
}
else {
    Delete-VM.ps1 $VMName -NoHeader
}

echo "#"
echo "# Create virtual machine $VMName"
echo "#"

$VMStoragePath = (Get-Item -Path '~\DevEnv\Virtual Machines').FullName
$VMSwitchName = (Get-VMSwitch | ? SwitchType -eq 'Internal')[0].Name

New-VM -Name $VMName -MemoryStartupBytes 2GB -SwitchName $VMSwitchName -Path $VMStoragePath -Generation 2 -NoVHD | Out-Default
Set-VM -Name $VMName -AutomaticStopAction ShutDown
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 2GB -MaximumBytes 4GB
Set-VMProcessor -VMName $VMName -Count 2
Start-VM -VMName $VMName
Stop-VM -VMName $VMName -Force | Out-Default
echo ""

echo "#"
echo "# Copy hard disk"
echo "#"

$VHDName = $VMName + '.vhdx'
$VMXStoragePath = Join-Path -Path $VMStoragePath -ChildPath $VMName
$VHDStoragePath = Join-Path -Path $VMXStoragePath -ChildPath 'Virtual Hard Disks'
if (-not (Test-Path -Path $VHDStoragePath)) {
    New-Item -Path $VMXStoragePath -Name "Virtual Hard Disks" -ItemType Directory
}
$VHDStoragePath = Join-Path -Path $VHDStoragePath -ChildPath $VHDName

$SavedVHDStoragePath = Join-Path -Path $VMStoragePath -ChildPath "Virtual Hard Disks\$SavedVHDName"
if ($SavedVHDStoragePath -notmatch '\.vhdx$') {
	$SavedVHDStoragePath += '.vhdx'
}
if (-not (Test-Path -Path $SavedVHDStoragePath -PathType Leaf)) {
	Write-Error -Message ("Path $SavedVHDStoragePath does not exist.")
	return
}

Copy-Item $SavedVHDStoragePath -Destination $VHDStoragePath
echo ""

echo "#"
echo "# Add devices to virtual machine"
echo "#"

$VMNetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
$VMDVDDrive1 = Add-VMDVDDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 0 -Passthru
$VMDVDDrive2 = Add-VMDVDDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 1 -Passthru
$VMHardDiskDrive = Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2 -Path $VHDStoragePath -Passthru
Set-VMNetworkAdapter -VMNetworkAdapter $VMNetworkAdapter -StaticMACAddress ($VMNetworkAdapter.MACAddress)
Set-VMFirmware -VMName $VMName -BootOrder $VMDVDDrive1, $VMDVDDrive2, $VMHardDiskDrive, $VMNetworkAdapter -EnableSecureBoot Off
echo ""

echo "#"
echo "# Insert DVD disk"
echo "#"

$DVDStoragePath = (Get-Item -Path '~\DevEnv\Virtual Machines\Virtual DVD Disks\').FullName
$DevEnvISOPath = Join-Path -Path $DVDStoragePath -ChildPath "$VMName.iso"
if (-not (Test-Path -Path $DevEnvISOPath -PathType Leaf)) {
	Write-Error -Message ("Path $DevEnvISOPath does not exist.")
	return
}
Set-VMDVDDrive -VMDVDDrive $VMDVDDrive2 -Path $DevEnvISOPath
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
echo "# Pickup new SSH credentials of $VMName.localdomain"
echo "#"

Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@$VMName.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp

if ( $LastExitCode -ne 0 ) {
    echo ""
    
    echo "#"
    echo "# The first attempt failed, probably because PuTTY-keys changed, probably because restoring virtual hard disks from another system"
    echo "#"
    echo ""

    echo "#"
    echo "# Try again"
    echo "#"

    Write-Output 'y' | pscp  -r -pw rootroot root@$VMName.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
}

if ( $LastExitCode -ne 0 ) {
    echo ""
    
    echo "#"
    echo "# The second attempt failed, probably because the default root password was changed"
    echo "#"
    echo ""

    echo "#"
    echo "# Try again"
    echo "#"
    echo ""

    echo "#"
    echo "# Get password for root@$VMName.localdomain"
    echo "#"

    $RootPWD = Read-Host -AsSecureString "Please enter password for root@$VMName.localdomain"
    $RootPWD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPwd))
    Write-Output 'y' | pscp  -r -pw $RootPWD root@$VMName.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
    $RootPWD = ""
}

del $HOME\DevEnv\Scripts\_tmp
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "prepare-restore-devenv-$VMName"
$CMD = "~/devenv/scripts/prepare-update-devenv.sh"
if ( ($Option1 -eq '-noprompt') -or ($Option2 -eq '-noprompt') ) {
    Run-GuestScript $VMName $CMDName "$CMD" -NoPrompt
}
else {
    Run-GuestScript $VMName $CMDName "$CMD"
}
echo ""

echo "#"
echo "# Copy files from $HOME\DevEnv\@guest to root@$VMName.localdomain:/root"
echo "#"

if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
    Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
}
else {
    pscp  -r -i $HOME\.certs\putty.ppk $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
}
echo ""

#
# Run guest script on root@$VMName.localdomain
#

$CMDName = "restore-devenv-$VMName"
$CMD = ". ~/devenv/scripts/chmod-devenv.sh"
if ( ($Option1 -eq '-noprompt') -or ($Option2 -eq '-noprompt') ) {
    Run-GuestScript $VMName $CMDName "$CMD" -NoPrompt
}
else {
    Run-GuestScript $VMName $CMDName "$CMD"
}
echo ""

if ($VMName -eq 'repo0') {
    echo "#"
    echo "# Pickup new SSH credentials of repository.localdomain"
    echo "#"

    Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@repository.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
    del $HOME\DevEnv\Scripts\_tmp
}
if ($VMName -eq 'dev0') {
    echo "#"
    echo "# Pickup new SSH credentials of development.localdomain"
    echo "#"

    Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@development.localdomain:/root/devenv/taints/saved-devenv-$SavedVHDName $HOME\DevEnv\Scripts\_tmp
    del $HOME\DevEnv\Scripts\_tmp
}
echo ""
