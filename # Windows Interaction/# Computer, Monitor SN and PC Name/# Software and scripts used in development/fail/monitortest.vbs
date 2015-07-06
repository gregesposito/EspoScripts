'Give system Info for a PC

On Error Resume Next

do while strcomputer = "" and a < 2 
strcomputer = Inputbox ("Please enter the Computer name","Remote Computer Information Display","Hostmane is preferred search method") 
strcomputer = trim(strcomputer) 
a = a + 1 

loop 
if not strComputer <> "" then 
wscript.echo "No computer name entered, ending script" 
wscript.quit 
end if

On Error Resume Next 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
if err.number <> 0 then 
if err.number = -2147217405 then 
wscript.echo "You do not have sufficient access rights to this computer" 
wscript.quit 
else 
wscript.echo "Could not locate computer" &vbcrlf& "Please check IP Address/Computer Name and try again" 
wscript.quit 
end if 
end if

On Error Resume Next 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")

if err.number <> 0 then 
if err.number = -2147217405 then 
wscript.echo "You do not have sufficient access rights to this computer" 
wscript.quit 
else 
wscript.echo "Could not locate computer" &vbcrlf& "Please check IP Address/Computer Name and try again" 
wscript.quit 
end if 
end if 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS") 
Set colItems1 = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem") 
Set colItems2 = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True") 
Set colitems3 = objWMIService.ExecQuery("SELECT * FROM Win32_computersystem") 
Set colitems4 = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkLoginProfile") 
Set colitems5 = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk Where DriveType = 3")

Set colitems6 = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration")

Dim strComputer, VerOS, VerBig, Ver9x, Version9x, OS, OSystem

Set objWMI = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colItems = objWMI.ExecQuery("Select * from Win32_OperatingSystem",,48)

For Each objItem in colItems 
VerBig = Left(objItem.Version,3) 
Next 
Select Case VerBig 
Case "5.0" OSystem = "Windows 2000 So No RDP" 
Case "5.1" OSystem = "XP So RDP Will Work" 
Case "5.2" OSystem = "Windows 2003" 
Case "4.0" OSystem = "NT 4.0" 
Case Else OSystem = "Unknown (Win9x perhaps?)" 
End Select

objDocument.Writeln "Current value of ram==>" & ram & "<== " 
objDocument.Writeln "Monitor " & chr(tmpctr+65) & "" 
objDocument.Writeln "VESA Manufacturer ID= " & arrMonitorInfo(tmpctr,0) & "" 
objDocument.Writeln "Device ID= " & arrMonitorInfo(tmpctr,1) & "" 
objDocument.Writeln "Manufacture Date= " & arrMonitorInfo(tmpctr,2) & "" 
objDocument.Writeln "Serial Number= " & arrMonitorInfo(tmpctr,3) & "" 
objDocument.Writeln "Model Name= " & arrMonitorInfo(tmpctr,4) & "" 
objDocument.Writeln "EDID Version= " & arrMonitorInfo(tmpctr,5) & ""

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS") 
Set colItems1 = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem") 
Set colItems2 = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True") 
Set colitems3 = objWMIService.ExecQuery("SELECT * FROM Win32_computersystem") 
Set colitems4 = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkLoginProfile") 
Set colitems5 = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk Where DriveType = 3")

For Each objItem in colItems1 
ram = objItem.model

Next 
Select Case Trim(ram) 
Case "OptiPlex 760" 
ram = "DDR2" 
Case "OptiPlex GX240" 
ram = "SDRAM"	
Case "Dell Latitude D620" 
ram = "DDR2 SDRAM SODIMM" 
Case "OptiPlex 745" 
ram = "DDR2 " 
Case "OptiPlex GX270" 
ram = "DDR" 
Case "OptiPlex SX260" 
ram = "DDR" 
Case "OptiPlex GX620" 
ram = "DDR2"



Case Else 
ram = "Unknown Ram Type " 
End Select

Set objExplorer = CreateObject("InternetExplorer.Application") 
objExplorer.Navigate "about:blank" 
objExplorer.ToolBar = 0 
objExplorer.StatusBar = 0 
objExplorer.Width = 800 
objExplorer.Height = 600 
objExplorer.Left = 100 
objExplorer.Top = 100 
objExplorer.Visible = 1

Do While (objExplorer.Busy) 
Loop

Set objWMIService = GetObject("winmgmts:" _ 
& "{impersonationLevel=impersonate}!\\" _ 
& strComputer & "\root\cimv2") 
Set colComputer = objWMIService.ExecQuery _ 
("Select * from Win32_ComputerSystem")

Set objDocument = objExplorer.Document 
objDocument.Open

objDocument.Writeln "STH Remote Computer Information" 
objDocument.Writeln "" 
objExplorer.Document.Body.InnerHTML = " "

' Computer Detals

For Each objItem In colItems 
serial = objitem.serialnumber 
next 
For Each objItem In colItems1 
hostname = objitem.caption 
make = objitem.manufacturer 
model = objitem.model 
intRamMB = int((objitem.TotalPhysicalMemory) /1048576)+1

next

On Error Resume Next 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2") 
Set colItems = objWMIService.ExecQuery("Select * from Win32_Processor") 
For Each objItem in colItems 


procname = objItem.Name

Next

Set objWMIService = GetObject("winmgmts:" _ 
& "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
Set colBIOS = objWMIService.ExecQuery _ 
("Select * from Win32_BIOS") 
For each objBIOS in colBIOS 
Wbiosversion = objBIOS.Version 
Next

objDocument.Writeln "This is Version 12 18/05/10 " 
objDocument.Writeln "Computer Information For: " & Ucase(hostname) & "" 
objDocument.Writeln "Serial : " & Serial & "" 
objDocument.Writeln "Make : " & make & "" 
objDocument.Writeln "Model : " & Model & "" 
objDocument.Writeln "The O/S is " & OSystem &" " 
objDocument.Writeln "The Type Of RAM is: " & ram &" " 
objDocument.Writeln "The Amount Of RAM is: " & intRamMB & "MB " 
objDocument.Writeln "The Proccesor is: " & procname & " " 
objDocument.Writeln "The Bios Version is: " & wbiosversion & " "

For Each objItem In colItems5 
driveletter = objitem.name 
capacity = ((objitem.size / 1024) / 1024) / 1024 
free = ((objitem.FreeSpace / 1024) / 1024) / 1024 
free = FormatNumber (free,2) 
capacity = FormatNumber (capacity,2) 
objDocument.Writeln "Capacity of " &driveletter& " - " & capacity & "GB" 
objDocument.Writeln "Free Space on " &driveletter& " - " & Free & "GB" 
objDocument.Writeln "View Shares "

next

objDocument.Writeln "Please Wait, gathering more information..."

' User Details

For Each objItem In colItems3 
loggedon = objitem.username 
next 
For Each objItem In colItems4 
cachedlog = objitem.name 
username = objitem.FullName 
trimuser = mid(loggedon,5)

passwordexpire = objitem.passwordexpires 
badpassword = objitem.badpasswordcount 
if loggedon = cachedlog then 
objDocument.Writeln "User Information For..." 
objDocument.Writeln "" & username & "" 
objDocument.Writeln " User Name :" & loggedon &"" 
objDocument.Writeln "Email The user " 
objDocument.Writeln " Incorrect Password Attempts : " & badpassword &"" 
on error resume next 
Set objaccount = GetObject("WinNT://**********/"; &objitem.caption & ",user") 
if Err.Number <> 0 Then 
objDocument.Writeln "unable to retrieve password expiration information" 
Else 
If objAccount.PasswordExpired = 1 Then 
objDocument.Writeln "Password has Expired!" 
Else 
objDocument.Writeln "Password Expires " & objAccount.PasswordExpirationDate & " " 
end if 
end if 
end if 
next

objDocument.Writeln "Please Wait, gathering more information..."

dim strarrRawEDID() 
intMonitorCount=0 
Const HKLM = &H80000002 'HKEY_LOCAL_MACHINE 
'get a handle to the WMI registry object 
Set oRegistry = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "/root/default:StdRegProv") 
sBaseKey = "SYSTEM\CurrentControlSet\Enum\DISPLAY\" 
'enumerate all the keys HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\ 
iRC = oRegistry.EnumKey(HKLM, sBaseKey, arSubKeys) 
For Each sKey In arSubKeys 
'we are now in the registry at the level of: 
'HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\0 then 
intSerFoundAt=findit 
end if 
if instr(location(findit),strMdlFind)>0 then 
intMdlFoundAt=findit 
end if 
next

'if a location containing a serial number block was found then store it 
if intSerFoundAt<>-1 then 
tmp=right(location(intSerFoundAt),14) 
if instr(tmp,chr(&H0a))>0 then 
tmpser=trim(left(tmp,instr(tmp,chr(&H0a))-1)) 
else 
tmpser=trim(tmp) 
end if 
'although it is not part of the edid spec it seems as though the 
'serial number will frequently be preceeded by &H00, this 
'compensates for that 
if left(tmpser,1)=chr(0) then tmpser=right(tmpser,len(tmpser)-1) 
else 
tmpser="Serial Number Not Found in EDID data" 
end if

'if a location containing a model number block was found then store it 
if intMdlFoundAt<>-1 then 
tmp=right(location(intMdlFoundAt),14) 
if instr(tmp,chr(&H0a))>0 then 
tmpmdl=trim(left(tmp,instr(tmp,chr(&H0a))-1)) 
else 
tmpmdl=trim(tmp) 
end if 
'although it is not part of the edid spec it seems as though the 
'serial number will frequently be preceeded by &H00, this 
'compensates for that 
if left(tmpmdl,1)=chr(0) then tmpmdl=right(tmpmdl,len(tmpmdl)-1) 
else 
tmpmdl="Model Descriptor Not Found in EDID data" 
end if

'************************************************************** 
'next get the mfg date 
'************************************************************** 
'the week of manufacture is stored at EDID offset &H10 
tmpmfgweek=asc(mid(strarrRawEDID(tmpctr),&H10+1,1))

'the year of manufacture is stored at EDID offset &H11 
'and is the current year -1990 
tmpmfgyear=(asc(mid(strarrRawEDID(tmpctr),&H11+1,1)))+1990

'store it in month/year format 
tmpmdt=month(dateadd("ww",tmpmfgweek,datevalue("1/1/" & tmpmfgyear))) & "/" & tmpmfgyear

'************************************************************** 
'next get the edid version 
'************************************************************** 
'the version is at EDID offset &H12 
tmpEDIDMajorVer=asc(mid(strarrRawEDID(tmpctr),&H12+1,1))

'the revision level is at EDID offset &H13 
tmpEDIDRev=asc(mid(strarrRawEDID(tmpctr),&H13+1,1))

'store it in month/year format 
tmpver=chr(48+tmpEDIDMajorVer) & "." & chr(48+tmpEDIDRev)

'************************************************************** 
'next get the mfg id 
'************************************************************** 
'the mfg id is 2 bytes starting at EDID offset &H08 
'the id is three characters long. using 5 bits to represent 
'each character. the bits are used so that 1=A 2=B etc.. 
' 
'get the data 
tmpEDIDMfg=mid(strarrRawEDID(tmpctr),&H08+1,2) 
Char1=0 : Char2=0 : Char3=0 
Byte1=asc(left(tmpEDIDMfg,1)) 'get the first half of the string 
Byte2=asc(right(tmpEDIDMfg,1)) 'get the first half of the string 
'now shift the bits 
'shift the 64 bit to the 16 bit 
if (Byte1 and 64) > 0 then Char1=Char1+16 
'shift the 32 bit to the 8 bit 
if (Byte1 and 32) > 0 then Char1=Char1+8 
'etc.... 
if (Byte1 and 16) > 0 then Char1=Char1+4 
if (Byte1 and 8) > 0 then Char1=Char1+2 
if (Byte1 and 4) > 0 then Char1=Char1+1

'the 2nd character uses the 2 bit and the 1 bit of the 1st byte 
if (Byte1 and 2) > 0 then Char2=Char2+16 
if (Byte1 and 1) > 0 then Char2=Char2+8 
'and the 128,64 and 32 bits of the 2nd byte 
if (Byte2 and 128) > 0 then Char2=Char2+4 
if (Byte2 and 64) > 0 then Char2=Char2+2 
if (Byte2 and 32) > 0 then Char2=Char2+1

'the bits for the 3rd character don't need shifting 
'we can use them as they are 
Char3=Char3+(Byte2 and 16) 
Char3=Char3+(Byte2 and 8) 
Char3=Char3+(Byte2 and 4) 
Char3=Char3+(Byte2 and 2) 
Char3=Char3+(Byte2 and 1) 
tmpmfg=chr(Char1+64) & chr(Char2+64) & chr(Char3+64)

'************************************************************** 
'next get the device id 
'************************************************************** 
'the device id is 2bytes starting at EDID offset &H0a 
'the bytes are in reverse order. 
'this code is not text. it is just a 2 byte code assigned 
'by the manufacturer. they should be unique to a model 
tmpEDIDDev1=hex(asc(mid(strarrRawEDID(tmpctr),&H0a+1,1))) 
tmpEDIDDev2=hex(asc(mid(strarrRawEDID(tmpctr),&H0b+1,1))) 
if len(tmpEDIDDev1)=1 then tmpEDIDDev1="0" & tmpEDIDDev1 
if len(tmpEDIDDev2)=1 then tmpEDIDDev2="0" & tmpEDIDDev2 
tmpdev=tmpEDIDDev2 & tmpEDIDDev1

'************************************************************** 
'finally store all the values into the array 
'************************************************************** 
arrMonitorInfo(tmpctr,0)=tmpmfg 
arrMonitorInfo(tmpctr,1)=tmpdev 
arrMonitorInfo(tmpctr,2)=tmpmdt 
arrMonitorInfo(tmpctr,3)=tmpser 
arrMonitorInfo(tmpctr,4)=tmpmdl 
arrMonitorInfo(tmpctr,5)=tmpver 
end if 
next 
'For now just a simple screen print will suffice for output. 
'But you could take this output and write it to a database or a file 
'and in that way use it for asset management. 
for tmpctr=0 to intMonitorCount-1

objDocument.Writeln "Monitor Details..."

objDocument.Writeln "Monitor " & chr(tmpctr+65) &"" 
objDocument.Writeln "VESA Manufacturer ID " & arrMonitorInfo(tmpctr,0) &"" 
objDocument.Writeln "Device ID " & arrMonitorInfo(tmpctr,1) &"" 
objDocument.Writeln "Manufacture Date: "& arrMonitorInfo(tmpctr,2)&"" 
objDocument.Writeln "Serial Number "& arrMonitorInfo(tmpctr,3)&"" 
objDocument.Writeln "Model Name: "& arrMonitorInfo(tmpctr,4)&"" 
objDocument.Writeln "EDID Version: "& arrMonitorInfo(tmpctr,5)&""


next

objDocument.Writeln "Script Finished"