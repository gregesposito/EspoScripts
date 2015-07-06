@echo off
REM --- Parse list of servers
for /f %%a in (path\ServerName.txt) do CALL :RbtMe %%a
goto :DONE

:RbtMe
REM --- Restarting remote system.
shutdown -r -t 05 -c "Rebooting for Whatevas" -f -m %1
GOTO :EOF

:DONE