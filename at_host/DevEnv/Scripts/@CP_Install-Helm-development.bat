setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-Helm.ps1 development ;^
  Create-Users-Helm.ps1 development ;^
  ^<##^> ;^
  Install-HelmCLI.ps1 development ;^
  Copy-Users.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
