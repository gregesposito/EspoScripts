echo off

SET /P IP=enter the IP adrress=
  echo  IP address = %IP%
NET USE \\%IP%\IPC$ /user:administrator csgnt

xcopy "C:\Program Files\RealVNC\*.*" "\\%IP%\C$\Program Files\RealVNC\*.*" /r/i/c/h/k/e 

regedit /e "\\%IP%\C$\vncdmp.txt" "HKEY_LOCAL_MACHINE\Software\ORL" 


psexec \\%IP% -s -i -d C:\windows\regedit /s C:\vncdmp.txt 


psexec \\%IP% -s -i -d "C:\Program Files\RealVNC\WinVNC\winvnc.exe" -install 

psexec \\%IP% -s -i -d net start "VNC Server" 

pause