:: Create Admin users
:: Windows XP/7 - English
:: 
:: Function:
::	Create a user and password
::	Add that user to the group Administrators

net user username password /add
net localgroup administrators username /add
pause