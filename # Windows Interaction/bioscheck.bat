@echo off
wmic bios get name, version, releasedate
FOR /F "skip=1 tokens=*" %%c in ('wmic bios get name') do if not defined biosname set biosname=%%c
FOR /F "skip=1 tokens=*" %%c in ('wmic bios get version') do if not defined biosversion set biosversion=%%c
FOR /F "skip=1 tokens=*" %%c in ('wmic bios get releasedate') do if not defined biosdate set biosdate=%%c
echo BIOS: %biosname%-%biosversion%-%biosdate:~0,8%
pause