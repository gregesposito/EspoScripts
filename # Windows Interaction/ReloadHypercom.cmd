net stop "Hypercom Serial Server"
cd c:\drivers\HYPERCOM\HypercomOPOSSetup1.7.31_RC1
HypercomOPOSSetup.exe /s
net start "Hypercom Serial Server"