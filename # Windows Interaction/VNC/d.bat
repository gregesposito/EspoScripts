echo off
for /f %%p in (c:\vnc\IP.txt) do (
  echo Copying to IP address = %%p
  NET USE \\%%p\IPC$ /user:administrator csgnt
psexec \\%%p -s -i -d reg add "HKCU\software\adobe\Dreamweaver CS4\settings" /v LastDirectory /f /t REG_SZ /d "C:\Documents and Settings\%username%\My Documents" 
psexec \\%%p -s -i -d rename "c:\Documents and Settings\installer\Application Data\Adobe\Adobe Photoshop CS4\Adobe Photoshop CS4 Settings\Adobe Photoshop CS4 Prefs.psp" "c:\Documents and Settings\installer\Application Data\Adobe\Adobe Photoshop CS4\Adobe Photoshop CS4 Settings\Adobe Photoshop CS4 Prefs.old"

)
pause
exit