@echo off
:start
kontext vlak.asm #2 vlak.scn #1
tasm vlak.asm vlak.obj /z/zi
if errorlevel == 1 goto chyba
tlink vlak.obj, vlak.exe /l/v/x
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del vlak.obj
