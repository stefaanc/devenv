setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  Update-HostsFile "192.168.0.50" dev0 ;^
  Update-HostsFile dev0 development -Append ;^
  Update-HostsFile "192.168.0.51" dev1 ;^
  Update-HostsFile "192.168.0.52" dev2 ;^
  Restore-VMFromVHD.ps1 dev0 development-dev0 -NoPrompt -Force ;^
  Restore-VMFromVHD.ps1 dev1 development-dev1 -NoPrompt -Force ;^
  Restore-VMFromVHD.ps1 dev2 development-dev2 -NoPrompt -Force ;^
  Update-HostsFile "192.168.0.59" apps.development ;^
  Update-HostsFile "192.168.0.59" kube-dashboard.development ;^
  ^<##^> ;^
  Install-DockerCLI.ps1 -Force ;^
  Install-KubernetesCLI.ps1 development -Force ;^
  Open-NATPorts-Cluster.ps1 development ;^
  Install-HelmCLI.ps1 development -Force ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
