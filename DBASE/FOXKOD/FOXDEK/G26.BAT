@echo off
:start
tasm foxdek,foxdek /dV26;
if errorlevel == 1 goto chyba
tlink20 foxdek,foxdek;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del foxdek.map
del foxdek.obj
del foxdek26.exe
ren foxdek.exe foxdek26.exe
