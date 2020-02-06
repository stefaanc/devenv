# Get name of virtual machine
$VMName = $args[0]

# Get name of ISO-file for Centos 7 installation
$BootISOName = $args[1]

# Get options
# -NoPrompt
# -Force
$Option1 = $args[2]
$Option1 = "$Option1".ToLower()
$Option2 = $args[3]
$Option2 = "$Option2".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Create-VM.ps1 $VMName $BootISOName $Option1 $Option2"
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
echo "# Create hard drive"
echo "#"

$VHDName = $VMName + '.vhdx'
$VHDStoragePath = Join-Path -Path $VMStoragePath -ChildPath "$VMName\Virtual Hard Disks\$VHDName"

New-VHD -Path $VHDStoragePath -SizeBytes 40GB -Dynamic -BlockSizeBytes 1MB | Out-Default
echo ""

echo "#"
echo "# Add devices to virtual machine"
echo "#"

$VMNetworkAdapter = Get-VMNetworkAdapter -VMName $VMName
$VMDVDDrive1 = Add-VMDVDDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 0 -Passthru
$VMDVDDrive2 = Add-VMDVDDrive -VMName $VMName -ControllerNumber 0 -ControllerLocation 1 -Passthru
$VMHardDiskDrive = Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 2 -Path $VHDStoragePath -Passthru
Set-VMNetworkAdapter -VMNetworkAdapter $VMNetworkAdapter -StaticMACAddress ($VMNetworkAdapter.MACAddress)
Set-VMFirmware -VMName $VMName -BootOrder $VMDVDDrive1, $VMHardDiskDrive, $VMNetworkAdapter -EnableSecureBoot Off
echo ""

echo "#"
echo "# Insert DVD disks"
echo "#"

if ($BootISOName -notmatch '\.iso$') {
	$BootISOName += '.iso'
}
$DVDStoragePath = (Get-Item -Path '~\DevEnv\Virtual Machines\Virtual DVD Disks\').FullName
$BootISOPath = Join-Path -Path $DVDStoragePath -ChildPath $BootISOName
if (-not (Test-Path -Path $BootISOPath -PathType Leaf)) {
	Write-Error -Message ("Path $BootISOPath does not exist.")
	return
}
Set-VMDVDDrive -VMDVDDrive $VMDVDDrive1 -Path $BootISOPath

$KickstartISOPath = Join-Path -Path $DVDStoragePath -ChildPath "OEMDRV.iso"
if (-not (Test-Path -Path $KickstartISOPath -PathType Leaf)) {
	Write-Error -Message ("Path $KickstartISOPath does not exist.")
	return
}
Set-VMDVDDrive -VMDVDDrive $VMDVDDrive2 -Path $KickstartISOPath

$DevEnvISOPath = Join-Path -Path $DVDStoragePath -ChildPath "$VMName.iso"
if (-not (Test-Path -Path $DevEnvISOPath -PathType Leaf)) {
	Write-Error -Message ("Path $DevEnvISOPath does not exist.")
	return
}

echo ""

echo "#"
echo "# Start virtual machine $VMName"
echo "#"

Start-VM -Name $VMName
echo ""

echo "#"
echo "# Connect to console"
echo "#"

echo ""
echo "Please keep this PowerShell running"
echo "Continue in the console window, and close the console when finished . . . "
vmconnect.exe $env:COMPUTERNAME $VMName | Out-Default
echo ""

echo "#"
echo "# Eject DVD disks"
echo "#"

# Set-VMDVDDrive -VMDVDDrive $VMDVDDrive1 -Path ""   ### automatically ejected after installation
Set-VMDVDDrive -VMDVDDrive $VMDVDDrive2 -Path $DevEnvISOPath
echo ""

echo "#"
echo "# Copy files from ~\DevEnv\@guest to root@$VMName.localdomain:/root"
echo "#"

if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
   Write-Output 'y' | pscp -r -pw rootroot $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
}
else {
   pscp -r -pw rootroot $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
}

if ( $LastExitCode -ne 0 ) {
    echo ""

    echo "#"
    echo "# The first attempt failed, probably because thr default root password was changed"
    echo "# Try again"
    echo "#"
    echo ""

    echo "#"
    echo "# Try again"
    echo "#"
    echo ""

    echo "#"
    echo "# Get password for root@$VMName"
    echo "#"

    $RootPWD = Read-Host -AsSecureString "Please enter password for root@${VMName}"
    $RootPWD = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($RootPwd))
    if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
       Write-Output 'y' | pscp -r -pw $RootPWD $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
    }
    else {
       pscp -r -pw $RootPWD $HOME\DevEnv\@guest\* root@$VMName.localdomain:/root
    }
    $RootPWD = ""
}
echo ""

echo "#"
echo "# Pickup new SSH credentials of root@$VMName.localdomain"
echo "#"

Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@$VMName.localdomain:/root/.devenvrc $HOME\DevEnv\Scripts\_tmp
del $HOME\DevEnv\Scripts\_tmp
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "complete-install-centos-$VMName"
$CMD = ". ~/devenv/scripts/complete-install-centos.sh"
if ( ($Option1 -eq '-noprompt') -or ($Option2 -eq '-noprompt') ) {
    Run-GuestScript $VMName $CMDName "$CMD" -NoPrompt
}
else {
    Run-GuestScript $VMName $CMDName "$CMD"
}
