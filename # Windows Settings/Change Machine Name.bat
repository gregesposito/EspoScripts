echo. 
echo %computername%
echo Last computer renamed: %machine% 
echo. 
echo. 
echo. 
set /p machine= Input Computer to rename: 
echo. 
set /p newname= Input new computer name: 
echo. 
set /p pcdescription=Please enter your PC Description: 

@setlocal enableextensions
@cd /d "%~dp0"

echo Setting computer description to %pcdescription%...
echo.
:pause
reg add HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters /v "srvcomment" /t REG_SZ /d "%pcdescription%" /f

echo. 
c:\rencomp\netdom.exe renamecomputer %machine% /newname:%newname% /userD:maamc.org\administrator /passwordd:%TGBnhy6 /reboot:360 
NET SEND %machine% Pimp Slap!!!!- Computer Renamed: %newname% 
c:\rencomp\psexec -c \\%machine% shutdown /r 
goto A