@echo off
color 97
echo #
echo #
:start
echo EXTERNAL CHECK 
PING www.google.com -n 2
call :color
echo #
echo #
echo Gateway 1 CHECK
PING 192.168.0.1 -n 2
call :color
echo #
echo #
echo VPN Server 2 CHECK
PING NATVPNServer01 -n 2
call :color
echo #
echo #
echo DNS Server 3 CHECK
PING 10.9.0.71 -n 2
call :color 
echo #
echo #
pause
echo #
echo #
:color
    IF %ERRORLEVEL% EQU 0 (
        COLOR 97
		echo Successful!!!
    ) else (
        COLOR C7
		echo Failure!!!
    )
    GOTO:EOF