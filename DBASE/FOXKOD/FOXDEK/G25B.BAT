@echo off
:start
tasm foxdek,foxdek /dV25B;
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
del foxdk25b.exe
ren foxdek.exe foxdk25b.exe
