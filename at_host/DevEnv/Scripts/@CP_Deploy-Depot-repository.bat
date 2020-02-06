setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-NFS-Depot.ps1 repository ;^
  Update-HostsFile "192.168.0.120" depot ;^
  Deploy-Droppy.ps1 repository ;^
  Create-Users-Droppy.ps1 repository ;^
  ^<##^> ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
