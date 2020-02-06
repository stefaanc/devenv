setlocal EnableDelayedExpansion

rem
rem Set command
rem
  
set CMD=^
  Delete-VM.ps1 repo0 -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
