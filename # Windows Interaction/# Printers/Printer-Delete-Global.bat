@Echo Off 
REM Change \\COMPUTER\PRINTER by your printer's UNC

set /p printeruncpath=Please enter path to printer as \\Server\Printername: 
goto :done

:done
REM Add printer 
echo Attempting to delete %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /dn /gd /n "%printeruncpath%"

echo The printer should now be gone.

echo If you get an error, the printer is either not installed or misspelled.

REM Set printer as default 
::rundll32 printui.dll,PrintUIEntry /y /n\\COMPUTER\PRINTER

pause