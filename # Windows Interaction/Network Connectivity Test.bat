echo off

echo gathering IP configuration.

ipconfig/all > ipconfigResults.txt

start notepad ipconfigResults.txt
 
echo done gathering ip configuration

pause

echo pinging www.google.com
 
ping www.google.com > pingGoogleResults.txt

start notepad pingGoogleResults.txt

echo done pinging www.google.com