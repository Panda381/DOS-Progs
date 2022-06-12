rem @echo off
:start
tasm10 foxkod,foxkod;
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
ghhk0 load.exe a < crlf.txt
gihk a:load.exe
ghhk0 load.exe a < crlf.txt
gihk a:load.exe
rem call zakod load.exe
sload
rem call zakod foxkod.exe
ghhk0 foxkod.exe a < crlf.txt
gihk a:foxkod.exe
del load.exe
del foxkod20.exe
ren foxkod.exe foxkod20.exe
