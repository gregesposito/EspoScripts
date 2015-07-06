@echo off
for /f "tokens=1-5*" %%1 in ('vol C:') do (
   set vol=%%6 & goto done
)
:done
echo %vol%
pause