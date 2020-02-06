echo "#"
echo "# ======================================================================="
echo "# Update-Path.ps1"
echo "# ======================================================================="
echo "#"
echo ""

echo "#"
echo "# Add $HOME\DevEnv\Scripts to path"
echo "#"

$CurrentPath = (Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH).Path
if ( ! $CurrentPath.ToLower().Contains("$HOME\DevEnv\Scripts".ToLower()) ) {
    $NewPath = "$CurrentPath;$HOME\DevEnv\Scripts"
    Set-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment" -Name PATH -Value $NewPath
}
($Env:Path).Split(";")
echo ""
