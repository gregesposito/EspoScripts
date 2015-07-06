:: List domain PCs and ping list
:: Windows Server - English
:: 
:: Function:
::	Dump list of computers, name only
::	Remove limit to computers, override default of 100
::	Dump to text file locally
::	Set variable of names
::	Iterate through a file, doing ping each line

dsquery computer -o rdn -limit 0 > domain_pcs.txt
set names=%%a
for /f %names% in (domain_pcs.txt) do (ping %names%)
pause