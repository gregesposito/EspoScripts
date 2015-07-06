@echo off

echo Fixing up 10 ImageServer files...

DEL /F /Q /S 01\*.*
DEL /F /Q /S 02\*.*
DEL /F /Q /S 03\*.*
DEL /F /Q /S 04\*.*
DEL /F /Q /S 05\*.*
DEL /F /Q /S 06\*.*
DEL /F /Q /S 07\*.*
DEL /F /Q /S 08\*.*
DEL /F /Q /S 09\*.*
DEL /F /Q /S 10\*.*

copy *.xml 01
fart.exe --c-style *.xml ImageServer01 ImageServer02
copy *.xml 02
fart.exe --c-style *.xml ImageServer02 ImageServer03
copy *.xml 03
fart.exe --c-style *.xml ImageServer03 ImageServer04
copy *.xml 04
fart.exe --c-style *.xml ImageServer04 ImageServer05
copy *.xml 05
fart.exe --c-style *.xml ImageServer05 ImageServer06
copy *.xml 06
fart.exe --c-style *.xml ImageServer06 ImageServer07
copy *.xml 07
fart.exe --c-style *.xml ImageServer07 ImageServer08
copy *.xml 08
fart.exe --c-style *.xml ImageServer08 ImageServer09
copy *.xml 09
fart.exe --c-style *.xml ImageServer09 ImageServer10
copy *.xml 10

del *.xml

echo Done!
pause