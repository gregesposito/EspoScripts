::Simple monitor and kill process (exact name)
@echo off

set processname=ccmsetup.exe

echo Searching for %processname%...
echo.

:loop
for /f "tokens=*" %%i in ('tasklist /fi "imagename eq %processname%"') do set SCCMCHECK=%%i

if /I "%SCCMCHECK%" EQU "INFO: No tasks are running which match the specified criteria." (
ECHO.
ECHO SCCM AGENT DONE INSTALLING
echo.
echo WAITING 1 MINUTE FOR ACTIONS TO PROPAGATE TO CONTROL PANEL
ping -n 61 127.0.0.1>NUL
RUNDLL32 SHELL32.DLL,Control_RunDLL %WinDir%\CCM\SMSCFGRC.cpl,@n,t
pause
goto :end
)
  
  if /I "%SCCMCHECK%" NEQ "INFO: No tasks are running which match the specified criteria." (
   ECHO SCCM AGENT STILL INSTALLING, CHECKING AGAIN IN 45 SECONDS
)


ping -n 46 127.0.0.1>NUL
goto :loop

:end
pause