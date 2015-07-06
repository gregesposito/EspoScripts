@echo off
c:
cd\

:start
cls

echo.
set input=
set /p input=Please enter host name or IP address:

cls
echo.
echo Please wait...
echo.

for /f "tokens=3 delims=," %%i in ('"getmac /s %input% /fo csv /v /nh | findstr Local"') do set mac=%%~i

cls
echo.
echo.%mac%
echo.

pause
goto start