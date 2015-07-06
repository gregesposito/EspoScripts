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
set /p mcaststart=Please enter the first Multicast IP: 
set /p mcastend=Please enter the last Multicast IP: 

@setlocal enableextensions
@cd /d "%~dp0"

echo.
echo Setting the starting and ending multicast IP Addresses. Note that the WDS application needs to be closed/reopened to see this change.
echo.
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WDSServer\Parameters /v "McStartAddr" /t REG_SZ /d "%mcaststart%" /f
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WDSServer\Parameters /v "McEndAddr" /t REG_SZ /d "%mcastend%" /f
echo.

echo Setting speeds to 3 streams. Note that the WDS application needs to be closed/reopened to see this change.
echo.

REM 1 is default, 3 is 3 stream

reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WDSServer\Providers\WDSMC\Protocol /v "TpSlowClientHandling" /t REG_DWORD /d 3 /f

pause