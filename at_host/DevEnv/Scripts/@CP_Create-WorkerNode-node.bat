setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-KubernetesWorker.ps1 node ;^
  Create-Users-WorkerNode.ps1 node ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
