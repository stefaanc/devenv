setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  Update-HostsFile "192.168.0.250" node ;^
  Restore-VMFromVHD.ps1 node workernode-node -NoPrompt -Force ;^
  ^<##^> ;^
  Install-DockerCLI.ps1 -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
