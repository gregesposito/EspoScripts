@Echo Off 
REM Change \\COMPUTER\PRINTER by your printer's UNC
echo Choose a number for a printer and name

echo 5 - M1G120AC0271 - G120-ES3555C
echo 8 - P2234AB0271 - 234-LJP3015
echo 9 - P2234BC0271 - 234-LJCP3525
echo 26 - M2FACAB0271 - FAC-ES656
echo 105 - P2A210AC0271 - A210-LJCP3525
echo 106 - M2A210BC0271 - A210-ES3555C
echo 110 - P2A214AB0271 - A214-LJP2055DN
echo 113 - M2F232AB0271 - F232-ES456
echo 116 - P2F243AB0271 - F243-SA3160DNP
echo 118 - M2224AB0271 - 224-ES656
echo 144 - M2BALCAB0271 - BALC-ES456
echo 154 - M2C251AC0271 - C251-ES5055C
echo 159 - M2234CC0271 - 234-ES3555C
echo 560 - Manual Entry
echo 561 - Hulk Executive 4730 MFP 64 bit
echo 562 - Hulk Executive Color 4600
echo 563 - Sales 4345 MFP


set /p pnum=Please enter the printer to add: 
echo You entered: %pnum%

goto:%pnum%

:5
echo You choose %pnum% which is \\Mmhs0271-ps1\M1G120AC0271
set printeruncpath=\\Mmhs0271-ps1\M1G120AC0271
goto :done

:8
echo You choose %pnum% which is \\Mmhs0271-ps1\P2234AB0271
set printeruncpath=\\Mmhs0271-ps1\P2234AB0271
goto :done

:9
echo You choose %pnum% which is \\Mmhs0271-ps1\P2234BC0271
set printeruncpath=\\Mmhs0271-ps1\P2234BC0271
goto :done

:26
echo You choose %pnum% which is \\Mmhs0271-ps1\M2FACAB0271
set printeruncpath=\\Mmhs0271-ps1\M2FACAB0271
goto :done

:105
echo You choose %pnum% which is \\Mmhs0271-ps1\P2A210AC0271
set printeruncpath=\\Mmhs0271-ps1\P2A210AC0271
goto :done

:106
echo You choose %pnum% which is \\Mmhs0271-ps1\M2A210BC0271
set printeruncpath=\\Mmhs0271-ps1\M2A210BC0271
goto :done

:110
echo You choose %pnum% which is \\Mmhs0271-ps1\P2A214AB0271
set printeruncpath=\\Mmhs0271-ps1\P2A214AB0271
goto :done

:113
echo You choose %pnum% which is \\Mmhs0271-ps1\M2F232AB0271
set printeruncpath=\\Mmhs0271-ps1\M2F232AB0271
goto :done

:116
echo You choose %pnum% which is \\Mmhs0271-ps1\P2F243AB0271
set printeruncpath=\\Mmhs0271-ps1\P2F243AB0271
goto :done

:118
echo You choose %pnum% which is \\Mmhs0271-ps1\M2224AB0271
set printeruncpath=\\Mmhs0271-ps1\M2224AB0271
goto :done

:144
echo You choose %pnum% which is \\Mmhs0271-ps1\M2BALCAB0271
set printeruncpath=\\Mmhs0271-ps1\M2BALCAB0271
goto :done

:154
echo You choose %pnum% which is \\Mmhs0271-ps1\M2C251AC0271
set printeruncpath=\\Mmhs0271-ps1\M2C251AC0271
goto :done

:159
echo You choose %pnum% which is \\Mmhs0271-ps1\M2234CC0271
set printeruncpath=\\Mmhs0271-ps1\M2234CC0271
goto :done

:560
echo You choose %pnum% which is manual entry
set /p printeruncpath=Please enter path to printer as \\Server\Printername: 
goto :done

:561
echo You choose %pnum% which is Hulk Executive 4730 MFP 64 bit
set printeruncpath=\\hulk\Executive 4730 MFP 64 bit
goto :done

:562
echo You choose %pnum% which is Hulk Executive Color 4600
set printeruncpath=\\hulk\Executive 4600 Color Printer 64 bit
goto :done

:563
echo You choose %pnum% which is Sales 4345 MFP
set printeruncpath=\\hulk\Sales HP LaserJet 4345 mfp PCL 5 64 bit
goto :done

:done
REM Add printer 
echo Attempting to map %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /in /ga /n "%printeruncpath%"

echo Attempting to print a test page on %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /k /n "%printeruncpath%"

REM Set printer as default 
::rundll32 printui.dll,PrintUIEntry /y /n\\COMPUTER\PRINTER

pause