:::::::::::::::::::::::::::::::::::::::::
:: Automatically check & get admin rights
:::::::::::::::::::::::::::::::::::::::::
@echo off

CLS 

ECHO =============================
ECHO Running Admin shell
ECHO =============================

:checkPrivileges 
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges ) 

:getPrivileges 
if '%1'=='ELEV' (shift & goto gotPrivileges)  
ECHO. 
ECHO **************************************
ECHO Invoking UAC for Privilege Escalation 
ECHO **************************************

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs" 
"%temp%\OEgetPrivileges.vbs" 
exit /B 

:gotPrivileges 
::::::::::::::::::::::::::::
:START
::::::::::::::::::::::::::::
setlocal & pushd .
color 5f
REM Run shell as admin
set /p schoolcode=Please enter your schoolcode: 

@setlocal enableextensions
@cd /d "%~dp0"
cscript /nologo "%cd%\data\serial_number.vbs" >> pcserial.txt
set /p serialnum= <pcserial.txt

echo Setting computer name to T%serialnum%%schoolcode%...
echo.
:pause
wmic computersystem where name="%COMPUTERNAME%" call rename name="T%serialnum%%schoolcode%"
del pcserial.txt

echo A return value of 0 indicates success.
echo.
echo Hit any key to reboot (exit out to avoid reboot)
pause
shutdown.exe /r /t 00
pause