@echo off


REM To catch and block ----------

FOR /F "skip=2 tokens=2 delims=," %%c in ('wmic bios get serialnumber /format:csv') do if not defined serialnumdash set serialnumdash=%%c
echo %serialnumdash%
IF "%serialnumdash%"=="----------" (
COLOR c0
ECHO THIS MACHINE DOES NOT HAVE A VALID SERIAL
ECHO SERIAL %serialnumdash% OCCURS DURING A NON-FINISHED MOTHERBOARD SWAP
ECHO.
ECHO THIS SCRIPT WILL NOW EXIT . . .
pause
exit
)
IF "%serialnumdash%"=="8CG4340P5C" (
COLOR c0
ECHO THIS MACHINE IS GREGS
ECHO SERIAL %serialnumdash% OCCURS DURING A GREG LAPTOP
ECHO.
ECHO THIS SCRIPT WILL NOW EXIT . . .
pause
exit
)

:end
pause
