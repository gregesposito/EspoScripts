@ECHO OFF
::Force Client Machine to check for WSUS updates

wuauclt.exe /detectnow

exit