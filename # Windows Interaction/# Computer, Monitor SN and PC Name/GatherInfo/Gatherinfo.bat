@echo off
set /p pcinstaller=Please enter your last name: 
set /p pclocation=Please enter computer room: 

echo -----------------------------------------
cscript /nologo "%cd%\data\pc_name.vbs" > name.txt
set /p pcname= <name.txt
echo Installer: %pcinstaller% > %pcname%.txt
echo Room: %pclocation% >> %pcname%.txt

echo ----------------------------------------- >> %pcname%.txt

echo Domain (PC Name if None): %userdomain% >> %pcname%.txt
echo Currently Logged-In User: %UserName% >> %pcname%.txt

cscript /nologo "%cd%\data\serial_number.vbs" >> %pcname%.txt
"%cd%\data\MonitorInfoView.exe" /HideInactiveMonitors 1 /stext "%cd%\data\monitors.txt"
type "%cd%\data\monitors.txt" | find "Serial Number     :" >>%pcname%.txt

set qry=where "ipenabled=true"
set params=description^^,ipaddress^^,macaddress^^,MTU
for /f "usebackq skip=2 tokens=1-4 delims=," %%a in (
  `wmic nicconfig %qry% get %params% /format:csv ^<nul^|find /v "0.0.0.0"`
    ) do echo %%b %%c %%d >> %pcname%.txt

set qry=where "ipenabled=true"
set params=DNSServerSearchOrder
for /f "usebackq skip=2 tokens=1-4 delims=," %%a in (
  `wmic nicconfig %qry% get %params% /format:csv ^<nul^|find /v "0.0.0.0"`
    ) do echo DNS Servers %%b > tempdns.txt
type tempdns.txt >> %pcname%.txt

echo ----------------------------------------- >> %pcname%.txt

REM net use >> %pcname%.txt
net use >> netusetemp.txt
type netusetemp.txt | find ":" >> %pcname%.txt

del tempdns.txt
del "%cd%\data\monitors.txt"
del name.txt
del netusetemp.txt

type %pcname%.txt

pause