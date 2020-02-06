setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-Helm.ps1 repository ;^
  Create-UsersHelm.ps1 repository ;^
  ^<##^> ;^
  Install-HelmCLI.ps1 repository ;^
  Copy-Users.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
