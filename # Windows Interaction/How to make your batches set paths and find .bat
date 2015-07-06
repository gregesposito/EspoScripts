cls
@echo off

if %processor_architecture%==x86 set Path="%programfiles%\Microsoft Office\Office15"
if %processor_architecture%==AMD64 set Path="%programfiles(x86)%\Microsoft Office\Office15"

cd %path%
WINWORD.exe

pause