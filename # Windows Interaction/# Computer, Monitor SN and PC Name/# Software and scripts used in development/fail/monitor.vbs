
'''''''''''''''''''''''''''
' Monitor EDID Information'
'''''''''''''''''''''''''''
'*****************************************************************************************
'17 June 2004
'coded by Michael Baird
'
'and released under the terms of GNU open source license agreement
'(that is of course if you CAN release code that uses WMI under GNU)
'
'Please give me credit if you use my code

'this code is based on the EEDID spec found at http://www.vesa.org
'and by my hacking around in the windows registry
'the code was tested on WINXP,WIN2K and WIN2K3
'it should work on WINME and WIN98SE
'It should work with multiple monitors, but that hasn't been tested either.
'*****************************************************************************************
'
'*****************************************************************************************
'It should be noted that this is not 100% reliable
'I have witnessed occasions where for one reason or another windows
'can't or doesn't read the EDID info at boot (example would be someone
'booting with the monitor turned off) and so windows changes the active
'monitor to "Default_Monitor"
'Another reason for reliability problems is that there is no
'requirement in the EDID spec that a manufacture include the
'serial number in the EDID data AND only EDIDv1.2 and beyond 
'have a requirement that the EDID contain a descriptive
'model name
'That being said, here goes....
'*****************************************************************************************
'
'*****************************************************************************************
'Monitors are stored in HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\
'
'Unfortunately, not only monitors are stored here Video Chipsets and maybe some other stuff
'is also here.
'
'Monitors in "HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\" are organized like this:
' HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\<VESA_Monitor_ID>\<PNP_ID>\
'Since not only monitors will be found under DISPLAY sub key you need to find out which
'devices are monitors.
'This can be deterimined by looking at the value "HardwareID" located
'at HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\<VESA_Monitor_ID\<PNP_ID>\
'if the device is a monitor then the "HardwareID" value will contain the data "Monitor\<VESA_Monitor_ID>"
'
'The next difficulty is that all monitors are stored here not just the one curently plugged in.
'So, if you ever switched monitors the old one(s) will still be in the registry.
'You can tell which monitor(s) are active because they will have a sub-key named "Control"
'*****************************************************************************************
'
strComputer="."
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
'HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\<VESA_Monitor_ID\
'we need to dive in one more level and check the data of the "HardwareID" value
    sBaseKey2 = sBaseKey & sKey & "\"
    iRC2 = oRegistry.EnumKey(HKLM, sBaseKey2, arSubKeys2)
    For Each sKey2 In arSubKeys2
'now we are at the level of:
'HKLM\SYSTEM\CurrentControlSet\Enum\DISPLAY\<VESA_Monitor_ID\<PNP_ID>\
'so we can check the "HardwareID" value
        oRegistry.GetMultiStringValue HKLM, sBaseKey2 & sKey2 & "\", "HardwareID", sValue
        for tmpctr=0 to ubound(svalue)
            if lcase(left(svalue(tmpctr),8))="monitor\" then
'if it is a monitor we will check for the existance of a control subkey
'that way we know it is an active monitor
sBaseKey3 = sBaseKey2 & sKey2 & "\"
iRC3 = oRegistry.EnumKey(HKLM, sBaseKey3, arSubKeys3)
For Each sKey3 In arSubKeys3
if skey3="Control" then
'if the Control sub-key exists then we should read the edid info
oRegistry.GetBinaryValue HKLM, sbasekey3 & "Device Parameters\", "EDID", arrintEDID
             if vartype(arrintedid) <> 8204 then 'and if we don't find it...
strRawEDID="EDID Not Available" 'store an "unavailable message
else
for each bytevalue in arrintedid 'otherwise conver the byte array from the registry into a string (for easier processing later)
strRawEDID=strRawEDID & chr(bytevalue)
next
end if
'now take the string and store it in an array, that way we can support multiple monitors
redim preserve strarrRawEDID(intMonitorCount)
strarrRawEDID(intMonitorCount)=strRawEDID
intMonitorCount=intMonitorCount+1
end if
next
            end if
        next
        
    Next 
Next
'*****************************************************************************************
'now the EDID info for each active monitor is stored in an array of strings called strarrRawEDID
'so we can process it to get the good stuff out of it which we will store in a 5 dimensional array
'called arrMonitorInfo, the dimensions are as follows:
'0=VESA Mfg ID, 1=VESA Device ID, 2=MFG Date (M/YYYY),3=Serial Num (If available),4=Model Descriptor
'5=EDID Version
'*****************************************************************************************
dim arrMonitorInfo()
redim arrMonitorInfo(intMonitorCount-1,5)
dim location(3)
for tmpctr=0 to intMonitorCount-1
if strarrRawEDID(tmpctr) <> "EDID Not Available" then
'*********************************************************************
'first get the model and serial numbers from the vesa descriptor
'blocks in the edid. the model number is required to be present
'according to the spec. (v1.2 and beyond)but serial number is not
'required. There are 4 descriptor blocks in edid at offset locations
'&H36 &H48 &H5a and &H6c each block is 18 bytes long
'*********************************************************************
location(0)=mid(strarrRawEDID(tmpctr),&H36+1,18)
location(1)=mid(strarrRawEDID(tmpctr),&H48+1,18)
location(2)=mid(strarrRawEDID(tmpctr),&H5a+1,18)
location(3)=mid(strarrRawEDID(tmpctr),&H6c+1,18)
    
'you can tell if the location contains a serial number if it starts with &H00 00 00 ff
strSerFind=chr(&H00) & chr(&H00) & chr(&H00) & chr(&Hff)
'or a model description if it starts with &H00 00 00 fc
strMdlFind=chr(&H00) & chr(&H00) & chr(&H00) & chr(&Hfc)
    
intSerFoundAt=-1
intMdlFoundAt=-1
for findit = 0 to 3
if instr(location(findit),strSerFind)>0 then
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
wscript.echo "Monitor " & chr(tmpctr+65) & ")"
wscript.echo ".........." & "VESA Manufacturer ID= " & arrMonitorInfo(tmpctr,0)
wscript.echo ".........." & "Device ID= " & arrMonitorInfo(tmpctr,1)
wscript.echo ".........." & "Manufacture Date= " & arrMonitorInfo(tmpctr,2)
wscript.echo ".........." & "Serial Number= " & arrMonitorInfo(tmpctr,3)
wscript.echo ".........." & "Model Name= " & arrMonitorInfo(tmpctr,4)
wscript.echo ".........." & "EDID Version= " & arrMonitorInfo(tmpctr,5)
next