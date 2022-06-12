@echo off
:start
tasm foxkod,foxkod/s;
if errorlevel == 1 goto chyba
tlink20 foxkod,foxkod;
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del foxkod.map
del foxkod.obj
gload
rem ghhk0 load.exe a < c:\dos\utility\crlf.txt
rem gihk a:load.exe
rem call zakod load.exe
sload
rem call zakod foxkod.exe
rem del load.exe
