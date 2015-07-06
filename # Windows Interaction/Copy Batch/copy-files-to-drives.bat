@echo off

for /F "usebackq tokens=1,2,3,4 " %%i in (`wmic logicaldisk get caption^,description^,drivetype 2^>NUL`) do (

if %%l equ 2 (
echo %%i is a USB drive, copying files...
echo.
xcopy /E /Y /F "test.txt" "%%i"
echo.
)
)

pause