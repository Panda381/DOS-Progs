echo off
make dmmake.mak /d
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
:stop
del dosman.exe
dosmdel.com
konvhlp.com
del dosman.map
del *.obj
comtoexe dosman.com
del dosman.com
lzexe dosman.exe
del dosman.old
copy dosman.exe ..\dosman.exe
del dosman.exe
copy dosman.hlp ..\dosman.hlp
del dosman.hlp
