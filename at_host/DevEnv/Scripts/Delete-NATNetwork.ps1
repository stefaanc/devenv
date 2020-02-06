echo "#"
echo "# ======================================================================="
echo "# Delete-NATNetwork.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Remove NAT network"
echo "#"

Remove-NetNat
echo ""

echo "#"
echo "# Remove VM switch 'Virtual Switch Internal'"
echo "#"

Remove-VMSwitch "Virtual Switch Internal"
echo ""
