'************************************************************************************
'
'VBScript Source File
'
'AUTHORS: Greg Lowe
'
'Version 1
'
'Date 09-13-2010
'
'Comment: This script will create the folder for GenomeStudio Favorite file if it does not exist.
'Then it will copy over the File formats to remote PC, the three folders will get new permission applied.
'************************************************************************************
Option Explicit
'On Error Resume Next
Const OverwriteExisting = True
Const INPUT_FILE_NAME = "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\machines\machines.txt" 'Must have this file
Const ForReading = 1, ForWriting = 2, ForAppending = 8
Const HKEY_LOCAL_MACHINE = &H80000002


Dim objFSO, objFile, strComputer, strComputers, arrComputers, CopyFilePath, TargetFilePath, Target1, objBeadFav, objBead, ObjGenomeFav, ObjGenome, Folder, strNoReply, strReply, strCompleteTask, SrvFilePath, strbatfile, strProgramFiles, BS2, FS
'Count totals
strNoReply=0
strReply=0
strCompleteTask=0


Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.OpenTextFile(INPUT_FILE_NAME, 1)
strComputers = objFile.ReadAll
objFile.Close
arrComputers = Split(strComputers, vbCrLf)

'***************************************************************************
'Create log on \\win2k\Cidrfiles to record events.
Dim MyFile, f, f2
MyFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\logs\GenomeCopylog.txt" '***************Change name of log file
Set f2 = CreateObject ("Scripting.FileSystemObject")
Set f =f2.OpenTextFile(MyFile, 2, True)
f.WriteLine "Favorits File copy   "& Now()'***************Change Title of log file
f.WriteBlankLines(1)
'***************************************************************************

For Each strComputer In arrComputers
f.WriteBlankLines(1)
WScript.Echo
f.WriteLine "***" & strComputer & "***"
	'***************************************************************************

	'Create a .bat file on C:\ to Ping the folders.
	Dim aFile, p1, p2
	Wscript.Echo "Read Ping.bat"
	aFile= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\Ping.bat" '**********Change name of .bat
	Set p1 = CreateObject ("Scripting.FileSystemObject")
	Set p2 =p1.OpenTextFile(aFile, 2, True)
		p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer
		Wscript.Echo strComputer
	p2.Close

	'***************************************************************************
	'Run Ping.bat file and if Return results = 0 then do:
	Dim objShell, objExecObject, strText
	Set objShell = CreateObject("WScript.Shell")
	Set objExecObject = objShell.Exec ("%comspec% /c \\win2k\CIDRData\Informatics\VBSScripts\BATFiles\Ping.bat")

	Do While Not objExecObject.StdOut.AtEndOfStream
	    strText = objExecObject.StdOut.ReadAll()
	    If Instr(strText, "Reply") > 0 Then
	        Wscript.Echo "Reply received- Now executing script."
	        'f.WriteLine "Now executing script"

					'%%%%%%%%%%%%%%%%%%%%%%%%%
					'Getting the IP address to add to the bat file later.
					Dim objWMIService, IPConfigSet, IPConfig, i, IP
			  	Set objWMIService = GetObject("winmgmts:" _
			    		& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
							If Err =0 Then
									Wscript.echo  "Getting the IP address"
									f.WriteLine "Getting the IP address"
									Set IPConfigSet = objWMIService.ExecQuery _
							  				("Select * from Win32_NetworkAdapterConfiguration Where IPEnabled=TRUE")
					
									For Each IPConfig in IPConfigSet
									    If Not IsNull(IPConfig.IPAddress) Then
									        For i=LBound(IPConfig.IPAddress) to UBound(IPConfig.IPAddress)
									            WScript.Echo IPConfig.IPAddress(i)
									            IP=IPConfig.IPAddress(i)
									        Next
									    End If
									Next
							Else
								Wscript.echo  "Getting the IP address was  'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
								f.WriteLine "Getting the IP address  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description
							End If
							
			  		'***************************************************************************
						f.WriteLine strComputer & " " & Now
						'Paths for files
						TargetFilePath="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\BeadStudio\FavoriteFormats\"
						BS2= strProgramFiles & "\Illumina\"
						Target1="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\"
						objBead="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\BeadStudio\"
						objBeadFav="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\BeadStudio\FavoriteFormats\"
						ObjGenome="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\GenomeStudio\"
						ObjGenomeFav="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\GenomeStudio\FavoriteFormats\"
						'WScript.Echo ProgramFiles
						'WScript.Echo TargetFilePath
			
						'32 or 64 Bit OS?
						ProgramFiles(strComputer)
			
							 	'***************************************************************************
								'Create bat file to Permission Illumina folder
								Dim TargetProgamFilePath, StrXcacl, StrCMD, batFile
								'StrCMD= "C:\AdminFolderPerm.bat"
								StrCMD= "\\win2k\CIDRFiles\CIDRData\Informatics\VBSScripts\BATFiles\AdminFolderPerm.bat"
								'Path for locating Admin folder below
								TargetProgamFilePath= strProgramFiles & "Illumina"
								'Checking for c$\Program Files\Illumina on remote PC
								Set fs = CreateObject("Scripting.FileSystemObject")
									If (fs.FolderExists(TargetProgamFilePath))Then '"\\" & strComputer & "c$\Program Files\Illumina"
										WScript.Echo  "Folder exists:" &  strProgramFiles & "Illumina"
											f.WriteLine "Illumina folder exists"
											StrXcacl= "xcacls.vbs " & Chr(34) & strProgramFiles & "Illumina" & Chr(34) & " /G " & Chr(34) & "WIN2k\Domain Admins" & Chr(34) & ":F;F " & Chr(34)& "Authenticated Users" & Chr(34)& ":F;F /T /F /E /I"
'											Wscript.Echo "Creating the bat file for Illumina permission change."
'											Wscript.Echo "StrXcacl = "& StrXcacl
'											ObjBatFile(StrXcacl)'Creating the local bat file
'											SetPermission(StrCMD)'Runs Bat file to set Permisions
'											deletebat(StrCMD)' calles Deletes bat file function
											WScript.Echo CheckFolder(objBeadFav, ObjGenomeFav,ObjGenome)' This creates the BeadStudio and GenomStudio favoritformats folders if needed
									End If
								'***************************************************************************
			Else
	        Wscript.Echo "No reply received."
	        f.WriteLine "No reply received, Different OS or computer powered off?"
	        'f.WriteLine "******"
	    End If
	Loop

Next

'Clean up Ping files on C:\
WScript.Echo PingPathDelete() 'Delete the Ping.bat file
WScript.Echo PingPath2Delete()'Delete the Ping_.bat file

'***************************************************************************
'Functions
'***************************************************************************
'***************************************************************************
Function CheckFolder(objBeadFav, ObjGenomeFav, ObjGenome )
Dim ObjFolder,ObjS, Foldr
'WScript.echo objBeadFav
'WScript.echo  ObjGenomeFav
Set ObjFolder = CreateObject("Scripting.FileSystemObject")
'Beadstudio folder check
If (ObjFolder.FolderExists(objBeadFav)) Then
	ObjS=objBeadFav & " Beadstudio folder exists " 
	f.WriteLine " Beadstudio folder exists " 
	WScript.echo Copyfile(objBeadFav,ObjGenomeFav)'Copy files from server to Beadstudio folder
Else
	If (ObjFolder.FolderExists(objBead)) Then 
	ObjS=objBeadFav & " Beadstudio folder created " 
	Set Foldr=ObjFolder.CreateFolder (objBeadFav)
	f.WriteLine " Beadstudio folder created " 
	WScript.echo Copyfile(objBeadFav,ObjGenomeFav)'Copy files from server to Beadstudio folder
	End If
WScript.echo 'No BeadStudio Folder"		
End If	
'Genome folder check
If (ObjFolder.FolderExists(ObjGenomeFav)) Then
	ObjS=ObjGenomeFav & " Genome favorits folder exists "
	f.WriteLine  " Genome favorits folder exists "
	Wscript.echo " Genome favorits folder exists "
			If (ObjFolder.FolderExists(objBeadFav)) Then
							f.WriteLine "Copyfile2" 
							WScript.echo "Copyfile2"
							WScript.echo Copyfile2(objBeadFav,ObjGenomeFav)'Copy from server to GemoneStudio folder
			Else
							f.WriteLine "Copyfile3" 
							WScript.echo "Copyfile3" 	
							WScript.echo Copyfile3(objBeadFav,ObjGenomeFav)'Copy from Beadstudio to GenomeStudio folder
			End If
Else
		If (ObjFolder.FolderExists(ObjGenome)) Then	
				If (ObjFolder.FolderExists(ObjGenomeFav)) Then	
					f.WriteLine "Genome favorits folder exists "
					WScript.Echo "Genome favorits folder exists "	
				Else
					Set Foldr=ObjFolder.CreateFolder (ObjGenomeFav)'Create Favorites folder
					f.WriteLine " Genome favorits folder created "
					WScript.Echo " Genome favorits folder created "
						If (ObjFolder.FolderExists(objBeadFav)) Then
							f.WriteLine "Copyfile2" 
							WScript.echo "Copyfile2"
							WScript.echo Copyfile2(objBeadFav,ObjGenomeFav)'Copy from server to GemoneStudio folder
						Else
							f.WriteLine "Copyfile3" 
							WScript.echo "Copyfile3" 	
							WScript.echo Copyfile3(objBeadFav,ObjGenomeFav)'Copy from Beadstudio to GenomeStudio folder
						End If
				End If			
		Else
			Set Foldr=ObjFolder.CreateFolder (ObjGenome) 'Create Genome Folder
			ObjS=ObjGenomeFav & " Genome favorits folder created "
			Set Foldr=ObjFolder.CreateFolder (ObjGenomeFav)'Create Favorites folder
			f.WriteLine " Genome favorits folder created " 
			WScript.echo Copyfile2(objBeadFav,ObjGenomeFav)'Copy from Beadstudio to Genomestudio folder
		End If
End If	
CheckFolder=ObjS
End Function
'***************************************************************************
Function Copyfile(objBeadFav,ObjGenomeFav)'Copy from server to Beadstudio folder
'On Error Resume Next
Dim File, BeadPath, GenomePath, fs, CopyFilePath, objStartFolder, objFolder, colFiles
CopyFilePath="\\win2k\CIDRFiles\CIDRData\Informatics\IlluminaFileFormats\"
BeadPath="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\BeadStudio\FavoriteFormats\"
GenomePath="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\GenomeStudio\FavoriteFormats\"
Set File = CreateObject("Scripting.FileSystemObject")
	'Getting a list of all the files in the \\win2k\CIDRFiles\CIDRData\CIDRShared\IlluminaFileFormats folder.
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	objStartFolder = CopyFilePath
	Set objFolder = objFSO.GetFolder(objStartFolder)
	Set colFiles = objFolder.Files
	For Each objFile in colFiles
	    'Wscript.Echo objFile.Name & " Copy from server to Beadstudio"
	    'File.CopyFile From server , to PC
	  Set Fs = CreateObject("Scripting.FileSystemObject")
		If (fs.FileExists(objBeadFav & objFile))Then
				Wscript.echo "Files Exist " & objFile
				f.WriteLine "Files Exist " & objFile
				fs.DeleteFile objFile
'				If Err =0 Then
'					Wscript.echo "Files Exist"
'					f.WriteLine "Files Exist"
'				Else
'					Wscript.echo "Delete task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
'					f.WriteLine "Delete task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
'				End If
'				err.clear
		Else
				fs.CopyFile objFile, BeadPath, OverwriteExisting 'Copy from server to Beadstudio folder
				f.WriteLine "Copying " & objFile & " file"
				WScript.Echo "Copying " & objFile & " file to remote Computer "
				If Err =0 Then
					Wscript.echo "Copying task was successful"
					f.WriteLine "Copying task was successful"
				Else
					Wscript.echo "Copying task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
					f.WriteLine "Copying task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
				End If
	  End If
				err.clear
				
				WScript.echo " "
	Next
Set File =Nothing
Set objFSO =Nothing
Set objFolder =Nothing
Set colFiles =Nothing
End Function
'***************************************************************************
'***************************************************************************
Function Copyfile2(objBeadFav,ObjGenomeFav)'Copy from Beadstudio to Genomestudio folder
'On Error Resume Next
Dim File, fs, objStartFolder, objFolder, colFiles
'CopyFilePath="\\win2k\CIDRFiles\CIDRData\Informatics\IlluminaFileFormats"
'BeadPath="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\BeadStudio\FavoriteFormats\"
'GenomePath="\\" & strComputer & "\C$\Documents and Settings\All Users\Application Data\Illumina\GenomeStudio\FavoriteFormats\"
Set File = CreateObject("Scripting.FileSystemObject")
	'Getting a list of all the files in the \\win2k\CIDRFiles\CIDRData\CIDRShared\IlluminaFileFormats folder.
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	objStartFolder = objBeadFav
	Set objFolder = objFSO.GetFolder(objStartFolder)
	Set colFiles = objFolder.Files
	For Each objFile in colFiles
				'*********************************
				'Copy file from Beadstudio to GenomeStudio
				Set Fs = CreateObject("Scripting.FileSystemObject")				
				If (fs.FileExists(ObjGenomeFav & objFile))Then
						WScript.echo " File was there."	
						If (fs.FileExists(objBeadFav & objFile))Then
							'BeadStudio was there
						Else
							'No BeadStudio, Copy From server instead
							Wscript.echo Copyfile3(objBeadFav,ObjGenomeFav)
						End If
						'**************	
						If Err =0 Then
							Wscript.echo "Delete task was successful"
							f.WriteLine "Delete task was successful"
						Else
							Wscript.echo "Delete task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
							f.WriteLine "Delete task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
						End If
						err.clear
				Else	
						'Wscript.echo objFile & " Copy from Beadstudio to Genomestudio folder"
						'Copy Genome file over
						fs.CopyFile objFile, ObjGenomeFav, OverwriteExisting 'Copy from Beadstudio to Genomestudio folder
						f.WriteLine "Copying " & objFile & " file"
						WScript.Echo "Copying " & objFile & " file to " & ObjGenomeFav
						If Err =0 Then
							Wscript.echo "Copy from Beadstudio to Genomestudio folder was successful"
							f.WriteLine "Copy from Beadstudio to Genomestudio folder was successful"
						End If
				End If
						err.clear
				'*********************************
				WScript.echo " "
	Next
Set File =Nothing
Set objFSO =Nothing
Set objFolder =Nothing
Set colFiles =Nothing
End Function
'***************************************************************************
Function Copyfile3(objBeadFav,ObjGenomeFav)'Copy from server to Genomestudio folder
'On Error Resume Next
Dim File, BeadPath, GenomePath, fs, CopyFilePath, objStartFolder, objFolder, colFiles
CopyFilePath="\\win2k\CIDRFiles\CIDRData\Informatics\IlluminaFileFormats\"
Set File = CreateObject("Scripting.FileSystemObject")
	'Getting a list of all the files in the \\win2k\CIDRFiles\CIDRData\CIDRShared\IlluminaFileFormats folder.
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	objStartFolder = CopyFilePath
	Set objFolder = objFSO.GetFolder(objStartFolder)
	Set colFiles = objFolder.Files
	For Each objFile in colFiles
	    'File.CopyFile From server , to PC
	    Set Fs = CreateObject("Scripting.FileSystemObject")
		If (fs.FileExists(ObjGenomeFav & objFile))Then
		Else
				Set Fs = CreateObject("Scripting.FileSystemObject")	
				fs.CopyFile objFile, ObjGenomeFav, OverwriteExisting 'Copy from server to Beadstudio folder
				f.WriteLine "Copying " & objFile & " file"
				WScript.Echo "Copying " & objFile & " file to remote Computer "
				If Err =0 Then
					Wscript.echo "Copying task was successful"
					f.WriteLine "Copying task was successful"
				Else
					Wscript.echo "Copying task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
					f.WriteLine "Copying task was not successful, Err.#=  " & Err.Number & " -- " &  Err.Description
				End If
	  End If
				err.clear
				
				WScript.echo " "
	Next
Set File =Nothing
Set objFSO =Nothing
Set objFolder =Nothing
Set colFiles =Nothing
End Function
'***************************************************************************
'***************************************************************************
'Create a .bat file to Permission
'Function ObjBatFile(StrCMD, IP, StrXcacl)
Function ObjBatFile(StrXcacl)
Dim Bat, myf
Set Bat = CreateObject ("Scripting.FileSystemObject")
Set myf =Bat.OpenTextFile(StrCMD, 2, True)
	myf.WriteLine "NET USE \\" & IP & "\c$"
	'Ecample of:  StrXcacl="xcacls \\" & IP &  "\c$\admin /g "  & Chr(34) & "WIN2k\Domain Admins" & Chr(34) &  ":f;f System:F;F /t /e /y"
	myf.WriteLine StrXcacl
	'xcacls c:\admin /g "WIN2k\Domain Admins":f;f "Authenicated Users":r:r administrators:f System:F;F /Y
	myf.WriteLine "NET USE \\" & IP & "\c$ /DELETE"

	myf.WriteBlankLines(1)
	myf.WriteLine "Exit"
myf.Close
End Function
'***************************************************************************
'***************************************************************************
'Deletes the bat file create on the c:\
Function deletebat(StrCMD)
Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.DeleteFile(StrCMD)
If Err =0 Then
		Wscript.Echo "Finished:  Deleted the temp AdminFolderPerm.bat file."
		f.WriteLine "Finished:  Deleted the temp AdminFolderPerm.bat file."
	Else
		Wscript.echo  "Bat file delete was  'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
		f.WriteLine "Bat file delete was  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description
	End If
	Err.clear
End Function
'***************************************************************************
'***************************************************************************
'This runs the bat script to permission the folder
Function SetPermission(StrCMD)
Set objShell = CreateObject("Wscript.Shell")
objShell.Run ("%comspec% /k "& StrCMD),1 ,TRUE
If Err =0 Then
		Wscript.Echo "Success:  Ran bat file to set permissions."
		f.WriteLine "Success:  Ran bat file to set permissions."
	Else
		Wscript.echo  "Bat file to set permissions c:\admin was  'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
		f.WriteLine "Bat file to set permissions c:\admin was 'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description
	End If
	Err.clear
End Function
'***************************************************************************
'***************************************************************************
Function ProgramFiles(strComputer)				
				'Looks for BeadStudio Folder in Program Files.
				Dim fspath, bit32Path, bit64Path
				bit64Path="\\" & strComputer & "\C$\Program Files (x86)\"
				bit32Path="\\" & strComputer & "\C$\Program Files\"
				Set fspath = CreateObject("Scripting.FileSystemObject")
				If (fspath.FolderExists(bit64Path))Then 'Is OS 64 bit version?
							'f.WriteLine "OS 64 bit version"
							WScript.Echo "OS 64 bit version" & strProgramFiles= bit64Path
							 strProgramFiles= bit64Path
				Else
							'f.WriteLine "OS 32 bit version"
							WScript.Echo "OS 32 bit version"
							strProgramFiles=bit32Path
				End If
				Err.Clear
End Function
'***************************************************************************
'***************************************************************************
Function PingPathDelete
Dim fs2, PingPath
Set fs2 = CreateObject("Scripting.FileSystemObject")
	PingPath="c:\ping.bat"
If (fs2.FileExists(PingPath)) Then
						fs2.DeleteFile PingPath  'Remove ping.bat files
						If Err =0 Then
							Wscript.Echo "Ping File deleted" 
							f.WriteLine  "Ping File deleted" 	
						Else
							Wscript.echo  "Ping file not deleted! 'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
							f.WriteLine TargetFilePath &  " Ping file not deleted!  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description 
						End If
						err.clear
					End If
Set fs2=Nothing
End Function	
'***************************************************************************
'***************************************************************************
Function PingPath2Delete
Dim PingPath2, fs2
Set fs2 = CreateObject("Scripting.FileSystemObject")
	PingPath2="c:\ping_.bat"
If (fs2.FileExists(PingPath2)) Then
						fs2.DeleteFile PingPath2  'Remove ping_.bat files
						If Err =0 Then
							Wscript.Echo "Ping File deleted" 
							f.WriteLine  "Ping File deleted" 	
						Else
							Wscript.echo  "Ping file not deleted! 'Not' successful, Err.#= "  & Err.Number & " -- " &  Err.Description
							f.WriteLine TargetFilePath &  " Ping file not deleted!  'Not' successful, Err.#=  " & Err.Number & " -- " &  Err.Description 
						End If
						err.clear
					End If
Set fs2=Nothing	
End Function	
'***************************************************************************
'***************************************************************************
'End Functions
'***************************************************************************

'Close log
f.WriteBlankLines(1)
f.WriteLine "*****Exiting Script*****  " & Now()
f.Close
'%%%%%%%%%%%%%%%%%%%%%%%%%
'CLEAN UP YOUR MESS!!!!
'%%%%%%%%%%%%%%%%%%%%%%%%%
Set objFSO = Nothing
Set objFile = Nothing
Set f2 = Nothing
Set Folder =Nothing
Set f = Nothing
Set fs = Nothing
Set objExecObject =Nothing
Set objFile =Nothing
Set objShell =Nothing
Set p1 =Nothing