# Get name of virtual machine
$VMName = $args[0]

# Get option
# -Force
# -NoHeader
$Option1 = $args[1]
$Option1 = "$Option1".ToLower()
$Option2 = $args[2]
$Option2 = "$Option2".ToLower()

if ( ($Option1 -ne '-noheader') -and ($Option2 -ne '-noheader') ) {
    echo "#"
    echo "# ======================================================================="
    echo "# Delete-VM.ps1 $VMName $Option"
    echo "# ======================================================================="
    echo "#"
    echo ""
}

echo "#"
echo "# Turn off virtual machine $VMName"
echo "#"

if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
    Stop-VM -Name $VMName -TurnOff | Out-Default
}
else {
    Stop-VM -Name $VMName -TurnOff -Confirm | Out-Default
}
echo ""

echo "#"
echo "# Remove virtual machine $VMName"
echo "#"

$VMStoragePath = (Get-Item -Path '~\DevEnv\Virtual Machines').FullName
$VMStoragePath = Join-Path -Path $VMStoragePath -ChildPath $VMName

if ( ($Option1 -eq '-force') -or ($Option2 -eq '-force') ) {
    Remove-VM -Name $VMName -Force
    Remove-Item $VMStoragePath -Recurse -Force
}
else {
    Remove-VM -Name $VMName
    Remove-Item $VMStoragePath -Recurse
}
echo ""
