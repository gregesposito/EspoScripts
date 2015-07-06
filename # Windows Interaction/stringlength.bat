SET /P asset_tag1="Enter the StopTheft asset tag number: "
REM Set the value of temporary variable to the value of "string" variable
SET temp_str=%asset_tag1%
REM Initialize counter
SET str_len=0

:loop
if defined temp_str (
REM Remove the first character from the temporary string variable and increment 
REM counter by 1. Countinue to loop until the value of temp_str is empty string.
    SET temp_str=%temp_str:~1%
    SET /A str_len += 1
    GOTO loop
)

REM Echo the actual string value and its length.
ECHO %string% is %str_len% characters long!
pause