setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-NFS-Terminal.ps1 repository ;^
  Update-HostsFile "192.168.0.121" terminal ;^
  Open-FirewallPorts-DockerRegistry.ps1 repo0 ;^
  Deploy-DockerRegistry.ps1 repository ;^
  ^<##^> ;^
  Open-NATPorts-DockerRegistry.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
