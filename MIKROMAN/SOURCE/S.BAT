echo off
goto start1
:start
pause
:start1
c:
ask "Editace programu (A/N) ?"an
if errorlevel == 2 goto needit
kontext dos0use.asm #2 dos0dat.asm #1 
:needit
make dos0make /d
if errorlevel == 1 goto start
link dos0ini+dos0int+dos0lin+dos0win+dos0edi+dos0zob+dos0sel+dos0,dosman,dosm/m;
if errorlevel == 1 goto start
exe2bin dosman.exe dosman.com
del dosman.exe
tdmap dosm.map dosman.tds
rem del dosm.map
dos0del.com
del mikroman.com
ren dosman.com mikroman.com
