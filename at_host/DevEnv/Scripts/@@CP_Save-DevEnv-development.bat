setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Save-VHD.ps1 dev0 development-dev0 -NoPrompt -Force ;^
  Save-VHD.ps1 dev1 development-dev1 -NoPrompt -Force ;^
  Save-VHD.ps1 dev2 development-dev2 -NoPrompt -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
