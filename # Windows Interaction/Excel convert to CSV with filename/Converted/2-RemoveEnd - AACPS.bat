@echo off
REM set i=1
for %%f in (*.CSV) do call :renameit "%%f"
goto done

:renameit
REM ren %1 %1-fix.csv
REM set /A i+=1
find /v ",,,,,,,,,,,,,,,,,,,,,,," < %1 > Prepped/%1-prepped.csv
:done
