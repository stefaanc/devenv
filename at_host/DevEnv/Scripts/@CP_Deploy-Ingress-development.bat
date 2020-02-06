setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.59" apps.development ;^
  ^<##^> ;^
  Deploy-MetalLB.ps1 development ;^
  Deploy-NginxIngress.ps1 development ;^
  Create-Users-NginxIngress.ps1 development -NoPrompt ;^
  ^<##^> ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
