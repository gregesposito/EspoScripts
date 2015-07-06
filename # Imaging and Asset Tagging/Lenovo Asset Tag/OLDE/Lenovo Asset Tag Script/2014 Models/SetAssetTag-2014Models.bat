@ECHO OFF
:GET_INPUT
SET /P asset_tag="Enter the asset tag number, jeebo: "
SET /P response="Your asset tag is %asset_tag%. Is that right (y/n) "
IF /i {%response%}=={n} GOTO GET_INPUT
WinAIA.exe -set "USERASSETDATA.ASSET_NUMBER=%asset_tag%"
REM DEL %asset_tag%
pause