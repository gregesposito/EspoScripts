Function BytesToString(ByVal Bytes)
  Dim Result, N
  Result = ""
  For N = 0 To UBound(Bytes)
    If CInt(Bytes(N)) <> 0 Then
      Result = Result & Chr(Bytes(N))
    Else
      Exit For
    End If
  Next
  BytesToString = Result
End Function
 
Dim WMI, Monitors, Output, Monitor
Set WMI = GetObject("winmgmts:{impersonationlevel=impersonate}!root/wmi")
Set Monitors = WMI.InstancesOf("WmiMonitorID")
Output = ""
For Each Monitor In Monitors
  If Output <> "" Then
    Output = vbNewLine & Output
  End If
  Output = Output _
    & "Active: " & CStr(Monitor.Active) & vbNewLine _
    & "InstanceName: " & Monitor.InstanceName & vbNewLine _
    & "ManufacturerName: " & BytesToString(Monitor.ManufacturerName) & vbNewLine _
    & "ProductCodeID: " & BytesToString(Monitor.ProductCodeID) & vbNewLine _
    & "SerialNumberID: " & BytesToString(Monitor.SerialNumberID) & vbNewLine _
    & "UserFriendlyName: " & BytesToString(Monitor.UserFriendlyName) & vbNewLine _
    & "WeekOfManufacture: " & CStr(Monitor.WeekOfManufacture) & vbNewLine _
    & "YearOfManufacture: " & CStr(Monitor.YearOfManufacture)
Next
 
WScript.Echo Output
