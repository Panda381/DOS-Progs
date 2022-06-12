@echo off
:start
tasm vlak.asm vlak.obj /z
if errorlevel == 1 goto chyba
tlink vlak.obj, vlak.exe /x
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del vlak.obj

if not exist vlak\nul md vlak

copy vlak.bat vlak\vlak.bat
copy hlprun.com vlak\vlak$.com
copy vlak.txt vlak\vlak.txt
copy file_id.diz vlak\file_id.diz

copy vlak.exe vlak\vlak$.exe
cd vlak
lzexe vlak$.exe
del vlak$.old
cd..

if exist vlak\vlak$.pcx del vlak\vlak$.pcx
hlpgen vlak.pcx vlak\vlak$.pcx

if exist vlak\vlak$.scn del vlak\vlak$.scn
hlpgen vlak.scn vlak\vlak$.scn
