@echo off
set /a "counter=1"


:startmacro

IF "%counter%"=="10000" (
ECHO.
ECHO Ending process...
GOTO :endmacro
)

wol.exe AABBCC-DDEEFF >>speed.txt
 
 
set /a "counter+=1"

GOTO :startmacro

:endmacro
pause