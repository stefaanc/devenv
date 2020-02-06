setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Copy-PuttyPub.ps1 ;^
  ^<##^> ;^
  Update-HostsFile "192.168.0.250" node ;^
  Restore-VMFromVHD.ps1 node guest-node -NoPrompt -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
