setlocal EnableDelayedExpansion

@echo off
rem   All commands have to be concatenated on a single line to be able to pass them to PowerShell.
rem   Hence following rules:
rem   - make sure every line starts with at least one space         ( this avoids the first character being escaped by the ^ of the previous line )
rem   - make sure every line ends with ^                            ( this skips the <CR><LF> and escapes the first character of the next line )
rem   - make sure every code line ends with ;^                      ( this replaces <CR><LF> with a ; and escapes the first character of the next line )
rem   - put comments between ^<# and #^>                            ( this escapes the < and > for CommandPrompt, and this makes them in-line comments for PowerShell )
rem   - make sure the last line is a line with at least one space   ( this avoids the first character of the next line being escaped by the ^ of the previous line )
@echo on

rem
rem Set command
rem

set CMD0=^
  ^<# *** Prepare Development Environment *** #^> ;^
  ~/Devenv/Scripts/Update-Path.ps1 ;^
  Clean-DevEnv.ps1 ;^
  Install-Chocolatey.ps1 ;^
  Install-HostTools.ps1 -Force ;^
  Delete-VM.ps1 node -NoPrompt -Force ;^
  Delete-VM.ps1 repo0 -NoPrompt -Force ;^
  Delete-VM.ps1 dev0 -NoPrompt -Force ;^
  Delete-VM.ps1 dev1 -NoPrompt -Force ;^
  Delete-VM.ps1 dev2 -NoPrompt -Force ;^
  Delete-NATRules.ps1 ;^
  Delete-NATNetwork.ps1 ;^
  Update-HostsFile "192.168.0.1" gateway ;^
  Create-NATNetwork.ps1 ;^
  ^<##^> ;^
  Copy-PuttyPub.ps1 ;^
  
set CMD=^
  ^<##^> ;^
  !CMD0! ^
  ^<##^> ;^
  Wait-Key ;^
  
echo !CMD!
  
rem
rem Execute command
rem

PowerShell -NoProfile -Command Start-Process -Verb RunAs PowerShell '-ExecutionPolicy Bypass -Command !CMD!'
