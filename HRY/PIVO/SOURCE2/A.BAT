@echo off
:start
kontext _pivo.asm #2 _pivo.scn #1
tasm _pivo.asm _pivo.obj /z/zi
if errorlevel == 1 goto chyba
tlink _pivo.obj, _pivo.exe /l/v/x
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del _pivo.obj
