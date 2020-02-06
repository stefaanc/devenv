setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Stop-Firewall.ps1 dev0 ;^
  Stop-Firewall.ps1 dev1 ;^
  Stop-Firewall.ps1 dev2 ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
