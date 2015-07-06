@echo off
set /p pcinstaller=Please enter your last name: 
set /p pclocation=Please enter computer room: 
set /p monitorsn=Please enter monitor serial number:

echo -----------------------------------------
cscript /nologo "%cd%\data\pc_name.vbs" > name.txt
set /p pcname= <name.txt
REM echo %pcname%
echo Installer: %pcinstaller% > %pcname%.txt
echo Room: %pclocation% >> %pcname%.txt
cscript /nologo "%cd%\data\serial_number.vbs" >> %pcname%.txt
echo Monitor S/N: %monitorsn% >> %pcname%.txt
type %pcname%.txt
REM "%cd%\data\MonitorInfoView.exe" /stext "%cd%\data\monitors.txt"
REM type monitors.txt >> info.txt
REM type monitors.txt | find "Serial Number     :" >>info.txt
REM findstr "Monitor Serial" "%cd%\data\monitors.txt" > "%cd%/data/monitorstemp.txt"
REM findstr /V "Numeric" "%cd%\data\monitorstemp.txt" >>%pcname%.txt
REM del "%cd%\data\monitorstemp.txt"
REM del "%cd%\data\monitors.txt"
del name.txt
REM echo Monitor data added to %pcname%.txt
pause