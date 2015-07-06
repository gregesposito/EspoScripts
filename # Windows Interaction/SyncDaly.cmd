@echo off
TITLE Sync Daly MDT
set usbdir=%~dp0
robocopy "\\TSSGROUP-FS1\DS-Daly$\Applications" "%usbdir%DS-Daly\Applications" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Control" "%usbdir%DS-Daly\Control" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Operating Systems" "%usbdir%DS-Daly\Operating Systems" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Out-of-Box Drivers" "%usbdir%DS-Daly\Out-of-Box Drivers" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Packages" "%usbdir%DS-Daly\Packages" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Scripts" "%usbdir%DS-Daly\Scripts" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Templates" "%usbdir%DS-Daly\Templates" *.* /MIR
robocopy "\\TSSGROUP-FS1\DS-Daly$\Tools" "%usbdir%DS-Daly\Tools" *.* /MIR
echo Done!
timeout /t 10
exit
