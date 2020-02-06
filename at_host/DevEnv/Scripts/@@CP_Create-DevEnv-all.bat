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

rem  @@ Prepare DevEnv @@
  
set CMD0=^
  ^<# @ Prepare Development Environment @ #^> ;^
  ~/Devenv/Scripts/Update-Path.ps1 ;^
  Clean-DevEnv.ps1 ;^
  Install-Chocolatey.ps1 ;^
  Install-HostTools.ps1 -Force ;^
  Delete-VM.ps1 node -Force ;^
  Delete-VM.ps1 repo0 -Force ;^
  Delete-VM.ps1 dev0 -Force ;^
  Delete-VM.ps1 dev1 -Force ;^
  Delete-VM.ps1 dev2 -Force ;^
  Delete-NATRules.ps1 ;^
  Delete-NATNetwork.ps1 ;^
  Update-HostsFile "192.168.0.1" gateway ;^
  Create-NATNetwork.ps1 ;^
  ^<##^> ;^
  Copy-PuttyPub.ps1 ;^
  
rem  @@ Create DevEnv Guest @@
  
set CMD1=^
  ^<# @ Create Guest @ #^> ;^
  Update-HostsFile "192.168.0.250" node ;^
  Create-VM.ps1 node CentOS-7-x86_64-DVD-1810 -NoPrompt -Force ;^
  Install-GuestTools.ps1 node -NoPrompt ;^
  ^<##^> ;^
  Create-Users-Guest.ps1 node -NoPrompt ;^
  
set CMD9=^
  ^<# @@ Save DevEnv Guest @@ #^> ;^
  Save-VHD.ps1 node guest-node -NoPrompt -Force ;^
  
rem  @@ Create DevEnv WorkerNode @@
  
set CMD10=^
  ^<# @@ Restore DevEnv Guest @@ #^> ;^
  Update-HostsFile "192.168.0.250" node ;^
  Restore-VMFromVHD.ps1 node guest-node -NoPrompt -Force ;^
  
set CMD11=^
  ^<# @ Install Docker @ #^> ;^
  Install-Docker.ps1 node -NoPrompt ;^
  Create-Users-Docker.ps1 node -NoPrompt ;^
  ^<##^> ;^
  Install-DockerCLI.ps1 -Force ;^
  
set CMD12=^
  ^<# @ Create WorkerNode @ #^> ;^
  Install-KubernetesWorker.ps1 node -NoPrompt ;^
  Create-Users-WorkerNode.ps1 node -NoPrompt ;^
  
set CMD19=^
  ^<# @@ Save DevEnv WorkerNode @@ #^> ;^
  Save-VHD.ps1 node workernode-node -NoPrompt -Force ;^
  
rem  @@ Create DevEnv Repository @@
  
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
  
rem  @@ Create DevEnv Development @@
  
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
  !CMD0! ^
  !CMD1! ^
  !CMD9! ^
  !CMD11! ^
  !CMD12! ^
  !CMD19! ^
  !CMD20! ^
  !CMD21! ^
  !CMD22! ^
  !CMD23! ^
  !CMD24! ^
  !CMD25! ^
  !CMD39! ^
  !CMD51! ^
  !CMD52! ^
  !CMD53! ^
  !CMD54! ^
  !CMD55! ^
  !CMD69! ^
  ^<##^> ;^
  Copy-Users.ps1 repository ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 repository ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!

rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
