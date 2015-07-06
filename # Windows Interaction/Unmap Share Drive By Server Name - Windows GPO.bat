@echo off

net use | findstr "\\yourservername" > C:\tempyourservername.txt
for /f "tokens=2,3 delims= " %%i in ('type C:\tempyourservername.txt') do call :delshare %%i

del C:\tempyourservername.txt

:delshare
Rem if not "%1" == "" echo "net use %1 /delete"
If not "%1" == "" net use %1 /delete