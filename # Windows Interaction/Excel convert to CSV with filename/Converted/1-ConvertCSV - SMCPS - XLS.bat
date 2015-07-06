:: Run Convert program to transform XLSX files to CSV
:: 2014-03-02
@setlocal enableextensions
@cd /d "%~dp0"
::cd c:\Program Files (x86)\Softinterface, Inc\Convert XLS\
::ConvertXLS.EXE /S"%USERPROFILE%\Desktop\Converted\*.XLS" /F-4143 /N"1^A2:Y1000" /G /C6 /M2 /R /V
"%ProgramFiles(x86)%\Softinterface, Inc\Convert XLS\ConvertXLS.EXE" /S"%cd%\*.XLS" /F-4143 /N"1^A2:Y1000" /G /C6 /M2 /R /V

pause