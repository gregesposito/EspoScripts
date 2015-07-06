echo off

SET /P IP=enter the IP adrress=
  echo  IP address = %IP%
NET USE \\%IP%\IPC$ /user:administrator csgnt


psexec \\%IP% -s -i -d net stop "VNC Server" 

psexec \\%IP% -s -i -d "C:\Program Files\RealVNC\WinVNC\winvnc.exe" -uninstall 

psexec \\%IP% -s -i -d net start "VNC Server" 
del "\\%IP%\C$\Program Files\RealVNC\*.*" /s
pause