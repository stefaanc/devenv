setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.29" kube-dashboard.repository ;^
  ^<##^> ;^
  Deploy-KubernetesDashboard.ps1 repository ;^
  Deploy-Heapster.ps1 repository ;^
  Create-Users-KubernetesDashboard.ps1 repository ;^
  ^<##^> ;^
  Copy-Users.ps1 repository ;^
  Import-Certificates.ps1 repository ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
