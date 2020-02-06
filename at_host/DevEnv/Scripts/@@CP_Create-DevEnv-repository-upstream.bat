setlocal EnableDelayedExpansion

@echo off
rem   All commands have to be concatenated on a single line to be able to pass them to PowerShell.
rem   Hence following rules:
rem   - make sure every line starts with at least one space         ( this avoids the first character being escaped by the ^ of the previous line )
rem   - make sure every line ends with ^                            ( this skips the <CR><LF> and escapes the first character of the next line )
rem   - make sure every code line ends with ;^                      ( this replaces <CR><LF> with a ; and escapes the first character of the next line )
rem   - put comments between ^<# and #^>                            ( this escapes the < and > for CommandPrompt, and this makes them in-line comments for PowerShell )
rem   - make sure the last line is a line with at least one space   ( this avoids the first character of the next line being escaped by the ^ of the previous line )
@echo on

rem
rem Set command
rem
  
set CMD26=^
  ^<# @ Deploy Depot Repository @ #^> ;^
  Update-HostsFile "192.168.0.120" depot.repository ;^
  Update-HostsFile depot.repository depot -Append ;^
  Update-HostsFile "192.168.0.29" droppy.repository ;^
  Update-HostsFile droppy.repository droppy -Append ;^
  ^<##^> ;^
  Install-NFS-Depot.ps1 repository -NoPrompt ;^
  Deploy-Droppy.ps1 repository -NoPrompt ;^
  Create-Users-Droppy.ps1 repository -NoPrompt ;^
  
set CMD27=^
  ^<# @ Deploy Terminal Repository @ #^> ;^
  Update-HostsFile "192.168.0.121" terminal.repository ;^
  Update-HostsFile terminal.repository terminal -Append ;^
  ^<##^> ;^
  Install-NFS-Terminal.ps1 repository -NoPrompt ;^
  Deploy-DockerRegistry.ps1 repository -NoPrompt ;^
  
set CMD28=^
  ^<# @ Deploy Atlas Repository @ #^> ;^
  Update-HostsFile "192.168.0.122" atlas.repository ;^
  Update-HostsFile atlas.repository atlas -Append ;^
  Update-HostsFile "192.168.0.29" chartmuseum-ui.repository ;^
  Update-HostsFile chartmuseum-ui.repository chartmuseum-ui -Append ;^
  ^<##^> ;^
  Install-NFS-Atlas.ps1 repository -NoPrompt ;^
  Deploy-ChartMuseum.ps1 repository -NoPrompt ;^
  Deploy-ChartMuseumUI.ps1 repository -NoPrompt ;^
  Create-Users-ChartMuseumUI.ps1 repository -NoPrompt ;^
 
set CMD29=^
  ^<# @ Install HelmPush Repository @ #^> ;^
  Install-HelmPush.ps1 repository -NoPrompt ;^
  ^<##^> ;^
  
set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  !CMD26! ^
  !CMD27! ^
  !CMD28! ^
  !CMD29! ^
  ^<##^> ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!

rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
