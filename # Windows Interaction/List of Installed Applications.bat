@echo off

If Exist c:\installedprogs.txt Del c:\installedprogs.txt

regedit /e c:\regexport.txt "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall" 

find "DisplayName" c:\regexport.txt >c:\regprogs.txt

for /f "tokens=2 delims==" %%a in (c:\regprogs.txt) do echo %%~a >>c:\installedprogs.csv

del c:\regexport.txt
del c:\regprogs.txt

C:\installedprogs.csv

exit