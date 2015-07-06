@echo off
echo UNINSTALLING JUNIPER PULSE (4 or 5)...
"%programfiles(x86)%\Juniper Networks\Junos Pulse\PulseUninstall.exe" /silent=1 _?=%programfiles(x86)%\Juniper Networks\Junos Pulse
echo DONE
pause
pause
echo READY TO INSTALL JUNIPER PULSE 5...
msiexec /i "C:\Daly\001 - Batch Installs\JunosPulse.x64.msi" /qn /norestart
echo DONE
pause