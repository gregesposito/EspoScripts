set /p pip=Please enter a valid pingable printer IP Address:
echo Printer IP: %pip%
echo Pulling Serial number (uses SNMP)...
"%cd%\snmpwalk.exe" -r:%pip% -os:1.3.6.1.2.1.17.4.3.1.2 -op:1.3.6.1.2.1.17.4.3.1.3 >%pip%serial.txt
pause