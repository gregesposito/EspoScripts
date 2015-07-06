@ECHO off
TITLE RunAS
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
C:
CD\
CLS

:MENU
CLS

ECHO ============= BOSS MENU =============
ECHO -------------------------------------
ECHO 1.  Selection 1
ECHO 2.  Set IP
ECHO 3.  Set WDS Multicast
ECHO 4.  Change PC Description
ECHO 5.  Enable Remote Desktop
ECHO 6.  Allow Remote Desktop
ECHO 7.  Change Adapter Name
ECHO -------------------------------------
ECHO 8.  Disable IEESC
ECHO -------------------------------------
ECHO 9.  Set DNS
ECHO -------------------------------------
ECHO ==========PRESS 'Q' TO QUIT==========
ECHO.

SET INPUT=
SET /P INPUT=Please select a number:

IF /I '%INPUT%'=='1' GOTO Selection1
IF /I '%INPUT%'=='2' GOTO Set IP
IF /I '%INPUT%'=='3' GOTO Set WDS Multicast
IF /I '%INPUT%'=='4' GOTO Change PC Description
IF /I '%INPUT%'=='5' GOTO Enable Remote Desktop
IF /I '%INPUT%'=='6' GOTO Allow Remote Desktop
IF /I '%INPUT%'=='7' GOTO Change Adapter Name
IF /I '%INPUT%'=='8' GOTO Disable IEESC
IF /I '%INPUT%'=='9' GOTO Set DNS
IF /I '%INPUT%'=='Q' GOTO Quit

CLS

ECHO ============INVALID INPUT============
ECHO -------------------------------------
ECHO Please select a number from the Main
echo Menu [1-9] or select 'Q' to quit.
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE > NUL
GOTO MENU

:Selection1

Whatever code you want goes here...

:Set IP

@echo off 
ipconfig /all
pause

echo Notice: Set IP?
echo Choose: 
echo [A] Set Static IP 
echo [B] Set DHCP 
echo. 
:choice 
SET /P C=[A,B]? 
for %%? in (A) do if /I "%C%"=="%%?" goto A 
for %%? in (B) do if /I "%C%"=="%%?" goto B 
goto choice 

:A 
@echo off 
echo "Please enter Static IP Address Information" 
echo "Static IP Address:" 
set /p IP_Addr=

echo "Subnet Mask:" 
set /p Sub_Mask=

echo "Default Gateway:" 
set /p D_Gate=

echo "Setting Static IP Information" 
netsh interface ip set address name="Local Area Connection" static %IP_Addr% %Sub_Mask% %D_Gate%
netsh int ip show config 
pause 
goto end

:B 
@ECHO OFF 
ECHO Resetting IP Address and Subnet Mask For DHCP 
netsh int ip set address name = "Local Area Connection" source = dhcp

ipconfig /renew

ECHO Here are the new settings for %computername%: 
netsh int ip show config

pause 
goto end 

:end

:Set WDS Multicast

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

:Change PC Description

set /p pcname=Please enter your PC Name: 
set /p pcdescription=Please enter your PC Description: 

@setlocal enableextensions
@cd /d "%~dp0"

echo Setting computer description to %pcdescription%...
echo.
:pause
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v "srvcomment" /t REG_SZ /d "%pcdescription%" /f
echo.

pause

echo Setting computer name to %pcname%...
echo.
:pause
wmic computersystem where name="%COMPUTERNAME%" call rename name="%pcname%"

echo A return value of 0 indicates success.
echo.
echo Hit any key to reboot (exit out to avoid reboot)
pause

shutdown.exe /r /t 00
pause

:Enable Remote Desktop

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
pause

:Allow Remote Desktop

netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
pause

:Change Adapter Name

@echo off
netsh interface set interface name="Local Area Connection" newname="Ethernet"
pause

:Disable IEESC

ECHO ON
::Related Article
::933991 Standard users cannot turn off the Internet Explorer Enhanced Security feature on a Windows Server 2003-based terminal server
::http://support.microsoft.com/default.aspx?scid=kb;EN-US;933991

:: Rem out if you like to Backup the registry keys
::REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" "%TEMP%.HKEY_LOCAL_MACHINE.SOFTWARE.Microsoft.Active Setup.Installed Components.A509B1A7-37EF-4b3f-8CFC-4F3A74704073.reg" 
::REG EXPORT "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" "%TEMP%.HKEY_LOCAL_MACHINE.SOFTWARE.Microsoft.Active Setup.Installed Components.A509B1A8-37EF-4b3f-8CFC-4F3A74704073.reg" 

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /v "IsInstalled" /t REG_DWORD /d 0 /f 

::Removing line below as it is not needed for Windows 2003 scenarios. You may need to enable it for Windows 2008 scenarios
::Rundll32 iesetup.dll,IEHardenLMSettings
Rundll32 iesetup.dll,IEHardenUser
Rundll32 iesetup.dll,IEHardenAdmin
Rundll32 iesetup.dll,IEHardenMachineNow

::This apply to Windows 2003 Servers
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenadmin" /f /va
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenuser" /f /va

REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenadmin" /t REG_DWORD /d 0 /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\OC Manager\Subcomponents" /v "iehardenuser" /t REG_DWORD /d 0 /f

::REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" /f /va
::REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" /f /va

:: Optional to remove warning on first IE Run and set home page to blank. remove the :: from lines below
:: 32-bit HKCU Keys
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "First Home Page" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Default_Page_URL" /t REG_SZ /d "about:blank" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /t REG_SZ /d "about:blank" /f
:: This will disable a warning the user may get regarding Protected Mode being disable for intranet, which is the default.
:: See article http://social.technet.microsoft.com/Forums/lv-LV/winserverTS/thread/34719084-5bdb-4590-9ebf-e190e8784ec7 
:: Intranet Protected mode is disable. Warning should not appear and this key will disable the warning
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer\Main" /v "NoProtectedModeBanner" /t REG_DWORD /d 1 /f

:: Removing Terminal Server Shadowing x86 32bit 
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Terminal Server\Install\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /f
;;  Removing Terminal Server Shadowing Wow6432Node
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Terminal Server\Install\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap" /v "IEHarden" /f
pause

:Set DNS

netsh interface ipv4 set dns name="Local Area Connection" static 8.8.8.8 primary
netsh interface ipv4 add dns name="Local Area Connection" 8.8.4.4
pause

:Quit
CLS

ECHO ==============THANKYOU===============
ECHO -------------------------------------
ECHO ======PRESS ANY KEY TO CONTINUE======

PAUSE>NUL
EXIT
Comments