$HOMEDRIVE = $env:HOMEDRIVE
# if this doesn't work ($env:HOMEDRIVE doesn't exist), comment the previous line, uncomment and adapt the next line
# $HOMEDRIVE = "C:"
$HOMEPATH = $env:HOMEPATH
# if this doesn't work ($env:HOMEPATH doesn't exist), comment the previous line, and uncomment and adapt the next line
# $HOMEPATH = "\Users\$env:USERNAME"

Set-Variable HOME "$HOMEDRIVE$HOMEPATH" -Force
# also replace "~"
(Get-PSProvider 'FileSystem').Home = $HOME

Set-Variable PATH "$env:PATH;$HOME\DevEnv\Scripts"

if ( Test-Path -Path "$HOME\.kube\profile.ps1" ) {
    . $HOME\.kube\profile.ps1
}
if ( Test-Path -Path "$HOME\.helm\profile.ps1" ) {
    . $HOME\.helm\profile.ps1
}
