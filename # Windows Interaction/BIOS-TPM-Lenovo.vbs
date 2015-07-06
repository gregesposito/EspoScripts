On Error Resume Next

Dim wsh

Sub WriteInfo(str)
	objTextFile.WriteLine str
	WScript.Echo str
End Sub

OK = FALSE

Set wsh = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
logFN = objFSO.BuildPath(wsh.ExpandEnvironmentStrings("%TEMP%"), "TurnOnTPM.log")
Set objTextFile = objFSO.CreateTextFile(logFN, True)

Set objWMIService = GetObject("WinMgmts:{ImpersonationLevel=Impersonate}!\\.\root\wmi")
Err.Clear
Set colSetItems = objWMIService.ExecQuery("Select * from Lenovo_SetBiosSetting")

For Each objItem in colSetItems
	WriteInfo("Enabling TPM chip in BIOS...")
	ObjItem.SetBiosSetting "SecurityChip,Active;", strReturn
Next

If (Err.Number = 0) Or (strReturn = "Success") Then
	WriteInfo("TPM chip enabled successfully.")
	strReturn = "error"
	Set colSaveItems = objWMIService.ExecQuery("Select * from Lenovo_SaveBiosSettings")

	For Each objItem in colSaveItems
		WriteInfo("Saving BIOS settings....")
   		ObjItem.SaveBiosSettings ";", strReturn
	Next
			
	If (Err.Number = 0) Or (strReturn = "Success") Then
		WriteInfo("BIOS settings saved successfully.")
		OK = True
	Else
	WriteInfo("Failed to save BIOS settings.")
	End If
Else
	WriteInfo("Cannot enable TPM chip in BIOS.")
End If

If Not OK Then
	WriteInfo("Operation failed.")
	WScript.Quit(1)
End If

objTextFile.Close