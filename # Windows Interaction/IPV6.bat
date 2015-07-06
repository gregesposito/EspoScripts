@Echo off
@ECHO Windows Registry Editor Version 5.00 > %TEMP%\DisableIPv6.reg
@ECHO [HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters] >> %TEMP%\DisableIPv6.reg
@ECHO “DisabledComponents”=dword:000000ff >> %TEMP%\DisableIPv6.reg
REGEDIT /S %TEMP%\DisableIPv6.reg