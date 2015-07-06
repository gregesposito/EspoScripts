@echo off
set /p texte=< C:\Users\Greg\Desktop\test.txt  
set "secondline="
for /F "skip=1 delims=" %%i in (C:\Users\Greg\Desktop\test.txt) do if not defined secondline set "secondline=%%i" 
echo %texte% %secondline%
copy "C:\Users\Greg\Desktop\test.txt" "C:\%texte%-%secondline%.txt" /Y /V
pause