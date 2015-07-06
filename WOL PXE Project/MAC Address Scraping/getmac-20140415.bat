@echo off
echo Acquiring MACs...
getmac /v /nh /fo csv >macs.csv
setlocal EnableDelayedExpansion
for /F "delims=" %%a in (macs.csv) do (
    set line=%%a
    set line=!line:,,=, ,!
    set line=!line:,,=, ,!
    for /F "tokens=1,2,3* delims=," %%i in (^"!line!^") do (
        echo|set /p=""%%i,%%j,%%k"," >>macs.txt
    )
)
echo.
echo Setting MACs...
set /p pmac= <macs.txt
echo.
echo %pmac%
del macs.csv
del macs.txt
pause