@echo off
color 1e
SETLOCAL ENABLEEXTENSIONS
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
echo. 
echo. ...Here to you the amount of your Installed / Available RAM.
ping -n 2 127.0.0.1 >NUL

echo.
echo. =====================================
echo.   O.S. Available RAM is :  %MEMPHYMB%  MB.
echo. =====================================
echo.
echo. =====================================
echo.   REAL Installed RAM is :  %MEMTOTIN%  MB.
echo. =====================================
echo.
ping -n 4 127.0.0.1 >NUL

rem endlocal & SET MEMTOT=%MEMTOTIN% & SET MEMPHYS=%MEMPHYMB%
IF %MEMTOTIN% GTR 3072 (
  GOTO :plus4g
  ) ELSE (
  GOTO :noptch
  )
:plus4g
SET NFO1=- Test Message - You surely have more
SET NFO1=%NFO1% than 3 GB RAM !! (will close in 5 seconds)
GOTO :quest
:noptch
SET NFO1=- Test Message - You surely have less
SET NFO1=%NFO1% than 4 GB RAM !! (will close in 5 seconds)
GOTO :quest

:quest
MSG %USERNAME% /TIME:5 /W %NFO1%

ping -n 2 127.0.0.1 >NUL