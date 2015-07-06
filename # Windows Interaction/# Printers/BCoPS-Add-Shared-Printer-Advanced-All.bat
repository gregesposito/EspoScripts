@Echo Off 
REM Change \\COMPUTER\PRINTER by your printer's UNC
echo Choose a number for a printer and name

echo 1 - M1MAINAB0271 - MAIN-ES656
echo 2 - M1F136AB0271 - F136-ES656
echo 3 - M1LIBAB0271 - LIBRA-E656
echo 4 - P1LIBBB0271 - LIBRA-LJP3010
echo 5 - P1LIBCB0271 - LIBRA-LJP3010
echo 6 - P1CLABAB0271 - CLAB-LJP3010
echo 7 - P1WORKAB0271 - WORK-LJ4240
echo 8 - M1WORKBC0271 - WORK-OJPROX576DW
echo 9 - P1GUIDAB0271 - GUID-LJ4250
echo 10 - M1GUIDBB0271 - GUID-ES456
echo 11 - M1E144JAB0271 - E144J-ES456
echo 12 - P1E144JBB0271 - E144J-LJ4250
echo 13 - M1F135AB0271 - F135-LJ4250
echo 14 - P1F135AAB0271 - F135A-LJP4014N
echo 15 - P1G116AAB0271 - G116A-LJP3010
echo 16 - M1G116ABB0271 - G116A-ES456
echo 17 - P1G116ACB0271 - G116A-LJP3015
echo 18 - M1G120AC0271 - G120-ES3555C
echo 19 - P1131AB0271 - 131-LJP4015N
echo 20 - P1F130AC0271 - F130-LJCP4005N
echo 21 - P1F128AB0271 - F128-LJP3010
echo 22 - P1F129AB0271 - F129-LJP3010
echo 23 - P1F128BB0271 - F128-LJ2055DN
echo 24 - P1127AAB0271 - 127A-LJP3005
echo 25 - P1G124AB0271 - G124-LJP3005
echo 26 - P1G124BB0271 - G124-LJP3005
echo 27 - P1G123AB0271 - G123-LJ4250
echo 28 - P1G123BC0271 - G123-LJPRO200
echo 29 - P1121AB0271 - 121-LJP3010
echo 30 - P1G121AB0271 - G121-LJP3010
echo 31 - P1119AB0271 - 119-LJP3010
echo 32 - P1G1146AB0271 - G1146-P4014N
echo 33 - P1108AC0271 - 108-LJCP2025
echo 34 - P1E106AB0271 - E106-LJP3010
echo 35 - M1C141AAB0271 - C141A-ES456
echo 36 - M1GYMAB0271 - GYM-ES456
echo 37 - P1101AC0271 - 101-LJPRO400
echo 38 - P1???AB0271 - ???-SA3180DNP
echo 39 - M1F115AC0271 - F115-OJPROX576DW
echo 40 - P1SPEDAB0271 - SPED-LJ600
echo 41 - P1121AB0271 - 121-SA9022DP
echo 42 - M1A172AC0271 - A172-ES3555C
echo 43 - M1S202AB0271 - S202-ES456
echo 44 - M2F232AB0271 - F232-ES456
echo 45 - P2234AB0271 - 234-LJP3015
echo 46 - P2234BC0271 - 234-LJCP3525
echo 47 - M2234CC0271 - 234-ES3555C
echo 48 - M2FACAB0271 - FAC-ES656
echo 49 - P2A210AC0271 - A210-LJCP3525
echo 50 - M2A210BC0271 - A210-ES3555C
echo 51 - P2A214AB0271 - A214-LJP2055DN
echo 52 - P2F243AB0271 - F243-SA3160DNP
echo 53 - M2BALCAB0271 - BALC-ES456
echo 54 - M2C251AC0271 - C251-ES5055C
echo 55 - M2224AB0271 - 224-ES656

set /p pnum=Please enter the printer to add: 
echo You entered: %pnum%

goto:%pnum%

:1
echo You choose %pnum% which is \\Mmhs0271-ps1\M1MAINAB0271
set /p printeruncpath=\\Mmhs0271-ps1\M1MAINAB0271
goto :done

:2
echo You choose %pnum% which is \\Mmhs0271-ps1\M1F136AB0271
set /p printeruncpath=\\Mmhs0271-ps1\M1F136AB0271
goto :done

:3
echo You choose %pnum% which is \\Mmhs0271-ps1\M1LIBAB0271
set /p printeruncpath=\\Mmhs0271-ps1\M1LIBAB0271
goto :done

:4
echo You choose %pnum% which is \\Mmhs0271-ps1\P1LIBBB0271
set /p printeruncpath=\\Mmhs0271-ps1\P1LIBBB0271
goto :done

:5
echo You choose %pnum% which is \\Mmhs0271-ps1\P1LIBCB0271
set /p printeruncpath=\\Mmhs0271-ps1\P1LIBCB0271
goto :done

:6
echo You choose %pnum% which is \\Mmhs0271-ps1\P1CLABAB0271
set /p printeruncpath=\\Mmhs0271-ps1\P1CLABAB0271
goto :done

:7
echo You choose %pnum% which is \\Mmhs0271-ps1\P1WORKAB0271
set /p printeruncpath=\\Mmhs0271-ps1\P1WORKAB0271
goto :done

:8
echo You choose %pnum% which is \\Mmhs0271-ps1\M1WORKBC0271
set /p printeruncpath=\\Mmhs0271-ps1\M1WORKBC0271
goto :done

:9
echo You choose %pnum% which is \\Mmhs0271-ps1\P1GUIDAB0271
set /p printeruncpath=\\Mmhs0271-ps1\P1GUIDAB0271
goto :done

:10
echo You choose %pnum% which is \\Mmhs0271-ps1\M1GUIDBB0271
set /p printeruncpath=\\Mmhs0271-ps1\M1GUIDBB0271
goto :done

:11
echo You choose %pnum% which is \\Mmhs0271-ps1\M1E144JAB0271
set /p printeruncpath=\\Mmhs0271-ps1\M1E144JAB0271
goto :done

:12
echo You choose %pnum% which is \\Mmhs0271-ps1\P1E144JBB0271
set /p printeruncpath=
goto :done

:13
echo You choose %pnum% which is \\Mmhs0271-ps1\M1F135AB0271
set /p printeruncpath=
goto :done

:14
echo You choose %pnum% which is \\Mmhs0271-ps1\P1F135AAB0271
set /p printeruncpath=
goto :done

:15
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G116AAB0271
set /p printeruncpath=
goto :done

:16
echo You choose %pnum% which is \\Mmhs0271-ps1\M1G116ABB0271
set /p printeruncpath=
goto :done

:17
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G116ACB0271
set /p printeruncpath=
goto :done

:18
echo You choose %pnum% which is \\Mmhs0271-ps1\M1G120AC0271
set /p printeruncpath=
goto :done

:19
echo You choose %pnum% which is \\Mmhs0271-ps1\P1131AB0271
set /p printeruncpath=
goto :done

:20
echo You choose %pnum% which is \\Mmhs0271-ps1\P1F130AC0271
set /p printeruncpath=
goto :done

:21
echo You choose %pnum% which is \\Mmhs0271-ps1\P1F128AB0271
set /p printeruncpath=
goto :done

:22
echo You choose %pnum% which is \\Mmhs0271-ps1\P1F129AB0271
set /p printeruncpath=
goto :done

:23
echo You choose %pnum% which is \\Mmhs0271-ps1\P1F128BB0271
set /p printeruncpath=
goto :done

:24
echo You choose %pnum% which is \\Mmhs0271-ps1\P1127AAB0271
set /p printeruncpath=
goto :done

:25
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G124AB0271
set /p printeruncpath=
goto :done

:26
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G124BB0271
set /p printeruncpath=
goto :done

:27
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G123AB0271
set /p printeruncpath=
goto :done

:28
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G123BC0271
set /p printeruncpath=
goto :done

:29
echo You choose %pnum% which is \\Mmhs0271-ps1\P1121AB0271
set /p printeruncpath=
goto :done

:30
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G121AB0271
set /p printeruncpath=
goto :done

:31
echo You choose %pnum% which is \\Mmhs0271-ps1\P1119AB0271
set /p printeruncpath=
goto :done

:32
echo You choose %pnum% which is \\Mmhs0271-ps1\P1G1146AB0271
set /p printeruncpath=
goto :done

:33
echo You choose %pnum% which is \\Mmhs0271-ps1\P1108AC0271
set /p printeruncpath=
goto :done

:34
echo You choose %pnum% which is \\Mmhs0271-ps1\P1E106AB0271
set /p printeruncpath=
goto :done

:35
echo You choose %pnum% which is \\Mmhs0271-ps1\M1C141AAB0271
set /p printeruncpath=
goto :done

:36
echo You choose %pnum% which is \\Mmhs0271-ps1\M1GYMAB0271
set /p printeruncpath=
goto :done

:37
echo You choose %pnum% which is \\Mmhs0271-ps1\P1101AC0271
set /p printeruncpath=
goto :done

:38
echo You choose %pnum% which is \\Mmhs0271-ps1\P1???AB0271
set /p printeruncpath=
goto :done

:39
echo You choose %pnum% which is \\Mmhs0271-ps1\M1F115AC0271
set /p printeruncpath=
goto :done

:40
echo You choose %pnum% which is \\Mmhs0271-ps1\P1SPEDAB0271
set /p printeruncpath=
goto :done

:41
echo You choose %pnum% which is \\Mmhs0271-ps1\P1121AB0271
set /p printeruncpath=
goto :done

:42
echo You choose %pnum% which is \\Mmhs0271-ps1\M1A172AC0271
set /p printeruncpath=
goto :done

:43
echo You choose %pnum% which is \\Mmhs0271-ps1\M1S202AB0271
set /p printeruncpath=
goto :done

:44
echo You choose %pnum% which is \\Mmhs0271-ps1\M2F232AB0271
set /p printeruncpath=
goto :done

:45
echo You choose %pnum% which is \\Mmhs0271-ps1\P2234AB0271
set /p printeruncpath=
goto :done

:46
echo You choose %pnum% which is \\Mmhs0271-ps1\P2234BC0271
set /p printeruncpath=
goto :done

:47
echo You choose %pnum% which is \\Mmhs0271-ps1\M2234CC0271
set /p printeruncpath=
goto :done

:48
echo You choose %pnum% which is \\Mmhs0271-ps1\M2FACAB0271
set /p printeruncpath=
goto :done

:49
echo You choose %pnum% which is \\Mmhs0271-ps1\P2A210AC0271
set /p printeruncpath=
goto :done

:50
echo You choose %pnum% which is \\Mmhs0271-ps1\M2A210BC0271
set /p printeruncpath=
goto :done

:51
echo You choose %pnum% which is \\Mmhs0271-ps1\P2A214AB0271
set /p printeruncpath=
goto :done

:52
echo You choose %pnum% which is \\Mmhs0271-ps1\P2F243AB0271
set /p printeruncpath=
goto :done

:53
echo You choose %pnum% which is \\Mmhs0271-ps1\M2BALCAB0271
set /p printeruncpath=
goto :done

:54
echo You choose %pnum% which is \\Mmhs0271-ps1\M2C251AC0271
set /p printeruncpath=
goto :done

:55
echo You choose %pnum% which is \\Mmhs0271-ps1\M2224AB0271
set /p printeruncpath=
goto :done

:56
echo You choose %pnum% which is manual entry
set /p printeruncpath=Please enter path to printer as \\Server\Printername: 
goto :done

:done
REM Add printer 
echo Attempting to map %printeruncpath%...
rundll32 printui.dll,PrintUIEntry /in /ga /n "%printeruncpath%"

::echo Attempting to print a test page on %printeruncpath%...
::rundll32 printui.dll,PrintUIEntry /k /n "%printeruncpath%"

REM Set printer as default 
::rundll32 printui.dll,PrintUIEntry /y /n\\COMPUTER\PRINTER

pause