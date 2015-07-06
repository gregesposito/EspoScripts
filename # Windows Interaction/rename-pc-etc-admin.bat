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
set /a newtimehour = %time:~0,2%
set /a newtimehour -=4
echo Old time is %time%

time %newtimehour%%time:~2,14%
echo New time is %time%
echo.

:powerset
color 3f
echo Setting power scheme to balanced...
powercfg -SETACTIVE 381b4222-f694-41f0-9685-ff5bb260df2e
echo Checking...
for /f "delims=" %%a in ('powercfg -getactivescheme') do @set powercheck=%%a
if not "%powercheck%"  == "Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)" goto :powerseterror
echo %powercheck% is set
echo.

goto :schoolname

:powerseterror
color 4f
REM == Make the Screen Red ===
echo Power settings is wrong, is currently %powercheck%
pause
cls
goto :powerset

:schoolname
color 1f
echo Setting computer name...
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