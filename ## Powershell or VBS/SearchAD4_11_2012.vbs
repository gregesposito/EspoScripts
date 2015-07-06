'***************************************************************************
'
' VBScript Source File
'
' Version: 1
'
' AUTHORS: Greg Lowe
'
' DATE  : 4/6/2012
'
' COMMENT: 
'***************************************************************************
Option Explicit 
'On Error Resume Next 
Const OverwriteExisting = True
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002
'***************************************************************************
'The format is such as it will be easier to find in a folder later MMDDYY.
' ### call function to get the date ###
today_date()


'Create log to record events.
Dim MyFile, f, f2,strComputer, objFSO, thisday
Set objFSO = CreateObject("Scripting.FileSystemObject")
MyFile= "\\win2k\cidrfiles\CIDRData\Informatics\VBSScripts\logs\ AD_computer"& thisday & ".log" '***************Change name of log file
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "Win2k.cidr.jhmi.edu"
'***************************************************************************

Const ADS_SCOPE_SUBTREE = 2
Dim objConnection, objCommand, objRecordSet, intTestOU
Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection

objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 

objCommand.CommandText = _
    "SELECT Name, distinguishedName FROM 'LDAP://dc=win2k,dc=cidr,dc=jhmi,dc=edu' " _
        & "WHERE objectCategory='Computer'"  
Set objRecordSet = objCommand.Execute

objRecordSet.MoveFirst
Do Until objRecordSet.EOF
    intTestOU = InStr(objRecordSet.Fields("distinguishedName").Value, "OU=test")
    If intTestOU = 0 Then
        'Wscript.Echo objRecordSet.Fields("Name").Value
        
								'***************************************************************************
								'Create a .bat file on C:\ to Ping the folders.
								Dim aFile, p1, p2
								
								aFile= "C:\Ping_.bat" '**********Change name of .bat
								Set p1 = CreateObject ("Scripting.FileSystemObject")
								Set p2 =p1.OpenTextFile(aFile, 2, True)
									p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & objRecordSet.Fields("Name").Value 
									'Wscript.Echo strComputer
								p2.Close
							
								'***************************************************************************
									'Run Ping.bat file and if Return results = 0 then do:
									Dim objShell, objExecObject, strText
									Set objShell = CreateObject("WScript.Shell")
									Set objExecObject = objShell.Exec ("%comspec% /c C:\Ping_.bat")
									
									Do While Not objExecObject.StdOut.AtEndOfStream
									    strText = objExecObject.StdOut.ReadAll()
									    If Instr(strText, "Reply") > 0 Then
'									    	If objRecordSet.Fields("Name").Value= RegExp() Then	
'									    		'Wscript.Echo
'									    	Else
									        Wscript.Echo objRecordSet.Fields("Name").Value & " -Ping reply received"
									        f.WriteLine objRecordSet.Fields("Name").Value & " -Ping reply received"
'									      End IF  
										
											'%%%%%%%%%%%%%%%%%%%%%%%%%
									    Else
									        Wscript.Echo objRecordSet.Fields("Name").Value & " -No ping."
									        f.WriteLine objRecordSet.Fields("Name").Value & " -No ping."
									    End If
									Loop
									'***************************************************************************
		 End If
    objRecordSet.MoveNext
Loop
'***************************************************************
'Function RegExp()
'Dim re, targetString
'	Set re = New RegExp
'	With re
'	    .Pattern = "ISICIDR-" & "^ISICIDR"
'	    .Global = True
'	    .IgnoreCase = True
'	End With
'End Function
'
're.Test()
'***************************************************************
'***************************************************************
' ### This funtion gets the date in format MMDDYY ###
Function Today_Date()

thisday=Right("0" & Month(Date),2) & Right("0" & Day(Date),2) & Right(Year(Date),2)

thisday=Right(Year(Date),2) & Right("0" & Month(Date),2) & Right("0" & Day(Date),2)

End Function
'***************************************************************
'%%%%%%%%%%%%%%%%%%%%%%%%%
'Close log.txt 
f.WriteBlankLines(1)
f.WriteLine "Exit"	
f.Close

'%%%%%%%%%%%%%%%%%%%%%%%%%
'CLEAN UP YOUR MESS!!!!
'%%%%%%%%%%%%%%%%%%%%%%%%%
Set MyFile =Nothing
Set f =Nothing
Set f2 =Nothing
Set	objConnection = Nothing
Set objCommand = Nothing
Set objRecordSet = Nothing
Set intTestOU = Nothing  
Set strComputer =Nothing 
Set objFSO = Nothing     	
										
		
											