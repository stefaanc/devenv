echo "#"
echo "# ======================================================================="
echo "# Install-Chocolatey.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Install Chocolatey"
echo "#"

if ( !( Test-Path -Path "$HOMEDRIVE/ProgramData/chocolatey" ) ) {
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
echo ""
