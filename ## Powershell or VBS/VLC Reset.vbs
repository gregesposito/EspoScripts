' Begin code for rewrite.vbs
' Downloaded from the Scripting Guide for Windows
' http://www.pctools.com/guides/scripting/
' Version: 1.0 (June 8, 2005)

Option Explicit

Dim WSHShell, RegKey, Key, Result

Set WSHShell = CreateObject("WScript.Shell")

RegKey = "HKLM\Software\Microsoft\Windows NT\CurrentVersion\WPAEvents\"


' This rewrites the windows CD Key
WSHShell.RegWrite regkey & "OOBETimer", 654213, "REG_BINARY"


' this runs the windows authentication after reseting the key
Dim shell
set shell = CreateObject("WScript.Shell")
shell.Run "%systemroot%\system32\oobe\msoobe.exe /a", 1, false


' End code