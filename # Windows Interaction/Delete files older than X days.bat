set deletepath=<enter path>
set days=<enter number of days>
set extension=<enter file extension>
FORFILES /P %deletepath% /M *.%extension% /D -%days% /C "cmd /c del @file"