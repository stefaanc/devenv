setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.59" apps ;^
  Update-HostsFile apps apps.development -Append ;^
  Deploy-KubeApps.ps1 development ;^
  Create-Users-KubeApps.ps1 development ;^
  ^<##^> ;^
  Copy-Users.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
