@Echo Off 
REM Change \\COMPUTER\PRINTER by your printer's UNC

:560
set /p printeruncpath=Please enter path to printer as \\Server\Printername: 
goto :done

:done
REM Add printer 
echo Attempting to map %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /in /ga /n "%printeruncpath%"

echo You probably need to restart the print spooler or restart and wait.

echo If you rerun for this printer and it says it already is installed, it is installed.
REM RESTART THE PRINT SPOOLER AND THEN WAIT FOR 1 MIN
REM echo Attempting to print a test page on %printeruncpath%...
REM rundll32 printui.dll,PrintUIEntry /k /n "%printeruncpath%"

REM Set printer as default 
::rundll32 printui.dll,PrintUIEntry /y /n\\COMPUTER\PRINTER

pause