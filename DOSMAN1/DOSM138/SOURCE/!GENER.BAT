echo off

rem === ceska verze ===
set demo=
set slov=
set upver=/dupver
set angl=
make dm.mak
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
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
copy dosman.hlp ..\dosman.hlp
copy dosman.exe ..\cz\dosman.exe
del dosman.hlp
del dosman.exe

rem === slovenska verze ===
set demo=
set slov=/dslov
set upver=/dupver
set angl=
make dm.mak
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
del dosman.exe
dosmdel.com
del dosman.map
del *.obj
comtoexe dosman.com
del dosman.com
lzexe dosman.exe
del dosman.old
copy dosman.exe ..\sl\dosman.exe
del dosman.exe

rem === anglicka verze ===
set demo=
set slov=
set upver=/dupver
set angl=/dangl
make dm.mak
if errorlevel == 1 goto stop
tlink dmini+dmint+dmlin+dmwin+dmedi+dmzob+dmmen+dmsel+dmhlp+dmfnd+dmtre+dmcom+dmuse1+dm,dosman
if errorlevel == 1 goto stop
exe2bin dosman.exe dosman.com
del dosman.exe
dosmdel.com
del dosman.map
del *.obj
comtoexe dosman.com
del dosman.com
lzexe dosman.exe
del dosman.old
copy dosman.exe ..\en\dosman.exe
del dosman.exe

:stop
