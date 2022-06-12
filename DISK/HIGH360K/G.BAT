@echo off
:start
tasm high360k,high360k;
if errorlevel == 1 goto chyba
tlink high360k,high360k;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del high360k.map
del high360k.obj
