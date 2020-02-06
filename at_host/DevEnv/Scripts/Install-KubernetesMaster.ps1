# Get name of virtual machine
$VMName = $args[0]

# Get name of cluster
$ClusterName = $args[1]

# Get IP-address of CIDR network
$CIDRNetwork = $args[2]

# Get option
# -NoPrompt
$Option = $args[3]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-KubernetesMaster.ps1 $VMName $ClusterName $CIDRNetwork $Option"
echo "# ======================================================================="
echo "#"
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "install-kubernetesmaster-$VMName"
$CMD = "~/devenv/scripts/install-kubernetesmaster.sh $ClusterName $CIDRNetwork"
Run-GuestScript $VMName $CMDName "$CMD" $Option

echo "#"
echo "# Pickup SSH credentials of root@$ClusterName.localdomain"
echo "#"

Write-Output 'y' | pscp  -r -i $HOME\.certs\putty.ppk root@$ClusterName.localdomain:/root/devenv/taints/installed-kubernetesmaster $HOME\DevEnv\Scripts\_tmp
del $HOME\DevEnv\Scripts\_tmp
echo ""
