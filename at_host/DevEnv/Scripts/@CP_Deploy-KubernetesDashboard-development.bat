setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.59" kube-dashboard.development ;^
  ^<##^> ;^
  Deploy-KubernetesDashboard.ps1 development ;^
  Deploy-Heapster.ps1 development ;^
  Create-Users-KubernetesDashboard.ps1 development ;^
  ^<##^> ;^
  Copy-Users.ps1 development ;^
  Import-Certificates.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
