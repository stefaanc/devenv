setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Delete-NATNetwork.ps1 ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
