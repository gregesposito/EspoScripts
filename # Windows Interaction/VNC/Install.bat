echo off
for /f %%p in (c:\vnc\IP.txt) do (
  echo Copying to IP address = %%p
  NET USE \\%%p\IPC$ /user:administrator csgnt
copy "\\%%p\C$\Documents and Settings\All Users\Start Menu\Programs\Accessories\Remote Desktop Connection.*" "\\%%p\C$\Documents and Settings\All Users\Desktop\" /y
)
exit