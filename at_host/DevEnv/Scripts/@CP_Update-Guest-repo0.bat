setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-Guest.ps1 repo0;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
