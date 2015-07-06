@echo off
for /F "skip=1 tokens=*" %%c in ('wmic computersystem get model') do if not defined model set model=%%c
for /F "skip=1 tokens=*" %%d in ('wmic bios get serialnumber') do if not defined serial set serial=%%d

echo SETTING SYSTEM INFO MODEL TO %model% Service Tag %serial%
echo.

echo Windows Registry Editor Version 5.00 > modelfix.reg
echo. >> modelfix.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation] >> modelfix.reg
echo "Model"="%model% Service Tag %serial%" >> modelfix.reg

regedit.exe /s "C:\Daly\001 - Batch Installs\modelfix.reg"

for /f "tokens=2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v Model 2^>^&1^|find "REG_"') do @set fn=%%b

if /I "%fn%" NEQ "%model% Service Tag %serial%" (
color c0
ECHO SET MODEL FAILED
)
if /I "%fn%" EQU "%model% Service Tag %serial%" (
color a0
ECHO SET MODEL SUCCESS
)

pause