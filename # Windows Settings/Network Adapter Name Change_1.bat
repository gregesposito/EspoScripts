@echo off
for/F "tokens=3*" %%I in ('netsh interface show interface ^| find "Enabled" ^| find "Connected"') do ^
netsh interface set interface name = "%%J" newname = "Management"