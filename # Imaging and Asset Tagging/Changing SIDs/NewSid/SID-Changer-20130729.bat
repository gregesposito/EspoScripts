@ECHO OFF
:GET_INPUT
echo Your computer name is currently: %computername%
SET /P computer_name="Enter the computer name you'd like to use: "
SET /P response="Your new computer name is %computer_name%. Is that right (y/n) "
IF /i {%response%}=={n} GOTO GET_INPUT
newsid.exe /a %computer_name%
DEL %computer_name%