Set WinShell = CreateObject("WScript.Shell")
key = "HKEY_LOCAL_MACHINE\SOFTWARE\Acro Software Inc\CutePDF Writer\Destination Folder"

On Error Resume Next

value = WinShell.RegRead(key)

if(value) Then
Else
	WinShell.regwrite "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations\LowRiskFileTypes", ".exe;", "REG_SZ"

	WinShell.Run "\\usosrv01\installs\CutePDF\converter\setup.exe", 0, true
	WinShell.Run "\\usosrv01\installs\CutePDF\CuteWriter.exe /verysilent", 0, true

	WinShell.regdelete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations\LowRiskFileTypes"
end if