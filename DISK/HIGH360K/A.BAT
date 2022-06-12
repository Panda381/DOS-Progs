@echo off
:start
c:\assemb\kontext high360k.asm
tasm high360k,high360k/z/zi;
if errorlevel == 1 goto chyba
tlink high360k,high360k/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del high360k.map
del high360k.obj
