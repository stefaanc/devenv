setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  cd ~ ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -NoExit -Command !CMD!'
