setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Patch-KubernetesDashboard.ps1 development timeout 43200;^
  Patch-KubernetesDashboard.ps1 development banner DEFAULT;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
