set /a newtimehour = %time:~0,2%
set /a newtimehour -=4
echo Old time is %time%

time %newtimehour%%time:~2,14%
echo New time is %time%
echo.
pause