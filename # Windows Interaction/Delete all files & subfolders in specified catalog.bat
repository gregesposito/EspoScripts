:Easy batch script to delete all files and subfolders in specific folder/drive. e.g If U want to delete all files and subfolders in d:\temp catalog without deleting source (d:\temp) catalog.

Used for scheduled clearing shared folders.:

echo off

REM Edit your folder path
set CAT=d:\temp

dir "%%CAT%%"/s/b/a | sort /r >> %TEMP%\files2del.txt
for /f "delims=;" %%D in (%TEMP%\files2del.txt) do (del /q "%%D" & rd "%%D")
del /q %TEMP%\files2del.txt