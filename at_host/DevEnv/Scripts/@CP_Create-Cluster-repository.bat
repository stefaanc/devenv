setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.20" repo0 ;^
  Update-HostsFile repo0 repository -Append ;^
  Restore-VMFromVHD.ps1 repo0 workernode-node ;^
  ^<##^> ;^
  Install-KubernetesMaster.ps1 repo0 repository "192.168.250.0/24" ;^
  Create-Users-Cluster.ps1 repository ;^
  ^<##^> ;^
  Install-KubernetesCLI.ps1 repository ;^
  Open-NATPorts-Cluster.ps1 repository ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
