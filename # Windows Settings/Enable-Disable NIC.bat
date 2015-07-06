@ECHO off
TITLE SUPERSCRIPT VERSION 3.3 2014-07-08
ECHO ======================
ECHO ESCALATING PERMISSIONS
ECHO ======================

:checkPrivileges 
NET FILE 1>NUL 2>NUL
IF '%errorlevel%' == '0' ( GOTO :gotPrivileges ) else ( GOTO :getPrivileges ) 

:getPrivileges 
IF '%1'=='ELEV' (shIFt & GOTO :gotPrivileges)  
ECHO. 
ECHO *****************
ECHO Invoking UAC For Privilege Escalation 
ECHO *****************

SETlocal DisableDelayedExpansion
SET "batchPath=%~0"
SETlocal EnableDelayedExpansion
ECHO SET UAC = CreateObject^("Shell.Application"^) > "%temp%\UAC.vbs" 
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\UAC.vbs" 
"%temp%\UAC.vbs" 
exit \B 

:gotPrivileges 
::::::::::::::::::::::::::::
:START
::::::::::::::::::::::::::::
setlocal & pushd .

COLOR 0f

CLS

goto Choices

REM use this command to determine what the adapter index number is
REM wmic nic get name, index


:Top
choice /c:123456
If ERRORLEVEL == 6 goto Enable_Wireless_Disable_LAN
If ERRORLEVEL == 5 goto Enable_LAN_Disable_Wireless
If ERRORLEVEL == 4 goto Disable_Wireless
If ERRORLEVEL == 3 goto Disable_LAN
If ERRORLEVEL == 2 goto Enable_Wireless
If ERRORLEVEL == 1 goto Enable_LAN
goto EOF

:1
:Enable_LAN
wmic path win32_networkadapter where index=7 call enable
goto :EOF

:2
:Enable_Wireless
wmic path win32_networkadapter where index=11 call enable
goto :EOF

:3
:Disable_LAN
wmic path win32_networkadapter where index=7 call disable
goto :EOF

:4
:Disable_Wireless
wmic path win32_networkadapter where index=11 call disable
goto :EOF

:5
:Enable_LAN_Disable_Wireless
wmic path win32_networkadapter where index=7 call enable
goto :4

:6
:Enable_Wireless_Disable_LAN
wmic path win32_networkadapter where index=11 call enable
goto :3


:Choices
echo 1 Enable LAN
echo 2 Enable Wireless
echo 3 Disable LAN
echo 4 Disable Wireless
echo 5 Enable LAN / Disable Wireless
echo 6 Enable Wireless / Disable LAN
goto Top


:EOF