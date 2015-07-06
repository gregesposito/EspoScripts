:  befor running this batch make sure you network connection
:   name = (  Local Area Connection  ) or change the name in the next command
: download the (  nvspbind  )  from msdn microsoft & put it with this batch in the same folder
: after running this bach the IPv6 will uncheck as if you did it manual
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
@setlocal enableextensions
@cd /d "%~dp0"

nvspbind /d "Ethernet" ms_tcpip6

echo Command Processed

pause