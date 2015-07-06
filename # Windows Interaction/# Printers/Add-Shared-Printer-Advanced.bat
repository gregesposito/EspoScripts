@Echo Off 
REM Change \\COMPUTER\PRINTER by your printer's UNC

REM Add printer 
set /p printeruncpath=Please enter path to printer as \\Server\Printername: 
echo Attempting to map %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /in /n "%printeruncpath%"

echo Attempting to print a test page on %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /k /n "%printeruncpath%"

REM Set printer as default 
::rundll32 printui.dll,PrintUIEntry /y /n\\COMPUTER\PRINTER

pause