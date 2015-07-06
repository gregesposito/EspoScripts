@ECHO OFF
set version=2.7
CLS
:MENU
CLS
title Autotask Connectivity Diagnostic Tool v%version%
echo.
echo.
echo Autotask Connectivity Diagnostic Tool v%version%
echo.
echo.
ECHO ============= ZONE SELECTION =============
ECHO ------------------------------------------
ECHO 1.  Limited Release
ECHO 2.  Pre-Release
ECHO 3.  America East
ECHO 4.  United Kingdom
ECHO 5.  America West
ECHO 6.  Australia
ECHO ------------------------------------------
ECHO ============ PRESS 'Q' TO QUIT ===========
ECHO.

SET INPUT=
SET /P INPUT=Please select your zone: 

IF /I '%INPUT%'=='1' GOTO Selection1
IF /I '%INPUT%'=='2' GOTO Selection2
IF /I '%INPUT%'=='3' GOTO Selection3
IF /I '%INPUT%'=='4' GOTO Selection4
IF /I '%INPUT%'=='5' GOTO Selection5
IF /I '%INPUT%'=='6' GOTO Selection6
IF /I '%INPUT%'=='Q' GOTO Quit

CLS
echo.
echo.
ECHO ============ INVALID INPUT ============
ECHO ---------------------------------------
ECHO Please select your zone from the Main
echo Menu or press 'Q' to quit.
ECHO ---------------------------------------
ECHO ====== PRESS ANY KEY TO CONTINUE ======

PAUSE > NUL
GOTO MENU

:Selection1
set zonename=Limited Release
set zone=LR
set url=ww1
GOTO DOTASK

:Selection2
set zonename=Pre-Release
set zone=PR
set url=ww2
GOTO DOTASK

:Selection3
set zonename=America East
set zone=AE
set url=ww3
GOTO DOTASK

:Selection4
set zonename=United Kingdom
set zone=UK
set url=ww4
GOTO DOTASK

:Selection5
set zonename=America West
set zone=AW
set url=ww5
GOTO DOTASK

:Selection6
set zonename=Australia
set zone=AU
set url=ww6
GOTO DOTASK

:DOTASK
:PROMPT
CLS
title Autotask Connectivity Diagnostic Tool v%version% - %zonename%
echo.
echo.
echo This utility will gather diagnostic information and run connectivity tests
echo.
SET TEST=
SET /P TEST=Would you like to start the test? (Y/N): 

IF /I '%TEST%'=='Y' GOTO RUN
IF /I '%TEST%'=='N' GOTO MENU
GOTO PROMPT

:RUN
@echo off
set logpath=logs\
set logfile=Autotask_CDT_%date:~-10,2%%date:~-7,2%%date:~-4,4%_%time:~1,1%%time:~3,2%%time:~6,2%.log
echo Autotask Connectivity Diagnostic Tool v%version% - %zonename%  > %logpath%%logfile%
echo File: %logfile%   Zone: %zone%   URL: %url% >> %logpath%%logfile%
echo.
echo.
echo Collecting IP information...
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo Public IP Address: >> %logpath%%logfile%
include\wget -qO- https://%url%.autotask.net/speedtest/iplookup.asp --no-check-certificate | findstr /r "[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*" >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo ---------------------- >> %logpath%%logfile%
echo Local network adaptors >> %logpath%%logfile%
echo ---------------------- >> %logpath%%logfile%
ipconfig /all >> %logpath%%logfile%
echo.
echo.
echo Flushing DNS cache...
ipconfig /flushdns >> %logpath%%logfile% 2>&1
echo.
echo.
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo Checking name resolution...
echo ----------------------------- >> %logpath%%logfile%
echo DNS results from local server >> %logpath%%logfile%
echo ----------------------------- >> %logpath%%logfile%
nslookup %url%.autotask.net >> %logpath%%logfile% 2>&1
nslookup %zone%.autotask.net >> %logpath%%logfile% 2>&1
echo. 
echo.
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo Checking network connectivity...
echo -------------------- >> %logpath%%logfile%
echo Network ping results >> %logpath%%logfile%
echo -------------------- >> %logpath%%logfile%
ping -a %url%.autotask.net >> %logpath%%logfile%
ping -a %zone%.autotask.net >> %logpath%%logfile%
echo. 
echo.
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo Testing your connection speed...
echo ------------------->> %logpath%%logfile%
echo Speed Test Results >> %logpath%%logfile%
echo ------------------->> %logpath%%logfile%
include\wget -O NUL https://%url%.autotask.net/speedtest/speedtest/random1000x1000.jpg --no-check-certificate --no-cache --save-headers -a %logpath%%logfile% 
include\wget -O NUL https://%zone%.autotask.net/speedtest/speedtest/random1000x1000.jpg --no-check-certificate --no-cache --save-headers -a %logpath%%logfile%
echo. 
echo. 
title Autotask Connectivity Diagnostic Tool v%version% - %zonename%
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo ------------->> %logpath%%logfile%
echo Trace Routes >> %logpath%%logfile%
echo ------------->> %logpath%%logfile%
echo Performing Trace Routes...  (this may take a few minutes)
tracert -w 1000 %url%.autotask.net >> %logpath%%logfile%
tracert -w 1000 %zone%.autotask.net >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo. >> %logpath%%logfile%
echo File: %logfile%   Zone: %zone%   URL: %url%   %date%   %time% >> %logpath%%logfile%
CLS
echo.
echo.
ECHO =============== THANK YOU ===============
ECHO -----------------------------------------
ECHO All tests completed successfully. 
ECHO Please send all files located in the logs
ECHO directory to Autotask Product Support.
ECHO -----------------------------------------
ECHO ========= PRESS ANY KEY TO EXIT =========

PAUSE>NUL
:Quit
CLS
EXIT