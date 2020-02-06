setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  _UPDATE-AFTER-REBOOT.ps1 ;^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
