strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colBIOS = objWMIService.ExecQuery _
    ("Select * from Win32_BIOS")
Set wshShell = WScript.CreateObject( "WScript.Shell" )
strComputerName = wshShell.ExpandEnvironmentStrings( "%COMPUTERNAME%" )	
For each objBIOS in colBIOS
REM    Wscript.Echo "Manufacturer: " & objBIOS.Manufacturer
REM    WScript.Echo "Computer Name: " & strComputerName
REM    Wscript.Echo "Computer Serial Number: " & 
Wscript.Echo objBIOS.SerialNumber
Next