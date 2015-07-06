VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Monitor EDID Information"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4245
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4245
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Text6 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   11
      Top             =   1920
      Width           =   855
   End
   Begin VB.TextBox Text5 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   9
      Top             =   1560
      Width           =   1095
   End
   Begin VB.TextBox Text4 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   7
      Top             =   1200
      Width           =   2055
   End
   Begin VB.TextBox Text3 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   5
      Top             =   840
      Width           =   855
   End
   Begin VB.TextBox Text2 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   3
      Top             =   480
      Width           =   1215
   End
   Begin VB.TextBox Text1 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   1800
      TabIndex        =   1
      Top             =   120
      Width           =   2295
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Right Justify
      Caption         =   "EDID Version:"
      Height          =   255
      Left            =   120
      TabIndex        =   10
      Top             =   1920
      Width           =   1575
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Right Justify
      Caption         =   "Model:"
      Height          =   255
      Left            =   120
      TabIndex        =   8
      Top             =   1560
      Width           =   1575
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Right Justify
      Caption         =   "Serial Number:"
      Height          =   255
      Left            =   120
      TabIndex        =   6
      Top             =   1200
      Width           =   1575
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Right Justify
      Caption         =   "Built Date:"
      Height          =   255
      Left            =   120
      TabIndex        =   4
      Top             =   840
      Width           =   1575
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Right Justify
      Caption         =   "Device ID:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   480
      Width           =   1575
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Right Justify
      Caption         =   "Manufacturer ID:"
      Height          =   255
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   1575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Form_Load()
'''''''''''''''''''''''''''
' Monitor EDID Information'
'''''''''''''''''''''''''''
'17 June 2004
'coded by Michael Baird
'
'Modified by Denny MANSART (27/07/2004)
'
'Modified by Patrick Fitchie (17/03/2005)
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

Dim Reg As New RegistryRoutines
Dim reg2 As New RegistryRoutines
Dim MonitorsCollection As New Collection
Dim EISAIDsCollection As New Collection
Dim DisplayKeys As New Collection
Dim Monitor As Variant
Dim EISAID As Variant
Dim DisplayKey As Variant
Dim Displays()
If GetOSData() = "XP" Then
    strDisplayBaseKey = "SYSTEM\CurrentControlSet\Enum\DISPLAY"
Else
    strDisplayBaseKey = "ENUM\Monitor"
End If
Set MonitorsCollection = Reg.EnumRegistryKeys(HKEY_LOCAL_MACHINE, strDisplayBaseKey)

intMonitorCount = 0
intDisplaySubKeysCount = 0
i = 0
' Deleting from strarrDisplaySubKeys "Default_Monitor" value
For Each Monitor In MonitorsCollection
    
    Set EISAIDsCollection = Reg.EnumRegistryKeys(HKEY_LOCAL_MACHINE, strDisplayBaseKey & "\" & Monitor)
    For Each EISAID In EISAIDsCollection
        Set DisplayKeys = Reg.EnumRegistryKeys(HKEY_LOCAL_MACHINE, strDisplayBaseKey & "\" & Monitor & "\" & EISAID)
        For Each DisplayKey In DisplayKeys
            If DisplayKey = "Control" Then
                reg2.hkey = HKEY_LOCAL_MACHINE
                reg2.KeyRoot = strDisplayBaseKey & "\" & Monitor
                reg2.Subkey = EISAID
                If LCase(Left(reg2.GetRegistryValue("HardwareID", ""), 8)) = "monitor\" Then
                    intdisplaycount = intdisplaycount + 1
                    ReDim Preserve Displays(intdisplaycount, 2)
                    Displays(intdisplaycount - 1, 0) = strDisplayBaseKey & "\" & Monitor & "\" & EISAID
                    reg2.Subkey = EISAID & "\Device Parameters"
                    Displays(intdisplaycount - 1, 1) = reg2.GetRegistryValue("EDID", "")
                    If VarType(Displays(intdisplaycount - 1, 1)) = 8209 Then
                        For Each strbytevalue In Displays(intdisplaycount - 1, 1)
                            strRAWEDID = strRAWEDID & Chr(strbytevalue)
                        Next
                        Displays(intdisplaycount - 1, 1) = strRAWEDID
                    Else
                        Displays(intdisplaycount - 1, 1) = "EDID Not Available"
                    End If
                End If
            End If
        Next
    Next
    
    For i = 0 To intdisplaycount - 1
        Debug.Print Displays(i, 0)
        Debug.Print Displays(i, 1)
    Next
Next

If intdisplaycount = 0 Then Exit Sub

'*****************************************************************************************
'now the EDID info For each active monitor is stored in an dictionnary of strings called oRawEDID
'so we can process it to get the good stuff out of it which we will store in a 5 dimensional array
'called arrMonitorInfo, the dimensions are as follows:
'0=VESA Mfg ID, 1=VESA Device ID, 2=MFG Date (M/YYYY),3=Serial Num (If available),4=Model Descriptor
'5=EDID Version
'*****************************************************************************************

Dim arrMonitorInfo()
ReDim arrMonitorInfo(intdisplaycount - 1, 5)
Dim location(3)

For i = 0 To intdisplaycount - 1

    If Displays(i, 1) <> "EDID Not Available" Then

        '*********************************************************************
        'first get the model and serial numbers from the vesa descriptor
        'blocks in the edid. the model number is required to be present
        'according to the spec. (v1.2 and beyond)but serial number is not
        'required. There are 4 descriptor blocks in edid at offset locations
        '&H36 &H48 &H5a and &H6c each block is 18 bytes long
        '*********************************************************************
        
        location(0) = Mid(Displays(i, 1), &H36 + 1, 18)
        location(1) = Mid(Displays(i, 1), &H48 + 1, 18)
        location(2) = Mid(Displays(i, 1), &H5A + 1, 18)
        location(3) = Mid(Displays(i, 1), &H6C + 1, 18)
        
        
        'you can tell If the location contains a serial number If it starts with &H00 00 00 ff
        strSerFind = Chr(&H0) & Chr(&H0) & Chr(&H0) & Chr(&HFF)
        
        'or a model description If it starts with &H00 00 00 fc
        strMdlFind = Chr(&H0) & Chr(&H0) & Chr(&H0) & Chr(&HFC)
        
        intSerFoundAt = -1
        intMdlFoundAt = -1

        For findit = 0 To 3
            If InStr(location(findit), strSerFind) > 0 Then
                intSerFoundAt = findit
            End If
            If InStr(location(findit), strMdlFind) > 0 Then
                intMdlFoundAt = findit
            End If
        Next

        'If a location containing a serial number block was found then store it
        If intSerFoundAt <> -1 Then
            tmp = Right(location(intSerFoundAt), 14)
            If InStr(tmp, Chr(&HA)) > 0 Then
                tmpser = Trim(Left(tmp, InStr(tmp, Chr(&HA)) - 1))
            Else
                tmpser = Trim(tmp)
            End If
        
            'although it is not part of the edid spec it seems as though the
            'serial number will frequently be preceeded by &H00, this
            'compensates For that
            If Left(tmpser, 1) = Chr(0) Then
                tmpser = Right(tmpser, Len(tmpser) - 1)
            Else
                tmpser = "Serial Number Not Found in EDID data"
            End If
        
            'If a location containing a model number block was found then store it
            If intMdlFoundAt <> -1 Then
                tmp = Right(location(intMdlFoundAt), 14)
                If InStr(tmp, Chr(&HA)) > 0 Then
                    tmpmdl = Trim(Left(tmp, InStr(tmp, Chr(&HA)) - 1))
                Else
                    tmpmdl = Trim(tmp)
                End If
        
                'although it is not part of the edid spec it seems as though the
                'serial number will frequently be preceeded by &H00, this
                'compensates For that
                If Left(tmpmdl, 1) = Chr(0) Then
                    tmpmdl = Right(tmpmdl, Len(tmpmdl) - 1)
                Else
                    tmpmdl = "Model Descriptor Not Found in EDID data"
                End If
        
                '**************************************************************
                'Next get the mfg date
                '**************************************************************
                'the week of manufacture is stored at EDID offset &H10
                tmpmfgweek = Asc(Mid(Displays(i, 1), &H10 + 1, 1))
                
                'the year of manufacture is stored at EDID offset &H11
                'and is the current year -1990
                tmpmfgyear = (Asc(Mid(Displays(i, 1), &H11 + 1, 1))) + 1990
                
                'store it in month/year format
                tmpmdt = Month(DateAdd("ww", tmpmfgweek, DateValue("1/1/" & tmpmfgyear))) & "/" & tmpmfgyear
                
                '**************************************************************
                'Next get the edid version
                '**************************************************************
                'the version is at EDID offset &H12
                tmpEDIDMajorVer = Asc(Mid(Displays(i, 1), &H12 + 1, 1))
                
                'the revision level is at EDID offset &H13
                tmpEDIDRev = Asc(Mid(Displays(i, 1), &H13 + 1, 1))
                
                'store it in month/year format
                If tmpEDIDMajorVer < 255 - 48 And tmpEDIDRev < 255 - 48 Then
                    tmpver = Chr(48 + tmpEDIDMajorVer) & "." & Chr(48 + tmpEDIDRev)
                Else
                    tmpver = "Not available"
                End If
        
                '**************************************************************
                'Next get the mfg id
                '**************************************************************
                'the mfg id is 2 bytes starting at EDID offset &H08
                'the id is three characters long. using 5 bits to represent
                'each character. the bits are used so that 1=A 2=B etc..
                '
                'get the data
                tmpEDIDMfg = Mid(Displays(i, 1), &H8 + 1, 2)
                
                Char1 = 0: Char2 = 0: Char3 = 0
                
                Byte1 = Asc(Left(tmpEDIDMfg, 1)) 'get the first half of the string
                Byte2 = Asc(Right(tmpEDIDMfg, 1)) 'get the first half of the string
                
                'now shift the bits
                'shift the 64 bit to the 16 bit
                If (Byte1 And 64) > 0 Then Char1 = Char1 + 16
                
                'shift the 32 bit to the 8 bit
                If (Byte1 And 32) > 0 Then Char1 = Char1 + 8
                
                'etc....
                If (Byte1 And 16) > 0 Then Char1 = Char1 + 4
                If (Byte1 And 8) > 0 Then Char1 = Char1 + 2
                If (Byte1 And 4) > 0 Then Char1 = Char1 + 1
                
                'the 2nd character uses the 2 bit and the 1 bit of the 1st byte
                If (Byte1 And 2) > 0 Then Char2 = Char2 + 16
                If (Byte1 And 1) > 0 Then Char2 = Char2 + 8
                
                'and the 128,64 and 32 bits of the 2nd byte
                If (Byte2 And 128) > 0 Then Char2 = Char2 + 4
                If (Byte2 And 64) > 0 Then Char2 = Char2 + 2
                If (Byte2 And 32) > 0 Then Char2 = Char2 + 1
                
                'the bits For the 3rd character don't need shifting
                'we can use them as they are
                Char3 = Char3 + (Byte2 And 16)
                Char3 = Char3 + (Byte2 And 8)
                Char3 = Char3 + (Byte2 And 4)
                Char3 = Char3 + (Byte2 And 2)
                Char3 = Char3 + (Byte2 And 1)
                
                tmpmfg = Chr(Char1 + 64) & Chr(Char2 + 64) & Chr(Char3 + 64)
        
                '**************************************************************
                'Next get the device id
                '**************************************************************
                'the device id is 2bytes starting at EDID offset &H0a
                'the bytes are in reverse order.
                'this code is not text. it is just a 2 byte code assigned
                'by the manufacturer. they should be unique to a model
                tmpEDIDDev1 = Hex(Asc(Mid(Displays(i, 1), &HA + 1, 1)))
                tmpEDIDDev2 = Hex(Asc(Mid(Displays(i, 1), &HB + 1, 1)))
                
                If Len(tmpEDIDDev1) = 1 Then tmpEDIDDev1 = "0" & tmpEDIDDev1
                If Len(tmpEDIDDev2) = 1 Then tmpEDIDDev2 = "0" & tmpEDIDDev2
                
                tmpdev = tmpEDIDDev2 & tmpEDIDDev1
        
                '**************************************************************
                'finally store all the values into the array
                '**************************************************************
                arrMonitorInfo(i, 0) = tmpmfg
                arrMonitorInfo(i, 1) = tmpdev
                arrMonitorInfo(i, 2) = tmpmdt
                arrMonitorInfo(i, 3) = tmpser
                arrMonitorInfo(i, 4) = tmpmdl
                arrMonitorInfo(i, 5) = tmpver
            End If
        End If
    End If


        Text1 = arrMonitorInfo(i, 0)
        Text2 = arrMonitorInfo(i, 1)
        Text3 = arrMonitorInfo(i, 2)
        Text4 = arrMonitorInfo(i, 3)
        Text5 = arrMonitorInfo(i, 4)
        Text6 = arrMonitorInfo(i, 5)



Next


End Sub

Public Function GetOSData() As String
On Error Resume Next
'Os Information
Dim Reg As New RegistryRoutines

Reg.hkey = HKEY_LOCAL_MACHINE
Reg.KeyRoot = "Software\Microsoft\Windows NT"
Reg.Subkey = "CurrentVersion"
strosversion = Reg.GetRegistryValue("CurrentVersion", "")
Debug.Print strosversion
If Left(strosversion, 1) = "5" Then
    GetOSData = "XP"
    Debug.Print "OS = XP"
Else
    GetOSData = "98"
    Debug.Print "OS = 98"
End If
End Function



