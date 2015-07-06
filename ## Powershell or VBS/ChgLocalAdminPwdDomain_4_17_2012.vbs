'***************************************************************************                                                                             
' VBScript Source File                                                                                                                                   
' Version: 1                                                                                                                                             
' AUTHORS: Greg Lowe                                                                                                                                     
' DATE  : 4/16/2012                                                                                                                                      
' COMMENT: Changes the Local administrator password and gets the MAC addresses for each computer in AD that returns a ping 
' Windows 7 and 2008 do not allows vbscript                                                                           
'***************************************************************************                                                                             
Option Explicit                                                                                                                                          
'On Error Resume Next                                                                                                                                    
Const OverwriteExisting = True                                                                                                                           
Const ForReading = 1, ForWriting = 2, ForAppending = 8                                                                                                   
Const HKEY_LOCAL_MACHINE = &H80000002                                                                                                                    
'***************************************************************************
'***************************************************************************                                                                             
'The format is such as it will be easier to find in a folder later MMDDYY.                                                                               
' ### call function to get the date ###                                                                                                                  
today_date()                                                                                                                                             
                                                                                                                                                         
                                                                                                                                                         
'Create log to record events.                                                                                                                            
Dim MyFile, f, f2, objFSO, thisday                                                                                                           
Set objFSO = CreateObject("Scripting.FileSystemObject")                                                                                                  
MyFile= "\\win2k\cidrfiles\CIDRData\Informatics\VBSScripts\logs\ Local_Admin_PWD"& thisday & ".log" '***************Change name of log file                 
Set f2 = CreateObject ("Scripting.FileSystemObject")                                                                                                     
Set f =f2.OpenTextFile(MyFile, 2, True)                                                                                                                  
f.WriteLine "Win2k.cidr.jhmi.edu"                                                                                                                        
f.WriteLine  Date()                                                                                                                                      
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
'Prompts for input
Dim strPassword 
strPassword= InputBox("New password")
'***************************************************************************
'***************************************************************************
                                                                                                                                                         
Const ADS_SCOPE_SUBTREE = 2                                                                                                                              
Dim objConnection, objCommand, objRecordSet, intTestOU, strComputer                                                                                                   
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
        strComputer=objRecordSet.Fields("Name").Value 
        Wscript.Echo strComputer                                                                                                  
                '***************************************************************************                                                                                                                                         
								'***************************************************************************                                                             
								'Create a .bat file on C:\ to Ping the folders.                                                                                          
								Dim aFile, p1, p2                                                                                                                        
								                                                                                                                                         
								aFile= "C:\Ping_.bat" '**********Change name of .bat                                                                                     
								Set p1 = CreateObject ("Scripting.FileSystemObject")                                                                                     
								Set p2 =p1.OpenTextFile(aFile, 2, True)                                                                                                  
									p2.WriteLine "%SYSTEMROOT%\system32\ping -n 3 -w 1000 " & strComputer                                             
									'Wscript.Echo strComputer                                                                                                                
								p2.Close                                                                                                                                 
							  '***************************************************************************                                                                                                                                         
								'***************************************************************************                                                             
									'Run Ping.bat file and if Return results = 0 then do:                                                                                  
									Dim objShell, objExecObject, strText                                                                                                   
									Set objShell = CreateObject("WScript.Shell")                                                                                           
									Set objExecObject = objShell.Exec ("%comspec% /c C:\Ping_.bat")                                                                        
									                                                                                                                                       
									Do While Not objExecObject.StdOut.AtEndOfStream                                                                                        
									    strText = objExecObject.StdOut.ReadAll()                                                                                           
									    If Instr(strText, "Reply") > 0 Then                                                                                                
									    	Wscript.Echo vbCrLf & "----------" & vbCrLf & strComputer   & " --Reply recieved"
								        f.WriteLine vbCrLf & "----------" & vbCrLf & strComputer   & " --Reply recieved"
								        On Error Resume Next
								        Set objWMIService = GetObject("winmgmts:\\" & strComputer   & "\root\cimv2")
														If objWMIService Is Nothing Then
														    WScript.Echo "Unable to bind to WMI on " & strComputer  
														    WScript.Echo "----------"
														    f.WriteLine "Unable to bind to WMI on " & strComputer  
														    f.WriteLine "----------"
														Else
														    'WScript.Echo "Successfully bound to WMI on " & strComputer  
														    'f.WriteLine "Successfully bound to WMI on " & strComputer  
														    Wscript.Echo PWDChangeAdmin(strComputer  ,strPassword)
														End If
									                                                                                                                                       
											'%%%%%%%%%%%%%%%%%%%%%%%%%                                                                                                         
									    Else                                                                                                                               
									    		'List Computer name here*******************                                                                                    
									        Wscript.Echo strComputer  & " -No ping."                                                                  
									        'f.WriteLine strComputer  & " -No ping."                                                                  
									        Wscript.Echo                                                                                                                   
									    End If                                                                                                                             
									Loop                                                                                                                                   
									Wscript.Echo                                                                                                                           
									'***************************************************************************
									'***************************************************************************                                                           
		 End If                                                                                                                                              
    objRecordSet.MoveNext                                                                                                                                
Loop                                                                                                                                                     
'***************************************************************************
'Functions 
'***************************************************************************                                                                                      
'***************************************************************                                                                                         
' ### This funtion gets the date in format MMDDYY ###                                                                                                    
Function Today_Date()                                                                                                                                    
                                                                                                                                                         
thisday=Right("0" & Month(Date),2) & Right("0" & Day(Date),2) & Right(Year(Date),2)                                                                      
                                                                                                                                                         
thisday=Right(Year(Date),2) & Right("0" & Month(Date),2) & Right("0" & Day(Date),2)                                                                      
                                                                                                                                                         
End Function                                                                                                                                             
'*************************************************************** 
'***********************************************************
Function PWDChangeAdmin(strComputer  ,strPassword)
Dim objUser
Set objUser = GetObject("WinNT://" & strComputer & "/administrator") 
		 	'objUser.SetPassword strPassword 
			'objUser.Setinfo 
					If Err = 0 Then  
					    'write eventlog 
					    'WScript.Echo  vbCrLf & "----------" & vbCrLf & strComputer   & "--Password changed" 
					    WScript.Echo strComputer   & " --Password changed"
					    WScript.Echo "----------"                                                  
							'Appending to log.         		                                                                        
							'f.WriteLine vbCrLf & "----------" & vbCrLf & strComputer   & "--Password changed" 
							f.WriteLine strComputer   & " --Password changed"              
							f.WriteLine "----------"   		
					Else 
					     f.WriteLine  strComputer   & vbCrLf & Now & vbCrLf & Err.Number & ":" & Err.Description 
					End if 
					Err.Clear
End Function
'***********************************************************                                                                                                                
'***************************************************************                                                                                         
' ### This funtion gets the Get MAC address ###                                                                                                          
Function GetMAC()                                                                                                                                        
On Error Resume next                                                                                                                                     
Dim objWMIService,objCollection,objItem, strValueIP, strValueMac,strValue                                                                                
			'sub srNetSettingsQry(ByVal strComputer  )                                                                                                           
			  Set objWMIService = GetObject("winmgmts:\\" & strComputer  & "\root\cimv2")                                                 
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
			          strValue = strComputer   & vbTab & strValueIP & vbTab & strValueMac                                                                        
			          Wscript.Echo strValue                                                                                                                    
			          f.WriteLine strValue                                                                                                                     
			          f.WriteBlankLines(1)                                                                                                                     
			          'strValue = ""                                                                                                                           
			     end if                                                                                                                                        
			  next                                                                                                                                             
			  		'Error checking                                                                                                                              
					  If Err =0 Then                                                                                                                               
							'Wscript.Echo "Success:  Ran WMI query."                                                                                                   
						Else                                                                                                                                         
							f.Writeline "Failed:  WMI query, Err.#=  " & Err.Number & " -- " &  Err.Description                                                        
							Wscript.echo "Failed:  WMI query, Err.#=  " & Err.Number & " -- " &  Err.Description                                                       
							f.WriteBlankLines(1)                                                                                                                       
						End If                                                                                                                                       
						err.clear                                                                                                                                    
			'End sub	                                                                                                                                         
End Function                                                                                                                                             
'***************************************************************
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
Set MyFile =Nothing                                                                                                                                      
Set f =Nothing                                                                                                                                           
Set f2 =Nothing                                                                                                                                          
Set	objConnection = Nothing                                                                                                                              
Set objCommand = Nothing                                                                                                                                 
Set objRecordSet = Nothing                                                                                                                               
Set intTestOU = Nothing                                                                                                                                  
Set strComputer   =Nothing                                                                                                                                 
Set objFSO = Nothing     	                                                                                                                               
										                                                                                                                                     
		                                                                                                                                                     
											                                                                                                                                   


                                                                                     
                                                                                         
                                                                                         
                                                                                         