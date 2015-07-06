'***************************************************************************
'
' VBScript Source File
'
' Version: 1.2
'
' AUTHORS: Greg Lowe
'
' DATE  : 7\5\05
'
' COMMENT: On each computer try to locate and delete all the users BAM icons and delete them. 
' Then add the new BAM and CIDR Infinum LIMS Selection Interface icons from the local machine (All user start menu) and copy them 
'to the remote computers All user start menu.
'First check what computer are listed in the Machines.txt on genosrv2!!!
'5/22/06- Desktkop icons do not get deleted? Send email telling all to delete their Desktops icons. 
'9/13/06- Added copy of the CIDR Infinum LIMS Selection Interface icon.
'10/10/06- Make sure the J2SE 5 is installed "jre-1_5_0-windows-i586.exe".
'***************************************************************************
Option Explicit 
'On Error Resume Next
Const HKEY_LOCAL_MACHINE = &H80000002
Const OverwriteExisting = True
Const INPUT_FILE_NAME = "\\win2k\cidrfiles\cidrdata\Informatics\VBSScripts\machines\machines.txt"
Const FOR_READING = 1
Const ForAppending = 8
Const CIDRfiles = "\\WIN2K\CIDRFiles"

Dim objFSO, objFile, strComputer, strComputers, arrComputers 
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(INPUT_FILE_NAME, FOR_READING)
strComputers = objFile.ReadAll
objFile.Close
arrComputers = Split(strComputers, vbCrLf)

'***************************************************************************	
'Create BAMlog on C:\ to record events.
Dim MyFile, f, f2
MyFile= "\\win2k\cidrfiles\cidrdata\Informatics\VBSScripts\logs\BAMlog.txt"
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "BAMlog events on  "& Now()
f.WriteBlankLines(1)
'***************************************************************************
			
For Each strComputer In arrComputers
f.WriteBlankLines(1)
WScript.Echo
f.WriteLine "***" & strComputer & "***"
	'***************************************************************************
	'Create a .bat file on C:\ to Permission the folders.
	Dim aFile, p1, p2
	
	aFile= "C:\Ping.bat"
	Set p1 = CreateObject ("Scripting.FileSystemObject")
	Set p2 =p1.OpenTextFile(aFile, 2, True)
		p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer 
		Wscript.Echo strComputer
	p2.Close

	'***************************************************************************
	'Run Ping.bat file and if Return results = 0 then do:
	Dim objShell, objExecObject, strText
	Set objShell = CreateObject("WScript.Shell")
	Set objExecObject = objShell.Exec ("%comspec% /c C:\Ping.bat")
	
	Do While Not objExecObject.StdOut.AtEndOfStream
	    strText = objExecObject.StdOut.ReadAll()
	    If Instr(strText, "Reply") > 0 Then
	    	WScript.Echo
	        WScript.Echo "Reply received- Now executing script."
	        WScript.Echo
	        f.WriteLine "***Now executing script***" 
	        Dim objRegistry, strKeyPath, strValueName, arrSubkeys, objSubkey, strSubPath, strValue
			
			Set objRegistry=GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")                          
			strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
			objRegistry.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubkeys         
			
			For Each objSubkey In arrSubkeys
				strValueName = "ProfileImagePath"
			    	strSubPath = strKeyPath & "\" & objSubkey
			    	objRegistry.GetExpandedStringValue HKEY_LOCAL_MACHINE,strSubPath,strValueName,strValue
			   	'Wscript.Echo strValue
			   	
			   	'Split to get the user name only for each Documents and settings account.
			   	Dim MyString, MyArray, User
				MyString = strValue
				MyArray = Split(MyString, "\", -1, 1)
				' MyArray(0) contains "C:"
				' MyArray(1) contains "Documents and Settigns"
				' MyArray(2) contains "Administrator"
				User = MyArray(2)
				'Wscript.echo  user
			 
			    	
			    	'Builds the "Desktop" path strings.
			    	Dim  Desktop, StartM
				Desktop =  "\\" & strComputer & "\c$\Documents and Settings\" & User & "\Desktop\CIDR Bioinformatics Application Manager.LNK"
				'Builds the "Start Manu" and path strings.
				StartM = "\\" & strComputer & "\c$\Documents and Settings\" & User & "\Start Menu\CIDR Bioinformatics Application Manager.LNK"
			
				Dim CopyFilePath, CopyFilePath2
				CopyFilePath="C:\Documents and Settings\All Users\Start Menu\CIDR Bioinformatics Application Manager.lnk"
				'CopyFilePath2="C:\Documents and Settings\All Users\Start Menu\CIDR Infinium LIMS Selection Interface.lnk"
				 
				Dim fs	'Check for and Deleting user Desktop icon.
					Set fs = CreateObject("Scripting.FileSystemObject")	
					If (fs.FileExists(Desktop)) Then
						fs.DeleteFile Desktop, OverwriteExisting
						Wscript.Echo "Desktop link exists - Deleted " & strValue & vbCRLF & vbCRLF
						f.WriteLine "Desktop link exists - Deleted " 
					Else
						Wscript.Echo "No Short cut! Desktop " & strValue & vbCRLF & vbCRLF
						f.WriteLine "No Short cut! Desktop " 
					End If
				
				Dim fsm	'Check for and Deleting user StartMemu icon.
					Set fsm = CreateObject("Scripting.FileSystemObject")	
					If (fsm.FileExists(StartM)) Then
						fsm.DeleteFile StartM, OverwriteExisting
						Wscript.Echo "StartMenu link exists - Deleted " & strValue & vbCRLF & vbCRLF
						f.WriteLine "StartMenu link exists - Deleted "	
					Else
						Wscript.Echo "No Short cut! StartMenu " & strValue & vbCRLF & vbCRLF
						f.WriteLine "No Short cut! StartMenu " 
					End If
			
			Next
				'Copy the new BAM shortcut to AllUsersStartMenu
				'With File Paths, you would be wise to put them into Variables like this (for Troubleshooting):
				Dim TargetFilePath
				Dim CheckPath
				TargetFilePath="\\" & strComputer & "\c$\Documents and Settings\All Users\Start Menu\"
				CheckPath="\\" & strComputer & "\c$\Documents and Settings\All Users\Start Menu\CIDR Bioinformatics Application Manager.lnk"
				
					'Wscript.Echo "checkpath veriable : " & CheckPath
					'Check for ALLUsers Stat Menu file then copies over it
					Dim fs2
					Set fs2 = CreateObject("Scripting.FileSystemObject")	
					If (fs2.FileExists(CheckPath)) Then
						fs2.CopyFile CopyFilePath,TargetFilePath, OverwriteExisting  'Adds the BAM link
						'fs2.CopyFile CopyFilePath2,TargetFilePath, OverwriteExisting 'Adds the Infinum LIMS Link
						If Err =0 Then
							Wscript.Echo "All Users\Start Menu links exists - replaced " 
							f.WriteLine "All Users\Start Menu links exists - replaced " 	
						Else
							Wscript.echo  "Creating All Users\Start Menu link was  'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
							f.WriteLine "Creating All Users\Start Menu link was  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description 
						End If
						err.clear
						
						
					Else
						fs2.CopyFile CopyFilePath,TargetFilePath, OverwriteExisting
						'fs2.CopyFile CopyFilePath2,TargetFilePath, OverwriteExisting
						If Err =0 Then
							Wscript.Echo "No Short cut! All Users\Start Menu - Adding new lnk"  
							f.WriteLine "No Short cut! All Users\Start Menu - Adding new lnk" 	
						Else
							Wscript.echo  "Creating All Users\Start Menu link was  'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
							f.WriteLine "Creating All Users\Start Menu link was  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description 
						End If
						err.clear
						 
					End If
	    Else
	        Wscript.Echo "No reply received."
	        f.WriteLine "No reply received is computer is powered off?" 
	        'f.WriteLine "******"
	    End If
	Loop
Next
Wscript.Echo "*********************"

'CLEAN UP YOUR MESS!!!!
Set objRegistry=Nothing
Set objExecObject=Nothing
Set MyString =Nothing
'Close BAMlog.txt 
f.WriteLine "Exit"	
f.Close

