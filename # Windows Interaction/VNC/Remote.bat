echo off
for /f %%p in (c:\vnc\IP.txt) do (
  echo Copying to IP address = %%p
  NET USE \\%%p\IPC$ /user:administrator csgnt
psexec \\%%p -s -i -d reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /f /t REG_DWORD /d "0"

)
pause
exit