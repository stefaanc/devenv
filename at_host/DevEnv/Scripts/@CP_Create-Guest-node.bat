setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Update-HostsFile "192.168.0.250" node ;^
  Create-VM.ps1 node CentOS-7-x86_64-DVD-1810 ;^
  ^<##^> ;^
  Create-Users-Guest.ps1 node ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
