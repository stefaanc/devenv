setlocal EnableDelayedExpansion

rem
rem Set command
rem

set CMD=^
  Install-Docker.ps1 node ;^
  Create-UsersDocker.ps1 node ;^
  ^<##^> ;^
  Install-DockerCLI.ps1 ;^
  ^<##^> ;^
  Wait-Key ;^
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
