@echo off
FOR /f "tokens=* delims=  " %%i in ('type "test.txt" ^| findstr "19"') do echo %%i
pause
