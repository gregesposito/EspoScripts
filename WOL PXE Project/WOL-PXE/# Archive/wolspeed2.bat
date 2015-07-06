@echo off
set /a "counter=1"


:startmacro

IF "%counter%"=="10000" (
ECHO.
ECHO Ending process...
GOTO :endmacro
)

mc-wol.exe AA:BB:CC:DD:EE:FF >>speed.txt
 
 
set /a "counter+=1"

GOTO :startmacro

:endmacro
pause