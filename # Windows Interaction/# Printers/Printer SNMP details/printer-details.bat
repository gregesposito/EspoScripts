@echo off

:no 
set /p pip=Please enter a valid pingable printer IP Address:
echo Printer IP: %pip%
echo Printer IP: %pip% >> %pfloorplannum%.txt 
ping -n 1 %pip% | find "TTL" >nul
if errorlevel 1 echo IP not responding && goto :no
arp -a | find "%pip%" >> %pip%arp.txt 
set /p pmac= <%pip%arp.txt
for /f "tokens=1,2,3,4 delims=/ " %%a in ("%pmac%") do set p1=%%a&set p2=%%b&set p3=%%c&set p4=%%d
REM echo.IP: %p1%
echo Printer MAC  : %p2%
REM echo.Static    : %p3%
REM echo.Other   : %p4%
REM echo Printer MAC: %pmac%
echo -----------------------------------------
echo Pulling Serial number (uses SNMP)...
"%cd%\data\snmpget.exe" -r:%pip% -o:1.3.6.1.2.1.43.5.1.1.17.1 -q> %pip%serial.txt
set /p pserial= <%pip%serial.txt
echo.
echo IP Printer Serial: %pserial%
del %pip%serial.txt
del %pip%arp.txt

set /p pserialfound=Did a serial get found? (Y/N)? 
if /i {%pserialfound%}=={y} (goto :yesfound) 
if /i {%pserialfound%}=={yes} (goto :yesfound) 
goto :notfound 

:notfound 
echo.
echo Attempting direct communication via PJL...
echo If no data returns in a few seconds, type Control-C
echo but say No to ending the Batch Script
"%cd%\data\printerserial.exe" %pip% > %pip%serial.txt
set /p pserial= <%pip%serial.txt
echo.
echo IP Printer Serial: %pserial%
del %pip%serial.txt

set /p pserialfound=Did a serial get found? (Y/N)? 
if /i {%pserialfound%}=={y} (goto :yesfound) 
if /i {%pserialfound%}=={yes} (goto :yesfound) 
goto :notfound2 

:notfound2
set /p pserial=Please enter the serial number:
set /p pmodel=Please enter the model number:
set /p ppages=Please enter the page count:
goto :end

:yesfound
echo -----------------------------------------
echo Pulling Model number (uses SNMP)...
"%cd%\data\snmpget.exe" -r:%pip% -o:1.3.6.1.2.1.25.3.2.1.3.1 -q > %pip%model.txt
set /p pmodel= <%pip%model.txt
echo.
echo IP Printer Model: %pmodel%
del %pip%model.txt

set /p pmodelfound=Did a model get found? (Y/N)? 
if /i {%pmodelfound%}=={y} (goto :yesfoundmodel) 
if /i {%pmodelfound%}=={yes} (goto :yesfoundmodel) 
goto :notfoundmodel 

:notfoundmodel 
echo.
echo Attempting direct communication via PJL...
echo If no data returns in a few seconds, type Control-C
echo but say No to ending the Batch Script
"%cd%\data\printermodel.exe" %pip% > %pip%model.txt
set /p pmodel= <%pip%model.txt
echo.
echo IP Printer Model: %pmodel%
del %pip%model.txt

:yesfoundmodel
echo -----------------------------------------
echo Pulling Total Page count (uses SNMP)...
"%cd%\data\snmpget.exe" -r:%pip% -o:1.3.6.1.2.1.43.10.2.1.4.1.1 -q > %pip%pages.txt
set /p ppages= <%pip%pages.txt
echo.
echo IP Printer Pages: %ppages%
echo.
del %pip%pages.txt

:end

echo.
echo Hit any key to close out.
pause