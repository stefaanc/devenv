setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  Update-HostsFile "192.168.0.20" repo0 ;^
  Update-HostsFile repo0 repository -Append ;^
  Restore-VMFromVHD.ps1 repo0 repository-repo0 -NoPrompt -Force ;^
  Update-HostsFile "192.168.0.29" apps.repository ;^
  Update-HostsFile "192.168.0.29" kube-dashboard.repository ;^
  ^<##^> ;^
  Install-DockerCLI.ps1 -Force ;^
  Install-KubernetesCLI.ps1 repository -Force ;^
  Open-NATPorts-Cluster.ps1 repository ;^
  Install-HelmCLI.ps1 repository -Force ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
