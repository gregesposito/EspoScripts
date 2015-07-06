' . "My Workstation"
Option Explicit

Const HKLM = &H80000002
Dim ChangeValue, ComputerName, Value
ChangeValue = false
Select Case WScript.Arguments.UnNamed.Count
	Case 0	ComputerName = "."
	Case 1
		ComputerName = WScript.Arguments.UnNamed(0)
	Case 2
		ComputerName = WScript.Arguments.UnNamed(0)
		ChangeValue = True
		Value = Trim(WScript.Arguments.UnNamed(1))
	Case Else
		WScript.Echo "run with computername and (optional) " _
			& "new description in doublequotes. Note: " _
			& " - ""."" refers to the local computer." _
			& vbLf & " - if no description is provided, script " _
			& "returns the current description."
		WScript.Quit
End Select

' If we can't find the computer, tell them and quit
On Error Resume Next
Dim reg: Set reg = GetObject("winmgmts:\\" _ 
    & ComputerName & "\root\default:StdRegProv")
If Err.Number <> 0 Then
	WScript.Echo ComputerName & vbCrLf & "0x" & Hex(Err.Number) _
		& vbcrLf & Err.Description
	WScript.Quit Err.Number
End If
On Error Goto 0

Dim key
key = "SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
Dim ValueName: ValueName = "srvcomment"



Dim ret, msg

If ChangeValue Then
	' Chop overlong values
	If Len(Value) > 48 Then Value = Left(Value, 48)
	ret = reg.SetStringValue( _
		HKLM, key, ValueName, value)
Else
	ret = reg.GetStringValue( _
		HKLM, key, ValueName, value)
	' set null values to an empty string for display
	If VarType(value) = vbNull Then value = ""
	msg = ComputerName & " = " & value
End If

If ret <> 0 Then
	' If we don't already have a computer name in the message,
	' we want to set one.
	if Len(msg) = 0 Then msg = ComputerName _
	& " comment could not be set."
	msg = msg & vbCrLf & "   warning: net error "  & ret
End If
WScript.Echo msg
WScript.Quit( ret )