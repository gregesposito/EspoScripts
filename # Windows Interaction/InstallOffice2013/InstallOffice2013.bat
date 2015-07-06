setlocal 

REM ********************************************************************* 
REM Environment customization begins here. Modify variables below. 
REM ********************************************************************* 

REM Get ProductName from the Office product's core Setup.xml file, and then add "office14." as a prefix. 
set ProductName=Office15.Standard 

REM Set DeployServer to a network-accessible location containing the Office source files. 
set DeployServer=\\MyFileServer\Office2013 

REM Set ConfigFile to the configuration file to be used for deployment (required) 
set ConfigFile=\\MyFileServer\Office2013\Standard.WW\config.xml 

REM Set AdminFile to the .MSP file to be used for deployment 
set AdminFile=\\MyFileServer\Office2013\updates\Office2013.MSP 

REM Set LogLocation to a central directory to collect log files. 
set LogLocation=\\MyFileServer\Office2010LogFiles 

REM Uninstall 2007 Compatibility pack 
msiexec /qn /x {90120000-0020-0409-0000-0000000FF1CE} 

REM ********************************************************************* 
REM Deployment code begins here. Do not modify anything below this line. 
REM ********************************************************************* 

IF NOT "%ProgramFiles(x86)%"=="" (goto ARP64) else (goto ARP86) 
REM Check for 32 and 64 bit versions of Office 2010 in regular uninstall key.(Office 64bit would also appear here on a 64bit OS) 

:ARP86 
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName% 
if %errorlevel%==1 (goto End) else (goto End) 
REM If x86 is detected simply run the x86 installer! 

REM Operating system is X64. Check for 32 bit Office in emulated Wow6432 uninstall key 
:ARP64 
reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall\%ProductName% 
if NOT %errorlevel%==1 (goto End) else (goto Office2010Detect64) 

:Office2010Detect64 
reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall\Office14.Standard 
if NOT %errorlevel%==1 (\\MyFileServer\Office2010\setup.exe /uninstall standard /config \\MyFileServer\Office2010\Standard.WW\silentuninstall.xml) else (goto Office2003Detect64) 

:Office2003Detect64 
REM Remove office 2003 & wait 30 seconds to allow uninstall to finish before starting the Office 2013 install
reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{90120409-6000-11D3-8CFE-0150048383C9} 
if NOT %errorlevel%==1 ( 
msiexec /x \\MyFileServer\Office2003\std11.msi /qn /forcerestart /l C:\Users\crumpta\Office2003Remove.log 
ping localhost -n30
) else (goto DeployOffice) 

REM If 1 returned, the product was not found. Run setup here. 
:DeployOffice 
start /wait %DeployServer%\setup.exe /config %ConfigFile% /adminfile %AdminFile% 
echo %date% %time% Setup ended with error code %errorlevel%. >> %LogLocation%\%computername%.txt 

REM If 0 or other was returned, the product was found or another error occurred. Do nothing. 
:End 

Endlocal