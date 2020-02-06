setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-HelmPush.ps1 development ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
