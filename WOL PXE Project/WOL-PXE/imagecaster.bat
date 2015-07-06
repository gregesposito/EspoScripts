@echo off
TITLE ImageCaster
setlocal enabledelayedexpansion

set /a "counter=26"

:startmacro

IF "%counter%"=="1" (
ECHO Setting the switch source to 192.168.0.10
set icsw=192.168.0.10
del WOLlog%counter%.txt
)

IF "%counter%"=="2" (
ECHO.
ECHO Setting the switch source to 192.168.0.11
set icsw=192.168.0.11
del WOLlog%counter%.txt
)

IF "%counter%"=="3" (
ECHO.
ECHO Setting the switch source to 192.168.0.12
set icsw=192.168.0.12
del WOLlog%counter%.txt
)

IF "%counter%"=="4" (
ECHO.
ECHO Setting the switch source to 192.168.0.13
set icsw=192.168.0.13
del WOLlog%counter%.txt
)

IF "%counter%"=="5" (
ECHO.
ECHO Setting the switch source to 192.168.0.14
set icsw=192.168.0.14
del WOLlog%counter%.txt
)

IF "%counter%"=="6" (
ECHO.
ECHO Setting the switch source to 192.168.0.15
set icsw=192.168.0.15
del WOLlog%counter%.txt
)

IF "%counter%"=="7" (
ECHO.
ECHO Setting the switch source to 192.168.0.16
set icsw=192.168.0.16
del WOLlog%counter%.txt
)

IF "%counter%"=="8" (
ECHO.
ECHO Setting the switch source to 192.168.0.17
set icsw=192.168.0.17
del WOLlog%counter%.txt
)

IF "%counter%"=="9" (
ECHO.
ECHO Setting the switch source to 192.168.0.18
set icsw=192.168.0.18
del WOLlog%counter%.txt
)

IF "%counter%"=="10" (
ECHO.
ECHO Setting the switch source to 192.168.0.19
set icsw=192.168.0.19
del WOLlog%counter%.txt
)

IF "%counter%"=="11" (
ECHO.
ECHO Setting the switch source to 192.168.0.20
set icsw=192.168.0.20
del WOLlog%counter%.txt
)

IF "%counter%"=="12" (
REM POTENTIALLY SKIP THIS ONE
ECHO.
ECHO Setting the switch source to 192.168.0.21
set icsw=192.168.0.21
del WOLlog%counter%.txt
)

IF "%counter%"=="13" (
ECHO.
ECHO Setting the switch source to 192.168.0.22
set icsw=192.168.0.22
del WOLlog%counter%.txt
)

IF "%counter%"=="14" (
ECHO.
ECHO Setting the switch source to 192.168.0.23
set icsw=192.168.0.23
del WOLlog%counter%.txt
)

IF "%counter%"=="15" (
ECHO.
ECHO Setting the switch source to 192.168.0.24
set icsw=192.168.0.24
del WOLlog%counter%.txt
)

IF "%counter%"=="16" (
REM POTENTIALLY SKIP THIS ONE
ECHO.
ECHO Setting the switch source to 192.168.0.25
set icsw=192.168.0.25
del WOLlog%counter%.txt
)

IF "%counter%"=="17" (
REM POTENTIALLY SKIP THIS ONE
ECHO.
ECHO Setting the switch source to 10.1.1.145
set icsw=10.1.1.145
del WOLlog%counter%.txt
)

IF "%counter%"=="18" (
ECHO.
ECHO Setting the switch source to 192.168.0.26
set icsw=192.168.0.26
del WOLlog%counter%.txt
)

IF "%counter%"=="19" (
ECHO.
ECHO Setting the switch source to 192.168.0.27
set icsw=192.168.0.27
del WOLlog%counter%.txt
)

IF "%counter%"=="20" (
ECHO.
ECHO Setting the switch source to 192.168.0.28
set icsw=192.168.0.28
del WOLlog%counter%.txt
)

IF "%counter%"=="21" (
ECHO.
ECHO Setting the switch source to 192.168.0.29
set icsw=192.168.0.29
del WOLlog%counter%.txt
)

REM END OF CURRENT MDT SWITCHES
IF "%counter%"=="22" (
ECHO.
ECHO Setting the switch source to 10.1.1.145
set icsw=10.1.1.145
del WOLlog%counter%.txt
)

IF "%counter%"=="23" (
ECHO.
ECHO Setting the switch source to 10.1.1.145
set icsw=10.1.1.145
del WOLlog%counter%.txt
)

IF "%counter%"=="24" (
ECHO.
ECHO Setting the switch source to 10.1.1.145
set icsw=10.1.1.145
del WOLlog%counter%.txt
)

IF "%counter%"=="25" (
ECHO.
ECHO Setting the switch source to 10.1.1.145
set icsw=10.1.1.145
del WOLlog%counter%.txt
)

IF "%counter%"=="26" (
ECHO.
ECHO Setting the switch source to 192.168.0.25
set icsw=192.168.0.25
del WOLlog%counter%.txt
)

IF "%counter%"=="27" (
ECHO.
ECHO Ending process...
GOTO :endmacro
)

kitty.exe -telnet %icsw% -cmd "\n no page\n show mac-address\n logout\n y\n n" -log test.txt

REM WolCmd.exe requires no middle dash
REM mc-wol.exe requires colons
REM wol.exe works with middle dash

del testmac4.txt

REM Rip out MACs (or anything that fits a pattern like a MAC)
REM findstr /R /C:"[0-9A-F]-[0-9A-F][0-9]" test.txt > testmac.txt
REM findstr /R /C:"[0-9A-F]" test.txt > testmac.txt

more +27 test.txt >testmac.txt

for /F "tokens=*" %%A in (testmac.txt) do (
 set mactester=%%A
 echo !mactester:~3,13! >>testmac3.txt
 REM echo !mactester:~3,13!
)
REM pause
REM Rip out the patten again, after moving characters to remove whitespace
findstr /R /C:"[0-9A-F]" testmac3.txt > testmac4.txt

for /F "tokens=*" %%A in (testmac4.txt) do (
 set mactester=%%A
 REM echo MAC is !mactester:~0,13!
 REM echo MAC middle is !mactester:~6,1!
 echo Sending WOL to !mactester:~0,13!
 wol.exe !mactester:~0,13! >>WOLlog%counter%.txt
 REM echo WOL was %errorlevel%
)
del testmac.txt
del testmac3.txt

REM set /a "counter+=1"

GOTO :startmacro

:endmacro
pause