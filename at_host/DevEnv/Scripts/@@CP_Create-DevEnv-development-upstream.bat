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
  
set CMD56=^
  ^<# @ Install HelmPush Development @ #^> ;^
  ^<##^> ;^
  
set CMD57=^
  ^<# @ Deploy KubeApps Development @ #^> ;^
  Update-HostsFile "192.168.0.59" kube-apps.development ;^
  Update-HostsFile kube-apps.development kube-apps -Append ;^
  ^<##^> ;^
  Deploy-KubeApps.ps1 development -NoPrompt ;^
  Create-Users-KubeApps.ps1 development -NoPrompt ;^
  ^<##^> ;^
  
set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  !CMD56! ^
  !CMD57! ^
  ^<##^> ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!

rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
