@echo off
for /f "Tokens=*" %%f in ('dir /l/b/a-d') do (rename "%%f" "%%f")
pause