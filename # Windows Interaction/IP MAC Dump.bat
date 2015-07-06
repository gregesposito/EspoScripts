:: http://social.technet.microsoft.com/Forums/da/ITCG/thread/450dca77-f1e9-4c39-9597-f500300af4d4

@echo off
setlocal
set target=file2.txt
set /p =%date% %time% %UserName% < nul >> %target%
set qry=where "ipenabled=true"
set params=description^^,ipaddress^^,macaddress^^,MTU
for /f "usebackq skip=2 tokens=1-4 delims=," %%a in (
  `wmic nicconfig %qry% get %params% /format:csv ^<nul^|find /v "0.0.0.0"`
    ) do echo %%b %%c %%d >> %target%
echo.>> %target%

pause