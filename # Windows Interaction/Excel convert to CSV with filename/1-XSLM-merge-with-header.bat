@echo off
@setlocal enableextensions
@cd /d "%~dp0"

DEL /F /Q /S "# Processed Raw CSV\*.*"

echo Making directories...
echo.
md "# Processed"
md "# Processed Raw CSV"
echo.
echo Moving main files...
robocopy . "# Processed" *.xlsm /mov /NFL /NDL /NJH /NJS /nc /ns /np
echo.
echo Hit any key to begin conversion. There will be many lines of warnings.
pause
echo.
echo Converting XLSM to CSV...
echo %cd%
FOR /F "tokens=*" %%G IN ('dir /b "%cd%\# Processed\*.xlsm"') DO ssconvert -S "# Processed\%%G" "# Processed Raw CSV\%%G.csv"

echo.
echo Creating primary import file

REM set header="Serial Number","Floor Plan #",Floor,"Suite/Room Number",Department,Manufacturer,Model,"Recommendation State","Pallet Number"

REM echo %header% > Main-temp.csv

cd "%cd%\# Processed Raw CSV/"
for %%f in ("*.csv.0") do (
echo %%f > "%%f.csv" 
)
for %%f in ("*.csv.0") do (
more "%%f" >> "%%f.csv"
type "%%f.csv" >> "..\Main-temp.csv"
)
cd ..
findstr /v ",,,,,,,," Main-temp.csv > Main-temp2.csv
findstr /v ",,,,,,," Main-temp2.csv > Main.csv
DEL Main-temp.csv
DEL Main-temp2.csv
echo Main.csv file created. Please check columns for school names.
pause