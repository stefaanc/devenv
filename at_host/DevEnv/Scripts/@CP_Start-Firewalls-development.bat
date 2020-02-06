setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Start-Firewall.ps1 dev0 ;^
  Start-Firewall.ps1 dev1 ;^
  Start-Firewall.ps1 dev2 ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
