@ECHO off

ECHO CHECKING INSTALLED INTEL GRAPHICS DRIVER

dxdiag /t dxdiaglog.txt

for /f "tokens=*" %%i in ('type "dxdiaglog.txt"  ^|  find "Driver Version: 10.18.10.3345"') do set INTELGFXVERS=%%i

if /I "%INTELGFXVERS%" NEQ "Driver Version: 10.18.10.3345" (
color c0
ECHO.
ECHO INTEL GRAPHICS DRIVER IS NOT CORRECT, SHOULD BE VERSION 10.18.10.3345
)
if /I "%INTELGFXVERS%" EQU "Driver Version: 10.18.10.3345" (
color b0
ECHO.
ECHO INTEL GRAPHICS IS CORRECT, IS VERSION %INTELGFXVERS%
ECHO.
)

REM del drivers.txt
pause