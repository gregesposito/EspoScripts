'***************************************************************************
' VBScript Source File
' Version: 2
' AUTHORS: Greg Lowe
' DATE  : 4/17/2012
' COMMENT: Changes the local admin password of computers in the imput file 
'If the computer is ping-able but locked-up the script states it cannot find the path Set objUser = GetObject("WinNT://" & strComputer & "/administrator") 
'***************************************************************************
Option Explicit 
'On Error Resume Next 
Const OverwriteExisting = True
Const INPUT_FILE_NAME = "\\WIN2k\CIDRfiles\CIDRData\Informatics\VBSScripts\Machines\machines.txt" 'Must have this file
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002


Dim objFSO, objFile, strComputer, strComputers, arrComputers 
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(INPUT_FILE_NAME, 1)
strComputers = objFile.ReadAll
objFile.Close
arrComputers = Split(strComputers, vbCrLf)
'***************************************************************************                                                                             
'Prompts for input
Dim strPassword
strPassword= InputBox("New password")
'strPassword= InputBox("Security Check", "")

'***************************************************************************
'***************************************************************************	
'Create log to record events.
Dim MyFile, f, f2, objFSO1, thisday                                                                                                           
'Set objFSO1 = CreateObject("Scripting.FileSystemObject")                                                                                                  
MyFile= "\\win2k\cidrfiles\CIDRData\Informatics\VBSScripts\logs\ Local_Admin_PWD"& thisday & ".log" '***************Change name of log file                 
Set f2 = CreateObject ("Scripting.FileSystemObject")                                                                                                     
Set f =f2.OpenTextFile(MyFile, 2, True)                                                                                                                  
f.WriteLine "Win2k.cidr.jhmi.edu"
f.WriteLine "Local Admin password change" 
f.WriteLine  Date()
f.WriteLine "***************************" 
f.WriteBlankLines(1)   
WScript.Echo "Win2k.cidr.jhmi.edu"                                                                                                                               
WScript.Echo "Local Admin password change" 
WScript.Echo "***************************" 
WScript.Echo
'***************************************************************************
'***************************************************************************	
'Password log.
Dim MyFile2, objf, objf2
MyFile2= "c:\Local_admin_PWD.Log" '***************Change name of log file
Set objf2 = CreateObject ("Scripting.FileSystemObject")
Set objf =objf2.OpenTextFile(MyFile2, 2, True)
objf.WriteLine strPassword '***************Record of typed password change.
'***************************************************************************
'***************************************************************************
			
For Each strComputer In arrComputers
'WScript.Echo
'f.WriteLine "***" & strComputer & "***"
	'***************************************************************************
	'Create a .bat file Ping the folders.
	Dim aFile, p1, p2
	
	aFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\Ping.bat" '**********Change name of .bat
	Set p1 = CreateObject ("Scripting.FileSystemObject")
	Set p2 =p1.OpenTextFile(aFile, 2, True)
		p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer 
		'Wscript.Echo strComputer
	p2.Close

	'***************************************************************************
	'Run Ping.bat file and if Return results = 0 then do:
	Dim objShell, objExecObject, strText,objWMIService
	Set objShell = CreateObject("WScript.Shell")
	Set objExecObject = objShell.Exec ("%comspec% /c \\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\Ping.bat")
	  	Do While Not objExecObject.StdOut.AtEndOfStream
		    strText = objExecObject.StdOut.ReadAll()
		    If Instr(strText, "Reply") > 0 Then
		        Wscript.Echo vbCrLf & "----------" & vbCrLf & strComputer & " --Reply recieved"
		        f.WriteLine vbCrLf & "----------" & vbCrLf & strComputer & " --Reply recieved"
		        On Error Resume Next
		        Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
								If objWMIService Is Nothing Then
								    WScript.Echo "Unable to bind to WMI on " & strComputer
								    WScript.Echo "----------"
								    f.WriteLine "Unable to bind to WMI on " & strComputer
								    f.WriteLine "----------"
								Else
								    'WScript.Echo "Successfully bound to WMI on " & strComputer
								    'f.WriteLine "Successfully bound to WMI on " & strComputer
								    Wscript.Echo PWDChangeAdmin(strComputer,strPassword)
								End If
						'Isnothing(strComputer)
		        		
		    Else
		        Wscript.Echo vbCrLf & "----------" & vbCrLf & strComputer & " -No reply received. " 
		        WScript.Echo "----------"
		        f.WriteLine vbCrLf & "----------" & vbCrLf & strComputer &  " -No reply received." 
		        f.WriteLine "----------"
		    End If
		Loop
Next

'***************************************************************************
'Functions
'***************************************************************************
'***********************************************************
Function PWDChangeAdmin(strComputer,strPassword)
Dim objUser
Set objUser = GetObject("WinNT://" & strComputer & "/administrator") 
		 	objUser.SetPassword strPassword 
			objUser.Setinfo 
					If Err = 0 Then  
					    'write eventlog 
					    'WScript.Echo  vbCrLf & "----------" & vbCrLf & strComputer & "--Password changed" 
					    WScript.Echo strComputer & " --Password changed"
					    WScript.Echo "----------"                                                  
							'Appending to log.         		                                                                        
							'f.WriteLine vbCrLf & "----------" & vbCrLf & strComputer & "--Password changed" 
							f.WriteLine strComputer & " --Password changed"              
							f.WriteLine "----------"   		
					Else 
					     f.WriteLine  strComputer & vbCrLf & Now & vbCrLf & Err.Number & ":" & Err.Description 
					End if 
					Err.Clear
End Function
'***********************************************************
'***************************************************************************
Function DeleteLogfile()
'Deletes the bat file created on the c:\ to permission the folders
Dim objFSO, aFile2
'aFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\NewUser.bat"
Afile2="c:\Local_admin_PWD.Log"
Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile(aFile)
Wscript.Echo
	If Err =0 Then
		Wscript.Echo "Success:  Deleted Local_admin_PWD.Log."
	Else
		Wscript.echo "Failed:  to deleted the Local_admin_PWD.Log, Err.#=  " & Err.Number & " -- " &  Err.Description 
	End If
	err.clear
Set objFSO =  Nothing
End Function

'***************************************************************************


'*********************************************
'End Functions Section
'*********************************************           

'%%%%%%%%%%%%%%%%%%%%%%%%%
'Close log.txt 
f.WriteBlankLines(1)
f.WriteLine "Exit"	
f.Close

'***************************************************************************
'Delete the password file.
DIM intAnswer
intAnswer = _
    Msgbox("Do you want to delete the password files?", _
        vbYesNo, "c:\Local_admin_PWD.Log")

If intAnswer = vbYes Then
    'Wscript.Echo "You answered yes."
    DeleteLogfile()
    Wscript.Echo "Exit"
Else
   Wscript.Echo "You answered no? Go look at c:\Local_admin_PWD.Log. Then delete it!"
End If
'***************************************************************************
'%%%%%%%%%%%%%%%%%%%%%%%%%
'CLEAN UP YOUR MESS!!!!
'%%%%%%%%%%%%%%%%%%%%%%%%%
Set objExecObject =Nothing
Set objFile =Nothing
Set objShell =Nothing
Set p1 =Nothing
Set f2 =Nothing
