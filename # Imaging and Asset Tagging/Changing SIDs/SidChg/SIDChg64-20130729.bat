@ECHO OFF
@setlocal enableextensions
@cd /d "%~dp0"
:GET_INPUT
echo Your computer name is currently: %computername%
SET /P computer_name="Enter the computer name you'd like to use: "
SET /P response="Your new computer name is %computer_name%. Is that right (y/n) "
IF /i {%response%}=={n} GOTO GET_INPUT
sidchg64.exe /COMPNAME:%computer_name% /F /R /KEY:38eZM-Qy9JM-2WSEE-dv
DEL %computer_name%