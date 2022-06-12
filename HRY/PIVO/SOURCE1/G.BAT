@echo off
:start
tasm _pivo.asm _pivo.obj /z
if errorlevel == 1 goto chyba
tlink _pivo.obj, _pivo.exe /x
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del _pivo.obj
