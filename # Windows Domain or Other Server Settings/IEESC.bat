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

REM  IEHarden Removal Project
REM  HasVersionInfo: Yes
REM  Author: Axelr
REM  Productname: Remove IE Enhanced Security
REM  Comments: Helps remove the IE Enhanced Security Component of Windows 2003 and 2008(including R2)
REM  IEHarden Removal Project End
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