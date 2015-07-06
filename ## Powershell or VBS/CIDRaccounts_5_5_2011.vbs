'***************************************************************************
'
' VBScript Source File
'
' Version: 1
'
' AUTHORS: Greg Lowe
'
' DATE  : 12/20/2006
'
' COMMENT:  This script will create a new user account and all folders assoicated with that user.
' 
'***************************************************************************
Option Explicit 
'On Error Resume Next 
Const OverwriteExisting = True
Const ForReading = 1, ForWriting = 2, ForAppending = 8

'***************************************************************************	
'Create log on \\Win2k\CIDRfiles to record events.
Dim MyFile, f, f2
MyFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\logs\NewCIDRAccount.txt" '*******  Where log is written!
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "Creating new user " & struserName & " folders" &  Now()
f.WriteBlankLines(1)

'***************************************************************************
'Prompts for input
Dim strFirstName,strLastName,struserName, strStartDate, Strdate 
strFirstName= InputBox("User's First name?" & _
	VBNewLine & "(i.e. Gregory)",,"Not Greg")
strLastName= InputBox("User's Last name?" & _
	VBNewLine & "(i.e. Willson)")
struserName= InputBox("User name?" & _
	VBNewLine & "(i.e. only 8 charters allowed)",,"must match email address")
strStartDate= InputBox("Employee Start Date?" & _
	VBNewLine & "(Use this format)",,"9/29/2011")
	
'strFirstName= "test"
'strLastName= "3"
'struserName="test3"
'strStartDate="12/20/2006"

Strdate= strStartDate & " 8:00 AM"
'FullName = strFirstName & " " & strLastName

'***************************************************************************
'Create User account
Dim objContainer, objUser
	'Creating the in the CIDRuser OU instead of the defualt location 
	Set objContainer = GetObject("LDAP://OU=CIDRusers,dc=win2k,dc=cidr,dc=jhmi,dc=edu")
	Set objUser = objContainer.Create("User", "cn=" & strFirstName & " " & strLastName)
	objUser.Put "sAMAccountName", struserName
'Configuring user accountPage information
	objUser.sn = strLastName					'objUser.Put "sn", "LastName"
	objUser.givenName = strFirstName				'objUser.Put "givenName", "FirstName"
	objUser.FullName = strFirstName & " " & strLastName         	'Display name.
	objUser.userPrincipalName = struserName & "@win2k.cidr.jhmi.edu"
	objUser.scriptPath = "logonbeta2.wsh"				'Set logon script
	'objUser.ProfilePath = "\\genosrv2\home\" & struserName		'Set Home Folder path
	objUser.SetInfo
	'Must have user created to set the password
	objUser.SetPassword "Temp123."
	objUser.SetInfo
If Err.Number <>0 Then
    WScript.Echo "Error:    Set tempory password failed with error " _
                            & Hex(Err.Number)
Else
    WScript.Echo "Success:  Tempory password set for user"
    WScript.Echo "          " & objUser.ADsPath
End If
	objUser.Put "pwdLastSet", 0 			'Forces a user to change their password the next time they logon 
	objUser.AccountDisabled = True			'Disables account
	objUser.SetInfo

'***************************************************************************
'Paths
	Dim CIDRusersPath,CIDRusersPersonalPath,CIDRUserHome
	CIDRusersPath="\\Win2k\CIDRFiles\CIDRUser\" & struserName
	CIDRusersPersonalPath="\\Win2k\CIDRFiles\CIDRUser\" & struserName & "\_Personal"

WScript.Echo CreateCIDRUserFolder(struserName)
WScript.Echo CreateCIDRUserPersonalFolder(struserName)
WScript.Echo CreateNewUserBat(struserName)

WScript.Echo RunNewUserBat() 'Runs the permission changes NewUser.bat
f.WriteLine "Ran RunNewUserBat()"
WScript.Echo DeleteNewUserBat()'Runs the permission changes NewUser.bat
f.WriteLine "DeleteNewUserBat()"

'***************************************************************************
'Here is the fields for the email (sSmtpServer,sUsername,sPassword,sTo,sCC,sBCC,sFrom,sSubject,sBody,sAttach) Must have blank quotes if not in use!
Dim bFlag
bFlag = CDOSYS_Send_Email("alderaan.cidr.jhmi.edu","","","support@cidr.jhmi.edu","","","support@cidr.jhmi.edu","New Windows Account Created!"," This email message is auto generated when running the CIDRAccount2.vbs script. A new user account was created " & Chr(34) & struserName & Chr(34) & ", Their first name is " & Chr(34) & strFirstName & Chr(34) & ", Last name is " & Chr(34) & strLastName & Chr(34) & ". Don't forget to create the Unix account!","")
	If Err =0 Then
		Wscript.Echo "Success:  Sent Email with attached NewUserName.txt file."
		Call SetOutlook(struserName,Strdate)'Set the Appt in Outlook for new user start
	Else
		Wscript.echo "Failed:  to sent Email with attached NewUserName.txt file, Err.#=  " & Err.Number & " -- " &  Err.Description 
	End If
	err.clear


'***********************************************
'Functions Section
'***********************************************
'***************************************************************************
Function CreateCIDRUserFolder(struserName)
'Create O: Shared and _Personal folders on Genosrv3
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")
If objFSO.FolderExists("\\win2k\cidrfiles\cidruser\" & struserName) Then
	Wscript.Echo "User Folder Exist"
Else
  objFSO.CreateFolder("\\win2k\cidrfiles\cidruser\" & struserName)
End If
	If Err =0 Then
			Wscript.Echo "Success:  'Created new folder for " & struserName&  " in CIDRUser folder."
			'f.WriteLine "Success:  'Created new folder for " & struserName&  " in CIDRUser folder."
		Else
			Wscript.echo "Failed:  'Created new folder for " & struserName&  " to New CIDRUser folder, Err.#=  " & Err.Number & " -- " &  Err.Description 
			'f.WriteLine "Failed:  'Created new folder for " & struserName&  " to New CIDRUser folder, Err.#=  " & Err.Number & " -- " &  Err.Description 
		End If
		err.clear
		'Wscript.Echo "CreateCIDRUserPersonalFolder " & CreateCIDRUserPersonalFolder(struserName)
Set objFSO =Nothing
End Function
'***************************************************************************
'***************************************************************************
Function CreateCIDRUserPersonalFolder(struserName)
'****Now Create the Users _Personal folder on CIDRUsers
 Dim Objfs, Foldr
 'Now Create the folder on CIDRUsers
 Wscript.Echo "CreateCIDRUserPersonalFolder " & struserName
	Set Objfs = CreateObject("Scripting.FileSystemObject")
	If Objfs.FolderExists("\\win2k\cidrfiles\cidruser\" & struserName &"\_Personal") then
  		Wscript.Echo "User Folder Exist"
	Else
		Objfs.CreateFolder("\\win2k\cidrfiles\cidruser\" & struserName &"\_Personal")
		If Err =0 Then
			Wscript.Echo "Success:  'Created new folder for " & struserName&  " in CIDRUser folder\_Personal."
			'f.WriteLine "Success:  'Created new folder for " & struserName&  " in CIDRUser folder\_Personal.."
		Else
			Wscript.echo "Failed:  'Created new folder for " & struserName&  " to New CIDRUser folder\_Personal., Err.#=  " & Err.Number & " -- " &  Err.Description 
			'f.WriteLine "Failed:  'Created new folder for " & struserName&  " to New CIDRUser folder\_Personal., Err.#=  " & Err.Number & " -- " &  Err.Description 
		End If
		err.clear
	End If
Set Objfs =Nothing
End Function
'***************************************************************************
'***************************************************************************
Function CreateNewUserBat(struserName) 
'Create a .bat file on \\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\ to Permission the folders.
Dim aFile, fs, f
aFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\NewUser.bat"
'aFile= "c:\NewUser.bat"
Set fs = CreateObject ("Scripting.FileSystemObject")
Set f =fs.OpenTextFile(aFile, 2, True)
	f.WriteLine "NET USE \\165.112.177.225\u$"
	f.WriteLine "xcacls.vbs " & Chr(34) & "\\165.112.177.225\CIDRUser\" & struserName & Chr(34) & " /G " &  Chr(34) & "Win2k\" & "Domain Users" & Chr(34) & ":WXW;98654321 " & Chr(34) & "Win2k\" & struserName & Chr(34) & ":M;B76321 " & Chr(34) & "WIN2k\Domain Admins" & Chr(34) & ":f;f System:F;F " & Chr(34) & "CREATOR OWNER" & Chr(34) & ":F;F /I Copy"
	f.WriteLine "NET USE \\165.112.177.225\u$ /DELETE"
	f.WriteLine "NET USE \\165.112.177.225\u$"
	f.WriteLine "xcacls.vbs " & Chr(34) & "\\165.112.177.225\CIDRUser\" & struserName & "\_Personal" & Chr(34) & " /G " & Chr(34) & "Win2k\" & struserName & Chr(34) & ":M;B76321 " & Chr(34) & "WIN2k\Domain Admins" & Chr(34) & ":f;f " & Chr(34) & "CREATOR OWNER" & Chr(34) &":f;f System:F;F /I REMOVE"
	f.WriteLine "NET USE \\165.112.177.225\u$ /DELETE"
	f.WriteLine "NET USE \\165.112.177.225\P$"
	'f.WriteLine "xcacls.vbs " & Chr(34) & "\\165.112.177.225\Home\" & struserName & Chr(34) & " /G " & Chr(34) & "Win2k\"  & struserName & Chr(34) & ":F " & Chr(34) & "WIN2k\Domain Admins" & Chr(34) & ":f;f System:F;F"
	'f.WriteLine "NET USE \\165.112.177.225\P$ /DELETE"
	f.WriteBlankLines(1)
	f.WriteLine "Exit"	
f.Close
	If Err =0 Then
		Wscript.Echo "Success:  'NewUser.bat' created."
	Else
		Wscript.echo "Failed:  'NewUser.bat' creation, Err.#=  " & Err.Number & " -- " &  Err.Description 
	End If
	err.clear
Set fs =Nothing
Set f =Nothing
End Function
'***************************************************************************
'***************************************************************************
Function RunNewUserBat()
'This runs the bat script to permission the folders created
Dim objShell
Set objShell = CreateObject("Wscript.Shell")
objShell.Run ("%comspec% /K \\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\NewUser.bat"),1 ,TRUE
Wscript.Echo
	If Err =0 Then
		Wscript.Echo "Success:  Ran bat file to set permissions."
	Else
		Wscript.echo "Failed:  to run bat file to set permissions, Err.#=  " & Err.Number & " -- " &  Err.Description 
	End If
	err.clear
Set objShell = Nothing
End Function
'***************************************************************************
'***************************************************************************
Dim sSmtpServer, sUsername, sPassword, sTo, sCC, sBCC, sFrom, sSubject, sBody, sAttach, oMessage, oConfiguration, cFields, aFiles, sFile
Function CDOSYS_Send_Email(sSmtpServer,sUsername,sPassword,sTo,sCC,sBCC,sFrom,sSubject,sBody,sAttach)
    'These weird constants do NOT cause any communications with schemas.microsoft.com.  They are just naming conventions.
    Const cdoSendUsingMethod =        "http://schemas.microsoft.com/cdo/configuration/sendusing"
    Const cdoSMTPServer =             "http://schemas.microsoft.com/cdo/configuration/smtpserver"
    Const cdoSMTPServerPort =         "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
    Const cdoSMTPConnectionTimeout =  "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
    Const cdoSMTPAuthenticate =       "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
    Const cdoSendUserName =           "http://schemas.microsoft.com/cdo/configuration/sendusername"
    Const cdoSendPassword =           "http://schemas.microsoft.com/cdo/configuration/sendpassword"
    Const cdoSendUsingPickup =        1    'Use the local IIS-SMTP service for delivery.
    Const cdoSendUsingPort =          2    'Use a remote SMTP server for delivery.
    
    Set oMessage = WScript.CreateObject("CDO.Message")
    Set oConfiguration = WScript.CreateObject("CDO.Configuration")

    Set cFields = oConfiguration.Fields
    cFields.Item(cdoSendUsingMethod) = cdoSendUsingPort     'cdoSendUsingPort = Send to remote SMTP server (2), cdoSendUsingPickup = Send using local SMTP service (1).
    cFields.Item(cdoSMTPServer) = sSmtpServer               'IP address or DNS name of the remote SMTP server.   
    cFields.Item(cdoSMTPServerPort) = 25                 
    cFields.Item(cdoSMTPConnectionTimeout) = 30             'Timeout in seconds for connection.

    If LCase(sUsername) = "ntlm" Then
        cFields.Item(cdoSMTPAuthenticate) = 2               '2 = NTLM authentication.  NTLM uses the credentials of the WSH process itself.
    ElseIf sUsername <> "" Then 
        cFields.Item(cdoSMTPAuthenticate) = 1               '1 = Basic authentication.
        cFields.Item(cdoSendUserName) = sUsername           'Username for Basic authentication, ignored for anonymous or NTLM authentication.
        cFields.Item(cdoSendPassword) = sPassword           'Password for Basic authentication, ignored for anonymous or NTLM authentication.
    Else 
        cFields.Item(cdoSMTPAuthenticate) = 0               '0 = Anonymous authentication.
    End If
    
    cFields.Update                                          'Save data so far.
    Set oMessage.Configuration = oConfiguration             
                                       
    oMessage.To = sTo
    oMessage.CC = sCC
    oMessage.BCC = sBCC
    oMessage.From = sFrom
    oMessage.Subject = sSubject
    oMessage.TextBody = sBody
    
    If sAttach <> "" Then 
        aFiles = Split(sAttach,";")
        For Each sFile In aFiles
            oMessage.AddAttachment sFile
        Next
    End If
    
    oMessage.Send
    
    If Err.Number = 0 Then
        CDOSYS_Send_Email = True
    Else
        CDOSYS_Send_Email = False
    End If
    
    Set oMessage = Nothing
    Set oConfiguration = Nothing
End Function
'***************************************************************************
'***************************************************************************
Function SetOutlook(struserName,Strdate)
'Setup an appoitnment in Outlook
Dim objOutlook, objAppointment
		Const olAppointmentItem = 1
		
		Set objOutlook = CreateObject("Outlook.Application")
		Set objAppointment = objOutlook.CreateItem(olAppointmentItem)
		
		objAppointment.Start = Strdate 'surround the date and time with pound signs #4/11/2005 11:00 AM#
		objAppointment.Duration = 60 'Duration properties are expressed in minutes
		objAppointment.Subject = "New Employee "& struserName & " starts"
		objAppointment.Body = "Set up computer email with them!"
		objAppointment.ReminderMinutesBeforeStart = 15 'ReminderMinutesBeforeStart properties are expressed in minutes
		objAppointment.ReminderSet = True
		objAppointment.Save
			'Check for errors
			If Err =0 Then
				Wscript.Echo "Success: Created outlook appt."
			Else
				Wscript.echo "Failed: to Created outlook appt, Err.#=  " & Err.Number & " -- " &  Err.Description 
			End If
			err.clear
		Set objOutlook =Nothing
		Set objAppointment = Nothing
End Function
'***************************************************************************
'***************************************************************************
Function DeleteNewUserBat()
'Deletes the bat file created on the c:\ to permission the folders
Dim objFSO, aFile
aFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\NewUser.bat"
Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile(aFile)
Wscript.Echo
	If Err =0 Then
		Wscript.Echo "Success:  Deleted the temp Newuser.bat file."
	Else
		Wscript.echo "Failed:  to Deleted the temp Newuser.bat file, Err.#=  " & Err.Number & " -- " &  Err.Description 
	End If
	err.clear
Set objFSO =  Nothing
End Function
'NewUserEmail.txt Need to Delete this file
'***************************************************************************
'*********************************************
'End Functions Section
'*********************************************
'Clean up Memory