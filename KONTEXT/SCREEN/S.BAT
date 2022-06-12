@echo off
:start
kontext screen.asm 
tasm screen.asm /zi
if errorlevel == 1 goto chyba
tlink screen.obj, screen.ovl /t
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del screen.obj
del screen.map