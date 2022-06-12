@echo off
:start
tasm foxkod,foxkod /dv25;
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
sload
ghhk0 foxkod.exe a < crlf.txt
gihk a:foxkod.exe
del load.exe
del foxkod25.exe
ren foxkod.exe foxkod25.exe
