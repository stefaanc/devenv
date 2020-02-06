# Get name of worker virtual machine
$VMName = $args[0]

# Get name of master virtual machine
$MasterVMName = $args[1]

# Get name of cluster
$ClusterName = $args[2]

# Get option
# -NoPrompt
$Option = $args[3]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Join-Cluster.ps1 $VMName $MasterVMName $ClusterName $Option"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Copy token from $HOME\.certs to root@$VMName.localdomain:/root/.certs"
echo "#"

pscp -i $HOME\.certs\putty.ppk $HOME\.certs\cluster.* root@$VMName.localdomain:/root/.certs
echo ""

#
# Run guest script on root@$VMName
#

$CMDName = "join-cluster-$VMName"
$CMD = "~/devenv/scripts/join-cluster.sh $MasterVMName $ClusterName"
Run-GuestScript $VMName $CMDName "$CMD" $Option
