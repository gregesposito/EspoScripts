@echo off
setlocal enabledelayedexpansion

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
 wol.exe !mactester:~0,13! 
)
del testmac.txt
del testmac3.txt

pause