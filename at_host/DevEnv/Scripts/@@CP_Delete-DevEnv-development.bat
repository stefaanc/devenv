setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Delete-VM.ps1 dev0 -Force ;^
  Delete-VM.ps1 dev1 -Force ;^
  Delete-VM.ps1 dev2 -Force ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
