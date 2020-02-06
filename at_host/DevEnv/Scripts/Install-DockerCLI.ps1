# Get options
# -Force
$Option = $args[0]
$Option = "$Option".ToLower()

echo "#"
echo "# ======================================================================="
echo "# Install-DockerCLI.ps1 $Option"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Install/upgrade docker-cli"
echo "#"


if ($Option -eq '-force') {
    choco upgrade docker-cli -y
}
else {
    choco upgrade docker-cli
}
echo ""