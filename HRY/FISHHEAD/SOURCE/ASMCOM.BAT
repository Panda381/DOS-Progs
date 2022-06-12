@echo off
:start
tasm %1.asm %1.obj
if errorlevel == 1 goto chyba
tlink %1.obj, %1.com /t
if errorlevel == 1 goto chyba
goto konec
:chyba
pause
goto start
:konec
del %1.map
del %1.obj
