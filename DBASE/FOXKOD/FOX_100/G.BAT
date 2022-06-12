@echo off
:start
tasm foxkod,foxkod;
if errorlevel == 1 goto chyba
tlink foxkod,foxkod;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del foxkod.map
del foxkod.obj
gload
call zakod load.exe
sload
call zakod foxkod.exe
del load.exe
