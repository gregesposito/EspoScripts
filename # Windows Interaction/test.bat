@echo off
set /p currentversion= <C:\currentmdt.txt
echo C:\Daly\%currentversion%
CALL "C:\Daly\%currentversion%"
pause