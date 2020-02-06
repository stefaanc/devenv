setlocal EnableDelayedExpansion

@echo off
rem   All commands have to be concatenated on a single line to be able to pass them to PowerShell.
rem   Hence following rules:
rem   - make sure every line starts with at least one space         ( this avoids the first character being escaped by the ^ of the previous line )
rem   - make sure every line ends with ^                            ( this skips the <CR><LF> and escapes the first character of the next line )
rem   - make sure every code line ends with ;^                      ( this replaces <CR><LF> with a ; and escapes the first character of the next line )
rem   - put comments between ^<# and #^>                            ( this escapes the < and > for CommandPrompt, and this makes them in-line comments for PowerShell )
rem   - make sure the last line is a line with at least one space   ( this avoids the first character of the next line being escaped by the ^ of the previous line )
@echo on

rem
rem Set command
rem
  
set CMD20=^
  ^<# @@ Delete DevEnv WorkerNode @@ #^> ;^
  Delete-VM.ps1 node -Force ;^
  
set CMD21=^
  ^<# @ Create Cluster Repository @ #^> ;^
  Update-HostsFile "192.168.0.20" repo0 ;^
  Update-HostsFile repo0 repository -Append ;^
  Restore-VMFromVHD.ps1 repo0 workernode-node -NoPrompt -Force ;^
  ^<##^> ;^
  Install-KubernetesMaster.ps1 repo0 repository "192.168.250.0/24" -NoPrompt ;^
  Create-Users-Cluster.ps1 repository -NoPrompt ;^
  ^<##^> ;^
  Install-KubernetesCLI.ps1 repository -Force ;^
  Open-NATPorts-Cluster.ps1 repository ;^
  
set CMD22=^
  ^<# @ Install Helm Repository @ #^> ;^
  Install-Helm.ps1 repository -NoPrompt ;^
  Create-Users-Helm.ps1 repository -NoPrompt ;^
  ^<##^> ;^
  Install-HelmCLI.ps1 repository -Force ;^
  
set CMD23=^
  ^<# @ Deploy Metrics Server Repository @ #^> ;^
  Deploy-MetricsServer.ps1 repository -NoPrompt ;^
  ^<##^> ;^
  
set CMD24=^
  ^<# @ Deploy Ingress Repository @ #^> ;^
  Update-HostsFile "192.168.0.29" apps.repository ;^
  ^<##^> ;^
  Deploy-MetalLB.ps1 repository -NoPrompt ;^
  Deploy-NginxIngress.ps1 repository -NoPrompt ;^
  Create-Users-NginxIngress.ps1 repository -NoPrompt ;^
  ^<##^> ;^
  
set CMD25=^
  ^<# @ Deploy Kubernetes Dashboard Repository @ #^> ;^
  Update-HostsFile "192.168.0.29" kube-dashboard.repository ;^
  ^<##^> ;^
  Deploy-KubernetesDashboard.ps1 repository -NoPrompt ;^
  Deploy-Heapster.ps1 repository -NoPrompt ;^
  Create-Users-KubernetesDashboard.ps1 repository -NoPrompt ;^
  
set CMD39=^
  ^<# @@ Save DevEnv Repository @@ #^> ;^
  Save-VHD.ps1 repo0 repository-repo0 -NoPrompt -Force ;^
   
set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  !CMD20! ^
  !CMD21! ^
  !CMD22! ^
  !CMD23! ^
  !CMD24! ^
  !CMD25! ^
  !CMD39! ^
  ^<##^> ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!

rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
