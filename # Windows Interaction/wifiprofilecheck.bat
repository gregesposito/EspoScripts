@echo off
netsh wlan show profiles name=BCPS_WiFi>wificheck.txt
set /p checkwifi= <wificheck.txt
del wificheck.txt

IF /I "%checkwifi%" EQU "Profile "BCPS_WiFi" is not found on the system." (
COLOR c0
ECHO WIFI PROFILE NOT FOUND
)ELSE (
COLOR a0
ECHO WIFI PROFILE FOUND
)

pause