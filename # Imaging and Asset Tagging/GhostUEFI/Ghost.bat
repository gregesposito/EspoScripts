@echo off
@setlocal enableextensions
@cd /d "%~dp0"
echo Beginning drive wipe...
diskpart /s "%cd%\createpartitions.txt"
echo.
echo Drive wipe complete. Image now with mode=prestore
echo.
pause
echo Assigning BCD Boot
W:\Windows\System32\bcdboot W:\Windows /s S:
pause