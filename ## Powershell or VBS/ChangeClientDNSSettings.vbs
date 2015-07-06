'***************************************************************************
'
' VBScript Source File
'
' Version: 2
'
' AUTHORS: Greg Lowe
'
' DATE  : 3/24/06
'
' Last Updated: 12/14/2006
'
' COMMENT: Adding in error checking just show errors 451- "Object not a collection" and still change the DNS setting?
' I just added the "On error resume next" and just skipped all errors. If you run the scipt using the cscript in the CMD window
'you will see what the DNS is set to after it has been changed. Also adds the new DNS domain settings. 
'***************************************************************************
Option Explicit 
'On Error Resume Next 
Const OverwriteExisting = True
Const INPUT_FILE_NAME = "\\win2k\cidrdata\Informatics\VBSScripts\machines\machines.txt" 'Must have this file
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002


Dim objFSO, objFile, strComputer, strComputers, arrComputers, objWMIService, colNetCards, objNetCard, arrDNSServers, colNicConfigs, objNicConfig, strDNSServer, arrDNSSuffixes, strDNSSuffix, objNetworkSettings, objNIC
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(INPUT_FILE_NAME, 1)
strComputers = objFile.ReadAll
objFile.Close
arrComputers = Split(strComputers, vbCrLf)

'***************************************************************************	
'Create log to record events.
Dim MyFile, f, f2
MyFile= "\\genosrv3\cidrdata\Informatics\VBSScripts\logs\ServerDNSSettingLog.txt" '***************Change name of log file
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "Change DNS setting on  "& Now()'***************Change Title of log file
'***************************************************************************
			
For Each strComputer In arrComputers
f.WriteBlankLines(1)
WScript.Echo
f.WriteLine "***" & strComputer & "***"
	'***************************************************************************
	'Create a .bat file on C:\ to Ping the folders.
	Dim aFile, p1, p2
	
	aFile= "C:\Ping_.bat" '**********Change name of .bat
	Set p1 = CreateObject ("Scripting.FileSystemObject")
	Set p2 =p1.OpenTextFile(aFile, 2, True)
		p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer 
		Wscript.Echo strComputer
	p2.Close

	'***************************************************************************
	'Run Ping.bat file and if Return results = 0 then do:
	Dim objShell, objExecObject, strText
	Set objShell = CreateObject("WScript.Shell")
	Set objExecObject = objShell.Exec ("%comspec% /c C:\Ping_.bat")
	
	Do While Not objExecObject.StdOut.AtEndOfStream
	    strText = objExecObject.StdOut.ReadAll()
	    If Instr(strText, "Reply") > 0 Then
	    	Wscript.Echo
	        Wscript.Echo "Reply received- Now executing script."
	        'f.WriteLine "Now executing script" 
	        	
		'%%%%%%%%%%%%%%%%%%%%%%%%%
		'Place code here   
		'Set WMI Variables and query the WMI database
		Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
		
		' Set DNS Suffix object
		Set objNetCard = objWMIService.Get("Win32_NetworkAdapterConfiguration")
		
		'Create DNS Suffix array and config the NIC
				arrDNSSuffixes = Array("win2k.cidr.jhmi.edu", "snp.cidr.jhmi.edu", "cidr.jhmi.edu")
				objNetCard.SetDNSSuffixSearchOrder(arrDNSSuffixes)
					
		If Err =0 Then
			Wscript.Echo
			Wscript.Echo "Modified DNS Suffix search order"
			f.WriteLine "Modified DNS Suffix search order"
		Else
			Wscript.Echo
			Wscript.Echo "Failed with Err.#= " & Err.Number & " -- " & Err.Description
			f.WriteLine "Modify DNS Suffix failed with Err.#= " & Err.Number & " -- " & Err.Description
		End If

		' Set DNS Server object - Note: This required a different parameter setting for objWMIService
		Set objNetworkSettings = objWMIService.ExecQuery("Select * From Win32_NetworkAdapterConfiguration where IPEnabled = True")
			For Each objNIC in objNetworkSettings
				'Create the DNS Server array and config the NIC
				arrDNSServers = Array("165.112.177.220","165.112.177.247","165.112.177.221", "165.112.176.1")
				objNIC.SetDNSServerSearchOrder(arrDNSServers)
			Next
		If Err =0 Then
			Wscript.Echo
			Wscript.Echo "DNS Server address added" 
			f.WriteLine "DNS Server address added" 	
		Else
			Wscript.Echo
			Wscript.echo  "Failed with Err.#= "  & Err.Number & " -- " &  Err.Description
			f.WriteLine "DNS Server address not added, Err.#=  " & Err.Number & " -- " &  Err.Description 
		End If

		err.clear

		
		'List the DNS server and suffix settings for all network cards. 
		Set colNicConfigs = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration")
 
 		Wscript.Echo
 		For Each objNicConfig In colNicConfigs
			If Not IsNull(objNicConfig.DNSServerSearchOrder) Then
				Wscript.Echo
				Wscript.Echo "Current DNS Server Settings"
					For Each strDNSServer In objNicConfig.DNSServerSearchOrder
						wscript.echo strDNSServer
					Next
				End If
			If Not IsNull(objNicConfig.DNSDomainSuffixSearchOrder) Then
				Wscript.Echo
				Wscript.Echo "Current DNS Suffix Settings"
					For Each strDNSSuffix In objNicConfig.DNSDomainSuffixSearchOrder
						Wscript.Echo strDNSSuffix
					Next
			End If
		Next
		'%%%%%%%%%%%%%%%%%%%%%%%%%
	    Else
	        Wscript.Echo "No reply received."
	        f.WriteLine "No reply received, Different OS or computer powered off?" 
	        'f.WriteLine "******"
	    End If
	Loop

Next

'%%%%%%%%%%%%%%%%%%%%%%%%%
'Close log.txt 
f.WriteBlankLines(1)
f.WriteLine "Exit"	
f.Close

'%%%%%%%%%%%%%%%%%%%%%%%%%
'CLEAN UP YOUR MESS!!!!
'%%%%%%%%%%%%%%%%%%%%%%%%%
Set objExecObject =Nothing
Set objFile =Nothing
Set objShell =Nothing
Set p1 =Nothing
Set f2 =Nothing
Set objWMIService = Nothing
Set colNetCards = Nothing