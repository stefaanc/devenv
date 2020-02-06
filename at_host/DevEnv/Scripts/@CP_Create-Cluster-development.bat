setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.50" dev0 ;^
  Update-HostsFile dev0 development -Append ;^
  Update-HostsFile "192.168.0.51" dev1 ;^
  Update-HostsFile "192.168.0.52" dev2 ;^
  Restore-VMFromVHD.ps1 dev0 workernode-node ;^
  Restore-VMFromVHD.ps1 dev1 workernode-node ;^
  Restore-VMFromVHD.ps1 dev2 workernode-node ;^
  ^<##^> ;^
  Install-KubernetesMaster.ps1 dev0 development "10.244.0.0/16" ;^
  Generate-Token-Cluster.ps1 development ;^
  Join-Cluster.ps1 dev1 dev0 development ;^
  Join-Cluster.ps1 dev2 dev0 development ;^
  Create-Users-Cluster.ps1 development ;^
  ^<##^> ;^
  Install-KubernetesCLI.ps1 development ;^
  Open-NATPorts-Cluster.ps1 development ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
