@echo off
:start
kontext foxdek.asm
tasm foxdek,foxdek/z/zi/dV25A;
if errorlevel == 1 goto chyba
tlink20 foxdek,foxdek/l/v;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del foxdek.map
del foxdek.obj
