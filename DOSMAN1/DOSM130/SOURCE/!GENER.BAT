echo off

rem === ceska verze ===
make dmmake.mak /d
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
del dosman.exe
dosmdel.com
copy dosmanc.txt dosman.txt
konvhlp.com
del dosman.txt
del dosman.map
del *.obj
comtoexe dosman.com
del dosman.com
lzexe dosman.exe
del dosman.old
copy dosman.exe ..\dosman.exe
copy dosman.hlp ..\dosman.hlp
copy dosman.exe ..\cz\dosman.exe
copy dosman.hlp ..\cz\dosman.hlp
del dosman.exe
del dosman.hlp


rem === slovenska verze ===
make dmsmake.mak /d
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
del dosman.exe
dosmdel.com
copy dosmans.txt dosman.txt
konvhlp.com
del dosman.txt
del dosman.map
del *.obj
comtoexe dosman.com
del dosman.com
lzexe dosman.exe
del dosman.old
copy dosman.exe ..\sl\dosman.exe
copy dosman.hlp ..\sl\dosman.hlp
del dosman.exe
del dosman.hlp

:stop
