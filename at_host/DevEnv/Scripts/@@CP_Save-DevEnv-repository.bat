setlocal EnableDelayedExpansion

rem
rem Set command
rem
  
set CMD=^
  Save-VHD.ps1 repo0 repository-repo0 -NoPrompt -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
