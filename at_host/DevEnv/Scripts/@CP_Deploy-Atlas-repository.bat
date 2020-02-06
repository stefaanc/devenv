setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-NFS-Atlas.ps1 repository ;^
  Update-HostsFile "192.168.0.122" atlas ;^
  Open-FirewallPorts-ChartMuseum.ps1 repo0 ;^
  Deploy-ChartMuseum.ps1 repository ;^
  ^<##^> ;^
  Open-NATPorts-ChartMuseum.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
