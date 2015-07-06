@echo off
set /p pcinstaller=Please enter your last name: 
set /p pclocation=Please enter computer room: 

echo -----------------------------------------
cscript /nologo "%cd%\data\pc_name.vbs" > name.txt
set /p pcname= <name.txt
REM echo %pcname%
echo Installer: %pcinstaller% > %pcname%.txt
echo Room: %pclocation% >> %pcname%.txt
cscript /nologo "%cd%\data\serial_number.vbs" >> %pcname%.txt
type %pcname%.txt
"%cd%\data\MonitorInfoView.exe" /stext "%cd%\data\monitors.txt"
REM type monitors.txt >> info.txt
REM type monitors.txt | find "Serial Number     :" >>info.txt
findstr "Monitor Serial" "%cd%\data\monitors.txt" > "%cd%/data/monitorstemp.txt"
findstr /V "Numeric" "%cd%\data\monitorstemp.txt" >>%pcname%.txt
del "%cd%\data\monitorstemp.txt"
del "%cd%\data\monitors.txt"
del name.txt
echo Monitor data added to %pcname%.txt
pause