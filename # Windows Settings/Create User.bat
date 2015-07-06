echo '$Firstname=Read-Host "Please enter a Firstname"' > c:\createusers.ps1
echo '$Lastname=Read-Host "Please enter a Lastname"' >> c:\createusers.ps1
echo 'echo "$Firstname,$Lastname" > c:\users.csv' >> c:\createusers.ps1
echo '# Comment out above lines with # and edit c:\users.csv for multiple users' >> c:\createusers.ps1
echo ' ' >> c:\createusers.ps1
echo 'Import-Module ActiveDirectory' >> c:\createusers.ps1
echo '$csvfile = Import-CSV -Path c:\users.csv -Header @("Firstname","Lastname")' >> c:\createusers.ps1
echo 'foreach ($user in $csvfile)' >> c:\createusers.ps1
echo '{' >> c:\createusers.ps1
echo 'New-ADUser `' >> c:\createusers.ps1
echo ' -AccountPassword (ConvertTo-SecureString -AsPlainText "D3faultP0ss" -Force) `' >> c:\createusers.ps1
echo ' -Name $user.Firstname `' >> c:\createusers.ps1
echo ' -givenname $user.Firstname `' >> c:\createusers.ps1
echo ' -surname $user.Lastname `' >> c:\createusers.ps1
echo ' -Enabled $true `' >> c:\createusers.ps1
echo ' -DisplayName ($user.Firstname +” “+$user.Lastname) `' >> c:\createusers.ps1
echo ' -SamAccountName $user.Firstname `' >> c:\createusers.ps1
echo ' -userprincipalname ($user.Firstname + “@itedge.com.au”) `' >> c:\createusers.ps1
echo ' -ChangePasswordAtLogon $true `' >> c:\createusers.ps1
echo ' -HomeDrive "H:" `' >> c:\createusers.ps1
echo ' -HomeDirectory "\\serv2008r2\home\$($user.Firstname)" `' >> c:\createusers.ps1
echo ' -Path “OU=edgeusers,DC=itedge,DC=com,DC=au”' >> c:\createusers.ps1
echo ' }' >> c:\createusers.ps1
echo ' ' >> c:\createusers.ps1
echo 'mkdir "c:\home\$($user.Firstname)"' >> c:\createusers.ps1
echo ' icacls "c:\home\$($user.Firstname)" /grant "$($user.Firstname):(OI)(CI)M"' >> c:\createusers.ps1
echo ' $User1 = Get-ADUser -Identity "$($user.Firstname)"' >> c:\createusers.ps1
echo ' Add-ADGroupMember -Identity "Accounting" -Member "$User1"' >> c:\createusers.ps1
echo '}' >> c:\createusers.ps1