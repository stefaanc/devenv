# Get name of virtual machine
$VMName = $args[0]

# Get name of command
$CMDName = $args[1]

# Get command-string
$CMD = $args[2]

# Get options
# -NoPrompt
$Option = $args[3]
$Option = "$Option".ToLower()

# Get password
$Password = $args[4]
$Password = "$Password".ToLower()

echo "#"
echo "# Run guest script on root@$VMName.localdomain"
echo "#"

if ( $Option -ne '-noprompt' ) {
    $CMD = $CMD + ' ; read -p "Press any key to continue . . . " -n 1'
}
$CMDFile = "$HOME\DevEnv\Scripts\PuTTY-cmd\_cmd.txt"
$LOGFile = "$HOME\DevEnv\Scripts\PuTTY-log\$CMDName-$(Get-Random).log"

echo ""
echo "Guest script : $CMD"
echo ""
New-Item -Type File -Path ~\DevEnv\Scripts\PuTTY-cmd\ -Name _cmd.txt -Force -Value $CMD
echo ""
echo "Please wait until guest script completes . . . \n"

if ( $Password -eq '' ) {
    putty -ssh -t -i $HOME\.certs\putty.ppk -m $CMDFile root@$VMName.localdomain -sessionlog $LOGFile | Out-Default
}
else {
    putty -ssh -t -pw $Password -m $CMDFile root@$VMName.localdomain -sessionlog $LOGFile | Out-Default
}
exit $LastExitCode
