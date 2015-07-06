'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'
' File:     ConfigMe.vbs
' Updated:  April 2004
' Version:  1.0
' Author:   Dan Thomson, myITforum.com columnist
'           I can be contacted at dethomson@hotmail.com
'
' Purpose:  This script is designed to run at the end of the Sysprep process.
'           It will query a network database to determine how the systems
'           TCP/IP configuration and domain membership should be configured.
'           Once determined, this script will then configure the system
'           accordingly and initiate a system reboot (if required).
'
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

'**Start Encode**
' The line above exists if there is a desire to encode the script for security reasons.
' To encode the script, download the script encoder via the link below.
' http://www.msdn.microsoft.com/library/default.asp?url=/downloads/list/webdev.asp

On Error Resume Next

Const Database    = "SysInfo.mdb"         ' The name of the database to search for configuration data
Const Table       = "tblSysInfo"          ' Tha name of the table which contains configuration data
Const DataStore   = "\\Server\data"       ' The name of the share where the database can be found
Const MappedDrive = "U:"                  ' Map this drive letter to the share above

Const UserName    = "SomeUser"	          ' Use this username to join the domain and map the drive
Const Password    = "password"            ' Password for above user

Const ForAppending = 8      ' Used for File manipulation

Dim objFileSys              ' File system object
Dim objNetwork              ' Network object
Dim strSerialNumber         ' The serial number of the system to be configured
Dim strComputerName         ' New computer name
Dim strDomain               ' The name of the domain to be joined
Dim strOU                   ' The name of the OU where the account will be placed
Dim blnUseDHCP              ' True if this system will use DHCP
Dim strIPAddress            ' List of IP addresss which should be used
Dim strSubnetMask           ' List of Subnet masks which should be used
Dim strGateway              ' List of Gateways which should be used
Dim strDNSServers           ' List of DNS servers which should be used
Dim strWINS1                ' Primary WINS server
Dim strWINS2                ' Secondary WINS server
Dim strWinDir               ' Windows directory
Dim strLogFile              ' Log file
Dim blnRebootRequired       ' Is a reboot required?
Dim blnFatalError           ' True if a fatal error occurred in one of the procedures

' Set default values
blnRebootRequired = False   ' A reboot is NOT required
blnFatalError = False       ' A fatal error has not occurred

' Create standard object references
Set objFileSys = CreateObject("Scripting.FileSystemObject")
Set objNetwork = CreateObject("Wscript.Network")
Set objShell   = CreateObject("WScript.Shell")

' Get Windows directory
strWinDir = objShell.ExpandEnvironmentStrings("%WinDir%")

' Path and name of log file
strLogFile = strWinDir & "\Temp\SystemConfig.log"

' Open log file
Set objLogFile = objFileSys.OpenTextFile(strLogFile, ForAppending, True)

' Map a drive to the network share where the database resides. This
' mapping uses alternate credentials.
objLogFile.WriteLine "Mapping drive letter " & MappedDrive & " to " & DataStore
objLogFile.WriteLine ""
objNetwork.MapNetworkDrive MappedDrive, DataStore, false, UserName, Password

' Get the system serial number
strSerialNumber = GetSerialNumber()
If blnFatalError Then Call Cleanup      'Error check

' Get system configuration data
Call GetSystemData(MappedDrive & "\" & Database, Table, strSerialNumber)

' Unmap the mapped drive
objLogFile.WriteLine "UnMapping drive letter " & MappedDrive
objLogFile.WriteLine ""
objNetwork.RemoveNetworkDrive MappedDrive, True, True

If blnFatalError Then Call Cleanup      'Error check

' Configure system name if the current and new name differ
Call ChangeName(strComputerName)
If blnFatalError Then Call Cleanup      'Error check

' Configure TCP/IP settings
If blnUseDHCP Then
  objLogFile.WriteLine "This system is specified to use DHCP. No need to change IP configuration."
  If blnFatalError Then Call Cleanup    'Error check
Else
  Call ConfigStaticIP()
End If

' Configure domain membership
Call JoinDomain(strComputerName, strDomain, strOU, UserName, Password)
If blnFatalError Then Call Cleanup      'Error check

' Reboot?
If blnRebootRequired Then Call Reboot(6)  'Forced reboot

Call Cleanup()

'******************************************************************************
' Sub-routines
'******************************************************************************

'******************************************************************************
' Name: GetSerialNumber
'
' Purpose: Get the system serial number
'
' Inputs:  none
'
' Outputs: Returns the BIOS serial number of the local system
'
' Requirements: An SMBIOS 2 compliant BIOS
'               A windows OS with a current version of WMI installed
'******************************************************************************
Private Function GetSerialNumber()

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the GetSerialNumber procedure"

  Dim strComputer
  Dim objWMIService
  Dim colSMBIOS
  Dim objSMBIOS
  Dim strSerialNumber

  strComputer = "."
  Set objWMIService = GetObject("winmgmts:" _
      & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  Set colSMBIOS = objWMIService.ExecQuery _
      ("Select * from Win32_SystemEnclosure")
  For Each objSMBIOS in colSMBIOS
      strSerialNumber = objSMBIOS.SerialNumber
  Next

  If strSerialNumber = "" Then
    objLogFile.WriteLine vbTab & "Could not retrieve serial number"
    blnFatalError = True
  Else
    objLogFile.WriteLine vbTab & "Found serial number: " & strSerialNumber
    GetSerialNumber = strSerialNumber
  End If

  Set colSMBIOS = Nothing
  Set objWMIService = Nothing

End Function

'******************************************************************************
' Name: GetSystemData
'
' Purpose: Get the system configuration data from a database
'
' Inputs:  strDatabase      Name of the database to search for system
'                           configuration data
'          strTable         Name of the table in the database which contains
'                           the system configuration data
'          strSerialNumber  Serial number to be searched for in the database
'
' Outputs: strComputerName
'          strDomain
'          strOU
'          blnUseDHCP
'          strIPAddress
'          strSubnetMask
'          strGateway
'          strDNSServers
'          strWINS1
'          strWINS2
'
'******************************************************************************
Private Sub GetSystemData(strDatabase, strTable, strSerialNumber)

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the GetSystemData procedure"

  Const adOpenStatic = 3
  Const adLockOptimistic = 3

  Dim objConnection
  Dim objRecordSet
  Dim intNumRec

  Set objConnection = CreateObject("ADODB.Connection")
  Set objRecordSet = CreateObject("ADODB.Recordset")

  objLogFile.WriteLine vbTab & "Opening " & strDatabase

  objConnection.Open _
      "Provider = Microsoft.Jet.OLEDB.4.0; " & _
          "Data Source = " & strDatabase

  objLogFile.WriteLine vbTab & "Querying the database"

  objRecordSet.Open "SELECT * FROM " & strTable & _
      " WHERE SerialNumber = '" & strSerialNumber & "'", _
          objConnection, adOpenStatic, adLockOptimistic

  intNumRec = objRecordset.RecordCount
  'Wscript.Echo "Number of records: " & intNumRec

  If Not objRecordset.EOF Then
    If intNumRec = 1 Then
      objLogFile.WriteLine vbTab & "Successfully queried database...collecting system configuration data"
      strComputerName = objRecordset.Fields.Item("ComputerName")
      strDomain       = objRecordset.Fields.Item("Domain")
      strOU           = objRecordset.Fields.Item("OU")
      blnUseDHCP      = objRecordset.Fields.Item("UseDHCP")
      strIPAddress    = objRecordset.Fields.Item("IPAddress")
      strSubnetMask   = objRecordset.Fields.Item("Subnet")
      strGateway      = objRecordset.Fields.Item("Gateway")
      strDNSServers   = objRecordset.Fields.Item("DNS")
      strWINS1        = objRecordset.Fields.Item("Wins1")
      strWINS2        = objRecordset.Fields.Item("Wins2")
    Else
      blnFatalError = True
      objLogFile.WriteLine vbTab & "Too many records found."
    End If
  Else
    blnFatalError = True
    objLogFile.WriteLine vbTab & "No matching record found."
  End If

  objLogFile.WriteLine vbTab & "Closing " & strDatabase

  objRecordSet.Close
  objConnection.Close
  Set objRecordSet = Nothing
  Set objConnection = Nothing

End Sub

'******************************************************************************
' Name: ChangeName
'
' Purpose: Change the name of the system
'
' Input:   strComputerName = New name
'
' Outputs: Sets blnRebootRequired to True if the rename succeeds
'
' Requirements: Windows XP or newer OS
'
'******************************************************************************
Private Sub ChangeName(strComputerName)

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the ChangeName procedure"

  Dim strComputer
  Dim objWMIService
  Dim objComputer
  Dim intError

  strComputer = "."
  Set objWMIService = GetObject("winmgmts:" _
      & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

  For Each objComputer in objWMIService.InstancesOf("Win32_ComputerSystem")
    If UCase(objComputer.Name) = UCase(strComputerName) Then
      objLogFile.WriteLine vbTab & "No need to change computer name"
    Else
      objLogFile.WriteLine vbTab & "Attempting to rename system"
      intError = objComputer.Rename(strComputerName)
      objLogFile.WriteLine vbTab & GetWMIError(intError)
      ' Even though the WMI error message usually states that no reboot is
      ' required. One is definitely required to update all registry settings.
      If intError <= 1 Then
        blnRebootRequired = True
      Else
        blnFatalError = True
      End If
    End If
  Next

  Set objWMIService = Nothing

End Sub

'******************************************************************************
' Name: ConfigStaticIP
'
' Purpose: Configure the follwoing IP Address settings
'          IP Address, Subnet mask, Default Gateway
'          DNS server search list, WINS server list
'
' Inputs:  strIPAddress       A string of one or more valid IP Addresses
'                             Example: "192.168.0.45,192.168.0.46"
'          strSubnetMask      A string of one or more valid Subnet Masks
'                             Example: "255.255.255.0,255.255.255.0"
'          strGateway         A valid IP Gateway address
'                             Example: "192.168.0.1,192.168.0.2"
'          strDNSServers      A series of addresses to use for DNS queries.
'                             Example: "192.168.0.100,192.168.0.200"
'          strWINS1           The address of the primary WINS server
'          strWINS1           The address of the secondary WINS server
'
' Outputs: none
'
' Requirements: A windows OS with a current version of WMI installed
'******************************************************************************
Private Sub ConfigStaticIP()

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the ConfigStaticIP procedure"

  Dim strComputer
  Dim objWMIService
  Dim colNetAdapters
  Dim objNetAdapter
  Dim intError

  strComputer = "."

  ' Many of the inputs need to be formated as arrays.
  If Instr(strIPAddress, ",") Then
    arrIPAddress = Split(strIPAddress, ",", -1, 1)
  Else
    arrIPAddress = Array(strIPAddress)
  End If

  If Instr(strSubnetMask, ",") Then
    arrSubnetMask = Split(strSubnetMask, ",", -1, 1)
  Else
    arrSubnetMask = Array(strSubnetMask)
  End If

  If Instr(strGateway, ",") Then
    arrGateway = Split(strGateway, ",", -1, 1)
  Else
    arrGateway = Array(strGateway)
  End If

  If Instr(strDNSServers, ",") Then
    arrDNSServers = Split(strDNSServers, ",", -1, 1)
  Else
    arrDNSServers = Array(strDNSServers)
  End If

  Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
  Set colNetAdapters = objWMIService.ExecQuery _
      ("Select * from Win32_NetworkAdapterConfiguration where IPEnabled=TRUE")

  For Each objNetAdapter in colNetAdapters
    ' Config IP address(s) and Subnet Mask(s)
    objLogFile.WriteLine vbTab & "Configuring TCP/IP settings"

    If arrIPAddress(0) <> "" AND arrSubnetMask(0) <> "" Then
      intError = objNetAdapter.EnableStatic(arrIPAddress, arrSubnetMask)
      objLogFile.WriteLine vbTab & "IP Address(s): " & GetWMIError(intError)
      If intError > 1 Then blnFatalError = True
    End If

    If arrGateway(0) <> "" Then
      ' Config Gateway(s)
      intError = objNetAdapter.SetGateways(arrGateway)
      objLogFile.WriteLine vbTab & "Gateway(s): " & GetWMIError(intError)
      If intError > 1 Then blnFatalError = True
    End If

    If arrDNSServers(0) <> "" Then
      ' Config DNS
      intError = objNetAdapter.SetDNSServerSearchOrder(arrDNSServers)
      objLogFile.WriteLine vbTab & "DNS server search list: " & GetWMIError(intError)
      If intError > 1 Then blnFatalError = True
    End If

    If strWINS1 <> "" OR Not IsNull(strWINS1) Then
      ' Config WINS
      If IsNull(strWINS2) Then strWINS2 = ""

      intError = objNetAdapter.SetWINSServer(strWINS1, strWINS2)
      objLogFile.WriteLine vbTab & "WINS Primary & Secondary: " & GetWMIError(intError)
      If intError > 1 Then blnFatalError = True
    End If

  Next

End Sub

'******************************************************************************
' Name: JoinDomain
'
' Purpose: Join a system to a domain
'
' Inputs:  strComputer   Name of computer
'          strDomain     Name of domain which the system is to join
'          strOU         Name of OU where the computer account is to be placed
'          strUserName   Name of the user which is to be used for the join
'          strPassword   Password of the user used for the join
'
' Outputs: Sets blnRebootRequired to True if the join succeeds
'
' Requirements: Windows XP or newer OS
'
' Other: This procedure also sets the ActiveComputerName registry entry so that
'        the procedure uses the appropriate name during the join.
'
'******************************************************************************
Private Sub JoinDomain(strComputer, strDomain, strOU, strUserName, strPassword)

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the JoinDomain procedure"

  Const JOIN_DOMAIN             = 1
  Const ACCT_CREATE             = 2
  Const ACCT_DELETE             = 4
  Const WIN9X_UPGRADE           = 16
  Const DOMAIN_JOIN_IF_JOINED   = 32
  Const JOIN_UNSECURE           = 64
  Const MACHINE_PASSWORD_PASSED = 128
  Const DEFERRED_SPN_SET        = 256
  Const INSTALL_INVOCATION      = 262144

  Dim objWMIService
  Dim ibjComputer
  Dim intError

  Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")

  For Each objComputer in objWMIService.InstancesOf("Win32_ComputerSystem")

    If UCase(objComputer.Domain) = UCase(strDomain) Then
        objLogFile.WriteLine vbTab & "No need to change domain membership"
    Else
      objLogFile.WriteLine vbTab & "Attempting to update the ActiveComputerName"

      Set objShell = CreateObject("Wscript.Shell")
      Err.Clear
      objShell.RegWrite "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\" & _
                        "ComputerName\ActiveComputerName\ComputerName", _
                        strComputer, "REG_SZ"
      If Err.Number = 0 Then
        objLogFile.WriteLine vbTab & "Successfully updated the ActiveComputerName"
      Else
        objLogFile.WriteLine vbTab & "Error updating the ActiveComputerName"
        objLogFile.WriteLine vbTab & Err.Number & " " & Err.Description
        blnFatalError = True
      End If
      Set objShell = Nothing

      ' If strOU is blank then set it to NULL
      If strOU = "" Then strOU = NULL

      objLogFile.WriteLine vbTab & "Joining system to the " & strDomain & " domain"

      intError = objComputer.JoinDomainOrWorkGroup(strDomain, _
                                                   strPassword, _
                                                   strDomain & "\" & strUserName, _
                                                   strOU, _
                                                   JOIN_DOMAIN + ACCT_CREATE)
      objLogFile.WriteLine vbTab & GetWMIError(intError)
  
      ' Even though the WMI error message usually states that no reboot is required.
      ' One is definitely required to update.
      If intError <= 1 Then
        blnRebootRequired = True
      Else
        blnFatalError = True
      End If
    End If

  Next

  Set objWMIService = Nothing

End Sub

'******************************************************************************
' Name: Reboot
'
' Purpose: To reboot the system
'
' Inputs:  intMode   Shutdown mode
'                    (logoff or shutdown or reboot or poweroff and force)
'                       0          1          2           8          4
'
' Outputs: none
'
' Requirements: A windows OS with a current version of WMI installed
'******************************************************************************
Private Sub Reboot(intMode)

  On Error Resume Next

  objLogFile.WriteLine "-->Executing the Reboot procedure"

  Dim strComputer
  Dim objWMIService
  Dim colOperatinSystems
  Dim objOperatingSystem
  Dim intError
  Dim strMessage

  strComputer = "."
  Set objWMIService = GetObject("winmgmts:" _
      & "{impersonationLevel=impersonate,(Shutdown)}!\\" & _
          strComputer & "\root\cimv2")
  Set colOperatingSystems = objWMIService.ExecQuery _
      ("Select * from Win32_OperatingSystem")
  For Each objOperatingSystem in colOperatingSystems
      'objOperatingSystem.Reboot()

      objLogFile.WriteLine vbTab & "Initiating system reboot"
      'intError = objOperatingSystem.Win32ShutDown(intMode)

      IF intError = 0 Then
        objLogFile.WriteLine vbTab & "Successfully initiated reboot"
      Else
        objLogFile.WriteLine vbTab & "Failed to initiate reboot"
        objLogFile.WriteLine vbTab & GetWMIError(intError)
        blnFatalError = True
      End If
  Next

End Sub

'******************************************************************************
' Name: GetWMIError
'
' Purpose: Translate WMI error codes to text string
'
' Inputs:  intError   Error code returned from WMI method
'
' Outputs: Message which relates to the intError
'
' Requirements: A windows OS with a current version of WMI installed
'******************************************************************************
Function GetWMIError(intError)

  On Error Resume Next

  Select Case intError
    Case 0  : GetWMIError = "Successful completion, no reboot required."
    Case 1  : GetWMIError = "Successful completion, reboot required."
      blnRebootRequired = True
    Case 64 : GetWMIError = "Method not supported when the NIC is in DHCP mode."
    Case 65 : GetWMIError = "Unknown failure."
    Case 66 : GetWMIError = "Invalid subnet mask."
    Case 67 : GetWMIError = "An error occurred while processing an instance that was returned."
    Case 68 : GetWMIError = "Invalid input parameter."
    Case 69 : GetWMIError = "More than five gateways specified."
    Case 70 : GetWMIError = "Invalid IP address."
    Case 71 : GetWMIError = "Invalid gateway IP address."
    Case 72 : GetWMIError = "An error occurred while accessing the registry for the requested information."
    Case 73 : GetWMIError = "Invalid domain name."
    Case 74 : GetWMIError = "Invalid host name."
    Case 75 : GetWMIError = "No primary or secondary WINS server defined."
    Case 76 : GetWMIError = "Invalid file."
    Case 77 : GetWMIError = "Invalid system path."
    Case 78 : GetWMIError = "File copy failed."
    Case 79 : GetWMIError = "Invalid security parameter."
    Case 80 : GetWMIError = "Unable to configure TCP/IP service."
    Case 81 : GetWMIError = "Unable to configure DHCP service."
    Case 82 : GetWMIError = "Unable to renew DHCP lease."
    Case 83 : GetWMIError = "Unable to release DHCP lease."
    Case 84 : GetWMIError = "IP not enabled on adapter."
    Case 85 : GetWMIError = "IPX not enabled on adapter."
    Case 86 : GetWMIError = "Frame or network number bounds error."
    Case 87 : GetWMIError = "Invalid frame type."
    Case 88 : GetWMIError = "Invalid network number."
    Case 89 : GetWMIError = "Duplicate network number."
    Case 90 : GetWMIError = "Parameter out of bounds."
    Case 91 : GetWMIError = "Access denied."
    Case 92 : GetWMIError = "Out of memory."
    Case 93 : GetWMIError = "Already exists."
    Case 94 : GetWMIError = "Path, file, or object not found."
    Case 95 : GetWMIError = "Unable to notify service."
    Case 96 : GetWMIError = "Unable to notify DNS service."
    Case 97 : GetWMIError = "Interface not configurable."
    Case 98 : GetWMIError = "Not all DHCP leases can be released or renewed."
    Case 100 : GetWMIError = "DHCP not enabled on adapter."
    Case Else : GetWMIError = "Unknown error: " & intError
  End Select

End Function

'******************************************************************************
' Name: Cleanup
'
' Purpose: To cleanup existing objects prior to exiting
'
'******************************************************************************
Sub Cleanup()

  On Error Resume Next

  If blnFatalError Then objLogFile.WriteLine vbCrLf & "A fatal error occurred!"

  ' Close log file
  objLogFile.Close

  ' Cleanup
  Set objLogFile = Nothing
  Set objFileSys = Nothing
  Set objShell   = Nothing
  Set objNetwork = Nothing

  Wscript.Quit

End Sub
