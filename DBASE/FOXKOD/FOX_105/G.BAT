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
ghhk0 load.exe a < c:\dos\utility\crlf.txt
gihk a:load.exe
call zakod load.exe
sload
call zakod foxkod.exe
del load.exe
