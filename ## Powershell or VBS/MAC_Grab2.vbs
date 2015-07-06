'***************************************************************************
'
' VBScript Source File
'
' Version: 1.2
'
' AUTHORS: Greg Lowe
'
' DATE  : 8/22/2011
'
' COMMENT: List both IP and MAC address(s) on remote PC using WMI from list of computers.
'***************************************************************************
Option Explicit 
'On Error Resume Next 
Const OverwriteExisting = True
Const INPUT_FILE_NAME = "\\10.1.0.72\Users\wilattie\Desktop\Info.txt" 'Must have this file
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002


Dim objFSO, objFile, strComputer, strComputers, arrComputers 
Set objFSO = CreateObject("Scripting.FileSystemObject")
'Set objFile = objFSO.OpenTextFile(INPUT_FILE_NAME, 1)
'strComputers = objFile.ReadAll
'objFile.Close
arrComputers = Split(strComputers, vbCrLf)

'***************************************************************************	
'Create log to record events.
Dim MyFile, f, f2
MyFile= "c:\Users\wilattie\Desktop\Info.txt" '***************Change name of log file
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "MAC addresses "& Now()'***************Change Title of log file
f.WriteBlankLines(1)
'***************************************************************************
			
For Each strComputer In arrComputers
WScript.Echo
f.WriteLine "***" & strComputer & "***"
	'***************************************************************************
	'Create a .bat file Ping the folders.
	Dim aFile, p1, p2
	
	aFile= "\\10.1.0.72\Users\wilattie\Desktop\Ping.bat" '**********Change name of .bat
	Set p1 = CreateObject ("Scripting.FileSystemObject")
	Set p2 =p1.OpenTextFile(aFile, 2, True)
		p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer 
		'Wscript.Echo strComputer
	p2.Close

	'***************************************************************************
	'Run Ping.bat file and if Return results = 0 then do:
	Dim objShell, objExecObject, strText
	Set objShell = CreateObject("WScript.Shell")
	Set objExecObject = objShell.Exec ("%comspec% /c \\10.1.0.72\Users\wilattie\Desktop\Ping.bat")
	  	Do While Not objExecObject.StdOut.AtEndOfStream
		    strText = objExecObject.StdOut.ReadAll()
		    If Instr(strText, "Reply") > 0 Then
		        Wscript.Echo "Reply received- Now executing script."
		        'f.WriteLine "Now executing script" 
		        	
		'%%%%%%%%%%%%%%%%%%%%%%%%%
		'Put code here
		'http://kabheap.wordpress.com/2011/01/04/subroutine-to-acquire-mac-address-and-ip-address-pairs-from-a-windows-workstation/
				Dim objWMIService,objCollection,objItem, strValueIP, strValueMac,strValue
						'sub srNetSettingsQry(ByVal strComputer)
						  Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
						  Set objCollection = objWMIService.ExecQuery("select * from win32_networkadapterconfiguration WHERE IPEnabled='TRUE' " _
						     & "AND ServiceName<>'AsyncMac' " _
						     & "AND ServiceName<>'VMnetx' " _
						     & "AND ServiceName<>'VMnetadapter' " _
						     & "AND ServiceName<>'Rasl2tp' " _
						     & "AND ServiceName<>'msloop' " _
						     & "AND ServiceName<>'PptpMiniport' " _
						     & "AND ServiceName<>'Raspti' " _
						     & "AND ServiceName<>'NDISWan' " _
						     & "AND ServiceName<>'NdisWan4' " _
						     & "AND ServiceName<>'RasPppoe' " _
						     & "AND ServiceName<>'NdisIP' " _
						     & "AND ServiceName<>'' " _
						     & "AND Description<>'PPP Adapter.'",,48)
						
						  For Each objItem in objCollection
						     if objItem.IPAddress(0) <> "0.0.0.0" then
						          strValueIP = objItem.IPAddress(0)
						          strValueMac = objItem.MACAddress
						          strValue = strComputer & vbTab & strValueIP & vbTab & strValueMac
						          Wscript.Echo strValue
						          f.WriteLine strValue
						          f.WriteBlankLines(1)
						          'strValue = ""
						     end if
						  next
						'End sub	
			'%%%%%%%%%%%%%%%%%%%%%%%%%
	
	    Else
	        Wscript.Echo "No reply received   " & strComputer
	        f.WriteLine "No reply received is computer is powered off?" 
	        f.WriteBlankLines(1)
	    End If
	Loop

Next


'%%%%%%%%%%%%%%%%%%%%%%%%%
'CLEAN UP YOUR MESS!!!!
'%%%%%%%%%%%%%%%%%%%%%%%%%
Set objWMIService =Nothing
Set objCollection =Nothing
Set objExecObject =Nothing
Set objFile =Nothing
Set objShell =Nothing
Set p1 =Nothing
Set f2 =Nothing
Set objFSO = Nothing
'Close MAC.log 