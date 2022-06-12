@echo off
:start
kontext foxkod.asm
tasm foxkod,foxkod/z/zi/dv25;
if errorlevel == 1 goto chyba
tlink20 foxkod,foxkod/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del foxkod.map
del foxkod.obj
