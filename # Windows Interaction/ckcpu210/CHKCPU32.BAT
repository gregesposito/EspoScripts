@echo off
if exist chkcpu32.exe goto run
goto error

:run
chkcpu32.exe /v
goto done

:error
@echo  =====================================================
@echo  = ERROR: The Chkcpu32.exe program was not found.    =
@echo  = Please copy Chkcpu32.exe to the same folder as    =
@echo  = the Chkcpu32.bat file and run Chkcpu32.bat again. =
@echo  =====================================================

:done
@echo.
pause
