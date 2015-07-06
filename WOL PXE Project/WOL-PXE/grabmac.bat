@echo off
kitty.exe -telnet 10.1.1.145 -cmd "\n no page\n show mac-address\n logout\n y\n n" -log test2.txt
pause