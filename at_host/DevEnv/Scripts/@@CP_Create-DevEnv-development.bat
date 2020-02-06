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
  
set CMD50=^
  ^<# @@ Delete DevEnv WorkerNode @@ #^> ;^
  Delete-VM.ps1 node -Force ;^
  
set CMD51=^
  ^<# @ Create Cluster Development @ #^> ;^
  Update-HostsFile "192.168.0.50" dev0 ;^
  Update-HostsFile dev0 development -Append ;^
  Update-HostsFile "192.168.0.51" dev1 ;^
  Update-HostsFile "192.168.0.52" dev2 ;^
  Restore-VMFromVHD.ps1 dev0 workernode-node -NoPrompt -Force ;^
  Restore-VMFromVHD.ps1 dev1 workernode-node -NoPrompt -Force ;^
  Restore-VMFromVHD.ps1 dev2 workernode-node -NoPrompt -Force ;^
  ^<##^> ;^
  Install-KubernetesMaster.ps1 dev0 development "10.244.0.0/16" -NoPrompt ;^
  Generate-Token-Cluster.ps1 development -NoPrompt ;^
  Join-Cluster.ps1 dev1 dev0 development -NoPrompt ;^
  Join-Cluster.ps1 dev2 dev0 development -NoPrompt ;^
  Create-Users-Cluster.ps1 development -NoPrompt ;^
  ^<##^> ;^
  Install-KubernetesCLI.ps1 development -Force ;^
  Open-NATPorts-Cluster.ps1 development ;^
  
set CMD52=^
  ^<# @ Install Helm Development @ #^> ;^
  Install-Helm.ps1 development -NoPrompt ;^
  Create-Users-Helm.ps1 development -NoPrompt ;^
  ^<##^> ;^
  Install-HelmCLI.ps1 development -Force ;^
  
set CMD53=^
  ^<# @ Deploy Metrics Server Development @ #^> ;^
  Deploy-MetricsServer.ps1 development -NoPrompt ;^
  ^<##^> ;^
  
set CMD54=^
  ^<# @ Deploy Ingress Development @ #^> ;^
  Update-HostsFile "192.168.0.59" apps.development ;^
  Update-HostsFile apps.development apps -Append ;^
  ^<##^> ;^
  Deploy-MetalLB.ps1 development -NoPrompt ;^
  Deploy-NginxIngress.ps1 development -NoPrompt ;^
  Create-Users-NginxIngress.ps1 development -NoPrompt ;^
  ^<##^> ;^
  
set CMD55=^
  ^<# @ Deploy Kubernetes Dashboard Development @ #^> ;^
  Update-HostsFile "192.168.0.59" kube-dashboard.development ;^
  Update-HostsFile kube-dashboard.development kube-dashboard -Append ;^
  ^<##^> ;^
  Deploy-KubernetesDashboard.ps1 development -NoPrompt ;^
  Deploy-Heapster.ps1 development -NoPrompt ;^
  Create-Users-KubernetesDashboard.ps1 development -NoPrompt ;^
  
set CMD69=^
  ^<# @@ Save DevEnv Development @@ #^> ;^
  Save-VHD.ps1 dev0 development-dev0 -NoPrompt -Force ;^
  Save-VHD.ps1 dev1 development-dev1 -NoPrompt -Force ;^
  Save-VHD.ps1 dev2 development-dev2 -NoPrompt -Force ;^
  
set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  !CMD50! ^
  !CMD51! ^
  !CMD52! ^
  !CMD53! ^
  !CMD54! ^
  !CMD55! ^
  !CMD69! ^
  ^<##^> ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!

rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
