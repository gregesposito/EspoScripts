'********************************************************
'Function Isnothing(strComputer)
'Nothing is the equivalent of Null for an object reference so, 
'you would want to use them after GetObject, CreateObject..
On Error Resume Next
strComputer = "triton"
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
If objWMIService Is Nothing Then
    WScript.Echo "Unable to bind to WMI on " & strComputer
Else
    WScript.Echo "Successfully bound to WMI on " & strComputer
End If
'End Function
'********************************************************