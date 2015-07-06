:: List domain PCs
:: Windows Server - English
:: 
:: Function:
::	Dump list of computers, name only
::	Remove limit to computers, override default of 100
::	Dump to text file locally

dsquery computer -o rdn -limit 0 > domain_pcs.txt
pause