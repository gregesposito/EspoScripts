XCOPY C:\DIRECTORY\* C:\Dropbox\Backups\%date:~10,4%%date:~4,2%%date:~7,2%Backup\ /Y /S /I
echo Files Copied!
timeout 8
exit