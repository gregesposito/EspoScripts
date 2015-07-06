@ECHO OFF
cls

set USER=DOMAIN\administrator
set PROGRAM="%windir%\system32\cmd.exe"

if not exist %PROGRAM% goto ERR1

runas /user:%USER% /savecred %PROGRAM%

goto END

:ERR1
cls
echo %PROGRAM% not found!
echo.
pause
goto END

:END
exit