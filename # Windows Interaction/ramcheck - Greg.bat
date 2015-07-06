@echo off
SET /A MBT=1024*1024-1
SET /A MBT1=MBT/10

:phys
for /f "tokens=2 delims==" %%A in ('wmic computersystem get TotalPhysicalMemory /VALUE') DO CALL :phystot %%A
GOTO :slot

:phystot
  SET MEMPHY=%1
  SET/A MEMPHYMB=%MEMPHY:~0,-1%/MBT1
GOTO :eof

:slot
for /f "tokens=2 delims==" %%A in ('wmic memorychip get Capacity /VALUE') DO CALL :slotot %%A
GOTO :rport

:slotot
  SET MEMSLO=%1
  SET/A MEMSLOMB=%MEMSLO:~0,-1%/MBT1
  SET/A MEMTOTIN=MEMTOTIN+MEMSLOMB
GOTO :eof

:rport

echo Memory available to OS (Minus shared VRAM) :  %MEMPHYMB%  MB

echo Actual physically installed memory total :  %MEMTOTIN%  MB

pause