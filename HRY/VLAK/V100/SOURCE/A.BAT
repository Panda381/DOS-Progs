@echo off
:start
kontext vlak.asm #2 sceny.asm
tasm vlak.asm vlak.obj /z/zi
if errorlevel == 1 goto chyba
tlink vlak.obj, vlak.com, vlak.map /t/l/v/s/m
if errorlevel == 1 goto chyba
tdmap vlak.map vlak.com
goto konec
:chyba
pause
goto start
:konec
del vlak.map
del vlak.obj

copy /b vlak.com + titulek.scr + nic.scr + ruzne.scr + vagony.scr + veci.scr vlak2.com
del vlak.com
ren vlak2.com vlak.com
