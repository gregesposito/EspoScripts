@Echo off
:start
Echo. Please insert IP
set /p IP=
Echo. Please insert Exe Name -c if you want to run
seT /p cmd=

user1= administrator1
password1= password1

user2= administrator2
password2= password2

user3= administrator3
password3= password3




psexec \\%ip% -f -u %user1% -p %password1% -c "%cmd%"
if Not %ERRORLEVEL%==0 goto next
goto end

:next
psexec \\%ip% -f -u %user2% -p %password2% -c "%cmd%"
if Not %ERRORLEVEL%==0 goto next1
goto end

:next1
psexec \\%ip% -f -u %user3% -p %password3% -c "%cmd%"

:end  
goto start
exit