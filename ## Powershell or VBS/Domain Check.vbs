option explicit

dim shell
dim compsys, wmi, wql, results, string

set shell = CreateObject("WScript.Shell")

set wmi = getobject("winmgmts:") 
wql = "select * from win32_computersystem" 
set results = wmi.execquery(wql) 

For each compsys in results 
string = compsys.domain
string = "dc=" & compsys.domain
string = replace(string, ".", ",dc=")
shell.regwrite "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Domain", string, "REG_SZ"
Next 