:: List domain PCs, ping list, save results
:: Windows Server - English
:: 
:: Function:
::	Delete files from previous runs
::	Dump list of computers, name only
::	Remove limit to computers, override default of 100
::	Dump to text file locally
::	Set variable of hostnames
::	Iterate through file, ping each hostname
::	On success or failure, dump result to CSV with Datestamp
@echo off
Echo Deleting previous results...
del domain_pcs.txt
del results.csv
echo Exporting domain hosts listing...
dsquery computer -o rdn -limit 0 > domain_pcs.txt
set names=%%a
echo Checking hosts availability...
for /f %names% in (domain_pcs.txt) do (ping -n 1 -w 3 %names% > nul
if errorlevel 1 echo %names% Not Found! && echo %names%,failed,%date% >> results.csv
if not errorlevel 1 echo %names% Found! && echo %names%,success,%date% >> results.csv
) 
echo Process complete!
pause