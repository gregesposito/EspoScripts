FOR /F "usebackq" %%i IN (%1) DO @cscript %~dp0\NetComment.vbs %%i