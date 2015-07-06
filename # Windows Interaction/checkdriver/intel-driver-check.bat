@echo off

echo Checking Intel Graphics Driver...

%cd%\data\InstalledDriversList.exe /stext "drivers.txt" /sort "File Version"

for /f "tokens=*" %%i in ('type "drivers.txt"  ^|  find "10.18.10.3345"') do set INTELGFXVERS=%%i

if /I "%INTELGFXVERS%" NEQ "File Version      : 10.18.10.3345" (
ECHO.
ECHO Intel Graphics Driver not installed or not version 10.18.10.3345
)
if /I "%INTELGFXVERS%" EQU "File Version      : 10.18.10.3345" (
ECHO.
ECHO Intel Graphics Driver is correct, is %INTELGFXVERS%
echo.
)

del drivers.txt
pause